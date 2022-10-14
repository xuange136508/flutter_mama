import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ItemMark.dart';
import '../../../ReportProperties.dart';
import '../../page/common/base_view_model.dart';
import '../../widget/pop_up_menu_button.dart';
import '../common/app.dart';
import '../common/package_help_mixin.dart';

class AndroidLogViewModel extends BaseViewModel with PackageHelpMixin {
  static const String colorLogKey = 'colorLog';
  static const String filterPackageKey = 'filterPackage';
  static const String caseSensitiveKey = 'caseSensitive';

  String deviceId;

  bool isAutoScroll = true;
  bool isFilterPackage = true;
  String filterContent = "ExposuerUtil";

  List<String> logList = [];

  // 上报日志滚动控制器
  ScrollController logScrollController = ScrollController();
  FlutterListViewController scrollController = FlutterListViewController();
  TextEditingController findController = TextEditingController();

  bool isCaseSensitive = false;
  bool isShowLast = true;
  String pid = "";
  int findIndex = -1;
  Process? _process;


  // 事件类型
  List<FilterLevel> filterEventType = [
    FilterLevel("全部", ""),
    FilterLevel("曝光", "impression"),
    FilterLevel("点击", "click"),
    FilterLevel("分享", "share"),
    FilterLevel("收藏", "collect"),
    FilterLevel("取消收藏", "uncollect"),
    FilterLevel("关注", "attention"),
    FilterLevel("取消关注", "unattention"),
    FilterLevel("关闭", "close"),
    FilterLevel("拖拉", "drag"),
    FilterLevel("长按", "longPress"),
    FilterLevel("点赞", "applaud"),
    FilterLevel("取消点赞", "unapplaud")
  ];
  PopUpMenuButtonViewModel<FilterLevel> eventTypeViewModel = PopUpMenuButtonViewModel();


  AndroidLogViewModel(
    BuildContext context,
    this.deviceId,
  ) : super(context) {
    App().eventBus.on<DeviceIdEvent>().listen((event) async {
      logList.clear();
      deviceId = event.deviceId;
      kill();
      if (deviceId.isEmpty) {
        resetPackage();
        return;
      }
      await getInstalledApp(deviceId);
      listenerLog();
    });
    App().eventBus.on<AdbPathEvent>().listen((event) {
      logList.clear();
      adbPath = event.path;
      kill();
      listenerLog();
    });

    findController.addListener(() {
      findIndex = -1;
      notifyListeners();
    });

    // 事件类型筛选设置
    eventTypeViewModel.list = filterEventType;
    eventTypeViewModel.selectValue = filterEventType.first;
    eventTypeViewModel.addListener(() {
      listenerEventType();
    });
  }



  /// 初始化
  /// */
  void init() async {
    adbPath = await App().getAdbPath();
    await getInstalledApp(deviceId);
    pid = await getPid();
    // 先注释，避免多次监听造成日志错乱
    //execAdb(["-s", deviceId, "logcat", "-c"]);
    //listenerLog();
  }



  void selectPackageName(BuildContext context) async {
    var package = await showPackageSelect(context, deviceId);
    if (packageName == package || package.isEmpty) {
      return;
    }
    packageName = package;
    if (isFilterPackage) {
      logList.clear();
      pid = await getPid();
      kill();
      listenerLog();
      notifyListeners();
    }
  }


  /// 添加抓取adb日志监听方法
  /// */
  void listenerLog() {
    String level = "*:E";
    // 设置日志等级
    var list = ["-s", deviceId, "logcat", "$level"];
    if (isFilterPackage && pid.isNotEmpty) {
      // 过滤应用包名
      list.add("--pid=$pid");
    }
    // 执行adb命令抓取日志
    execAdb(list, onProcess: (process) {
      _process = process;
      process.stdout.transform(const Utf8Decoder()).listen((line) {
        // 过滤包含的关键字
        if (filterContent.isNotEmpty
            ? line.toLowerCase().contains(filterContent.toLowerCase())
            : true) {
          if (logList.length > 500) {
            logList.removeAt(0);
          }
          logList.add(line);

          // 上报日志解析处理
          handleReportList(line);
        }
      });
    });
  }

  void filter(String value) {
    filterContent = value;
    if (value.isNotEmpty) {
      logList.removeWhere((element) => !element.contains(value));
    }
    notifyListeners();
  }

  Color getLogColor(String log) {
    var split = log.split(" ");
    split.removeWhere((element) => element.isEmpty);
    String type = "";
    if (split.length > 4) {
      type = split[4];
    }
    switch (type) {
      case "V":
        break;
      case "D":
        return const Color(0xFF017F14);
      case "I":
        return const Color(0xFF0585C1);
      case "W":
        return const Color(0xFFBBBB23);
      case "E":
        return const Color(0xFFFF0006);
      case "F":
      default:
        break;
    }
    return const Color(0xFF383838);
  }

  /// 根据包名获取进程应用进程id
  Future<String> getPid() async {
    var result = await execAdb([
      "-s",
      deviceId,
      "shell",
      "ps | grep ${packageName} | awk '{print \$2}'"
    ]);
    if (result == null) {
      return "";
    }
    return result.stdout.toString().trim();
  }

  void kill() {
    _process?.kill();
    shell.kill();
  }

  Future<void> setFilterPackage(bool value) async {
    isFilterPackage = value;
    SharedPreferences.getInstance().then((preferences) {
      preferences.setBool(filterPackageKey, value);
    });
    if (value) {
      pid = await getPid();
      logList.removeWhere((element) => !element.contains(pid));
    }
    kill();
    listenerLog();
    notifyListeners();
  }



