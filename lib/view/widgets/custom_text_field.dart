import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatelessWidget {
  final String labelText;
  final Function(String) onChanged;
  final VoidCallback onTap;
  final TextEditingController controller;
  final InputDecoration customDecoration;
  final double padding;
  final IconData prefixIcon;
  final IconData suffixIcon;
  final String errorText;
  final bool isPassword;
  final String hintText;
  final TextInputType type;
  final VoidCallback suffixOnTap;
  final int maxLines;
  final bool readOnly;
  final Function(String) validator;

  final List<TextInputFormatter> formatter;
  const CustomFormField(
      {this.labelText,
      this.onChanged,
      this.controller,
      this.customDecoration,
      this.padding,
      this.onTap,
      this.prefixIcon,
      this.suffixIcon,
      this.errorText,
      this.isPassword,
      this.suffixOnTap,
      this.hintText,
      this.formatter,
      this.type,
      this.maxLines,
      this.readOnly,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding ?? 8.0),
      child: validator == null
          ? TextField(
              onChanged: onChanged,
              onTap: onTap,
              controller: controller,
              obscureText: isPassword ?? false,
              inputFormatters: formatter,
              maxLines: maxLines ?? 1,
              keyboardType: type,
              readOnly: readOnly ?? false,
              decoration: customDecoration ??
                  InputDecoration(
                      labelText: labelText,
                      errorText: errorText,
                      hintText: hintText,
                      border: OutlineInputBorder(),
                      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
                      suffixIcon: GestureDetector(onTap: suffixOnTap ?? null, child: Icon(suffixIcon))),
            )
          : TextFormField(
              onChanged: onChanged,
              onTap: onTap,
              validator: validator,
              controller: controller,
              obscureText: isPassword ?? false,
              inputFormatters: formatter,
              maxLines: maxLines ?? 1,
              keyboardType: type,
              readOnly: readOnly ?? false,
              decoration: customDecoration ??
                  InputDecoration(
                      labelText: labelText,
                      errorText: errorText,
                      hintText: hintText,
                      border: OutlineInputBorder(),
                      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
                      suffixIcon: GestureDetector(onTap: suffixOnTap ?? null, child: Icon(suffixIcon))),
            ),
    );
  }
}
