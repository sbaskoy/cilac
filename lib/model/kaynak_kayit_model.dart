class KaynakKayitModel {
  int id;
  int pZararliID; //zararlı türlerinden
  String kaynakAdi; //kaynak adını Zararlı Adı olarak gönder
  int pKaynakTurID; //kaynak türlerinden
  bool uremeDurumu; //bool
  String aciklama;
  int pEkipID; //Ekiplerden
  String adres;
  String il; //ORDU
  String ilce; //ilceden
  String geoKonum; //stringpoint
  String tarih;
  String ekAciklama;
  int metreKare;
  String mahalle;
  List<String> resimler;

  KaynakKayitModel(
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
      this.mahalle,
      this.resimler});
  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "pZararliID": this.pZararliID,
      "kaynakAdi": this.kaynakAdi,
      "pKaynakTurID": this.pKaynakTurID,
      "uremeDurumu": this.uremeDurumu,
      "aciklama": this.aciklama,
      "pEkipID": this.pEkipID,
      "adres": this.adres,
      "il": this.il,
      "ilce": this.ilce,
      "geoKonum": this.geoKonum,
      "tarih": this.tarih,
      "ekAciklama": this.ekAciklama,
      "metreKare": this.metreKare,
      "resimler": this.resimler,
      "mahalle": this.mahalle,
    };
  }
}
