import 'package:flutter/services.dart';

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String oldText = oldValue.text;
    String newText = newValue.text;

    int oldLen = oldText.length;
    int newLen = newText.length;

    if (oldLen == 0) {
      if (newText == "0") {
        newText = "";
      } else {
        if (!oldText.startsWith("(")) {
          newText = "(" + newText;
        }
      }
    }
    if (oldLen == 3 && newLen == 4) {
      newText += ") ";
    }
    if (oldLen == 4 && newLen == 5) {
      newText = oldText + ") " + newText.substring(newLen - 1, newLen);
    }
    if (oldLen == 5 && newLen == 6) {
      newText = oldText + " " + newText.substring(newLen - 1, newLen);
    }
    if (oldLen == 8 && newLen == 9) {
      newText += " ";
    }
    if (oldLen == 9 && newLen == 10) {
      newText = oldText + " " + newText.substring(newLen - 1, newLen);
    }
    int index = newText.length;
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: index),
    );
  }
}
