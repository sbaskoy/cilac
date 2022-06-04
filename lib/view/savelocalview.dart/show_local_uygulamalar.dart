import '../../localdb/uygulama_kayit_db.dart';
import '../../localdb/uygulama_konumlar_db.dart';
import '../../model/usermodel.dart';
import '../../model/uygulama_konum.dart';
import '../../model/uygulamakayit.dart';
import 'show_map_route.dart';
import 'package:flutter/material.dart';

class ShowLocal extends StatefulWidget {
  final UserModel user;
  const ShowLocal({Key key, this.user}) : super(key: key);

  @override
  _ShowLocalState createState() => _ShowLocalState();
}

class _ShowLocalState extends State<ShowLocal> {
  List<UygulamaKayit> list;
  List<UygulamaKonumlar> uygulamaKonumlar;
  bool isSavingUy = false;
  bool isSavingKo = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    // KAUIT EDİLEMEYEN UYGULAMALIR LOCALDEN ÇEKER
    list = await new UygulamaKayitDb().getAll();
    uygulamaKonumlar = await new UygulamaKonumlarDb().getAll();
    setState(() {});
  }

  void saveAllUygulama() async {
    setState(() {
      isSavingUy = true;
    });
    // bu uygulamaları apiye yollar
    for (var i in list) {
      await i.postAPI(widget.user.token);
      await UygulamaKayitDb().deleteWithID(i.id);
    }
    setState(() {
      isSavingUy = false;
    });
    getData();
  }

  void saveAllKonum() async {
    // kayıt edilemeyen tüm gezici uygulama konumları kayıt eder
    setState(() {
      isSavingKo = true;
    });
    for (var i in uygulamaKonumlar) {
      await i.postAPI(widget.user.token);
      await UygulamaKayitDb().deleteWithID(i.pUygulamaID);
    }
    setState(() {
      isSavingKo = false;
    });
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kaydedilmeyen Uygulamalar"),
      ),
      body: Center(
          child: Column(children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Kaydedilmeyen Uygulamalar",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(onPressed: saveAllUygulama, child: const Text("Tümünü Kaydet")),
        Expanded(
          child: SingleChildScrollView(
            child: isSavingUy
                ? const CircularProgressIndicator()
                : list == null
                    ? const CircularProgressIndicator()
                    : list.isEmpty
                        ? const Text("Kaydedilmemiş uygulamanız yok")
                        : Column(
                            children: List.generate(list.length, (index) {
                              return Card(
                                child: ListTile(
                                    title: Text(list[index].uygulamaTanimi),
                                    subtitle: Text(list[index].aciklama),
                                    trailing: IconButton(
                                        onPressed: () {
                                          list[index].postAPI(widget.user.token).then((value) {
                                            ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                                                content:
                                                    Text("${list[index].uygulamaTanimi} uygulaması kayıt edildi")));
                                            UygulamaKayitDb().deleteWithID(list[index].id);
                                            getData();
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.send,
                                          color: Colors.green,
                                        ))),
                              );
                            }),
                          ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Kaydedilmeyen Konumlar",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(onPressed: saveAllKonum, child: const Text("Tümünü Konumları Kaydet")),
        Expanded(
          child: isSavingKo
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: uygulamaKonumlar == null
                      ? const CircularProgressIndicator()
                      : uygulamaKonumlar.isEmpty
                          ? const Text("Kaydedilmemiş uygulamanız yok")
                          : Column(
                              children: List.generate(uygulamaKonumlar.length, (index) {
                                return Card(
                                  child: ListTile(
                                      title: Text(uygulamaKonumlar[index].pUygulamaID.toString()),
                                      leading: IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (c) => ShowMap(
                                                        route: uygulamaKonumlar[index],
                                                      )));
                                        },
                                        icon: const Icon(Icons.map),
                                      ),
                                      trailing: IconButton(
                                          onPressed: () {
                                            uygulamaKonumlar[index].postAPI(widget.user.token).then((value) {
                                              if (value.durumKodu == 0) {
                                                ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                                                    content: Text(
                                                        "${uygulamaKonumlar[index].pUygulamaID} uygulaması kayıt edildi")));
                                                new UygulamaKonumlarDb()
                                                    .deleteWithID(uygulamaKonumlar[index].pUygulamaID);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                                                    content: Text(
                                                  "${uygulamaKonumlar[index].pUygulamaID} bir hata oluştu.${value.durumMesaj}",
                                                  style: const TextStyle(color: Colors.red),
                                                )));
                                                //new UygulamaKonumlarDb().deleteWithID(uygulamaKonumlar[index].pUygulamaID);
                                              }
                                              getData();
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.send,
                                            color: Colors.green,
                                          ))),
                                );
                              }),
                            ),
                ),
        ),
      ])),
    );
  }
}
