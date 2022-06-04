import 'dart:convert';

import '../localdb/uygulama_alanlari_db.dart';
import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';
import '../global/global_function.dart';
class UygulamaAlanlari {
  int id;
  String uygulamaAlanAdi;
  int kayitSayisi;

  UygulamaAlanlari({this.id, this.uygulamaAlanAdi, this.kayitSayisi});

  UygulamaAlanlari.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uygulamaAlanAdi = json['uygulamaAlanAdi'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['uygulamaAlanAdi'] = this.uygulamaAlanAdi;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }
      UygulamaAlanlari getObj(json) => UygulamaAlanlari.fromJson(json);
  static Future<List> fromAPI(String token,String data) async {
    final Response response =
        await post(Uri.parse(API_URL + "api/lst/uygulamaalanlarilst"),
            headers: <String, String>{
              "Authorization": "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{"Data": data}));

    if (response.statusCode == 200) {
      return response.body.toList(new UygulamaAlanlari());
    } else if (response.statusCode == 400) {
      throw new BadRequestError(msg: response.body);
    } else {
      throw new InternalServerError(
          msg: "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz");
    }
  }
   static Future<List> fromLocal() async {
    return await (new UygulamaAlanlariDb().getAll());
  }
}
