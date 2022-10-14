import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../widgets/text_view.dart';
import '../../widget/adb_setting_dialog.dart';
import '../android_log/android_log_page.dart';
import '../common/base_page.dart';
import 'devices_model.dart';
import 'main_view_model.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends BasePage<MainPage, MainViewModel> {
  @override
  initState() {
    super.initState();
    viewModel.init();
  }

  @override
  Widget contentView(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
            color: Colors.white,
            width: 200,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset("images/mama.jpg", width: 300, height: 50),
                devicesView(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        // const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              // packageNameView(context, select),
              Expanded(
                child: buildContent(1),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget buildContent(int value) {
    if (value == 1) {
      return AndroidLogPage(viewModel.adbPath, viewModel.deviceId);
    } else {
      return Container();
    }
  }


  Widget devicesView() {
    return InkWell(
      onTap: () {
        viewModel.devicesSelect(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 10),
          Selector<MainViewModel, DevicesModel?>(
            selector: (context, viewModel) => viewModel.device,
            builder: (context, device, child) {
              return Container(
                constraints: const BoxConstraints(
                  maxWidth: 150,
                ),
                child: Text(
                  device?.itemTitle ?? "未连接设备",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            width: 5,
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF666666),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  @override
  createViewModel() {
    return MainViewModel(context);
  }
}
