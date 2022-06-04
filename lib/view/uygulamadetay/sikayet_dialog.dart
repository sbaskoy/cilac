import '../../base/network_manager.dart';
import '../../extansion/string_extansion.dart';
import '../../extansion/widget_extansion.dart';
import '../../model/sikayetlist_model.dart';
import '../../model/usermodel.dart';
import 'package:flutter/material.dart';

class SikayetDialog extends StatefulWidget {
  final int sikayetID;
  final UserModel user;
  const SikayetDialog({@required this.sikayetID, @required this.user});

  @override
  _SikayetDialogState createState() => _SikayetDialogState();
}

class _SikayetDialogState extends State<SikayetDialog> {
  bool loading = true;
  Sikayet sikayet;
  String err = "";
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      List res = await NetworkManager.instance.httpPost(
          path: "api/lst/SikayetDurumLst",
          data: <String, String>{
            "Data": " and bDurum=0 and ID=${widget.sikayetID}  order by sikayetAdresi",
            "pUserID": widget.user.id.toString(),
          },
          token: widget.user.token,
          model: new Sikayet());
      sikayet = res.map((e) => e as Sikayet).toList().first;
      loading = false;
    } catch (ex) {
     
      loading = false;
      err = "Şikayet yüklenirken bir hata oluştu";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: loading
            ? Container(
                height: 200,
                alignment: Alignment.center,
                child: SizedBox(height: 40, width: 40, child: const CircularProgressIndicator.adaptive()))
            : err.isNotEmpty
                ? Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: Text(
                      err,
                      style: const TextStyle(color: Colors.red),
                    ))
                : Material(
                    elevation: 20,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sikayet.sikayeKaydi.pAtananEkipID == 0 ? "Ekip Atanmamış" : sikayet.sikayeKaydi.ekipTanimi,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                        ).paddingAll(),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        Container(
                            margin: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 5,
                                    child: Container(
                                      child: Column(
                                        children: [
                                          if (sikayet.sikayeKaydi.adiSoyadi.isNotEmpty)
                                          buildRowText("Sikayeti Yapan:", sikayet.sikayeKaydi.adiSoyadi).paddingAll(),
                                         if (sikayet.sikayeKaydi.kaydiAlan.isNotEmpty)
                                          buildRowText("Kaydı Alan:", sikayet.sikayeKaydi.kaydiAlan).paddingAll(),
                                          if (sikayet.sikayeKaydi.konusu.isNotEmpty)
                                          buildRowText("Konu:", sikayet.sikayeKaydi.konusu).paddingAll(),
                                          if (sikayet.sikayeKaydi.sikayetAdresi.isNotEmpty)
                                          buildRowText("Adres:", sikayet.sikayeKaydi.sikayetAdresi).paddingAll(),
                                        ],
                                      ),
                                    )),
                              ],
                            )),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        Text(
                          sikayet.sikayeKaydi.tarih.dateToStr,
                          style: const TextStyle(fontSize: 16),
                        ).paddingAll(),
                        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Kapat"))
                      ],
                    ).paddingAll(),
                  ).paddingAll());
  }

  Widget buildRowText(String str1, String str2) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            str1,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(str2),
        )
      ],
    );
  }
}
