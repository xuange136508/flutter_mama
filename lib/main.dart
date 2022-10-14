import 'package:flutter/material.dart';
import 'log/page/main/main_page.dart';
import 'package:oktoast/oktoast.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MaterialApp(
          title: 'Flutter',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
      home: getFunctionWidget(),
    ));
  }

  Widget? getFunctionWidget() {
      return const MainPage();
    return null;
  }
}

