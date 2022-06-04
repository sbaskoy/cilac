
import '../error/errormodel.dart';
import 'package:flutter/material.dart';

class Helper{
   static String getErrorMessage(e) {
    if (e is BadRequestError) {
      return "Hata! kod: 400 Mesaj: ${e.msg}";
    } else if (e is AuthorizeError) {
      return "Hata! kod: 401 Mesaj: Oturumunuz sonlanmış.Yeniden giriş yapınız";
    } else if (e is InternalServerError) {
      return 'Hata! ${e.msg}';
    } else {
      return "$e";
    }
  }
    Widget errorMessage(state) {
    return StreamBuilder<String>(
      stream: state.errorMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 5),
              child: Text(snapshot.data,
                  textAlign: TextAlign.left, style:const TextStyle(color: Colors.red)));
        }
        return const Text('');
      },
    );
  }

  static Widget customError(text) {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 5),
        child: Text(text, textAlign: TextAlign.center, style:const TextStyle(color: Colors.red)));
  }
    static Widget emptyMessage(text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child:  Text(text, textAlign: TextAlign.left, style: const TextStyle(color: Colors.blue))
      ),
    );
  }
}