class KaynakGelenModel {
  int id;
  int pZararliID;
  String kaynakAdi;
  int pKaynakTurID;
  bool uremeDurumu;
  String aciklama;
  int pEkipID;
  String adres;
  String il;
  String ilce;
  String mahalle;
  String geoKonum;
  String tarih;
  String ekAciklama;
  int metreKare;
  List<String> resimler;
  int sonIlac;
  String sonIlacAdi;
  int donguGun;
  String gelecekUygulamaTarihi;

  KaynakGelenModel(
      {this.id,
      this.pZararliID,
      this.kaynakAdi,
      this.pKaynakTurID,
      this.uremeDurumu,
      this.aciklama,
      this.pEkipID,
      this.adres,
      this.il,
      this.ilce,
      this.geoKonum,
      this.tarih,
      this.ekAciklama,
      this.metreKare,
      this.resimler,
      this.sonIlac,
      this.sonIlacAdi,
      this.donguGun,
      this.mahalle,
      this.gelecekUygulamaTarihi});

  KaynakGelenModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pZararliID = json['pZararliID'];
    kaynakAdi = json['kaynakAdi'];
    pKaynakTurID = json['pKaynakTurID'];
    uremeDurumu = json['uremeDurumu'];
    aciklama = json['aciklama'];
    pEkipID = json['pEkipID'];
    adres = json['adres'];
    il = json['il'];
    ilce = json['ilce'];
    geoKonum = json['geoKonum'];
    tarih = json['tarih'];
    ekAciklama = json['ekAciklama'];
    metreKare = json['metreKare'];
    resimler = json['resimler'].cast<String>();
    sonIlac = json['sonIlac'];
    sonIlacAdi = json['sonIlacAdi'];
    donguGun = json['donguGun'];
    mahalle = json['mahalle'];
    gelecekUygulamaTarihi = json['gelecekUygulamaTarihi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['pZararliID'] = this.pZararliID;
    data['kaynakAdi'] = this.kaynakAdi;
    data['pKaynakTurID'] = this.pKaynakTurID;
    data['uremeDurumu'] = this.uremeDurumu;
    data['aciklama'] = this.aciklama;
    data['pEkipID'] = this.pEkipID;
    data['adres'] = this.adres;
    data['il'] = this.il;
    data['ilce'] = this.ilce;
    data['geoKonum'] = this.geoKonum;
    data['tarih'] = this.tarih;
    data['ekAciklama'] = this.ekAciklama;
    data['metreKare'] = this.metreKare;
    data['resimler'] = this.resimler;
    data['sonIlac'] = this.sonIlac;
    data['sonIlacAdi'] = this.sonIlacAdi;
    data['donguGun'] = this.donguGun;
    data['mahalle'] = this.mahalle;
    data['gelecekUygulamaTarihi'] = this.gelecekUygulamaTarihi;
    return data;
  }

  fromJson(json) => KaynakGelenModel.fromJson(json);
}
