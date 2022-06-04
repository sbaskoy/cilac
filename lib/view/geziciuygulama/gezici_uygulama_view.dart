import 'dart:convert';
import 'dart:io';

import 'package:cilac/view/savelocalview.dart/save_local_view.dart';
import 'package:flutter/gestures.dart';

import '../../localdb/alanlar_db.dart';
import '../../localdb/ekipman_db.dart';
import '../../localdb/hedef_zararli_db.dart';
import '../../localdb/ilaclar_db.dart';
import '../../localdb/kaynak_turleri_db.dart';
import '../../localdb/uygulama_alanlari_db.dart';
import '../../localdb/uygulama_tanim_db.dart';
import '../../localdb/yontemler_db.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../base/base_state.dart';
import '../../global/extansion.dart';
import '../../global/global_function.dart';

import '../../model/selecteditem.dart';
import '../../model/usermodel.dart';
import '../../model/uygulamakayit.dart';
import '../../model/uygulamatanim.dart';

import '../../palette.dart';
import '../application/add_photo.dart';
import '../application/select_view.dart';
import '../application/selectedimage.dart';
import '../functions/global_functions.dart';
import 'get_all_cordinates.dart';
import 'package:url_launcher/url_launcher.dart';

class GeziciUgulamaView extends StatefulWidget {
  final UserModel user;
  final LatLng cord;
  final int sikayetID;

  const GeziciUgulamaView({Key key, this.user, this.cord, this.sikayetID}) : super(key: key);
  @override
  _GeziciUgulamaViewState createState() => _GeziciUgulamaViewState();
}

class _GeziciUgulamaViewState extends BaseState<GeziciUgulamaView> {
  TextEditingController uygulamaTanimController = new TextEditingController();
  TextEditingController kaynakTurController = new TextEditingController(),
      ilceController = new TextEditingController(),
      aciklamaController = new TextEditingController(),
      ilacController = new TextEditingController(),
      ekipmanController = new TextEditingController(),
      yontemController = new TextEditingController(),
      adresController = new TextEditingController(),
      alanController = new TextEditingController(),
      uygAlnaController = new TextEditingController(),
      dateStartController = new TextEditingController(),
      dateFinishController = new TextEditingController(),
      zararliController = new TextEditingController();
  UygulamaTanim selectedModel;

