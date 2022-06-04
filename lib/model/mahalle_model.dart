import 'package:cilac/base/network_manager.dart';

class MahalleModel {
  int id;
  int pIlceID;
  String ilceAdi;
  String mahalleAdi;
  String oraKodu;
  int kayitSayisi;

  MahalleModel({this.id, this.pIlceID, this.ilceAdi, this.mahalleAdi, this.oraKodu, this.kayitSayisi});

  MahalleModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pIlceID = json['pIlceID'];
    ilceAdi = json['ilceAdi'];
    mahalleAdi = json['mahalleAdi'];
    oraKodu = json['oraKodu'];
    kayitSayisi = json['kayitSayisi'];
  }
  fromJson(json) => MahalleModel.fromJson(json);
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['pIlceID'] = this.pIlceID;
    data['ilceAdi'] = this.ilceAdi;
    data['mahalleAdi'] = this.mahalleAdi;
    data['oraKodu'] = this.oraKodu;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  static Future<List<MahalleModel>> fromAPI(String token) async {
    List res = await NetworkManager.instance
        .httpPost(path: "/api/lst/mahallelst", data: {"data": " "}, token: token, model: new MahalleModel());
    return res.map((e) => e as MahalleModel).toList();
  }
}
