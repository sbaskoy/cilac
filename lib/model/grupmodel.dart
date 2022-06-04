class GrupModel {
  int sayi;
  String grpAdi;
  String grpAdi2;
  String grpAdi3;

  GrupModel({this.sayi, this.grpAdi, this.grpAdi2, this.grpAdi3});

  GrupModel.fromJson(Map<String, dynamic> json) {
    sayi = json['sayi'];
    grpAdi = json['grpAdi'];
    grpAdi2 = json['grpAdi2'];
    grpAdi3 = json['grpAdi3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sayi'] = this.sayi;
    data['grpAdi'] = this.grpAdi;
    data['grpAdi2'] = this.grpAdi2;
    data['grpAdi3'] = this.grpAdi3;
    return data;
  }

  fromJson(json) => GrupModel.fromJson(json);
}
