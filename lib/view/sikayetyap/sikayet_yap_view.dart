import 'package:cilac/base/network_manager.dart';
import 'package:cilac/localdb/ilceler_db.dart';
import 'package:cilac/model/ekipler.dart';
import 'package:cilac/model/sikayet_kaydi.dart';
import 'package:cilac/model/sikayet_turu.dart';
import 'package:cilac/model/usermodel.dart';
import 'package:cilac/view/application/getloaciton.dart';

import 'package:cilac/view/widgets/custom_text_field.dart';
import 'package:cilac/view/widgets/phone_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class _State {
  final loading = new BehaviorSubject<bool>.seeded(false);
  final message = new BehaviorSubject<String>.seeded("");
  final cord = new BehaviorSubject<LatLng>();
  final sikayetTur = new BehaviorSubject<List<SikayetTuru>>();

  Future<List<SikayetTuru>> getTur(SikayetYapView view) async {
    if (this.sikayetTur.value == null) {
      List res = await NetworkManager.instance.httpPost(
          path: "api/lst/sikayetturlst", data: {"data": ""}, token: view.user.token, model: new SikayetTuru());
      this.sikayetTur.sink.add(res.map((e) => e as SikayetTuru).toList());
    }

    return Future.value(this.sikayetTur.value);
  }

  Future<void> sendData(SikayetYapView view) async {
    try {
      this.loading.sink.add(true);
      SikayetKaydi kayit = new SikayetKaydi(
          id: -1,
          tarih: DateTime.now().toIso8601String(),
          pPersonID: view.user.id,
          adiSoyadi: view.nameController.text,
          cepTel: view.phoneController.text,
          sikayetAdresi: view.adresController.text,
          adresAciklama: view.adresAciklamaController.text,
          il: "ORDU",
          ilce: view.ilceController.text,
          konusu: view.konuController.text,
          pSorumluID: int.parse(view.sorumluController.text.split("-")[0]),
          pAtananEkipID: int.parse(view.sorumluEkipController.text.split("-")[0]),
          durumu: view.durumController.text,
          bDurum: 1,
          geoKonum: "POINT(${cord.value.latitude} ${cord.value.longitude})",
          turu: view.turController.text.substring(0, view.turController.text.length - 1));
      var res = await NetworkManager.instance.httpPostRes(
        path: "api/act/Sikayetkayit",
        data: kayit.toJson(),
        token: view.user.token,
      );
      if (res.statusCode == 200) {
        this.message.sink.add("Şikayet kaydı başarı ile yapıldı");
      } else {
        this.message.sink.addError("Şikayet kaydı yapılırken bir hata oluştu");
      }

      this.loading.sink.add(false);
    } catch (e) {
      this.loading.sink.add(false);
      this.message.sink.addError(e.toString());
    }
  }

  dispose() {
    cord.close();
    message.close();
    loading.close();
    sikayetTur.close();
  }
}

class SikayetYapView extends StatelessWidget {
  final UserModel user;
  SikayetYapView({Key key, this.user}) : super(key: key);
  final TextEditingController ilceController = new TextEditingController();
  final TextEditingController sorumluController = new TextEditingController();
  final TextEditingController sorumluEkipController = new TextEditingController();
  final TextEditingController konuController = new TextEditingController();
  final nameController = new TextEditingController(),
      phoneController = new TextEditingController(),
      adresController = new TextEditingController(),
      turController = new TextEditingController(),
      durumController = new TextEditingController(text: "Kayıt"),
      adresAciklamaController = new TextEditingController();
  final formKey = new GlobalKey<FormState>();
  final state = new _State();
  String validator(String val) {
    if (val.isEmpty) return "Bu alan zorunludur";
    return null;
  }