  /// 筛选事件类型
  /// */
  void listenerEventType() {
    List<ReportProperties> resultList;
    String eventType = eventTypeViewModel.selectValue?.value ?? "";
    // 过滤当前日志类型，通知页面刷新
    if(eventType.isEmpty){
      resultList = totalLogList;
    }else{
      resultList = totalLogList
          .where((element) =>(element.event == eventType))
          .toList();
    }
    tableRows.clear();
    for (var result in resultList) {
      String? event = result?.event;
      //处理多日志合并的情况
      for(Properties properties in result?.properties?? []){
        String? position = properties.position;
        String? itemType = properties.itemType;
        String? itemId = properties.itemid;
        String? itemMark = properties.itemMark;
        //包含itemMark需二次解析
        ItemMark? itemMarkBean = parseItemMark(itemMark);
        String? itemName = itemMarkBean?.itemName;
        String? itemMark1 = itemMarkBean?.itemMark1;
        String? itemMark2 = itemMarkBean?.itemMark2;
        tableRows.add(TableRow(
            children: [
              getCommonText((tableRows.length + 1).toString(), isLimit: true),
              getCommonText(position),
              getCommonText(itemType),
              getCommonText(event),
              getCommonText(itemId),
              getCommonText(itemName),
              getCommonText(itemMark1),
              getCommonText(itemMark2),
            ]
        ));
      }
    }
    notifyListeners();
  }


  void copyLog(String log) {
    Clipboard.setData(ClipboardData(text: log));
  }

  void clearLog() {
    logList.clear();
    findIndex = -1;
    notifyListeners();
  }

  //日志数据集合
  List<ReportProperties> totalLogList = [];

  //表格数据集合
  List<TableRow> tableRows = [];

  //过滤重复日志
  String previousLog = "";

  /// 上报日志解析处理
  /// */
  handleReportList(String curLog) async {
    if (curLog?.isEmpty == true) {
      return;
    }
    Future(() => parseDevLog(curLog)).then((reportProperties) =>
        handleProperties(reportProperties)
    );
  }



  void handleProperties(ReportProperties? reportProperties){
    if (reportProperties != null) {
      //添加数据集合
      totalLogList.add(reportProperties);

      //处理多条属性的情况
      String? event = reportProperties?.event;
      for(Properties properties in reportProperties?.properties?? []){
        String? position = properties?.position;
        String? itemType = properties.itemType;
        String? itemId = properties.itemid;
        String? itemMark = properties.itemMark;
        //包含itemMark需二次解析
        ItemMark? itemMarkBean = parseItemMark(itemMark);
        String? itemName = itemMarkBean?.itemName;
        String? itemMark1 = itemMarkBean?.itemMark1;
        String? itemMark2 = itemMarkBean?.itemMark2;

        //过滤数据集合
        String eventType = eventTypeViewModel.selectValue?.value ?? "";
        if(eventType == "" || eventType == event){
          tableRows.add(TableRow(
              children: [
                getCommonText((tableRows.length + 1).toString(), isLimit: true),
                getCommonText(position),
                getCommonText(itemType),
                getCommonText(event),
                getCommonText(itemId),
                getCommonText(itemName),
                getCommonText(itemMark1),
                getCommonText(itemMark2),
                //getCommonText('$itemMark'),
              ]
          ));
          // 上报日志滚动到底部
          if(isAutoScroll){
            logScrollController.jumpTo(
              logScrollController.position.maxScrollExtent,
            );
          }
          notifyListeners();
        }

      }
    }
  }


  /// 日志解析
  /// */
  Future<ReportProperties?> parseDevLog(String? contents) async {
    if(contents?.isEmpty == true || contents == null){
      return null;
    }
    try{
      // 正则匹配
      RegExp reg = RegExp(r'(?<=ExposuerUtil:)(.*)');
      if (reg.hasMatch(contents)) {
        var matches = reg.allMatches(contents);
        for (int i = 0; i < matches.length; i++) {
          // 解析上报数据
          String? jsonData = matches.elementAt(i).group(0);
          ReportProperties reportProperties = ReportProperties.fromJson(jsonDecode(jsonData!));
          return reportProperties;
        }
      } else {
        //printLog("匹配失败");
      }
      return null;
    }
    on Exception{
      //printLog('解析异常');
      return null;
    }
  }

  /// ItemMark解析
  /// */
  ItemMark? parseItemMark(String? itemMark) {
    if(itemMark?.isEmpty == true || itemMark == null){
      return null;
    }
    try {
      ItemMark itemMarkBean = ItemMark.fromJson(
          jsonDecode(itemMark!));
      return itemMarkBean;
    } on Exception {
      printLog('解析异常');
      return null;
    }
  }

  /// 日志输出
  /// */
  void printLog(Object? object) {
    if (kDebugMode) {
      // print(object);
    }
  }


  /// 设置输出文案格式
  /// */
  Container getCommonText(String? content,{bool isLimit = false}) {
    return Container(
        //margin: EdgeInsets.only(left: 50, right: 50),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: SizedBox(
            width: isLimit? 30: 160,
            child: Text(validateInput(content),
                //overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  //backgroundColor: Colors.red
                ))
        )
      );
  }

  /// 过滤判空
  /// */
  String validateInput(String? input) {
    if (input?.isNotEmpty ?? false) {
      return input!!;
    } else {
      return "";
    }
  }

  /// 设置滚动底部
  /// */
  Future<void> setScrollBottom(bool value) async {
    isAutoScroll = value;
    notifyListeners();
  }


}

class FilterLevel extends PopUpMenuItem {
  String name;
  String value;

  FilterLevel(this.name, this.value) : super(name);
}
