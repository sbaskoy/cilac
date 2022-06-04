import 'dart:convert';

import '../localdb/uygulama_tanim_db.dart';
import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';
import '../global/global_function.dart';

class UygulamaTanim {
  int id;
  String uygulamaTanimi;
  String kaynakTurleri;
  String ilaclar;
  String ekipmanlar;
  String yontemler;
  String alanlar;
  String uygulamaAlanlari;
  String hedefZararli;
  int kayitSayisi;

  UygulamaTanim(
      {this.id,
      this.uygulamaTanimi,
      this.kaynakTurleri,
      this.ilaclar,
      this.ekipmanlar,
      this.yontemler,
      this.alanlar,
      this.uygulamaAlanlari,
      this.hedefZararli,
      this.kayitSayisi});

  UygulamaTanim.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uygulamaTanimi = json['uygulamaTanimi'];
    kaynakTurleri = json['kaynakTurleri'];
    ilaclar = json['ilaclar'];
    ekipmanlar = json['ekipmanlar'];
    yontemler = json['yontemler'];
    alanlar = json['alanlar'];
    uygulamaAlanlari = json['uygulamaAlanlari'];
    hedefZararli = json['hedefZararli'];
    kayitSayisi = json['kayitSayisi'];
  }
  UygulamaTanim getObj(json) => UygulamaTanim.fromJson(json);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['uygulamaTanimi'] = this.uygulamaTanimi;
    data['kaynakTurleri'] = this.kaynakTurleri;
    data['ilaclar'] = this.ilaclar;
    data['ekipmanlar'] = this.ekipmanlar;
    data['yontemler'] = this.yontemler;
    data['alanlar'] = this.alanlar;
    data['uygulamaAlanlari'] = this.uygulamaAlanlari;
    data['hedefZararli'] = this.hedefZararli;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  static Future<List> fromAPI(String token) async {
    final Response response = await post(Uri.parse(API_URL + "api/lst/uygulamatanimlarilst"),
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{"Data": " order by UygulamaTanimi"}));

    if (response.statusCode == 200) {
      
      return response.body.toList(new UygulamaTanim());
    } else if (response.statusCode == 401) {
      throw AuthorizeError.to();
    } else if (response.statusCode == 400) {
      throw new BadRequestError(msg: response.body);
    } else {
      throw InternalServerError.to();
    }
  }

  static Future<List> fromLocal() async {
    return await (new UygulamaTanimDb().getAll());
  }
}
