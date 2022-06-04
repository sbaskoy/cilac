import 'dart:convert';

import '../localdb/yontemler_db.dart';
import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';
import '../global/global_function.dart';

class Yontemler {
  int id;
  String yontemAdi;
  int kayitSayisi;

  Yontemler({this.id, this.yontemAdi, this.kayitSayisi});

  Yontemler.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    yontemAdi = json['yontemAdi'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['yontemAdi'] = this.yontemAdi;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  Yontemler getObj(json) => Yontemler.fromJson(json);
  static Future<List> fromAPI(String token, String data) async {
    final Response response = await post(Uri.parse(API_URL + "api/lst/yontemlerlst"),
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{"Data": data}));

    if (response.statusCode == 200) {
      return response.body.toList(new Yontemler());
    } else if (response.statusCode == 400) {
      throw new BadRequestError(msg: response.body);
    } else {
      throw new InternalServerError(msg: "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz");
    }
  }

  static Future<List> fromLocal() async {
    return await (new YontemlerDb().getAll());
  }
}
