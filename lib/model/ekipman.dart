import 'dart:convert';

import '../localdb/ekipman_db.dart';
import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';
import '../global/global_function.dart';
class Ekipman {
  int id;
  String ekipmanAdi;
  int kayitSayisi;

  Ekipman({this.id, this.ekipmanAdi, this.kayitSayisi});

  Ekipman.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ekipmanAdi = json['ekipmanAdi'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['ekipmanAdi'] = this.ekipmanAdi;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }
    Ekipman getObj(json) => Ekipman.fromJson(json);
  static Future<List> fromAPI(String token,String data) async {
    final Response response =
        await post(Uri.parse(API_URL + "api/lst/ekipmanlarlst"),
            headers: <String, String>{
              "Authorization": "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{"Data": data}));

    if (response.statusCode == 200) {
      return response.body.toList(new Ekipman());
    } else if (response.statusCode == 400) {
      throw new BadRequestError(msg: response.body);
    } else {
      throw new InternalServerError(
          msg: "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz");
    }
  }
   static Future<List> fromLocal() async {
    return await (new EkipmanDb().getAll());
  }
 
}
