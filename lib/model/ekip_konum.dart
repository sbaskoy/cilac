class EkipKonum {
  int id;
  String ekipTanimi;
  int pIlceID;
  int pPersonID;
  int pEkipID;
  String tarih;
  String cihazInfo;
  String geoKonum;
  int kayitSayisi;

  EkipKonum(
      {this.id,
      this.ekipTanimi,
      this.pIlceID,
      this.pPersonID,
      this.pEkipID,
      this.tarih,
      this.cihazInfo,
      this.geoKonum,
      this.kayitSayisi});

  EkipKonum.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ekipTanimi = json['ekipTanimi'];
    pIlceID = json['pIlceID'];
    pPersonID = json['pPersonID'];
    pEkipID = json['pEkipID'];
    tarih = json['tarih'];
    cihazInfo = json['cihazInfo'];
    geoKonum = json['geoKonum'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['ekipTanimi'] = this.ekipTanimi;
    data['pIlceID'] = this.pIlceID;
    data['pPersonID'] = this.pPersonID;
    data['pEkipID'] = this.pEkipID;
    data['tarih'] = this.tarih;
    data['cihazInfo'] = this.cihazInfo;
    data['geoKonum'] = this.geoKonum;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  fromJson(json) => EkipKonum.fromJson(json);
}
