import 'dart:convert';
import 'dart:io';

import 'package:cilac/base/network_manager.dart';
import 'package:cilac/model/kaynak_kayit_model.dart';
import 'package:cilac/model/uygulamakayit.dart';
import 'package:cilac/view/functions/global_functions.dart';
import 'package:cilac/view/kaynakkayit/kaynak_kayit_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class KaynakKayitState {
  final loading = new BehaviorSubject<bool>.seeded(false);
  final message = new BehaviorSubject<String>.seeded("");
  final cord = new BehaviorSubject<LatLng>();
  final uremeDurum = new BehaviorSubject<bool>.seeded(false);

  int getID(String text) => int.parse(text.split("-").first);
  Future<void> save(KaynakKayitViewState view, Function setState) async {
    try {
      List<String> resim = [];
      if (view.widget.model == null) {
        if (view.selectedImage == null) {
          setState(() {
            view.resColor = Colors.red;
            view.imageText = "En az bir resim şeçiniz";
          });
          return;
        }
      }

      this.loading.sink.add(true);

      for (var i in view.selectedImage?.where((element) => element.imagePath != null)?.toList() ?? []) {
        resim.add(base64Encode(File(i.imagePath).readAsBytesSync()));
      }

      var savedModel = new KaynakKayitModel(
          id: view.widget.model == null ? -1 : view.widget.model.id,
          pZararliID: getID(view.zararliTurController.text),
          kaynakAdi: view.kaynakTurController.text.split("-").last,
          pKaynakTurID: getID(view.kaynakTurController.text),
          uremeDurumu: this.uremeDurum.value,
          aciklama: view.aciklamaController.text + " - " + view.uygulamaController.text,
          pEkipID: getID(view.sorumluEkipController.text),
          adres: view.adresController.text,
          il: "ORDU",
          ilce: view.ilceController.text,
          geoKonum: "POINT(${cord.value.latitude} ${cord.value.longitude})",
          tarih: DateTime.now().toIso8601String(),
          ekAciklama: view.ekAciklamaController.text,
          metreKare: int.parse(view.metreKareController.text),
          mahalle: view.mahalleController.text,
          resimler: resim);

      // savedModel.resimler = [];
      // print(jsonEncode(savedModel.toJson()));
      ReturnModel model = await NetworkManager.instance.httpPost(
          path: "api/act/Kaynak", data: savedModel.toJson(), token: view.widget.user.token, model: ReturnModel());

      if (model == null) {
        await showAlertDialog(view.context, "Bilinmeyen bir hata oluştu.", Icons.error, Colors.amber);
      } else if (model.durumKodu == 0) {
        await showAlertDialog(view.context, "Kaynak başarılı bir şekilde kayıt edildi", Icons.done, Colors.green,
            text: "Kapat ve Yeni", onPressed: () {
          view.adresController.text = "";

          this.cord.sink.add(null);
          Navigator.pop(view.context);
          if (view.widget.model != null) {
            Navigator.pop(view.context);
          }
        });
      } else if (model.durumKodu > 100) {
        await showAlertDialog(view.context, "Bir hata oluştu.Mesaj ${model.durumMesaj}", Icons.error, Colors.red);
      } else if (model.iD > 0 && model.durumKodu == 1) {
        await showAlertDialog(view.context, "Bilgiler kayıt edildi ama resimler edilemedi", Icons.done, Colors.amber);
      } else {
        await showAlertDialog(
            view.context, "Uygulamayı locale kaydedip daha sonra tekrar tekrar deneyiniz", Icons.error, Colors.amber);
      }
      this.loading.sink.add(false);
    } catch (ex) {
      this.loading.sink.add(false);
      this.message.sink.addError(ex.toString());
    }
  }

  dispose() {
    cord.close();
    message.close();
    loading.close();
    uremeDurum.close();
  }
}
