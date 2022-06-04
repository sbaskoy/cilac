import 'package:rxdart/rxdart.dart';

import '../../base/network_manager.dart';
import '../../mixins/helper.dart';
import '../../model/ekipmodel.dart';
import '../../model/usermodel.dart';
import '../../model/uygulamakayit.dart';

class EkipAtaState {
  final _ekipList = new BehaviorSubject<List<Ekip>>();
  final _selectedEkip = new BehaviorSubject<int>.seeded(-1);
  final _errorMessage = new BehaviorSubject<String>();
  // 1 yükleniyor 2 işlem tamam 3 hata
  final _sendingData = new BehaviorSubject<int>.seeded(-1);

  Stream<int> get sendingData => _sendingData.stream;

  Function(int) get changeSendingData => _sendingData.sink.add;

  Stream<int> get selectedEkip => _selectedEkip.stream;

  Stream<String> get errorMessage => _errorMessage.stream;

  Function(String) get addError => _errorMessage.sink.add;

  int get getSelectedEkip => _selectedEkip.value;

  Function(int) get changeSelectedEkip => _selectedEkip.sink.add;

  Stream<List<Ekip>> get ekipList => _ekipList.stream;

  List<Ekip> get getEkipList => _ekipList.value;

  Function(List<Ekip>) get changeEkipList => _ekipList.sink.add;

  Function(String) get addErrorEkipList => _ekipList.sink.addError;
  // EKİPLERİ APİDEN ÇEKER
  void getData(UserModel user, int id) async {
    try {
      List res = await NetworkManager.instance.httpPost(
          model: Ekip(),
          token: user.token,
          path: "api/lst/ekiplerlst",
          data: <String, String>{"Data": "and pSorumluID=$id"});
      if (res != null) {
        changeEkipList(res.map((e) => e as Ekip).toList());
      } else {
        addErrorEkipList("Bilinmeyen bir hata oluştu");
      }
    } catch (e) {
      addErrorEkipList(Helper.getErrorMessage(e));
    }
  }

  Future<void> save(int sikayetID, UserModel user, int currentEkipID) async {
    addError('');
    try {
      List<int> lst = [-1, 0];
      if (_selectedEkip.value == null || lst.contains(_selectedEkip.value) || _ekipList.value.isEmpty) {
        addError("Ekip secmelisiniz");
        return;
      }
      if (currentEkipID == _selectedEkip.value) {
        addError("Ekip zaten bu şikayete atanmış");
        return;
      }
      changeSendingData(1);
      // api modeli
      ReturnModel res = await NetworkManager.instance.httpPost(
          model: new ReturnModel(),
          token: user.token,
          path: "api/act/SikayetEkipAta",
          data: <String, String>{"pSikayetID": sikayetID.toString(), "pEkipID": _selectedEkip.value.toString()});
      if (res.iD > 0 && res.durumKodu == 0) {
        // BAARILI
        changeSendingData(2);
      } else {
        // HATA 
        addError(res.durumMesaj);
        changeSendingData(3);
      }
    } catch (e) {
      addError(Helper.getErrorMessage(e));
      changeSendingData(3);
    }
  }

  dispose() {
    _ekipList.close();
    _selectedEkip.close();
    _errorMessage.close();
    _sendingData.close();
  }
}
