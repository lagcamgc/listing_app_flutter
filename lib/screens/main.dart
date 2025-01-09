import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'menu_frame.dart';

import '../colors.dart';
void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

Color mainColor = AppColors.primaryColor;
Color startingColor = AppColors.primaryColor;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Auto Directory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: mainColor,
        ),
        home: MenuFrame(),
    );
  }
}
