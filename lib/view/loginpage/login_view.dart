import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info/package_info.dart';

import '../../base/app_state.dart';
import '../geziciuygulama/get_all_cordinates.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../error/errormodel.dart';
import '../../model/usermodel.dart';
import '../../palette.dart';
import '../functions/global_functions.dart';
import '../home/home_view.dart';
import '../notification_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool showPassword = false;
  bool checkedValue;
  bool isLoading = false;
  String version = "";
  TextEditingController username = new TextEditingController(), password = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPreferences();
    AppState.instance.checkAppStatus(context);
    NoticationState.initNotification(context);
  }

  void loadPreferences() async {
    // KULLANICI ADI VE ŞİFREYİ YÜKLER
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username.text = prefs.getString("username") ?? "";
    password.text = prefs.getString("password") ?? "";
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      checkedValue = prefs.getString("password") != null ? true : false;
    });
  }

  void save() async {
    try {
      setState(() {
        isLoading = true;
      });
      FocusScope.of(context).requestFocus(new FocusNode());
      var token = await FirebaseMessaging.instance.getToken();
      log(token);
      UserModel model = await UserModel.fromAPI(username.text, password.text, token);
      if (checkedValue) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("username", username.text);
        prefs.setString("password", password.text);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool gezici = prefs.getBool("gezici") ?? false;

      setState(() {
        isLoading = false;
      });
      // EGER KULLANICI GEZİCİ UYGULAMA YAPARKEN UYGULAMAYI KAPATMIŞŞA
      // GEZİCİ UYGULAMA SAYFASINDAN BAŞLAR
      if (gezici) {
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (c) => GetAllCordinates(user: model)), (Route<dynamic> route) => false);
        return;
      } else {
        // ISTATISLIK SAYFASINA GÖNDERİR
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (c) => HomeView(user: model)), (Route<dynamic> route) => false);
      }
    } on BadRequestError catch (_) {
      setState(() {
        isLoading = false;
      });
      await showAlertDialog(context, "Kullanıcı adı veya şifre hatalı", Icons.error, Colors.red);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      await showAlertDialog(context, "Bir hata oluştu.$e ", Icons.error, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Stack(
        children: [
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.center,
              colors: [Colors.black87, Colors.transparent],
            ).createShader(rect),
            blendMode: BlendMode.darken,
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/bgCilac.jpeg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken))),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.22,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'CEVRE KORUMA VE KONTROL DAIRE BASKANLIGI',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.adventPro(
                        textStyle: TextStyle(
                          color: kYellow,
                          fontSize: size.width * 0.08,
                          fontWeight: FontWeight.w600,
                          shadows: const [
                            Shadow(
                              blurRadius: 6.0,
                              color: Colors.black87,
                              offset: Offset(4.0, 6.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.18,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: TextInputField(
                      controller: username,
                      hint: "Kullanici Adi",
                      icon: FontAwesomeIcons.user,
                      inputAction: TextInputAction.next,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: PasswordInput(
                      controller: password,
                      hint: "Sifre",
                      icon: FontAwesomeIcons.lock,
                      inputAction: TextInputAction.done,
                    ),
                  ),
                  Container(
                    height: size.height * 0.06,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: isLoading
                              ? const SizedBox(width: 40, height: 40, child: CircularProgressIndicator())
                              : RoundedButton(
                                  onPressed: save,
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Checkbox(
                              activeColor: Colors.white,
                              checkColor: kBrown,
                              value: checkedValue ?? false,
                              onChanged: (newValue) {
                                setState(() {
                                  checkedValue = newValue;
                                });
                              },
                            ),
                            Text(
                              'Beni Hatırla',
                              style: GoogleFonts.adventPro(
                                  textStyle: TextStyle(
                                      color: Colors.white54, fontWeight: FontWeight.w500, fontSize: size.width * 0.04)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "versiyon: $version",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class RoundedButton extends StatelessWidget {
  RoundedButton({Key key, this.buttonName, this.onPressed}) : super(key: key);

  final String buttonName;
  @required
  Function onPressed;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // ignore: deprecated_member_use
    return FlatButton(
      height: size.height * 0.17,
      color: kBgPink,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 0.8), borderRadius: BorderRadius.circular(16)),
      onPressed: onPressed,
      child: Text(
        'Giriş Yap',
        textAlign: TextAlign.center,
        style: GoogleFonts.adventPro(
          textStyle: kbodytext.copyWith(fontWeight: FontWeight.w500, fontSize: size.height * 0.028),
        ),
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    Key key,
    this.icon,
    this.hint,
    this.inputType,
    this.inputAction,
    this.controller,
  }) : super(key: key);

  final IconData icon;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
          height: size.height * 0.06,
          width: size.width * 0.7,
          decoration: BoxDecoration(
            color: Colors.grey[500].withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 0.8),
          ),
          child: TextField(
            controller: this.controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  icon,
                  size: size.height * 0.03,
                  color: kBlack,
                ),
                hintText: hint,
                hintStyle: GoogleFonts.adventPro(
                  textStyle: kbodytext.copyWith(color: kBlack, fontSize: size.height * 0.024),
                )),
            obscureText: true,
            style: kbodytext,
            keyboardType: inputType,
            textInputAction: inputAction,
          )),
    );
  }
}

class TextInputField extends StatelessWidget {
  const TextInputField({Key key, this.icon, this.hint, this.inputType, this.inputAction, this.controller})
      : super(key: key);

  final IconData icon;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
          height: size.height * 0.06,
          width: size.width * 0.7,
          decoration: BoxDecoration(
            color: Colors.grey[500].withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 0.8),
          ),
          child: TextField(
            controller: this.controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(
                  icon,
                  size: size.height * 0.03,
                  color: kBlack,
                ),
                hintText: hint,
                hintStyle: GoogleFonts.adventPro(
                  textStyle: kbodytext.copyWith(color: kBlack, fontSize: size.height * 0.024),
                )),
            style: kbodytext,
            keyboardType: inputType,
            textInputAction: inputAction,
          )),
    );
  }
}
