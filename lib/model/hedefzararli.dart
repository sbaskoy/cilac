import 'dart:convert';

import '../localdb/hedef_zararli_db.dart';
import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';
import '../global/global_function.dart';

class HedefZararli {
  int id;
  String zararliAdi;
  int kayitSayisi;

  HedefZararli({this.id, this.zararliAdi, this.kayitSayisi});

  HedefZararli.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    zararliAdi = json['zararliAdi'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['zararliAdi'] = this.zararliAdi;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  HedefZararli getObj(json) => HedefZararli.fromJson(json);
  static Future<List> fromAPI(String token, String data) async {
    final Response response = await post(Uri.parse(API_URL + "api/lst/zararliturlerilst"),
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{"Data": data}));

    if (response.statusCode == 200) {
      return response.body.toList(new HedefZararli());
    } else if (response.statusCode == 400) {
      throw new BadRequestError(msg: response.body);
    } else {
      throw new InternalServerError(
          msg: "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz");
    }
  }
   static Future<List> fromLocal() async {
    return await (new HedefZararliDb().getAll());
  }
}
