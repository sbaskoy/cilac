import 'package:flutter/cupertino.dart';

extension WidgetExtension on Widget {
  Padding paddingAll({double pa}) => Padding(
        padding: EdgeInsets.all(pa ?? 8),
        child: this,
      );
  Padding paddingOnly({double left, double right, double top, double bottom}) => Padding(
        padding: EdgeInsets.only(
          top: top ?? 0.0,
          bottom: bottom ?? 0.0,
          left: left ?? 0.0,
          right: right ?? 0.0,
        ),
        child: this,
      );
}
