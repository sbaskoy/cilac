class Ekipler {
  int id;
  String ekipTanimi;
  int pIlceID;
  String ilceAdi;
  int pSorumluID;
  String ekipSorumlusu;
  int kayitSayisi;

  Ekipler(
      {this.id, this.ekipTanimi, this.pIlceID, this.ilceAdi, this.pSorumluID, this.ekipSorumlusu, this.kayitSayisi});

  Ekipler.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ekipTanimi = json['ekipTanimi'];
    pIlceID = json['pIlceID'];
    ilceAdi = json['ilceAdi'];
    pSorumluID = json['pSorumluID'];
    ekipSorumlusu = json['ekipSorumlusu'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['ekipTanimi'] = this.ekipTanimi;
    data['pIlceID'] = this.pIlceID;
    data['ilceAdi'] = this.ilceAdi;
    data['pSorumluID'] = this.pSorumluID;
    data['ekipSorumlusu'] = this.ekipSorumlusu;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  fromJson(json) => Ekipler.fromJson(json);
}
