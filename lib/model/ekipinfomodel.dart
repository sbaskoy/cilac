class EkipKonum {
  int id;
  int pPersonID;
  int pEkipID;
  String tarih;
  String cihazInfo;
  String geoKonum;

  EkipKonum({this.id, this.pPersonID, this.pEkipID, this.tarih, this.cihazInfo, this.geoKonum});
  EkipKonum.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.pPersonID = json["pPersonID"];
    this.pEkipID = json["pEkipID"];
    this.tarih = json["tarih"];
    this.cihazInfo = json["cihazInfo"];
    this.geoKonum = json["geoKonum"];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data["ID"] = this.id;
    data["pPersonID"] = this.pPersonID;
    data["pEkipID"] = this.pEkipID;
    data["tarih"] = this.tarih;
    data["cihazInfo"] = this.cihazInfo;
    data["geoKonum"] = this.geoKonum;
    return data;
  }

  fromJson(json) {
    return EkipKonum.fromJson(json);
  }
}
