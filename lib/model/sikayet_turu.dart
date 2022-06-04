class SikayetTuru {
  int id;
  String sikayetTuru;
  bool selected;
  int kayitSayisi;

  SikayetTuru({this.id, this.sikayetTuru, this.kayitSayisi, this.selected = false});

  SikayetTuru.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sikayetTuru = json['sikayetTuru'];
    kayitSayisi = json['kayitSayisi'];
    this.selected = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['sikayetTuru'] = this.sikayetTuru;
    data['kayitSayisi'] = this.kayitSayisi;
    return data;
  }

  fromJson(json) => SikayetTuru.fromJson(json);
}
