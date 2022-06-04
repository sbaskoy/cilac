import 'package:cilac/view/kaynakliste/kaynak_liste_filter.dart';
import 'package:cilac/view/sikayetyap/sikayet_yap_view.dart';

import '../application/uygulama_sec.dart';
import '../ekipkonumliste/ekip_konum_liste.dart';
import '../savelocalview.dart/save_local_view.dart';
import '../savelocalview.dart/show_local_uygulamalar.dart';
import 'package:flutter/material.dart';

import '../ekipkonumbildir/ekipkonumbildir.dart';
import '../geziciuygulama/konum_sec.dart';
import '../loginpage/login_view.dart';
import '../sikayetlist/sikayetlist_view.dart';
import '../changepassword/change_password.dart';

class BuildDrawer extends StatelessWidget {
  final dynamic widget;
  const BuildDrawer({
    Key key,
    @required this.widget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.adiSoyadi),
                      Text(widget.user.email),
                      Text("@" + widget.user.kulAdi),
                      TextButton(
                        child: const Text("Şifre Değiştir"),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (c) {
                            return ChangePasswordView(
                              user: widget.user,
                            );
                          }));
                        },
                      )
                    ],
                  ),
                ),
              ],
            )),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SaveLocalView(
                              user: widget.user,
                            )));
              },
              leading: const Icon(Icons.save),
              title: const Text("Tanımları Cihazıma Kaydet"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UygulamaSec(
                              model: widget.user,
                            )));
              },
              leading: const Icon(Icons.add_circle, color: Colors.blue),
              title: const Text("Uygulama Yap"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GeziciKonum(
                              user: widget.user,
                            )));
              },
              leading: const Icon(Icons.add_box, color: Colors.green),
              title: const Text("Gezici Uygulama Yap"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SikayetListView(
                              user: widget.user,
                            )));
              },
              leading: const Icon(Icons.list),
              title: const Text("Sikayet Listesi"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EkipKonumBildir(
                              user: widget.user,
                            )));
              },
              leading: const Icon(Icons.location_on),
              title: const Text("Ekip Konum Kaydet"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EkipKonumListe(
                              user: widget.user,
                            )));
              },
              leading: const Icon(Icons.map),
              title: const Text("Ekipleri Göster"),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowLocal(
                              user: widget.user,
                            )));
              },
              leading: const Icon(
                Icons.close,
                color: Colors.red,
              ),
              title: const Text("Kaydedilmeyenleri Göster"),
            ),
            if (widget.user.tipi != "Mobil Kullanıcı")
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SikayetYapView(
                                user: widget.user,
                              )));
                },
                leading: const Icon(Icons.add_circle, color: Colors.blue),
                title: const Text("Şikayet/Talep Gir"),
              ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => KaynakListeFilter(
                              user: widget.user,
                            )));
              },
              leading: const Icon(Icons.list, color: Colors.purple),
              title: const Text("Kaynak Listesi"),
            ),
            ListTile(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginView()));
              },
              leading: const Icon(Icons.exit_to_app_outlined),
              title: const Text("Cıkış Yap"),
            )
          ],
        ),
      ),
    );
  }
}
