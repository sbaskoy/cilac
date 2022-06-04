import 'dart:convert';

import '../localdb/kaynak_turleri_db.dart';
import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';
import '../global/global_function.dart';

class KaynakTurleri {
  int id;
  String kaynakAdi;
  int kayitSayisi;

  KaynakTurleri({this.id, this.kaynakAdi, this.kayitSayisi});

  KaynakTurleri.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kaynakAdi = json['kaynakAdi'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['kaynakAdi'] = this.kaynakAdi;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  KaynakTurleri getObj(json) => KaynakTurleri.fromJson(json);
  static Future<List> fromAPI(String token, String data) async {
    final Response response = await post(Uri.parse(API_URL + "api/lst/kaynakturlerilst"),
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{"Data": data}));

    if (response.statusCode == 200) {
      return response.body.toList(new KaynakTurleri());
    } else if (response.statusCode == 400) {
      throw new BadRequestError(msg: response.body);
    } else {
      throw new InternalServerError(
          msg: "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz");
    }
  }
   static Future<List> fromLocal() async {
    return await (new KaynakTurleriDb().getAll());
  }
}
