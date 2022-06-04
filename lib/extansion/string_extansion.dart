import 'package:google_maps_flutter/google_maps_flutter.dart';

extension StringExtension on String {
  LatLng get pointToLatLng {
    List<String> point = this.replaceAll(new RegExp(r"POINT[ ]?\("), '').replaceAll(")", '').split(' ');
    return new LatLng(double.parse(point[0]), double.parse(point[1]));
  }

  String get dateToStr => this.replaceAll("T", " ").substring(0, this.length - 3);
  String get dartDateToStr => this.substring(0, 16);
  bool get nullOrEmpty {
    if (this == null) return false;
    if (this == '') return false;
    return true;
  }
}
