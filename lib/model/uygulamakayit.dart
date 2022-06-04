import 'dart:convert';

import '../localdb/uygulama_kayit_db.dart';
import 'package:http/http.dart';

import '../global/constant.dart';

class UygulamaKayit {
  String uygulamaTanimi;
  String kaynakTurleri;
  String ilaclar;
  String ekipmanlar;
  String yontemler;
  String alanlar;
  String hedefZararli;
  String konumlar;
  List<String> resimler;
  String mucadeleSekli;

  int id;
  int pUygulamaTanimID;
  int pEkipID;
  String adres;
  String konumID;
  String baslangicTarihi;
  String bitisTarihi;
  String ilce;
  String il;
  String aciklama;
  bool kaynakDurumu;
  bool uremeDurumu;
  int pKaynakID;
  int pSikayetID;
  int pPersonID;

  UygulamaKayit(
      {this.uygulamaTanimi,
      this.kaynakTurleri,
      this.ilaclar,
      this.ekipmanlar,
      this.yontemler,
      this.alanlar,
      this.hedefZararli,
      this.konumlar,
      this.resimler,
      this.mucadeleSekli,
      this.id,
      this.pUygulamaTanimID,
      this.pEkipID,
      this.adres,
      this.konumID,
      this.baslangicTarihi,
      this.bitisTarihi,
      this.ilce,
      this.il,
      this.aciklama,
      this.kaynakDurumu,
      this.uremeDurumu,
      this.pKaynakID,
      this.pSikayetID,
      this.pPersonID});
  UygulamaKayit.fromJson(data) {
    this.id = data["ID"];
    this.uygulamaTanimi = data["uygulamaTanimi"];
    this.kaynakTurleri = data["kaynakTurleri"];
    this.ilaclar = data["ilaclar"];
    this.ekipmanlar = data["ekipmanlar"];
    this.yontemler = data["yontemler"];
    this.alanlar = data["alanlar"];
    this.hedefZararli = data["hedefZararli"];
    this.konumlar = data["konumlar"];
    this.resimler = [];
    if (data["resimler"] != null) {
      data["resimler"].forEach((e) => resimler.add(e));
    }
    this.mucadeleSekli = data["mucadeleSekli"];
    this.id = data["id"];
    this.pUygulamaTanimID = data["pUygulamaTanimID"];
    this.pEkipID = data["pEkipID"];
    this.adres = data["adres"];
    this.konumID = data["konumID"];
    this.baslangicTarihi = data["baslangicTarihi"];
    this.bitisTarihi = data["bitisTarihi"];
    this.ilce = data["ilce"];
    this.il = data["il"];
    this.aciklama = data["aciklama"];
    this.kaynakDurumu = data["kaynakDurumu"];
    this.uremeDurumu = data["uremeDurumu"];
    this.pKaynakID = data["pKaynakID"];
    this.pSikayetID = data["pSikayetID"];
    this.pPersonID = data["pPersonID"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["ID"] = this.id;
    data["uygulamaTanimi"] = this.uygulamaTanimi;
    data["kaynakTurleri"] = this.kaynakTurleri;
    data["ilaclar"] = this.ilaclar;
    data["ekipmanlar"] = this.ekipmanlar;
    data["yontemler"] = this.yontemler;
    data["alanlar"] = this.alanlar;
    data["hedefZararli"] = this.hedefZararli;
    data["konumlar"] = this.konumlar;
    data["resimler"] = this.resimler;
    data["mucadeleSekli"] = this.mucadeleSekli;
    data["id"] = this.id;
    data["pUygulamaTanimID"] = this.pUygulamaTanimID;
    data["pEkipID"] = this.pEkipID;
    data["adres"] = this.adres;
    data["konumID"] = this.konumID;
    data["baslangicTarihi"] = this.baslangicTarihi;
    data["bitisTarihi"] = this.bitisTarihi;
    data["ilce"] = this.ilce;
    data["il"] = this.il;
    data["aciklama"] = this.aciklama;
    data["kaynakDurumu"] = this.kaynakDurumu;
    data["uremeDurumu"] = this.uremeDurumu;
    data["pKaynakID"] = this.pKaynakID;
    data["pSikayetID"] = this.pSikayetID;
    data["pPersonID"] = this.pPersonID;

    return data;
  }

  Future<ReturnModel> postAPI(token) async {
    Response response = await post(Uri.parse(API_URL + "api/act/Uygulama"),
        headers: <String, String>{
          "Authorization": "Bearer $token",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(this.toJson()));
    //log(jsonEncode(this.toJson()));
    // durum 0 başarılı
    // durum 100 büyükse hatalı
    // durum kodu 1 ve ıd varsa resim kayıt edilmedi

    if (response.statusCode == 200) {
      ReturnModel model = ReturnModel.fromJson(jsonDecode(response.body));

      return model;
    }
    return null;
  }

  static Future<List> fromLocal() async {
    return await (new UygulamaKayitDb().getAll());
  }
}

class ReturnModel {
  int iD;
  int durumKodu;
  String durumMesaj;

  ReturnModel({this.iD, this.durumKodu, this.durumMesaj});

  ReturnModel.fromJson(Map<String, dynamic> json) {
    iD = json['iD'];
    durumKodu = json['durumKodu'];
    durumMesaj = json['durumMesaj'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['iD'] = this.iD;
    data['durumKodu'] = this.durumKodu;
    data['durumMesaj'] = this.durumMesaj;
    return data;
  }

  fromJson(json) {
    return ReturnModel.fromJson(json);
  }
}
