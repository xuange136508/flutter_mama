import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../../ItemMark.dart';
import '../../../ReportProperties.dart';
import '../../../widgets/text_view.dart';
import '../../widget/adb_setting_dialog.dart';
import '../../widget/pop_up_menu_button.dart';
import '../common/base_page.dart';
import 'android_log_view_model.dart';


class AndroidLogPage extends StatefulWidget {
  final String deviceId;
  final String adbPathParams;

  const AndroidLogPage(this.adbPathParams,this.deviceId, {Key? key}) : super(key: key);

  @override
  State<AndroidLogPage> createState() => _AndroidLogPageState();
}

class _AndroidLogPageState
    extends BasePage<AndroidLogPage, AndroidLogViewModel> {
  @override
  void initState() {
    super.initState();
    viewModel.init();
    viewModel.adbPath = widget.adbPathParams;
  }

  @override
  Widget contentView(BuildContext context) {
    return Column(
      children: [
        //adb设置
        AdbSettingDialog(viewModel.adbPath),
        const SizedBox(height: 5),

        Row(
          children: [
            const SizedBox(width: 20),
            const TextView("事件类型："),
            //事件类型过滤
            filterEventType(),
            const SizedBox(width: 12),
            SizedBox(
              height: 30,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: const BorderSide(width: 1, color: Colors.grey),
                ),
                onPressed: () {
                  viewModel.tableRows.clear();
                  viewModel.totalLogList.clear();
                  viewModel.clearLog();
                },
                child: const TextView("清空日志",fontSize: 13),
              ),
            ),
            const SizedBox(width: 16),

            const SizedBox(width: 12),
            Selector<AndroidLogViewModel, bool>(
              selector: (context, viewModel) => viewModel.isAutoScroll,
              builder: (context, isAutoScroll, child) {
                return Checkbox(
                  value: isAutoScroll,
                  onChanged: (value) {
                    viewModel.setScrollBottom(value ?? false);
                  },
                );
              },
            ),
            const TextView("自动滚动"),

          ],
        ),
        const SizedBox(height: 10),

        //表头
        _buildTableHead(),
        //上报点位筛选框
        _buildReportView(),

        //日志内容显示框
        //_buildLogContentView(),
        const SizedBox(height: 10),
      ],
    );
  }


  /// 选择点位事件类型
  /// */
  Container filterEventType() {
    return Container(
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: PopUpMenuButton(
          viewModel: viewModel.eventTypeViewModel,
          menuTip: "选择事件类型",
        ),
      );
  }



  /// 上报日志分析的表格
  /// */
  Expanded _buildReportView() {
    return Expanded(
      child: Container(
          width: MediaQuery.of(context).size.width,
          color: const Color(0x66F0F0F0),
          child: Consumer<AndroidLogViewModel>(
            builder: (context, viewModel, child) {

              if(viewModel.totalLogList.length == 1000){
                showToast("上报日志过多，建议清理!");
              }
              return SingleChildScrollView(
                  controller: viewModel.logScrollController,
                  scrollDirection: Axis.vertical,
                  child:  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children:  viewModel.tableRows,
                    border: const TableBorder(
                      horizontalInside: BorderSide(color: Color(0xFFC0C0C0), width: 0.3),
                    ),
                  )
              );

            },
          )),
    );
  }



  /// 表头
  /// */
  Container _buildTableHead() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        color: const Color(0x66F0F0F0),
        //color: const Color(0xFF000000),
        child: Consumer<AndroidLogViewModel>(
          builder: (context, viewModel, child) {
            return Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: const TableBorder(
                  bottom: BorderSide(color: Color(0xFFC0C0C0), width: 0.3),
                ),
                children:[
                  TableRow(
                      children: [
                        getCommonText('序号', isLimit: true),
                        getCommonText('点位名(position)'),
                        getCommonText('点位类型(item_type)'),
                        getCommonText('事件类型(event)'),
                        getCommonText('点位内容ID(item_id)'),
                        getCommonText('点位内容名称(item_name)'),
                        getCommonText('扩展内容1(item_mark_1)'),
                        getCommonText('扩展内容2(item_mark_2)'),
                      ]
                  ),
                ]);
          },
        ));
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
                    ))
    ));
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


  /// 日志解析
  /// */
  ReportProperties? parseDevLog(String? contents) {
    if(contents?.isEmpty == true || contents == null){
      return null;
    }
    try{
      printLog("内容：$contents");
      // 正则匹配
      RegExp reg = RegExp(r'(?<=ExposuerUtil:)(.*)');
      if (reg.hasMatch(contents)) {
        var matches = reg.allMatches(contents);
        //printLog("${matches.length}");
        for (int i = 0; i < matches.length; i++) {
          printLog("${matches.elementAt(i).group(0)}");
          // 解析上报数据
          String? jsonData = matches.elementAt(i).group(0);
          ReportProperties reportProperties = ReportProperties.fromJson(jsonDecode(jsonData!));
          return reportProperties;
        }
      } else {
        printLog("匹配失败");
      }
      return null;
    }
    on Exception{
      printLog('解析异常');
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

  @override
  createViewModel() {
    return AndroidLogViewModel(
      context,
      widget.deviceId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.kill();
    viewModel.scrollController.dispose();
    viewModel.logScrollController.dispose();
  }




}


