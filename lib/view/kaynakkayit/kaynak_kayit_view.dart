import 'package:cilac/base/network_manager.dart';
import 'package:cilac/extansion/string_extansion.dart';
import 'package:cilac/localdb/hedef_zararli_db.dart';
import 'package:cilac/localdb/ilceler_db.dart';
import 'package:cilac/localdb/kaynak_turleri_db.dart';
import 'package:cilac/localdb/mahalle_db.dart';
import 'package:cilac/localdb/uygulama_tanim_db.dart';
import 'package:cilac/localdb/yontemler_db.dart';
import 'package:cilac/model/ekipler.dart';
import 'package:cilac/model/hedefzararli.dart';
import 'package:cilac/model/kaynak_donus_model.dart';
import 'package:cilac/model/kaynakturleri.dart';
import 'package:cilac/model/mahalle_model.dart';
import 'package:cilac/model/usermodel.dart';
import 'package:cilac/model/yontemler.dart';
import 'package:cilac/palette.dart';
import 'package:cilac/view/application/add_photo.dart';
import 'package:cilac/view/application/getloaciton.dart';
import 'package:cilac/view/application/selectedimage.dart';
import 'package:cilac/view/kaynakkayit/kaynak_kayit_state.dart';
import 'package:cilac/view/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class KaynakKayitView extends StatefulWidget {
  final UserModel user;
  final KaynakGelenModel model;
  const KaynakKayitView({Key key, this.user, this.model}) : super(key: key);

  @override
  KaynakKayitViewState createState() => KaynakKayitViewState();
}

class KaynakKayitViewState extends State<KaynakKayitView> {
  final TextEditingController ilceController = new TextEditingController();
  final TextEditingController kaynakTurController = new TextEditingController();
  final TextEditingController sorumluEkipController = new TextEditingController();
  final TextEditingController aciklamaController = new TextEditingController();
  final TextEditingController ekAciklamaController = new TextEditingController();
  final nameController = new TextEditingController(),
      metreKareController = new TextEditingController(),
      adresController = new TextEditingController(),
      zararliTurController = new TextEditingController(),
      durumController = new TextEditingController(text: "Kayıt"),
      uygulamaController = new TextEditingController(),
      mahalleController = new TextEditingController(),
      adresAciklamaController = new TextEditingController();

  final state = new KaynakKayitState();
  final formKey = GlobalKey<FormState>();
  Color resColor = kGreen;
  List<SelectedImageModel> selectedImage;
  String imageText = "Resim Seçiniz";
  String validator(String val) {
    if (val.isEmpty) return "Bu alan zorunludur";
    return null;
  }

  @override
  void initState() {
    super.initState();
    getMahalle();
    if (widget.model != null) {
      ilceController.text = widget.model.ilce;
      KaynakTurleriDb().getAllWithWhere("ID=${widget.model.pKaynakTurID}").then((value) {
        kaynakTurController.text = "${widget.model.pKaynakTurID}-${value.first.kaynakAdi}";
      });
      getSorumluEkip().then((value) {
        sorumluEkipController.text = "${widget.model.pKaynakTurID}-${value.first.ekipTanimi}";
      });
      state.uremeDurum.sink.add(widget.model.uremeDurumu);
      aciklamaController.text = widget.model.aciklama.split("-").first;
      uygulamaController.text = widget.model.aciklama.split("-")[1];
      adresController.text = widget.model.adres;
      mahalleController.text = widget.model.mahalle;
      ekAciklamaController.text = widget.model.ekAciklama;
      metreKareController.text = widget.model.metreKare.toString();
      state.cord.sink.add(widget.model.geoKonum.pointToLatLng);
      HedefZararliDb().getAllWithWhere("ID=${widget.model.pZararliID}").then((value) {
        zararliTurController.text = "${widget.model.pZararliID}-${value.first.zararliAdi}";
      });
    }
  }

