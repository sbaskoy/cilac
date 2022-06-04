import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../extansion/widget_extansion.dart';
import '../../mixins/helper.dart';
import '../../model/ekipmodel.dart';
import '../../model/sikayetlist_model.dart';
import '../../model/usermodel.dart';
import 'ekip_ata_state.dart';

class EkipAtaView extends StatelessWidget {
  final Sikayet sikayet;
  final UserModel user;
  const EkipAtaView({Key key, this.sikayet, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final EkipAtaState state = Provider.of<EkipAtaState>(context);
    state.getData(user, sikayet.sikayeKaydi.pSorumluID);
    state.changeSendingData(-1);
    state.changeSelectedEkip(sikayet.sikayeKaydi.pAtananEkipID);
    state.addError('');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
       const Text(
          "Ekip Ata",
          style: TextStyle(fontSize: 18),
        ).paddingAll(),
        ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200,
            ),
            child: StreamBuilder(
                stream: state.ekipList,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Text(snap.error);
                  }
                  if (snap.hasData) {
                    // EKİP LİSTESİ
                    List<Ekip> lst = snap.data;
                    return StreamBuilder(
                        stream: state.selectedEkip,
                        builder: (context, snap) {
                          if (snap.hasError) {
                            return Text(snap.error);
                          }
                          if (snap.hasData) {
                            return ListView.builder(
                                itemCount: lst.length,
                                itemBuilder: (context, index) {
                                  return RadioListTile(
                                      title: Text(lst[index].ekipTanimi),
                                      value: lst[index].id,
                                      toggleable: true,
                                      selected: lst[index].id == state.getSelectedEkip,
                                      groupValue: state.getSelectedEkip,
                                      onChanged: (a) {
                                        state.changeSelectedEkip(a);
                                      });
                                });
                          }
                          return const CircularProgressIndicator();
                        });
                  }
                  return const CircularProgressIndicator();
                })),
        Helper().errorMessage(state),
        StreamBuilder(
            stream: state.sendingData,
            builder: (context, snap) {
              if (snap.hasError) {
                return Text(snap.error);
              }
              if (snap.hasData) {
                if (snap.data == 1) {
                  return const CircularProgressIndicator();
                }
                if (snap.data == 2) {
                  return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          const Text("Ekip başarılı bir şekilde atandı",
                              textAlign: TextAlign.center, style: TextStyle(color: Colors.green, fontSize: 18)),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Kapat"))
                        ],
                      )).paddingAll();
                }
              }
              return TextButton(
                  onPressed: () {
                    state.save(sikayet.sikayeKaydi.id, user,sikayet.sikayeKaydi.pAtananEkipID);
                  },
                  child: const Text("Kaydet"));
            }),
      ],
    ).paddingAll();
  }
}