  Future<void> setAdress(LatLng _cord) async {
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

  Future<void> showMap(BuildContext context, _State state) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    LatLng _cord = await showDialog(
        context: context,
        builder: (c) => Dialog(
              child: GetLocation(
                cord: state.cord.value,
              ),
            ));
    if (_cord != null) {
      state.cord.sink.add(_cord);
      setAdress(_cord);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şikayet Yap"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomFormField(
                  controller: nameController,
                  hintText: "Şikayeti Yapan",
                  validator: validator,
                ),
                CustomFormField(
                  controller: phoneController,
                  hintText: "Cep Telefonu",
                  type: TextInputType.number,
                  formatter: [new PhoneFormatter(), FilteringTextInputFormatter.allow(new RegExp("[0-9 ()]"))],
                  validator: validator,
                ),
                CustomFormField(
                  controller: adresController,
                  hintText: "Şikayet Adresi",
                  readOnly: true,
                  suffixIcon: Icons.map,
                  onTap: () => showMap(context, state),
                  validator: validator,
                ),
                CustomFormField(
                  controller: adresAciklamaController,
                  hintText: "Adres Açıklama",
                ),
                CustomFormField(
                  hintText: "İlce",
                  controller: ilceController,
                  readOnly: true,
                  onTap: () => showIlceBottomList(context),
                  validator: validator,
                ),
                CustomFormField(
                  hintText: "Sorumlu",
                  controller: sorumluController,
                  readOnly: true,
                  onTap: () => showSorumluBottomList(context),
                  validator: validator,
                ),
                CustomFormField(
                  hintText: "Ekip",
                  controller: sorumluEkipController,
                  readOnly: true,
                  onTap: () => showSorumluEkipBottomList(context),
                  validator: validator,
                ),
                CustomFormField(
                  hintText: "Konusu",
                  controller: konuController,
                  maxLines: 3,
                ),
                CustomFormField(
                  hintText: "Türü",
                  controller: turController,
                  validator: validator,
                  readOnly: true,
                  onTap: () => showTurBottomSheet(context, state),
                ),
                CustomFormField(
                  hintText: "Durumu",
                  controller: durumController,
                  readOnly: true,
                  onTap: () => showDurumBottomList(context),
                ),
                StreamBuilder<bool>(
                    stream: state.loading,
                    initialData: false,
                    builder: (context, snap) {
                      if (snap.data) {
                        return const SizedBox(width: 30, height: 30, child:  CircularProgressIndicator.adaptive());
                      }
                      return ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              state.sendData(this);
                            }
                          },
                          child: const Text("Şikayeti Kaydet"));
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
      ),
    );
  }

  Future<List> getIlceler() async {
    List ilceler = (await new IlceDb().getAll()).where((element) => element.pilID == 366).toList();

    return Future.value(ilceler);
  }

  Future<List<Ekipler>> getSorumlu() async {
    List res = await NetworkManager.instance
        .httpPost(path: "api/lst/nwekiplerlst", data: {"data": ""}, token: user.token, model: new Ekipler());

    return Future.value(res.map((e) => e as Ekipler).toList());
  }

  Future<List<Ekipler>> getSorumluEkip() async {
    if (sorumluController.text.isEmpty) {
      throw ("Önce ekip sorumlusu seçmelisiniz");
    }
    var pSorumluID = sorumluController.text.split("-").first;
    List res = await NetworkManager.instance.httpPost(
        path: "api/lst/nwekiplerlst",
        data: {"data": " and pSorumluID=$pSorumluID"},
        token: user.token,
        model: new Ekipler());

    return Future.value(res.map((e) => e as Ekipler).toList());
  }

  void showTurBottomSheet(BuildContext context, _State state) async {
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
                StreamBuilder<List<SikayetTuru>>(
                    stream: state.sikayetTur,
                    builder: (context, snapshot) {
                      return FutureBuilder<List<SikayetTuru>>(
                        future: state.getTur(this),
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
                                      ? SingleChildScrollView(
                                          child: Column(
                                            children: List.generate(snap.data.length, (index) {
                                              return CheckboxListTile(
                                                  title: Text(snap.data[index].sikayetTuru),
                                                  value: snap.data[index].selected,
                                                  onChanged: (val) {
                                                    var lst = state.sikayetTur.value;
                                                    lst[index].selected = val;
                                                    turController.text += snap.data[index].sikayetTuru + ";";
                                                    state.sikayetTur.sink.add(lst);
                                                  });
                                            }),
                                          ),
                                        )
                                      : const CircularProgressIndicator.adaptive());
                        },
                      );
                    }),
              ],
            ),
          );
        });
  }

  Future<void> showDurumBottomList(context) async {
    List<String> list = [
      "Kayıt",
      "Beklemede",
      "Tekrar",
      "Uygulama",
      "İptal",
      "Diğer",
    ];
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
                Container(
                    padding: const EdgeInsets.all(8),
                    height: 200,
                    alignment: Alignment.center,
                    child: CupertinoPicker(
                        onSelectedItemChanged: (index) {
                          durumController.text = list[index];
                        },
                        scrollController: FixedExtentScrollController(
                            initialItem: list.indexWhere((element) => element == sorumluEkipController.text)),
                        itemExtent: 35,
                        looping: false,
                        children: List.generate(list.length, (index) {
                          return Text(
                            list[index],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline6,
                          );
                        })))
              ],
            ),
          );
        });
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

  Future<void> showSorumluBottomList(context) async {
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
                  future: getSorumlu(),
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
                                      sorumluController.text = snap.data[index].pSorumluID.toString() +
                                          "- " +
                                          snap.data[index].ekipSorumlusu +
                                          " - " +
                                          snap.data[index].ekipTanimi;
                                    },
                                    scrollController: FixedExtentScrollController(
                                        initialItem: snap.data.indexWhere((element) =>
                                            element.pSorumluID.toString() +
                                                "- " +
                                                element.ekipSorumlusu +
                                                " - " +
                                                element.ekipTanimi ==
                                            sorumluController.text)),
                                    itemExtent: 35,
                                    looping: false,
                                    children: List.generate(snap.data.length, (index) {
                                      return Text(
                                        snap.data[index].pSorumluID.toString() +
                                            "- " +
                                            snap.data[index].ekipSorumlusu +
                                            " - " +
                                            snap.data[index].ekipTanimi,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.caption.copyWith(fontSize: 18),
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
}
