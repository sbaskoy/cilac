class UygulamaDetay {
  String uygulamaTanimi;
  String kaynakTurleri;
  String ilaclar;
  String ekipmanlar;
  String yontemler;
  String alanlar;
  String hedefZararli;
  List<String> resimler;
  List<String> konumlar;
  String mucadeleSekli;
  int id;
  int pUygulamaTanimID;
  int pEkipID;
  String adres;
  String baslangicTarihi;
  String bitisTarihi;
  String ilce;
  String il;
  String aciklama;
  String ekipTanimi;
  String adiSoyadi;
  bool kaynakDurumu;
  bool uremeDurumu;
  int pKaynakID;
  int pSikayetID;
  int pPersonID;
  String sikayetEden;
  String sikayetTarihi;

  UygulamaDetay(
      {this.uygulamaTanimi,
      this.kaynakTurleri,
      this.ilaclar,
      this.ekipmanlar,
      this.yontemler,
      this.alanlar,
      this.hedefZararli,
      this.resimler,
      this.konumlar,
      this.mucadeleSekli,
      this.id,
      this.pUygulamaTanimID,
      this.pEkipID,
      this.adres,
      this.baslangicTarihi,
      this.bitisTarihi,
      this.ilce,
      this.il,
      this.aciklama,
      this.ekipTanimi,
      this.adiSoyadi,
      this.kaynakDurumu,
      this.uremeDurumu,
      this.pKaynakID,
      this.pSikayetID,
      this.pPersonID,
      this.sikayetEden,
      this.sikayetTarihi
      });

  UygulamaDetay.fromJson(Map<String, dynamic> json) {
   
    uygulamaTanimi = json['uygulamaTanimi'];
    kaynakTurleri = json['kaynakTurleri'];
    ilaclar = json['ilaclar'];
    ekipmanlar = json['ekipmanlar'];
    yontemler = json['yontemler'];
    alanlar = json['alanlar'];
    hedefZararli = json['hedefZararli'];
    if (json['resimler'] != null) {
      resimler = [];
      json['resimler'].forEach((v) {
        resimler.add(v);
      });
    }
    konumlar = json['konumlar'].cast<String>();
    mucadeleSekli = json['mucadeleSekli'];
    id = json['id'];
    pUygulamaTanimID = json['pUygulamaTanimID'];
    pEkipID = json['pEkipID'];
    adres = json['adres'];
    baslangicTarihi = json['baslangicTarihi'];
    bitisTarihi = json['bitisTarihi'];
    ilce = json['ilce'];
    il = json['il'];
    aciklama = json['aciklama'];
    ekipTanimi = json['ekipTanimi'];
    adiSoyadi = json['adiSoyadi'];
    kaynakDurumu = json['kaynakDurumu'];
    uremeDurumu = json['uremeDurumu'];
    pKaynakID = json['pKaynakID'];
    pSikayetID = json['pSikayetID'];
    pPersonID = json['pPersonID'];
    sikayetEden = json['sikayetEden'];
    sikayetTarihi = json['sikayetTarihi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uygulamaTanimi'] = this.uygulamaTanimi;
    data['kaynakTurleri'] = this.kaynakTurleri;
    data['ilaclar'] = this.ilaclar;
    data['ekipmanlar'] = this.ekipmanlar;
    data['yontemler'] = this.yontemler;
    data['alanlar'] = this.alanlar;
    data['hedefZararli'] = this.hedefZararli;
    if (this.resimler != null) {
      data['resimler'] = this.resimler.map((v) => v).toList();
    }
    data['konumlar'] = this.konumlar;
    data['mucadeleSekli'] = this.mucadeleSekli;
    data['id'] = this.id;
    data['pUygulamaTanimID'] = this.pUygulamaTanimID;
    data['pEkipID'] = this.pEkipID;
    data['adres'] = this.adres;
    data['baslangicTarihi'] = this.baslangicTarihi;
    data['bitisTarihi'] = this.bitisTarihi;
    data['ilce'] = this.ilce;
    data['il'] = this.il;
    data['aciklama'] = this.aciklama;
    data['ekipTanimi'] = this.ekipTanimi;
    data['adiSoyadi'] = this.adiSoyadi;
    data['kaynakDurumu'] = this.kaynakDurumu;
    data['uremeDurumu'] = this.uremeDurumu;
    data['pKaynakID'] = this.pKaynakID;
    data['pSikayetID'] = this.pSikayetID;
    data['pPersonID'] = this.pPersonID;
    return data;
  }

  fromJson(json) {
    return UygulamaDetay.fromJson(json);
  }
}
