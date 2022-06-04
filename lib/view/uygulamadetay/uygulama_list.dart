import 'dart:developer';

import 'package:flutter/material.dart';

import '../../model/grupmodel.dart';
import '../../model/usermodel.dart';
import 'uygulama_detay_view.dart';

class UygulamaDetayView extends StatelessWidget {
  final UserModel user;
  final GrupModel model;
  final String start;
  final String finish;
  final String sorgu;
  const UygulamaDetayView({Key key, this.user, this.model, this.start, this.finish, this.sorgu}) : super(key: key);
  @override
  Widget build(BuildContext context) {
  
    var s = (sorgu?.isNotEmpty ?? false)
        ? sorgu
        : ((start == null || finish == null)
            ? " and ilce='${model.grpAdi}' and EkipTanimi='${model.grpAdi2}' and UygulamaTanimi='${model.grpAdi3}'"
            : " and ilce='${model.grpAdi}' and EkipTanimi='${model.grpAdi2}' and UygulamaTanimi='${model.grpAdi3}' and baslangicTarihi>'$start' and baslangicTarihi<'$finish'");
    log(s);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uygulamalar"),
      ),
      body: Center(
        child: UygulamaDetayWidget(user: user, sorgu: s),
      ),
    );
  }
}