  Future<void> setAdress(LatLng _cord) async {
    // google mapsten konumdan adres alma
    final coordinates = new Coordinates(_cord.latitude, _cord.longitude);
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    Address first = addresses.first;

    if (first.addressLine != null) {
      adresController.text = first.addressLine;
    }
    if (first.subAdminArea != null) {
      String ilce = first.subAdminArea.toLowerCase() == "ordu merkez" ? "ALTINORDU" : first.subAdminArea.toUpperCase();
      ilceController.text = ilce;
    }
  }

 // KAYNAGIN KONUMU ALMA
  Future<void> showMap(BuildContext context, KaynakKayitState state) async {
    FocusScope.of(context).requestFocus(new FocusNode());

    LatLng _cord = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => WillPopScope(
                  onWillPop: () async => false,
                  child: Scaffold(
                    body: GetLocation(cord: state.cord.valueOrNull, heigth: double.infinity),
                  ),
                )));
    // LatLng _cord = await showDialog(
    //     context: context,
    //     builder: (c) => Dialog(
    //           child: GetLocation(
    //             cord: state.cord.value,
    //           ),
    //         ));
    if (_cord != null) {
      state.cord.sink.add(_cord);
      // ALINAN Konuma GÖRE ADRESİ BULMA
      setAdress(_cord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kaynak Kaydı"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              CustomFormField(
                  labelText: "Uygulama*",
                  controller: uygulamaController,
                  validator: validator,
                  readOnly: true,
                  onTap: () {
                    showAciklamaList(context);
                    setState(() {});
                  }),
              CustomFormField(
                controller: adresController,
                labelText: "Şikayet Adresi*",
                readOnly: false,
                suffixIcon: Icons.map,
                suffixOnTap: () => showMap(context, state),
                validator: validator,
              ),
              CustomFormField(
                labelText: "İlce*",
                controller: ilceController,
                readOnly: true,
                onTap: () => showIlceBottomList(context),
                validator: validator,
              ),
              CustomFormField(
                labelText: "Mahalle*",
                controller: mahalleController,
                readOnly: true,
                onTap: () => showMahalleBottomSheet(context),
                validator: validator,
              ),
              // CustomFormField(
              //   labelText: "Zararli Tür*",
              //   controller: zararliTurController,
              //   readOnly: true,
              //   onTap: () => showZararliTurBottomList(context),
              //   validator: validator,
              // ),
              CustomFormField(
                labelText: "Kaynak Türü*",
                controller: kaynakTurController,
                readOnly: true,
                onTap: () => showKaynakTurBottomList(context),
                validator: validator,
              ),
              CustomFormField(
                labelText: "Ekip*",
                controller: sorumluEkipController,
                readOnly: true,
                onTap: () => showSorumluEkipBottomList(context),
                validator: validator,
              ),
              CustomFormField(
                labelText: "Alan Büyüklüğü ( metre kare )*",
                controller: metreKareController,
                type: TextInputType.number,
                validator: validator,
                formatter: [FilteringTextInputFormatter.allow(new RegExp("[0-9]"))],
              ),
              StreamBuilder<bool>(
                  stream: state.uremeDurum,
                  initialData: false,
                  builder: (context, snapshot) {
                    return SwitchListTile(
                        title: Text("Üreme Durumu - ${snapshot.data ? 'Aktif' : 'Pasif'}"),
                        value: snapshot.data,
                        onChanged: (val) => state.uremeDurum.sink.add(val));
                  }),
              // if (uygulamaController.text == "KARASİNEK KAYNAĞI")
              CustomFormField(
                labelText: "Yöntem",
                controller: ekAciklamaController,
                readOnly: true,
                onTap: () => showYontemList(context),
                // validator: validator,
              ),
              CustomFormField(
                labelText: "Acıklama",
                controller: aciklamaController,
                maxLines: 3,
              ),
              if (widget.model == null) buildImagePicker(context),
              StreamBuilder<bool>(
                  stream: state.loading,
                  initialData: false,
                  builder: (context, snap) {
                    if (snap.data) {
                      return const SizedBox(width: 30, height: 30, child: CircularProgressIndicator.adaptive());
                    }
                    return ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            state.save(this, setState);
                          }
                        },
                        child: const Text("Kaydet"));
                  }),
              StreamBuilder<String>(
                stream: state.message,
                builder: (c, snap) {
                  if (snap.hasError) {
                    return Text(
                      snap.error,
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  if (snap.hasData) {
                    if (snap.data.isEmpty) return const SizedBox();
                    return Text(
                      snap.data,
                      style: const TextStyle(color: Colors.green),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List> getMahalle() async {
    if (ilceController.text.isEmpty) {
      throw ("Önce ilçe secinizi");
    }
    var res = (await MahalleDb().getAll());
    return Future.value(res.where((element) => element.ilceAdi == ilceController.text).toList());
  }

  Future<void> showMahalleBottomSheet(context) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(5),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tamam",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                FutureBuilder<List>(
                  future: getMahalle(),
                  builder: (context, snap) {
                    return Container(
                        padding: const EdgeInsets.all(8),
                        height: 200,
                        alignment: Alignment.center,
                        child: snap.hasError
                            ? Text(
                                snap.error.toString(),
                                style: const TextStyle(color: Colors.red),
                              )
                            : snap.hasData
                                ? CupertinoPicker(
                                    onSelectedItemChanged: (index) {
                                      mahalleController.text = snap.data[index].mahalleAdi;
                                    },
                                    scrollController: FixedExtentScrollController(
                                        initialItem: snap.data
                                            .indexWhere((element) => element.mahalleAdi == mahalleController.text)),
                                    itemExtent: 35,
                                    looping: false,
                                    children: List.generate(snap.data.length, (index) {
                                      return Text(
                                        snap.data[index].mahalleAdi,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline5,
                                      );
                                    }))
                                : const CircularProgressIndicator());
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<List> getIlceler() async {
    List ilceler = (await new IlceDb().getAll()).where((element) => element.pilID == 366).toList();

    return Future.value(ilceler);
  }

  Future<void> showIlceBottomList(context) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(5),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tamam",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                FutureBuilder<List>(
                  future: getIlceler(),
                  builder: (context, snap) {
                    return Container(
                        padding: const EdgeInsets.all(8),
                        height: 200,
                        alignment: Alignment.center,
                        child: snap.hasError
                            ? Text(
                                snap.error,
                                style: const TextStyle(color: Colors.red),
                              )
                            : snap.hasData
                                ? CupertinoPicker(
                                    onSelectedItemChanged: (index) {
                                      ilceController.text = snap.data[index].ilceAdi;
                                    },
                                    scrollController: FixedExtentScrollController(
                                        initialItem:
                                            snap.data.indexWhere((element) => element.ilceAdi == ilceController.text)),
                                    itemExtent: 35,
                                    looping: false,
                                    children: List.generate(snap.data.length, (index) {
                                      return Text(
                                        snap.data[index].ilceAdi,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline5,
                                      );
                                    }))
                                : const CircularProgressIndicator());
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<List<HedefZararli>> getZararliTur() async {
    List<HedefZararli> ilceler = (await new HedefZararliDb().getAll()).toList();

    return Future.value(ilceler);
  }

  Future<void> showZararliTurBottomList(context) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(5),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tamam",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                FutureBuilder<List<HedefZararli>>(
                  future: getZararliTur(),
                  builder: (context, snap) {
                    return Container(
                        padding: const EdgeInsets.all(8),
                        height: 200,
                        alignment: Alignment.center,
                        child: snap.hasError
                            ? Text(
                                snap.error,
                                style: const TextStyle(color: Colors.red),
                              )
                            : snap.hasData
                                ? CupertinoPicker(
                                    onSelectedItemChanged: (index) {
                                      zararliTurController.text =
                                          snap.data[index].id.toString() + "-" + snap.data[index].zararliAdi;
                                    },
                                    scrollController: FixedExtentScrollController(
                                        initialItem: snap.data.indexWhere((element) =>
                                            element.id.toString() + "-" + element.zararliAdi ==
                                            zararliTurController.text)),
                                    itemExtent: 35,
                                    looping: false,
                                    children: List.generate(snap.data.length, (index) {
                                      return Text(
                                        snap.data[index].id.toString() + "-" + snap.data[index].zararliAdi,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline5,
                                      );
                                    }))
                                : const CircularProgressIndicator());
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<List<KaynakTurleri>> getKaynakTur() async {
    List<KaynakTurleri> res = (await new KaynakTurleriDb().getAll()).toList();

    return Future.value(res);
  }

  Future<void> showKaynakTurBottomList(context) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(5),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tamam",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                FutureBuilder<List<KaynakTurleri>>(
                  future: getKaynakTur(),
                  builder: (context, snap) {
                    return Container(
                        padding: const EdgeInsets.all(8),
                        height: 200,
                        alignment: Alignment.center,
                        child: snap.hasError
                            ? Text(
                                snap.error,
                                style: const TextStyle(color: Colors.red),
                              )
                            : snap.hasData
                                ? CupertinoPicker(
                                    onSelectedItemChanged: (index) {
                                      kaynakTurController.text =
                                          snap.data[index].id.toString() + "-" + snap.data[index].kaynakAdi;
                                    },
                                    scrollController: FixedExtentScrollController(
                                        initialItem: snap.data.indexWhere((element) =>
                                            element.id.toString() + "-" + element.kaynakAdi ==
                                            kaynakTurController.text)),
                                    itemExtent: 35,
                                    looping: false,
                                    children: List.generate(snap.data.length, (index) {
                                      return Text(
                                        snap.data[index].id.toString() + "-" + snap.data[index].kaynakAdi,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline5,
                                      );
                                    }))
                                : const CircularProgressIndicator());
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<List<Ekipler>> getSorumluEkip() async {
    List res = await NetworkManager.instance
        .httpPost(path: "api/lst/nwekiplerlst", data: {"data": " "}, token: widget.user.token, model: new Ekipler());

    return Future.value(res.map((e) => e as Ekipler).toList());
  }

  Future<void> showSorumluEkipBottomList(context) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(5),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tamam",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                FutureBuilder<List<Ekipler>>(
                  future: getSorumluEkip(),
                  builder: (context, snap) {
                    return Container(
                        padding: const EdgeInsets.all(8),
                        height: 200,
                        alignment: Alignment.center,
                        child: snap.hasError
                            ? Text(
                                snap.error,
                                style: const TextStyle(color: Colors.red),
                              )
                            : snap.hasData
                                ? CupertinoPicker(
                                    onSelectedItemChanged: (index) {
                                      sorumluEkipController.text =
                                          snap.data[index].id.toString() + "- " + snap.data[index].ekipTanimi;
                                    },
                                    scrollController: FixedExtentScrollController(
                                        initialItem: snap.data.indexWhere((element) =>
                                            element.id.toString() + "- " + element.ekipTanimi ==
                                            sorumluEkipController.text)),
                                    itemExtent: 35,
                                    looping: false,
                                    children: List.generate(snap.data.length, (index) {
                                      return Text(
                                        snap.data[index].ekipTanimi,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline6,
                                      );
                                    }))
                                : const CircularProgressIndicator.adaptive());
                  },
                ),
              ],
            ),
          );
        });
  }

  getSqlData(data) => " ID in (${data.replaceAll(";", ",")})";

  Future<List<Yontemler>> getYontem() async {
    // List list = await new UygulamaTanimDb().getAll();
    // List<UygulamaTanim> tanimList = list.map((e) => e as UygulamaTanim).toList();

    // List<UygulamaTanim> tanim =
    //     tanimList.where((element) => element.uygulamaTanimi == uygulamaController.text).toList();
    // List<Yontemler> res;

    // if (tanim.isNotEmpty) {
    //   res = await YontemlerDb().getAllWithWhere(getSqlData(tanim.first.yontemler));
    // } else {
    //   res = (await new YontemlerDb().getAll()).toList();
    // }

    return Future.value((await new YontemlerDb().getAll()).toList());
  }

  Future<void> showYontemList(context) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(5),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tamam",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                FutureBuilder<List<Yontemler>>(
                  future: getYontem(),
                  builder: (context, snap) {
                    return Container(
                        padding: const EdgeInsets.all(8),
                        height: 200,
                        alignment: Alignment.center,
                        child: snap.hasError
                            ? Text(
                                snap.error,
                                style: const TextStyle(color: Colors.red),
                              )
                            : snap.hasData
                                ? CupertinoPicker(
                                    onSelectedItemChanged: (index) {
                                      ekAciklamaController.text = snap.data[index].yontemAdi;
                                    },
                                    scrollController: FixedExtentScrollController(
                                        initialItem: snap.data
                                            .indexWhere((element) => element.yontemAdi == ekAciklamaController.text)),
                                    itemExtent: 35,
                                    looping: false,
                                    children: List.generate(snap.data.length, (index) {
                                      return Text(
                                        snap.data[index].yontemAdi,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline6,
                                      );
                                    }))
                                : const CircularProgressIndicator.adaptive());
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<List<String>> getAciklama() async {
    List<String> list = (await new UygulamaTanimDb().getAll())
        .toList()
        .where((element) => element.uygulamaTanimi.contains("KAYNAĞI"))
        .map((e) => e.uygulamaTanimi)
        .toList();
    return Future.value(list);
  }

  Future<void> showAciklamaList(context) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(5),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ignore: deprecated_member_use
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tamam",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                FutureBuilder<List<String>>(
                  future: getAciklama(),
                  builder: (context, snap) {
                    return Container(
                        padding: const EdgeInsets.all(8),
                        height: 200,
                        alignment: Alignment.center,
                        child: snap.hasError
                            ? Text(
                                snap.error,
                                style: const TextStyle(color: Colors.red),
                              )
                            : snap.hasData
                                ? CupertinoPicker(
                                    onSelectedItemChanged: (index) {
                                      if (snap.data[index] == "KARASİNEK KAYNAĞI") {
                                        zararliTurController.text = "5-KARASİNEK";
                                      }
                                      if (snap.data[index] == "SİVRİSİNEK KAYNAĞI") {
                                        zararliTurController.text = "10-SİVRİSİNEK";
                                      }
                                      uygulamaController.text = snap.data[index];
                                    },
                                    scrollController: FixedExtentScrollController(
                                        initialItem:
                                            snap.data.indexWhere((element) => element == uygulamaController.text)),
                                    itemExtent: 35,
                                    looping: false,
                                    children: List.generate(snap.data.length, (index) {
                                      return Text(
                                        snap.data[index],
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.headline6,
                                      );
                                    }))
                                : const CircularProgressIndicator.adaptive());
                  },
                ),
              ],
            ),
          );
        });
  }

  Padding buildImagePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey,
              width: Theme.of(context).brightness == Brightness.dark ? 0.5 : 1,
            ),
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () async {
              var images = await Navigator.push(
                  context, MaterialPageRoute(builder: (c) => SelectPhotoView(selectedImage: selectedImage)));
              List<SelectedImageModel> a = images.where((element) => element.imagePath != null).toList();
              setState(() {
                resColor = a.isNotEmpty ? Colors.green : Colors.red;
                selectedImage = images;
                imageText = images.length > 1 ? "Seçilen resim sayısı (${a.length})" : "Resim Seçiniz";
              });
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    imageText,
                    style: TextStyle(color: resColor),
                  ),
                  IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: resColor,
                      ),
                      onPressed: null)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
