import 'package:rxdart/rxdart.dart';

import '../../base/network_manager.dart';
import '../../mixins/helper.dart';
import '../../model/usermodel.dart';
import '../../model/uygulamadetay.model.dart';

enum DetayState { TIMELINE, ALL }

class UygulamaDetayState {
  final _uygulamaDetayList = new BehaviorSubject<List<UygulamaDetay>>();
  final pageState = new BehaviorSubject<DetayState>.seeded(DetayState.ALL);
  Stream<List<UygulamaDetay>> get sikayetList => _uygulamaDetayList.stream;

  List<UygulamaDetay> get getsikayetList => _uygulamaDetayList.value;

  Function(List<UygulamaDetay>) get changeUygulamaDetayList => _uygulamaDetayList.sink.add;

  Function(String) get addErrorUygulamaDetayList => _uygulamaDetayList.sink.addError;

  void onChangeTab(String val) {
    if (val == "Tümü") {
      this.pageState.sink.add(DetayState.ALL);
    } else {
      this.pageState.sink.add(DetayState.TIMELINE);
    }
  }

  void getData(UserModel user, {String data}) async {
    try {
      List res = await NetworkManager.instance.httpPost(
          path: "api/lst/uygulamauygulamalst",
          data: <String, String>{
            "Data": data ?? "",
            "pUserID": user.id.toString(),
          },
          token: user.token,
          model: new UygulamaDetay());
      if (res != null) {
        var list = res.map((e) => e as UygulamaDetay).toList().reversed.toList();
        // list.sort((a, b) => a.baslangicTarihi.compareTo(b.baslangicTarihi));
        changeUygulamaDetayList(list);
      } else {
        addErrorUygulamaDetayList("Bilinmeyen bir hata!!");
      }
    } catch (e) {
     
      addErrorUygulamaDetayList(Helper.getErrorMessage(e));
    }
  }

  dispose() {
    _uygulamaDetayList.close();
    pageState.close();
  }
}
