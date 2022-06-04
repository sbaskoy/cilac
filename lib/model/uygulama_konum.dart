import 'dart:convert';

import 'package:http/http.dart';

import '../global/constant.dart';
import 'uygulamakayit.dart';

class UygulamaKonumlar {
  int pUygulamaID;
  List<Konum> data;

  UygulamaKonumlar(this.pUygulamaID, this.data);
  UygulamaKonumlar.fromJson(json) {
    pUygulamaID = json["pUygulamaID"];
    data = [];
    if (json["data"] != null) {
      json["data"].forEach((e) => data.add(Konum.fromJson(e)));
    }
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["pUygulamaID"] = this.pUygulamaID;
    data["data"] = this.data.map((e) => e.toJson()).toList();
    return data;
  }

  Future<ReturnModel> postAPI(token) async {
    Response response = await post(Uri.parse(API_URL + "api/act/UyKonum"),
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(this.toJson()));
    //log(jsonEncode(this.toJson()));
    // durum 0 başarılı
    // durum 100 büyükse hatalı
    // durum kodu 1 ve ıd varsa resim kayıt edilmedi
    // print(jsonEncode(this.toJson()));
    if (response.statusCode == 200) {
      ReturnModel model = ReturnModel.fromJson(jsonDecode(response.body));
    
      return model;
    }
    return null;
  }
}

class Konum {
  String tarih;
  String geoKonum;
  bool tip;

  Konum({this.tarih, this.geoKonum, this.tip});
  Konum.fromJson(json) {
    tarih = json["tarih"];
    geoKonum = json["geoKonum"];
    tip = json["tip"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["tarih"] = this.tarih;
    data["geoKonum"] = this.geoKonum;
    data["tip"] = this.tip;
    return data;
  }
}
