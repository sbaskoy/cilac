class Ekip {
  int id;
  String ekipTanimi;
  int pIlceID;
  List<String> tbl;
  int pSorumluID;
  int kayitSayisi;

  Ekip({this.id, this.ekipTanimi, this.pIlceID, this.tbl, this.pSorumluID, this.kayitSayisi});

  Ekip.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ekipTanimi = json['ekipTanimi'];
    pIlceID = json['pIlceID'];
    if (json['tbl'] != null) {
      tbl = [];
      json['tbl'].forEach((v) {
        tbl.add(v);
      });
    }
    pSorumluID = json['pSorumluID'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['ekipTanimi'] = this.ekipTanimi;
    data['pIlceID'] = this.pIlceID;
    if (this.tbl != null) {
      data['tbl'] = this.tbl.map((v) => v).toList();
    }
    data['pSorumluID'] = this.pSorumluID;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  fromJson(json) => Ekip.fromJson(json);
}
