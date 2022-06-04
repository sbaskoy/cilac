import 'dart:io';

import 'package:flutter/material.dart';

class SelectedImageModel {
  String imagePath;
  SelectedImageModel({this.imagePath});
  Widget getWidget(Function onPressed) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(5)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: this.imagePath == null
                  ? const Icon(Icons.add_a_photo)
                  : Image.file(
                      File(this.imagePath),
                      fit: BoxFit.fill,
                    ),
            ),
            if (this.imagePath != null)
              Positioned(
                top: 0,
                right: 5,
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration:
                     const BoxDecoration(shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,color: Colors.white,
                    ),
                    onPressed: onPressed,
                  ),
                ),
              ),
          ],
        ));
  }
}