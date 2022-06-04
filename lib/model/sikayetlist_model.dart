class Sikayet {
  SikayeKaydi sikayeKaydi;
  List<YapilanUygulamalar> yapilanUygulamalar;

  Sikayet({this.sikayeKaydi, this.yapilanUygulamalar});

  Sikayet.fromJson(Map<String, dynamic> json) {
    sikayeKaydi = json['sikayeKaydi'] != null ? new SikayeKaydi.fromJson(json['sikayeKaydi']) : null;
    if (json['yapilanUygulamalar'] != null) {
      yapilanUygulamalar = [];
      json['yapilanUygulamalar'].forEach((v) {
        yapilanUygulamalar.add(new YapilanUygulamalar.fromJson(v));
      });
    }
  }
  fromJson(json) {
    return Sikayet.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.sikayeKaydi != null) {
      data['sikayeKaydi'] = this.sikayeKaydi.toJson();
    }
    if (this.yapilanUygulamalar != null) {
      data['yapilanUygulamalar'] = this.yapilanUygulamalar.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SikayeKaydi {
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
  int pAtananEkipID;
  String durumu;
  bool bDurum;
  String geoKonum;
  String turu;
  String ekipTanimi;
  String kaydiAlan;
  String kulAdi;
  bool aktif;
  int pSorumluID;
  String ekipSorumlusu;
  int ekipSorumluIlceID;
  String ekipSorumluIlce;
  int kayitSayisi;

  SikayeKaydi(
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
      this.pAtananEkipID,
      this.durumu,
      this.bDurum,
      this.geoKonum,
      this.turu,
      this.ekipTanimi,
      this.kaydiAlan,
      this.kulAdi,
      this.aktif,
      this.pSorumluID,
      this.ekipSorumlusu,
      this.ekipSorumluIlceID,
      this.ekipSorumluIlce,
      this.kayitSayisi});

  SikayeKaydi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tarih = json['tarih'];
    pPersonID = json['pPersonID'];
    adiSoyadi = json['adiSoyadi'];
    cepTel = json['cepTel'];
    sikayetAdresi = json['sikayetAdresi'];
    adresAciklama = json['adresAciklama'];
    il = json['il'];
    ilce = json['ilce'];
    konusu = json['konusu'];
    pAtananEkipID = json['pAtananEkipID'];
    durumu = json['durumu'];
    bDurum = json['bDurum'];
    geoKonum = json['geoKonum'];
    turu = json['turu'];
    ekipTanimi = json['ekipTanimi'];
    kaydiAlan = json['kaydiAlan'];
    kulAdi = json['kulAdi'];
    aktif = json['aktif'];
    pSorumluID = json["pSorumluID"];
    ekipSorumlusu = json["EkipSorumlusu"];
    ekipSorumluIlceID = json["EkipSorumluIlceID"];
    ekipSorumluIlce = json["EkipSorumluIlce"];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['tarih'] = this.tarih;
    data['pPersonID'] = this.pPersonID;
    data['adiSoyadi'] = this.adiSoyadi;
    data['cepTel'] = this.cepTel;
    data['sikayetAdresi'] = this.sikayetAdresi;
    data['adresAciklama'] = this.adresAciklama;
    data['il'] = this.il;
    data['ilce'] = this.ilce;
    data['konusu'] = this.konusu;
    data['pAtananEkipID'] = this.pAtananEkipID;
    data['durumu'] = this.durumu;
    data['bDurum'] = this.bDurum;
    data['geoKonum'] = this.geoKonum;
    data['turu'] = this.turu;
    data['ekipTanimi'] = this.ekipTanimi;
    data['kaydiAlan'] = this.kaydiAlan;
    data['kulAdi'] = this.kulAdi;
    data['aktif'] = this.aktif;
    data['kayitSayisi'] = this.kayitSayisi;
    data["pSorumluID"] = this.pSorumluID;
    data["EkipSorumlusu"] = this.ekipSorumlusu;
    data["EkipSorumluIlceID"] = this.ekipSorumluIlceID;
    data["EkipSorumluIlce"] = this.ekipSorumluIlce;
    return data;
  }
}

class YapilanUygulamalar {
  int id;
  int pUygulamaTanimID;
  int pEkipID;
  String adres;
  String baslangicTarihi;
  String bitisTarihi;
  String ilce;
  String il;
  String aciklama;
  int pPersonID;
  int pSikayetID;
  int pKaynakID;
  String uygulamaTanimi;
  String ekipTanimi;
  String adiSoyadi;
  int kayitSayisi;

  YapilanUygulamalar(
      {this.id,
      this.pUygulamaTanimID,
      this.pEkipID,
      this.adres,
      this.baslangicTarihi,
      this.bitisTarihi,
      this.ilce,
      this.il,
      this.aciklama,
      this.pPersonID,
      this.pSikayetID,
      this.pKaynakID,
      this.uygulamaTanimi,
      this.ekipTanimi,
      this.adiSoyadi,
      this.kayitSayisi});

  YapilanUygulamalar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pUygulamaTanimID = json['pUygulamaTanimID'];
    pEkipID = json['pEkipID'];
    adres = json['adres'];
    baslangicTarihi = json['baslangicTarihi'];
    bitisTarihi = json['bitisTarihi'];
    ilce = json['ilce'];
    il = json['il'];
    aciklama = json['aciklama'];
    pPersonID = json['pPersonID'];
    pSikayetID = json['pSikayetID'];
    pKaynakID = json['pKaynakID'];
    uygulamaTanimi = json['uygulamaTanimi'];
    ekipTanimi = json['ekipTanimi'];
    adiSoyadi = json['adiSoyadi'];
    kayitSayisi = json['kayitSayisi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['pUygulamaTanimID'] = this.pUygulamaTanimID;
    data['pEkipID'] = this.pEkipID;
    data['adres'] = this.adres;
    data['baslangicTarihi'] = this.baslangicTarihi;
    data['bitisTarihi'] = this.bitisTarihi;
    data['ilce'] = this.ilce;
    data['il'] = this.il;
    data['aciklama'] = this.aciklama;
    data['pPersonID'] = this.pPersonID;
    data['pSikayetID'] = this.pSikayetID;
    data['pKaynakID'] = this.pKaynakID;
    data['uygulamaTanimi'] = this.uygulamaTanimi;
    data['ekipTanimi'] = this.ekipTanimi;
    data['adiSoyadi'] = this.adiSoyadi;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }
}
