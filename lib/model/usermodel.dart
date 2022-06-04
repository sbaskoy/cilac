import 'dart:convert';

import 'package:http/http.dart';

import '../error/errormodel.dart';
import '../global/constant.dart';

class UserModel {
  String token;
  int id;
  int pTesID;
  String adiSoyadi;
  String kulAdi;
  String sifre;
  String gsm;
  String email;
  int pTipID;
  String tipi;
  String unvani;
  bool aktif;
  String kayitEden;
  String islemAni;
  String degistiren;
  String zincir;
  String resimURL;
  int pPerIlceID;
  String perIlce;
  int pUstID;
  String mudurlukAdi;
  String eposta;
  String logo;
  String renk;
  String aciklama;
  int pIlceID;
  int kayitSayisi;

  UserModel(
      {this.token,
      this.id,
      this.pTesID,
      this.adiSoyadi,
      this.kulAdi,
      this.sifre,
      this.gsm,
      this.email,
      this.pTipID,
      this.tipi,
      this.unvani,
      this.aktif,
      this.kayitEden,
      this.islemAni,
      this.degistiren,
      this.zincir,
      this.resimURL,
      this.pPerIlceID,
      this.perIlce,
      this.pUstID,
      this.mudurlukAdi,
      this.eposta,
      this.logo,
      this.renk,
      this.aciklama,
      this.pIlceID,
      this.kayitSayisi});

  UserModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    id = json['id'];
    pTesID = json['pTesID'];
    adiSoyadi = json['adiSoyadi'];
    kulAdi = json['kulAdi'];
    sifre = json['sifre'];
    gsm = json['gsm'];
    email = json['email'];
    pTipID = json['pTipID'];
    tipi = json['tipi'];
    unvani = json['unvani'];
    aktif = json['aktif'];
    kayitEden = json['kayitEden'];
    islemAni = json['islemAni'];
    degistiren = json['degistiren'];
    zincir = json['zincir'];
    resimURL = json['resimURL'];
    pPerIlceID = json['pPerIlceID'];
    perIlce = json['perIlce'];
    pUstID = json['pUstID'];
    mudurlukAdi = json['mudurlukAdi'];
    eposta = json['eposta'];
    logo = json['logo'];
    renk = json['renk'];
    aciklama = json['aciklama'];
    pIlceID = json['pIlceID'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = this.token;
    data['id'] = this.id;
    data['pTesID'] = this.pTesID;
    data['adiSoyadi'] = this.adiSoyadi;
    data['kulAdi'] = this.kulAdi;
    data['sifre'] = this.sifre;
    data['gsm'] = this.gsm;
    data['email'] = this.email;
    data['pTipID'] = this.pTipID;
    data['tipi'] = this.tipi;
    data['unvani'] = this.unvani;
    data['aktif'] = this.aktif;
    data['kayitEden'] = this.kayitEden;
    data['islemAni'] = this.islemAni;
    data['degistiren'] = this.degistiren;
    data['zincir'] = this.zincir;
    data['resimURL'] = this.resimURL;
    data['pPerIlceID'] = this.pPerIlceID;
    data['perIlce'] = this.perIlce;
    data['pUstID'] = this.pUstID;
    data['mudurlukAdi'] = this.mudurlukAdi;
    data['eposta'] = this.eposta;
    data['logo'] = this.logo;
    data['renk'] = this.renk;
    data['aciklama'] = this.aciklama;
    data['pIlceID'] = this.pIlceID;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  static Future<UserModel> fromAPI(String username, String password, String token) async {
    final Response response = await post(Uri.parse(API_URL + "users/Authenticate"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{"KulAdi": username, "Sifre": password, "telToken": token}));

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      throw new BadRequestError(msg: response.body);
    } else {

      throw new InternalServerError(msg: "Servis kaynaklı bir hata oluştu.Daha sonra tekrar deneyiniz");
    }
  }
}
