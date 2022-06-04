
import 'package:rxdart/rxdart.dart';

import '../../base/network_manager.dart';
import '../../mixins/helper.dart';
import '../../model/sikayetlist_model.dart';
import '../../model/usermodel.dart';

class SikayetListState {
  final _sikayetList = new BehaviorSubject<List<Sikayet>>();

  Stream<List<Sikayet>> get sikayetList => _sikayetList.stream;

  List<Sikayet> get getsikayetList => _sikayetList.value;

  Function(List<Sikayet>) get changeSikayetList => _sikayetList.sink.add;

  Function(String) get addErrorSikayetList => _sikayetList.sink.addError;

  void getData(UserModel user) async {
    try {
      List res = await NetworkManager.instance.httpPost(
          path: "api/lst/SikayetDurumLst",
          data: <String, String>{
            "Data": " and bDurum=1 order by sikayetAdresi",
            "pUserID": user.id.toString(),
          },
          token: user.token,
          model: new Sikayet());
      if (res != null) {
        changeSikayetList(res.map((e) => e as Sikayet).toList());
      } else {
        addErrorSikayetList("Bilinmeyen bir hata!!");
      }
    } catch (e) {
      addErrorSikayetList(Helper.getErrorMessage(e));
    }
  }

  dispose() {
    _sikayetList.close();
  }
}