  List<SelectedItem> selectedKaynakTur,
      selectedIlac,
      selectedEkipman,
      selectedYontem,
      selectedAlan,
      selectedUygAlan,
      selectedHedefZarali;
  Color color = Colors.red;
  Color resColor = kGreen;
  List<SelectedImageModel> selectedImage;
  String imageText = "Resim Seçiniz";
  bool isLoadingData = false;
  bool isNotSavedDb = false;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkPermission();
    });
    getData();
  }

  void _launchURL() async => await launch("http://www.oryaz.com.tr/gizlilik.aspx");

  Future<void> checkPermission() async {
    var a = await Permission.locationAlways.status;
    if (a != PermissionStatus.granted) {
      await showModalBottomSheet(
          context: context,
          // isDismissible: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.location_pin,
                      size: 35,
                      color: Colors.blue,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      "CILAC, ilaçlama yaparken, ilaçlama yaptıgınız güzergahınız belirlemek için konum verilerinizi toplar." " Yaptıgınız ilaçlamayı bitirdiginiz zaman arka planda konum alma devam etmez.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        const TextSpan(
                            text:
                                "CILAC, uygulama kapalıyken veya kullanılmadığında bile Gezici Uygulama özelliğini etkinleştirmek için konum verilerini toplar. ",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        TextSpan(
                            recognizer: TapGestureRecognizer()..onTap = _launchURL,
                            text: " Gizlilik politikamız",
                            style: const TextStyle(color: Colors.blue)),
                      ])),
                const  Expanded(
                      child:  Image(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/konum.jpg"),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        TextButton(
                          child: const Text('Reddet'),
                          onPressed: () {
                            Navigator.pop(context);
                            Permission.locationAlways.status.then((value) {
                              if (value != PermissionStatus.granted) {
                                Navigator.pop(context);
                              }
                            });
                          },
                        ),
                        const Spacer(),
                        ElevatedButton(
                          child: const Text('İzin Ver'),
                          onPressed: () async {
                            try {
                              await Permission.locationAlways.request();
                              Navigator.of(context).pop();
                            } catch (_) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
    }
  }

  void getData() async {
    try {
      isNotSavedDb = false;
      isLoadingData = true;
      setState(() {});
      //checkPermission();
      List<UygulamaTanim> _list = await UygulamaTanimDb().getAll();
      if (_list == null) {
        setState(() {
          isNotSavedDb = true;
          isLoadingData = false;
        });
        return;
      }
      if (_list.isEmpty) {
        setState(() {
          isNotSavedDb = true;
          isLoadingData = false;
        });
        return;
      }
      UygulamaTanim model =
          _list.firstWhere((element) => element.uygulamaTanimi.toLowerCase().contains("sivrisinek ergin"));
      uygulamaTanimController.text = model.uygulamaTanimi;
      setState(() {
        selectedModel = model;
        isLoadingData = false;
      });
      final coordinates = new Coordinates(widget.cord.latitude, widget.cord.longitude);
      List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      Address first = addresses.first;
      if (first.addressLine != null) {
        adresController.text = first.addressLine;
      }
      if (first.subAdminArea != null) {
        String ilce =
            first.subAdminArea.toLowerCase() == "ordu merkez" ? "ALTINORDU" : first.subAdminArea.toUpperCase();
        ilceController.text = ilce;
      }
    } catch (e) {
      setState(() {
        isNotSavedDb = true;
        isLoadingData = false;
      });
    }
  }

  void save() async {
    try {
      if (formKey.currentState.validate()) {
        List<String> resim = [];
        if (selectedImage == null) {
          setState(() {
            resColor = Colors.red;
            imageText = "En az bir resim şeçiniz";
          });
          return;
        }
        setState(() => isLoadingData = true);
        for (var i in selectedImage.where((element) => element.imagePath != null).toList()) {
          resim.add(base64Encode(File(i.imagePath).readAsBytesSync()));
        }
        UygulamaKayit kayit = new UygulamaKayit(
            uygulamaTanimi: uygulamaTanimController.text,
            kaynakTurleri: selectedKaynakTur == null
                ? ""
                : selectedKaynakTur.where((e) => e.selected).map((e) => e.id).toString().del(),
            ilaclar:
                selectedIlac == null ? "" : selectedIlac.where((e) => e.selected).map((e) => e.id).toString().del(),
            ekipmanlar: selectedEkipman == null
                ? ""
                : selectedEkipman.where((e) => e.selected).map((e) => e.id).toString().del(),
            yontemler:
                selectedYontem == null ? "" : selectedYontem.where((e) => e.selected).map((e) => e.id).toString().del(),
            alanlar:
                selectedAlan == null ? "" : selectedAlan.where((e) => e.selected).map((e) => e.id).toString().del(),
            hedefZararli: selectedHedefZarali == null
                ? ""
                : selectedHedefZarali.where((e) => e.selected).map((e) => e.id).toString().del(),
            konumlar: "POINT (${widget.cord.latitude} ${widget.cord.longitude} )",
            resimler: resim,
            mucadeleSekli: "",
            id: -1,
            pUygulamaTanimID: selectedModel.id,
            pEkipID: 0,
            adres: adresController.text,
            konumID: "",
            baslangicTarihi: DateTime.now().toString().replaceAll(" ", "T"),
            bitisTarihi: DateTime.now().add(const Duration(hours: 1)).toString().replaceAll(" ", "T"),
            il: "ORDU",
            ilce: ilceController.text,
            kaynakDurumu: false,
            uremeDurumu: false,
            pKaynakID: -1,
            pSikayetID: widget.sikayetID ?? -1,
            aciklama: aciklamaController.text,
            pPersonID: widget.user.id);

        ReturnModel model = await kayit.postAPI(widget.user.token);
        //ReturnModel model = new ReturnModel(durumKodu: 0);
        setState(() => isLoadingData = false);
        if (model.durumKodu == 0) {
          await showAlertDialog(
              context,
              "Uygulamanız başarılı bir şekilde kayıt edildi.Uygulama sürekli konumuzu alarak uygulama yaptıgınıız rotayı takip edecek.",
              Icons.done,
              Colors.green, onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (c) => GetAllCordinates(
                          user: widget.user,
                          uygulama: model,
                          startPos: widget.cord,
                        )));
          }, text: "Başlat");
        } else if (model.durumKodu > 100) {
          await showAlertDialog(context, "Bir hata oluştu.Mesaj ${model.durumMesaj}", Icons.error, Colors.red);
        } else if (model.iD > 0 && model.durumKodu == 1) {
          await showAlertDialog(context, "Bilgiler kayıt edildi ama resimler edilemedi", Icons.done, Colors.amber);
        } else {
          await showAlertDialog(context, "Bilinmeyen bir hata oluştu", Icons.error, Colors.amber);
        }
      }
    } catch (e) {
      setState(() => isLoadingData = false);
      await showAlertDialog(context, "Bir hata oluştu.Hata $e", Icons.done, Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gezici Uygulama"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: isLoadingData
              ? const CircularProgressIndicator()
              : isNotSavedDb
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Uygulama Bulunamadı"),
                          TextButton(
                              onPressed: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SaveLocalView(
                                              user: widget.user,
                                            )));

                                getData();
                              },
                              child: const Text("Uygulama Tanımlarımı Güncelle"))
                        ],
                      ),
                    )
                  : Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: TextFormField(
                              readOnly: true,
                              controller: uygulamaTanimController,
                              validator: validator,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                                labelText: "Uygulama",
                                prefixIcon: const Icon(Icons.bookmark_sharp),
                              ),
                            ),
                          ),
                          buildColumn(context),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: adresController,
                              validator: validator,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                labelText: "Adres",
                              ),
                            ),
                          ),
                          buildImagePicker(context),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: aciklamaController,
                              validator: (val) {
                                return null;
                              },
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                labelText: "Açıklama",
                              ),
                            ),
                          ),
                          buildRowButton(size: getSize, text: "Kayıt Et ve Başlat", onPressed: save)
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  getSqlData(data) => " ID in (${data.replaceAll(";", ",")})";
  getControllertext(data) =>
      data.where((e) => e.selected == true).map((e) => e.adi).toString().replaceAll("(", "").replaceAll(")", "");

  Column buildColumn(BuildContext context) {
    return Column(
      children: [
        if (selectedModel == null ? false : selectedModel.alanlar.isNotEmpty)
          getTextField("Alan", alanController, () async {
            List alanlarlst = selectedAlan ?? await new AlanlarDb().getAllWithWhere(getSqlData(selectedModel.alanlar));
            var m = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (c) => Dialog(
                    child: SelectView(
                        title: "Alan Seç",
                        list: alanlarlst.map((e) => e.toJson()).toList(),
                        selectedItemList: selectedAlan)));
            setState(() => selectedAlan = m);
            alanController.text = selectedAlan.getCntText();
          }),
        if (selectedModel == null ? false : selectedModel.ekipmanlar.isNotEmpty)
          getTextField("Ekipman", ekipmanController, () async {
            List ekipmanlarlst =
                selectedEkipman ?? await EkipmanDb().getAllWithWhere(getSqlData(selectedModel.ekipmanlar));
            var m = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (c) => Dialog(
                      child: SelectView(
                        title: "Ekipman Seç",
                        list: ekipmanlarlst.getMap(),
                        selectedItemList: selectedEkipman,
                      ),
                    ));
            setState(() => selectedEkipman = m);
            ekipmanController.text = selectedEkipman.getCntText();
          }),
        if (selectedModel == null ? false : selectedModel.hedefZararli.isNotEmpty)
          getTextField("Hedef Zararli", zararliController, () async {
            List hedefZararlilst = selectedHedefZarali ??
                await new HedefZararliDb().getAllWithWhere(getSqlData(selectedModel.hedefZararli));
            var m = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (c) => Dialog(
                      child: SelectView(
                        title: "Zararli Tür Seç",
                        list: hedefZararlilst.getMap(),
                        selectedItemList: selectedHedefZarali,
                      ),
                    ));
            setState(() => selectedHedefZarali = m);
            zararliController.text = selectedHedefZarali.getCntText();
          }),
        if (selectedModel == null ? false : selectedModel.ilaclar.isNotEmpty)
          getTextField("İlaç", ilacController, () async {
            List ilaclarlst = selectedIlac ?? await new IlaclarDb().getAllWithWhere(getSqlData(selectedModel.ilaclar));

            var m = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (c) {
                  return Dialog(
                      child: SelectView(
                    title: "İlaç Seç",
                    list: ilaclarlst.getMap(),
                    selectedItemList: selectedIlac,
                  ));
                });
            setState(() => selectedIlac = m);
            ilacController.text = selectedIlac.getCntText();
          }),
        if (selectedModel == null ? false : selectedModel.yontemler.isNotEmpty)
          getTextField("Yöntem", yontemController, () async {
            List yontemlerlst =
                selectedYontem ?? await new YontemlerDb().getAllWithWhere(getSqlData(selectedModel.yontemler));
            var m = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (c) => Dialog(
                        child: SelectView(
                      title: "Yöntem Seç",
                      list: yontemlerlst.getMap(),
                      selectedItemList: selectedYontem,
                    )));
            setState(() => selectedYontem = m);
            yontemController.text = selectedYontem.getCntText();
          }),
        if (selectedModel == null ? false : selectedModel.kaynakTurleri.isNotEmpty)
          getTextField("Kaynak Türü", kaynakTurController, () async {
            List kaynakTurlerilst = selectedKaynakTur ??
                await new KaynakTurleriDb().getAllWithWhere(getSqlData(selectedModel.kaynakTurleri));
            var m = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (c) => Dialog(
                        child: SelectView(
                      title: "Kaynak Türü Seç",
                      list: kaynakTurlerilst.getMap(),
                      selectedItemList: selectedKaynakTur,
                    )));
            setState(() => selectedKaynakTur = m);
            kaynakTurController.text = selectedKaynakTur.getCntText();
          }),
        if (selectedModel == null ? false : selectedModel.uygulamaAlanlari.isNotEmpty)
          getTextField("Uygulama Alanı", alanController, () async {
            List alanlarlst = selectedAlan ??
                await new UygulamaAlanlariDb().getAllWithWhere(getSqlData(selectedModel.uygulamaAlanlari));
            var m = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (c) => Dialog(
                    child: SelectView(
                        title: "Uygulama Alanı Seç",
                        list: alanlarlst.map((e) => e.toJson()).toList(),
                        selectedItemList: selectedAlan)));
            setState(() => selectedAlan = m);
            alanController.text = selectedAlan.getCntText();
          })
      ],
    );
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

  Widget getTextField(String labelText, TextEditingController contr, [Function onTap]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TextFormField(
        onTap: onTap,
        readOnly: true,
        controller: contr,
        validator: validator,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          suffixIcon: const Icon(Icons.arrow_forward_ios),
          labelText: labelText,
        ),
      ),
    );
  }
}
