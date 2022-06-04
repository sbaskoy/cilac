import '../application/uygulama_sec.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extansion/string_extansion.dart';
import '../../extansion/widget_extansion.dart';
import '../../mixins/helper.dart';
import '../../model/sikayetlist_model.dart';
import '../../model/usermodel.dart';

import '../ekipata/ekip_ata_view.dart';
import '../geziciuygulama/konum_sec.dart';
import 'sikayetlist_state.dart';

class SikayetListView extends StatelessWidget {
  final UserModel user;

  const SikayetListView({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final SikayetListState state = Provider.of<SikayetListState>(context);
    state.getData(user);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sikayet listesi"),
      ),
      body: Center(
        child: StreamBuilder(
            stream: state.sikayetList,
            builder: (context, snap) {
              if (snap.hasError) {
                return Helper.customError(snap.error).paddingAll();
              }
              if (snap.hasData) {
                List<Sikayet> data = snap.data;
                if (data.isEmpty) {
                  return const Text("Henüz şikayet girilmemiş");
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var d = data[index].sikayeKaydi;
                    return Material(
                      elevation: 20,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: Column(
                        children: [
                          Text(
                            d.pAtananEkipID == 0 ? "Ekip Atanmamış" : d.ekipTanimi,
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
                                            buildRowText("Sikayeti Yapan:", d.adiSoyadi).paddingAll(),
                                            buildRowText("Kaydı Alan:", d.kaydiAlan).paddingAll(),
                                            buildRowText("Konu:", d.konusu).paddingAll(),
                                            buildRowText("Adres:", d.sikayetAdresi).paddingAll(),
                                            buildRowText("Telefon:", d.cepTel).paddingAll(),
                                          ],
                                        ),
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          children: [
                                            if (user.tipi == "Mobil Kullanıcı")
                                              IconButton(
                                                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                                                  onPressed: () => onTap(context, data[index])),
                                            if (user.tipi == "Mobil Kullanıcı")
                                              IconButton(
                                                  icon: const Icon(
                                                    Icons.add_box,
                                                    color: Colors.green,
                                                  ),
                                                  onPressed: () => onTap2(context, data[index])),
                                            if (user.tipi != "Mobil Kullanıcı")
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.amber,
                                                ),
                                                onPressed: () => onTap3(context, data[index], state),
                                              )
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
                            d.tarih.dateToStr,
                            style: const TextStyle(fontSize: 16),
                          ).paddingAll()
                        ],
                      ),
                    ).paddingAll();
                  },
                );
              }
              return const CircularProgressIndicator();
            }),
      ),
    );
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

  onTap(context, Sikayet data) => Navigator.push(context, MaterialPageRoute(builder: (c) {
        return UygulamaSec(
          model: user,
          sikayetID: data.sikayeKaydi.id,
          cord: data.sikayeKaydi.geoKonum.pointToLatLng,
        );
      }));

  onTap2(context, Sikayet data) => Navigator.push(context, MaterialPageRoute(builder: (c) {
        return GeziciKonum(
          user: user,
          sikayetID: data.sikayeKaydi.id,
          cord: data.sikayeKaydi.geoKonum.pointToLatLng,
        );
      }));

  onTap3(context, Sikayet sikayet, SikayetListState state) async {
    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: EkipAtaView(
              user: user,
              sikayet: sikayet,
            ),
          );
        });
    state.getData(user);
    //  ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: Text("Güncelledi")));
  }
}
