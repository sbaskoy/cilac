import 'package:flutter/material.dart';

Future<void> showAlertDialog(context, String bodyText, IconData icon, Color color, {Function onPressed,String text}) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  child: Icon(
                    icon,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
               const SizedBox(
                  height: 15,
                ),
                Text(
                  bodyText,
                  style: TextStyle(color: color, fontSize: 16),
                ),
               const SizedBox(
                  height: 5,
                ),
                TextButton(
                  child: Text(
                   text?? "Kapat",
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: onPressed ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      });
}

Widget buildRowButton({@required Size size, String text, Function onPressed}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: size.height * 0.06,
          width: size.width * 0.45,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: TextButton(
            onPressed: onPressed ?? () => print("Button"),
            child: Text(
              text ?? "Kaydet",
            ),
          ),
        ),
      ],
    ),
  );
}
