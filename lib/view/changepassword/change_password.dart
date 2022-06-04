import '../../base/network_manager.dart';
import '../../error/errormodel.dart';
import '../../mixins/helper.dart';
import '../../model/usermodel.dart';
import 'package:flutter/material.dart';
import '../../extansion/widget_extansion.dart';

class ChangePasswordView extends StatefulWidget {
  final UserModel user;

  const ChangePasswordView({Key key, @required this.user}) : super(key: key);
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordView> {
  final formKey = GlobalKey<FormState>();
  TextEditingController password = new TextEditingController();
  TextEditingController passwordAgain = new TextEditingController();
  String msgText = "";
  Color msgColor = Colors.green;
  bool isSaving = false;
  Future<void> save() async {
    if (formKey.currentState.validate()) {
      try {
        changeLoading(true);
        var res = await NetworkManager.instance.httpPostRes(
            token: widget.user.token,
            path: "api/act/sifredeg",
            data: <String, String>{"pUserID": widget.user.id.toString(), "Data": password.text});
        changeLoading(false);
        if (res.statusCode == 200) {
          setState(() {
            msgText = "Şifreniz başarılı bir şekilde değiştirdi";
            isSaving = false;
            msgColor = Colors.green;
          });
        } else if (res.statusCode == 400) {
          throw BadRequestError(msg: res.body);
        } else if (res.statusCode == 401) {
          throw AuthorizeError.to();
        } else {
          throw InternalServerError(msg: res.body);
        }
      } catch (e) {
        setState(() {
          msgText = Helper.getErrorMessage(e);
          isSaving = false;
          msgColor = Colors.red;
        });
      }
    }
  }

  void changeLoading(bool val) {
    setState(() {
      isSaving = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifremi değiştir"),
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                obscureText: true,
                controller: password,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: "Yeni Şifreniz",
                    labelText: "Yeni Şifreniz"),
              ).paddingAll(),
              TextFormField(
                obscureText: true,
                validator: (val) {
                  if (password.text != val) {
                    return "Şifreler aynı olmalıdır";
                  }
                  return null;
                },
                controller: passwordAgain,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: "Şifre Tekrar",
                    labelText: "Şifre Tekrar"),
              ).paddingAll(),
              Container(
                      height: 50,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(15)),
                      child: isSaving
                          ? const CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            )
                          : TextButton(
                              onPressed: save,
                              child: const Text(
                                "Değiştir",
                                style: TextStyle(color: Colors.white, fontSize: 17),
                              ),
                            ))
                  .paddingAll(),
              if (msgText.isNotEmpty)
                Text(
                  msgText,
                  style: TextStyle(color: msgColor, fontSize: 17),
                ).paddingAll()
            ],
          ),
        ),
      ),
    );
  }
}
