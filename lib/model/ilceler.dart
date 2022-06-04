import 'dart:convert';

import '../localdb/ilceler_db.dart';
import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';
import '../global/global_function.dart';

class Ilce {
  int id;
  int pilID;
  String ilceAdi;
  double lat;
  double lng;
  int zoom;
  String oraKodu;
  int kayitSayisi;

  Ilce(
      {this.id,
      this.pilID,
      this.ilceAdi,
      this.lat,
      this.lng,
      this.zoom,
      this.oraKodu,
      this.kayitSayisi});

  Ilce.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pilID = json['pilID'];
    ilceAdi = json['ilceAdi'];
    lat = json['lat'];
    lng = json['lng'];
    zoom = json['zoom'];
    oraKodu = json['oraKodu'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['pilID'] = this.pilID;
    data['ilceAdi'] = this.ilceAdi;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['zoom'] = this.zoom;
    data['oraKodu'] = this.oraKodu;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }
   Ilce getObj(json) => Ilce.fromJson(json);
    static Future<List> fromAPI(String token,data) async {
    final Response response =
        await post(Uri.parse(API_URL + "api/lst/ilcelerlst"),
            headers: <String, String>{
              "Authorization": "Bearer $token",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{"Data": data}));

    if (response.statusCode == 200) {
      return response.body.toList(new Ilce());
    } else if (response.statusCode == 400) {
      throw new BadRequestError(msg: response.body);
    } else {
      throw new InternalServerError(
          msg: "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz");
    }
  }
   static Future<List> fromLocal() async {
    return await (new IlceDb().getAll());
  }
}
