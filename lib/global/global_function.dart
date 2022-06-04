import 'dart:convert';

import '../view/widgets/open_camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

extension StringExtansion on String {
  toList(dynamic obj) {
    List list = [];
    jsonDecode(this).forEach((e) {
      list.add(obj.getObj(e));
    });
    return list;
  }
}

String validator(String value) => value.isEmpty ? "Bu alan zorunludur" : null;

Future<String> imgFromCamera(BuildContext context) async {
  //final File image = await ImagePicker.pickImage(source: ImageSource.camera, imageQuality: 50);
  String path = await Navigator.push(context, new MaterialPageRoute(builder: (c) => const GetPhoto()));
  if (path == null) {
    return null;
  }
  if (path.isEmpty) return null;
  return path;
}

Future<String> imgFromGallery(context, int maxSelected) async {
  final XFile image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);

  return image.path;
}
