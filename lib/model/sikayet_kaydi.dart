class SikayetKaydi {
  int id;
  String tarih;
  int pPersonID;
  String adiSoyadi;
  String cepTel;
  String sikayetAdresi;
  String adresAciklama;
  String il;
  String ilce;
  String konusu;
  int pSorumluID;
  int pAtananEkipID;
  String durumu;
  int bDurum;
  String geoKonum;
  String turu;

  SikayetKaydi(
      {this.id,
      this.tarih,
      this.pPersonID,
      this.adiSoyadi,
      this.cepTel,
      this.sikayetAdresi,
      this.adresAciklama,
      this.il,
      this.ilce,
      this.konusu,
      this.pSorumluID,
      this.pAtananEkipID,
      this.durumu,
      this.bDurum,
      this.geoKonum,
      this.turu
      });
  SikayetKaydi.fromJson(json) {
    this.id = json["id"];
    this.tarih = json["tarih"];
    this.pPersonID = json["pPersonID"];
    this.adiSoyadi = json["adiSoyadi"];
    this.cepTel = json["cepTel"];
    this.sikayetAdresi = json["sikayetAdresi"];
    this.adresAciklama = json["adresAciklama"];
    this.il = json["il"];
    this.ilce = json["ilce"];
    this.konusu = json["konusu"];
    this.pSorumluID = json["pSorumluID"];
    this.pAtananEkipID = json["pAtananEkipID"];
    this.durumu = json["durumu"];
  }
  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "tarih": this.tarih,
      "pPersonID": this.pPersonID,
      "adiSoyadi": this.adiSoyadi,
      "cepTel": this.cepTel,
      "sikayetAdresi": this.sikayetAdresi,
      "adresAciklama": this.adresAciklama,
      "il": this.il,
      "ilce": this.ilce,
      "konusu": this.konusu,
      "pSorumluID": this.pSorumluID,
      "pAtananEkipID": this.pAtananEkipID,
      "durumu": this.durumu,
      "bdurum":this.bDurum,
       "geoKonum":this.geoKonum,
      "turu":this.turu

    };
  }

  fromJson(json) => SikayetKaydi.fromJson(json);
}
