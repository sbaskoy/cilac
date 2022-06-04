import 'dart:developer';

import 'package:cilac/localdb/mahalle_db.dart';
import 'package:cilac/model/mahalle_model.dart';

import '../../localdb/alanlar_db.dart';
import '../../localdb/ekipman_db.dart';
import '../../localdb/hedef_zararli_db.dart';
import '../../localdb/ilaclar_db.dart';
import '../../localdb/ilceler_db.dart';
import '../../localdb/kaynak_turleri_db.dart';
import '../../localdb/kaynaklar_db.dart';
import '../../localdb/uygulama_alanlari_db.dart';
import '../../localdb/uygulama_tanim_db.dart';
import '../../localdb/yontemler_db.dart';
import '../../model/alanlar.dart';
import '../../model/ekipman.dart';
import '../../model/hedefzararli.dart';
import '../../model/ilaclar.dart';
import '../../model/ilceler.dart';
import '../../model/kaynaklar.dart';
import '../../model/kaynakturleri.dart';
import '../../model/usermodel.dart';

import '../../model/uygulamaalanlari.dart';
import '../../model/uygulamatanim.dart';
import '../../model/yontemler.dart';
import 'package:flutter/material.dart';

class Pos {
  static bool alanlar = false;
  static bool ekipman = false;
  static bool hedefZararli = false;
  static bool ilaclar = false;
  static bool ilce = false;
  static bool kaynakTurleri = false;
  static bool kaynaklar = false;
  static bool yontem = false;
  static bool uygulamaTanim = false;
  static bool mahalle = false;
  static DateTime lastUpdate;
}

class SaveLocalView extends StatefulWidget {
  final UserModel user;
  const SaveLocalView({Key key, this.user}) : super(key: key);

  @override
  _SaveLocalViewState createState() => _SaveLocalViewState();
}

