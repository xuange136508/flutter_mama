import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:process_run/shell_run.dart';
import 'package:provider/provider.dart';

import '../../widgets/text_view.dart';
import '../page/common/app.dart';

class AdbSettingDialog extends StatefulWidget {
  final String adbPath;

  const AdbSettingDialog(this.adbPath, {Key? key}) : super(key: key);

  @override
  State<AdbSettingDialog> createState() => _AdbSettingDialogState();
}

class _AdbSettingDialogState extends State<AdbSettingDialog> {
  final AdbSettingController controller = AdbSettingController();

  @override
  void initState() {
    super.initState();
    controller.textController.text = widget.adbPath;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const TextView(
                      "Adb设置：",
                      color: Colors.black,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        height: 32,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 5),
                            Expanded(
                              child: TextField(
                                controller: controller.textController,
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  hintText: "请输入Adb路径",
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final typeGroup =
                                    XTypeGroup(label: 'adb', extensions: []);
                                final file = await openFile(
                                    acceptedTypeGroups: [typeGroup]);
                                controller.textController.text =
                                    file?.path ?? "";
                              },
                              child: const Icon(
                                Icons.folder_open,
                                color: Colors.black38,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                          controller.testAdb();
                        },
                        child: const TextView("测试",fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                          controller.save(context);
                        },
                        child: const TextView("保存",fontSize: 13),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.4)
                  ],
                ),
                // adb提示内容
                // Consumer<AdbSettingController>(
                //     builder: (context, value, child) {
                //   return Container(
                //     padding: const EdgeInsets.symmetric(vertical: 5),
                //     child: TextView(value.resultText, color: value.resultColor),
                //   );
                // }),
              ],
            ),
          );
        });
  }
}


class AdbSettingController extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();

  String resultText = "";
  Color resultColor = Colors.black38;

  Future<bool> testAdb() async {
    if (textController.text.isEmpty) {
      resultText = "请先选择或输入ADB路径";
      showToast(resultText);
      // resultColor = Colors.red;
      // notifyListeners();
      return false;
    }
    try {
      var result = await Shell()
          .runExecutableArguments(textController.text, ["version"]);
      if (result.exitCode != 0 || result.outLines.isEmpty) {
        resultText = "请确认ADB路径是否正确";
        showToast(resultText);
        // resultColor = Colors.red;
        // notifyListeners();
        return false;
      }
      resultText = result.outText;
      showToast("执行成功：$resultText");
      // resultColor = Colors.green;
      // notifyListeners();
      return true;
    } catch (e) {
      resultText = "请确认ADB路径是否正确";
      showToast(resultText);
      // resultColor = Colors.red;
      // notifyListeners();
      return false;
    }
  }

  Future<void> save(BuildContext context) async {
    if (await testAdb()) {
      await App().setAdbPath(textController.text);
    }
  }
}
