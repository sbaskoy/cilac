import 'package:flutter/material.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  ThemeData get themeData => Theme.of(context);
  double getHeight(val) => MediaQuery.of(context).size.height * val;
  double getWidht(val) => MediaQuery.of(context).size.width * val;
  TextTheme get textTheme => themeData.textTheme;
  ColorScheme get colorSheme => themeData.colorScheme;
  Size get getSize => MediaQuery.of(context).size;
 
}