class _SaveLocalViewState extends State<SaveLocalView> {
  bool loading = true;
  String msg = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    saveData();
  }

  void setMsg(String msg) {
    if (mounted) {
      setState(() {
        this.msg = msg;
      });
    }
  }

  void saveData() async {
    try {
    
      if (Pos.lastUpdate == null) {
        Pos.lastUpdate = DateTime.now();
      } else {
        if (DateTime.now().difference(Pos.lastUpdate).inMinutes > 1) {
          Pos.alanlar = false;
          Pos.ekipman = false;
          Pos.hedefZararli = false;
          Pos.ilaclar = false;
          Pos.ilce = false;
          Pos.kaynakTurleri = false;
          Pos.kaynaklar = false;
          Pos.yontem = false;
          Pos.uygulamaTanim = false;
          Pos.mahalle = false;

          Pos.lastUpdate = DateTime.now();
        }
      }
      setMsg("Veriler kaydediliyor...");

      if (Pos.alanlar == false) {
        var a = await Alanlar.fromAPI(widget.user.token, "");
        var adb = new AlanlarDb();
        await adb.delete();
        for (var element in a) {
          await adb.insert(element as Alanlar);
        }
        Pos.alanlar = true;
        setMsg("Veriler kaydediliyor...");
      }

      if (Pos.ekipman == false) {
        var e = await Ekipman.fromAPI(widget.user.token, "");
        var edb = new EkipmanDb();
        await edb.delete();
        for (var element in e) {
          await edb.insert(element as Ekipman);
        }
        Pos.ekipman = true;
        setMsg("Veriler kaydediliyor...");
      }

      if (Pos.hedefZararli == false) {
        var hz = await HedefZararli.fromAPI(widget.user.token, "");
        var hzdb = new HedefZararliDb();
        await hzdb.delete();
        for (var element in hz) {
          await hzdb.insert(element as HedefZararli);
        }
        setMsg("Veriler kaydediliyor...");
        Pos.hedefZararli = true;
      }

      if (Pos.ilaclar == false) {
        var ilac = await Ilaclar.fromAPI(widget.user.token, "");
        var ilacdb = new IlaclarDb();
        await ilacdb.delete();
        for (var element in ilac) {
          await ilacdb.insert(element as Ilaclar);
        }
        setMsg("Veriler kaydediliyor...");
        Pos.ilaclar = true;
      }

      if (Pos.ilce == false) {
        var ilce = await Ilce.fromAPI(widget.user.token, "");
        var ilcedb = new IlceDb();
        await ilcedb.delete();
        for (var element in ilce) {
          await ilcedb.insert(element as Ilce);
        }
        setMsg("Veriler kaydediliyor...");
        Pos.ilce = true;
      }
      if (Pos.kaynakTurleri == false) {
        var kt = await KaynakTurleri.fromAPI(widget.user.token, "");
        var ktdb = new KaynakTurleriDb();
        await ktdb.delete();
        for (var element in kt) {
          await ktdb.insert(element as KaynakTurleri);
        }
        setMsg("Veriler kaydediliyor...");
        Pos.kaynakTurleri = true;
      }

      if (Pos.kaynaklar == false) {
        var k = await Kaynaklar.fromAPI(widget.user.token, "");
        var kdb = new KaynaklarDb();
        await kdb.delete();
        for (var element in k) {
          await kdb.insert(element as Kaynaklar);
        }
        setMsg("Veriler kaydediliyor...");
        Pos.kaynaklar = true;
      }

      if (Pos.yontem == false) {
        var ua = await Yontemler.fromAPI(widget.user.token, "");
        var uadb = new YontemlerDb();
        await uadb.delete();
        for (var element in ua) {
          uadb.insert(element as Yontemler);
        }
        setMsg("Veriler kaydediliyor...");
        Pos.yontem = true;
      }

      if (Pos.uygulamaTanim == false) {
        var uyTanim = await UygulamaTanim.fromAPI(widget.user.token);

        uyTanim.add(new UygulamaTanim(id: -1, uygulamaTanimi: "KAYNAK KAYDI"));
        var uydb = new UygulamaTanimDb();
        await uydb.delete();
        for (var element in uyTanim) {
          await uydb.insert(element);
        }
        setMsg("Veriler kaydediliyor...");
        Pos.uygulamaTanim = true;
      }

      if (Pos.mahalle == false) {
        var mahTanim = await MahalleModel.fromAPI(widget.user.token);
        var mahdb = new MahalleDb();
        await mahdb.delete();
        for (var element in mahTanim) {
          mahdb.insert(element);
        }
        setMsg("Veriler kaydediliyor...");
        Pos.mahalle = true;
      }

      msg = "Kayıt edildi";
    } catch (e) {
      msg = e.toString();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: loading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        msg,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(20),
                      width: double.infinity,
                      color: Colors.grey,
                      child: Card(
                        child: Column(
                          children: [
                            Text(
                              Pos.alanlar ? "Alanlar kayıt edildi" : "Alanlar kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.alanlar ? Colors.green : Colors.red,
                                fontSize: Pos.alanlar ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.ekipman ? "Ekipman kayıt edildi" : "Ekipman kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.ekipman ? Colors.green : Colors.red,
                                fontSize: Pos.ekipman ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.hedefZararli ? "Hedef Zararli kayıt edildi" : "Hedef Zararli kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.hedefZararli ? Colors.green : Colors.red,
                                fontSize: Pos.hedefZararli ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.ilaclar ? "İlaçlar kayıt edildi" : "İlaçlar kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.ilaclar ? Colors.green : Colors.red,
                                fontSize: Pos.ilaclar ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.ilce ? "İlçeler kayıt edildi" : "İlçeler kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.ilce ? Colors.green : Colors.red,
                                fontSize: Pos.ilce ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.kaynakTurleri ? "Kaynak Turleri kayıt edildi" : "Kaynak Turleri kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.kaynakTurleri ? Colors.green : Colors.red,
                                fontSize: Pos.kaynakTurleri ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.kaynaklar ? "Kaynaklar kayıt edildi" : "Kaynaklar kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.kaynaklar ? Colors.green : Colors.red,
                                fontSize: Pos.kaynaklar ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.yontem ? "Yöntemler kayıt edildi" : "Yöntemler kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.mahalle ? Colors.green : Colors.red,
                                fontSize: Pos.mahalle ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.uygulamaTanim ? "Uygulama kayıt edildi" : "Uygulama Tanımları kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.mahalle ? Colors.green : Colors.red,
                                fontSize: Pos.mahalle ? 20 : 15,
                              ),
                            ),
                            Text(
                              Pos.mahalle ? "Mahalleler kayıt edildi" : "Mahalleler kayıt edilmedi",
                              style: TextStyle(
                                color: Pos.mahalle ? Colors.green : Colors.red,
                                fontSize: Pos.mahalle ? 20 : 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(msg),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Geri"))
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
