import 'package:rxdart/rxdart.dart';

import '../../base/network_manager.dart';
import '../../extansion/list_extansion.dart';
import '../../mixins/helper.dart';
import '../../model/grupmodel.dart';
import '../../model/usermodel.dart';

class Ekip {
  String adi;
  List<GrupModel> data;
  Ekip({this.adi, this.data});
}

class Ilce {
  final String adi;
  final List<Ekip> data;

  Ilce({this.adi, this.data});
}

class IstatislikState {
  // BU DEĞİŞKENLER BUİLD METODU İÇERİSİNDE DİNLENİR
  // HERHANGİ BİR DEĞİŞİKLİKTE OTOMATİK GÜNCELLENİR
  // setState ALTERNATİVİ
  final _grupedData = new BehaviorSubject<List<Ilce>>();
// 1 ilceye göre 2 uygulamaya göre 3 tümü
  final _group = new BehaviorSubject<int>.seeded(1);

  final _data = new BehaviorSubject<List<GrupModel>>();
  final toplam = new BehaviorSubject<int>.seeded(0);
  final ekipler = new BehaviorSubject<List<String>>.seeded([]);
  final ekipler2 = new BehaviorSubject<List<String>>.seeded([]);
  final ekipGrup = new BehaviorSubject<List<GrupModel>>.seeded([]);

  final filter1 = new BehaviorSubject<String>.seeded("");
  final filter2 = new BehaviorSubject<String>.seeded("");

  Stream<int> get group => _group.stream;

  int get getGroup => _group.value;

  Function(int) get changeGrooup => _group.sink.add;

// data
  Stream<List<GrupModel>> get data => _data.stream;

  List<GrupModel> get getDataList => _data.value;

  Function(List<GrupModel>) get changeData => _data.sink.add;

  Function(String) get addErrorData => _data.sink.addError;

// groped data

  Stream<List<Ilce>> get grupedDataList => _grupedData.stream;

  List<Ilce> get getGrupedDataList => _grupedData.value;

  Function(List<Ilce>) get changeGrupedData => _grupedData.sink.add;

  Function(String) get addErrorGrupedData => _grupedData.sink.addError;
  double get getFilterTotal {
    return ekipGrup.value.fold(0, (previousValue, element) => previousValue + element.sayi);
  }

  Future<void> getData(UserModel user, String start, String finish) async {
    try {
      // APIDEN VERİ CEKER
      List res = await NetworkManager.instance
          .httpPost(path: "api/lst/istauygulamalst", token: user.token, model: GrupModel(), data: <String, String>{
        "Data": (start == null && finish == null) ? "" : " and baslangicTarihi>'$start' and baslangicTarihi<'$finish'",
        "pUserID": user.id.toString(),
        "grpAdi": "ilce",
        "grpAdi2": "EkipTanimi",
        "grpAdi3": "UygulamaTanimi"
      });

      if (res == null) {
        addErrorGrupedData("Bilinmeyen bir hata oluştu");
        return;
      }
      var data = res.map((e) => e as GrupModel).toList();
      toplam.sink.add(data.fold(0, (previousValue, element) => previousValue + element.sayi));
      changeData(data);
      // SEÇİLİ GORUBA GÖRE FİLTRELER

    
      if (_group.value == 1) {
        ilceyeGore();
      }
      if (_group.value == 2) {
        uygulamayaGore();
      }
      if (_group.value == 3) {
        ekipeGore();
      }
    } catch (e) {
      addErrorGrupedData(Helper.getErrorMessage(e));
      addErrorData(Helper.getErrorMessage(e));
    }
  }

  void ekipeGore() {
    List<GrupModel> mainList = _data.value;
    List<String> _ekipler = getEkip(mainList);
    this.ekipler.sink.add(_ekipler);
    filterGropedData(_ekipler.first);
    //Map<String, List> groupedData = mainList.groupByKey((e) => e.grpAdi2);
    //List<Ilce> ilceGrup = [];
    //for (var item in groupedData.entries) {
    //  List<GrupModel> newList = item.value.map((e) => e as GrupModel).toList();
    //  Map<String, List> ekipGrupData = newList.groupByKey((e) => e.grpAdi3);
    //  List<Ekip> ekipGrup = [];
    //  for (var item2 in ekipGrupData.entries) {
    //    ekipGrup.add(new Ekip(adi: item2.key, data: item2.value));
    //  }
    //  ilceGrup.add(new Ilce(adi: item.key, data: ekipGrup));
    //}
    //changeGrupedData(ilceGrup);
  }

  void filterGropedData(String value) {
    this.filter1.sink.add(value);
    List<GrupModel> mainList = _data.value;
    List<GrupModel> filteredModel = mainList.where((element) => element.grpAdi == value).toList();
    var d = getEkip2(filteredModel);
    this.ekipler2.sink.add(d);
    filterGropedData2(d.first);
  }

  void filterGropedData2(String value) {
    this.filter2.sink.add(value);
    List<GrupModel> mainList = _data.value;
    List<GrupModel> filteredModel = mainList
        .where((element) => element.grpAdi == this.filter1.value && element.grpAdi2 == this.filter2.value)
        .toList();
    this.ekipGrup.sink.add(filteredModel);
  }

  List<String> getEkip2(List<GrupModel> data) {
    var idSet = <String>{};
    for (var d in data) {
      idSet.add(d.grpAdi2);
    }
    return List.from(idSet);
  }

  List<String> getEkip(List<GrupModel> data) {
    var idSet = <String>{};
    for (var d in data) {
      idSet.add(d.grpAdi);
    }
    return List.from(idSet);
  }

  void uygulamayaGore() {
    List<GrupModel> mainList = _data.value;
    Map<String, List> groupedData = mainList.groupByKey((e) => e.grpAdi3);
    List<Ilce> ilceGrup = [];
    for (var item in groupedData.entries) {
      List<GrupModel> newList = item.value.map((e) => e as GrupModel).toList();
      Map<String, List> ekipGrupData = newList.groupByKey((e) => e.grpAdi);
      List<Ekip> ekipGrup = [];
      for (var item2 in ekipGrupData.entries) {
        ekipGrup.add(new Ekip(adi: item2.key, data: item2.value));
      }
      ilceGrup.add(new Ilce(adi: item.key, data: ekipGrup));
    }
    changeGrupedData(ilceGrup);
  }

  void ilceyeGore() {
    List<GrupModel> mainList = _data.value;
    Map<String, List> groupedData = mainList.groupByKey((e) => e.grpAdi);
    List<Ilce> ilceGrup = [];
    for (var item in groupedData.entries) {
      List<GrupModel> newList = item.value.map((e) => e as GrupModel).toList();
      Map<String, List> ekipGrupData = newList.groupByKey((e) => e.grpAdi2);
      List<Ekip> ekipGrup = [];
      for (var item2 in ekipGrupData.entries) {
        ekipGrup.add(new Ekip(adi: item2.key, data: item2.value));
      }
      ilceGrup.add(new Ilce(adi: item.key, data: ekipGrup));
    }
    changeGrupedData(ilceGrup);
  }

  dispose() {
    _grupedData.close();
    _group.close();
    _data.close();
    toplam.close();
    ekipler.close();
    ekipGrup.close();
    ekipler2.close();
    filter1.close();
    filter2.close();
  }
}
