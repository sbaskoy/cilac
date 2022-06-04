import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cilac/model/hedefzararli.dart';
import 'package:cilac/model/ilaclar.dart';
import 'package:cilac/model/kaynak_donus_model.dart';
import 'package:cilac/model/kaynakturleri.dart';
import 'package:cilac/view/kaynakliste/kaynak_liste.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../localdb/alanlar_db.dart';
import '../../localdb/ekipman_db.dart';
import '../../localdb/hedef_zararli_db.dart';
import '../../localdb/ilaclar_db.dart';
import '../../localdb/ilceler_db.dart';
import '../../localdb/kaynak_turleri_db.dart';
import '../../localdb/uygulama_kayit_db.dart';
import '../../localdb/yontemler_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../global/extansion.dart';
import '../../global/global_function.dart';

import '../../model/selecteditem.dart';
import '../../model/usermodel.dart';
import '../../model/uygulamakayit.dart';
import '../../model/uygulamatanim.dart';

import '../../palette.dart';
import '../../view/application/select_view.dart';
import '../functions/global_functions.dart';

import 'add_photo.dart';
import 'getloaciton.dart';
import 'selectedimage.dart';

class MakeApplicationView extends StatefulWidget {
  final UserModel model;
  final LatLng cord;
  final int sikayetID;
  final UygulamaTanim selectedModel;
  const MakeApplicationView({Key key, this.model, this.sikayetID, this.selectedModel, this.cord}) : super(key: key);
  @override
  _MakeApplicationViewState createState() => _MakeApplicationViewState();
}

class _MakeApplicationViewState extends State<MakeApplicationView> {
  TextEditingController cordinatKontroller = new TextEditingController();

  bool isLoadingData = false, isError = false;
  bool uremeAktif = true, uremePasif = false;
  bool kaynakAktif = true, kaynakPasif = false;
  final formKey = GlobalKey<FormState>();
  // Uygulamada şeçilen ilaçlar vs
  List<SelectedItem> selectedKaynakTur,
      selectedIlac,
      selectedEkipman,
      selectedYontem,
      selectedAlan,
      selectedUygAlan,
      selectedHedefZarali;
  // diger gerekli alanların kontrolleru
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
      kaynakController = new TextEditingController(),
      zararliController = new TextEditingController();
  String basTarih;
  String bitTarih;

  List ilceModel;
  Color color = Colors.red;
  Color resColor = kGreen;
  List<SelectedImageModel> selectedImage;
  String imageText = "Resim Seçiniz";
  LatLng cord;
  bool isKaynakUygulamasi = false;
  int pKaynakID = -1;
  @override
  void initState() {
    super.initState();
    basTarih = DateTime.now().toString().substring(0, 11);
    dateStartController.text = basTarih;
    bitTarih = DateTime.now().toString().substring(0, 11);
    dateFinishController.text = basTarih;
    this.cord = widget.cord;
    getData();
  }

  void getData() async {
    // List list = await UygulamaTanim.fromAPI(widget.model.token);
    // local veritabanından ilceleri yükler
    List ilceler = (await new IlceDb().getAll()).where((element) => element.pilID == 366).toList();
    // bu uygulamalar da kaynak gerekli bu yüzden kaynak field accar
    var kaynakApp = ["KAYNAK İPTALİ", "KARASİNEK LARVA UYGULAMASI", "SİVRİSİNEK LARVA UYGULAMASI"];
    if (kaynakApp.any((element) => element == widget.selectedModel.uygulamaTanimi)) {
      isKaynakUygulamasi = true;
    }
    updateLocation();

    setState(() {
      ilceModel = [...ilceler];
    });
  }

  void updateLocation() async {
    // mevcut konumu günceller
    var locRequest = await Permission.location.request();
    if (locRequest.isGranted) {
      LocationData loc = await Location.instance.getLocation();
      LatLng _cord = new LatLng(loc.latitude, loc.longitude);
      this.cord = _cord;
      cordinatKontroller.text = "POINT (${_cord.latitude} ${_cord.longitude})";
      setAdress(_cord);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text("Konum izni verilmedi"),
      ));
    }
  }

  Future<void> setAdress(LatLng _cord) async {
    // konuma göre adresi günceller
    cord = _cord;
    final coordinates = new Coordinates(_cord.latitude, _cord.longitude);
    List<Address> addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    Address first = addresses.first;
    if (first.addressLine != null) {
      adresController.text = first.addressLine;
    }
    if (first.subAdminArea != null) {
      // google altınorduyu ordu merkez verdiginde altınordya ceviriyorum
      String ilce = first.subAdminArea.toLowerCase() == "ordu merkez" ? "ALTINORDU" : first.subAdminArea.toUpperCase();
      ilceController.text = ilce;
    }
    setState(() {});
  }

  void getDetails() async {
    // tüm şeçimleri kaldırır
    setState(() => selectedAlan = null);
    alanController.text = "";
    setState(() => selectedEkipman = null);
    ekipmanController.text = "";
    setState(() => selectedHedefZarali = null);
    zararliController.text = "";
    setState(() => selectedIlac = null);
    ilacController.text = "";
    setState(() => selectedYontem = null);
    yontemController.text = "";
    setState(() => selectedKaynakTur = null);
    kaynakTurController.text = "";
    setState(() => selectedUygAlan = null);
    uygAlnaController.text = "";
  }

  void save(int process) async {
    try {
      // tüm gerekli alanlar doluysa
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
        // şeçilen resimleri base64 cevirir
        for (var i in selectedImage.where((element) => element.imagePath != null).toList()) {
          resim.add(base64Encode(File(i.imagePath).readAsBytesSync()));
        }
        log(widget.selectedModel.uygulamaTanimi);
        // api modeli

        UygulamaKayit kayit = new UygulamaKayit(
            uygulamaTanimi: widget.selectedModel.uygulamaTanimi,
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
            konumlar: "POINT (${this.cord.latitude} ${this.cord.longitude} )",
            resimler: resim,
            mucadeleSekli: "",
            id: -1,
            pUygulamaTanimID: widget.selectedModel.id,
            pEkipID: 0,
            adres: adresController.text,
            konumID: "",
            baslangicTarihi: DateTime.now().toString().replaceAll(" ", "T"),
            bitisTarihi: DateTime.now().add(const Duration(hours: 1)).toString().replaceAll(" ", "T"),
            il: "ORDU",
            ilce: ilceController.text,
            kaynakDurumu: kaynakAktif,
            uremeDurumu: uremeAktif,
            pKaynakID: pKaynakID ?? -1,
            pSikayetID: widget.sikayetID ?? -1,
            aciklama: aciklamaController.text,
            pPersonID: widget.model.id);
        if (process == 1) {
          ReturnModel model = await kayit.postAPI(widget.model.token);
          setState(() => isLoadingData = false);
          if (model == null) {
            await showAlertDialog(
                context,
                "Bilinmeyen bir hata oluştu. Uygulamayı locale kaydedip daha sonra tekrar tekrar deneyiniz",
                Icons.error,
                Colors.amber);
          } else if (model.durumKodu == 0) {
            await showAlertDialog(context, "Başarılı bir şekilde kayıt edildi", Icons.done, Colors.green,
                text: "Kapat ve Yeni", onPressed: () {
              adresController.text = "";
              cordinatKontroller.text = "";
              this.cord = null;
              Navigator.pop(context);
            });
          } else if (model.durumKodu > 100) {
            await showAlertDialog(context, "Bir hata oluştu.Mesaj ${model.durumMesaj}", Icons.error, Colors.red);
          } else if (model.iD > 0 && model.durumKodu == 1) {
            await showAlertDialog(context, "Bilgiler kayıt edildi ama resimler edilemedi", Icons.done, Colors.amber);
          } else {
            await showAlertDialog(
                context, "Uygulamayı locale kaydedip daha sonra tekrar tekrar deneyiniz", Icons.error, Colors.amber);
          }
        } else {
          await new UygulamaKayitDb().insert(kayit);
          setState(() => isLoadingData = false);
          await showAlertDialog(
              context,
              "Başarılı kendi veritabanınıza kayıt edildi.İnternetiniz oldugu zaman bu uygulamaları keyı etmelisiniz.",
              Icons.done,
              Colors.green,
              text: "Kapat ve Yeni", onPressed: () {
            adresController.text = "";
            cordinatKontroller.text = "";
            this.cord = null;
            Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      setState(() => isLoadingData = false);
      await showAlertDialog(context, "Bir hata oluştu.Hata $e", Icons.done, Colors.green);
    }
  }

  getSqlData(data) => " ID in (${data.replaceAll(";", ",")})";
  getControllertext(data) =>
      data.where((e) => e.selected == true).map((e) => e.adi).toString().replaceAll("(", "").replaceAll(")", "");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.selectedModel.uygulamaTanimi),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: isLoadingData
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(child: CircularProgressIndicator()),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                // konum fieldi
                                child: TextFormField(
                                  onTap: () async {
                                    // tıklanınca konum alır ve geri dönderir
                                    LatLng _cord = await showDialog(
                                        context: context,
                                        builder: (c) => Dialog(
                                              child: GetLocation(
                                                cord: this.cord,
                                              ),
                                            ));
                                    if (_cord != null) {
                                      this.cord = _cord;
                                      cordinatKontroller.text = "POINT (${_cord.latitude} ${_cord.longitude})";
                                      setAdress(_cord);
                                      setState(() {});
                                    }
                                  },
                                  readOnly: true,
                                  controller: cordinatKontroller,
                                  validator: validator,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    suffixIcon: const Icon(Icons.arrow_drop_down),
                                    labelText: "Uygulama Konumu",
                                    prefixIcon: const Icon(Icons.map),
                                  ),
                                ),
                              ),
                              IconButton(onPressed: updateLocation, icon: const Icon(Icons.update))
                            ],
                          ),
                        ),
                        // eger kannak uygulaması ile
                        if (isKaynakUygulamasi) _buildKaynakColumn(),
                        isLoadingData
                            ? const CircularProgressIndicator()
                            : Column(
                                children: [
                                  // dinamik olarka widget ekler
                                  buildColumn(context),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: TextFormField(
                                      // ilce adresten başta otomatik gelir ama el ile değiştirebilir
                                      onTap: () async {
                                        await showModal2(context, ilceModel);
                                      },
                                      readOnly: true,
                                      controller: ilceController,
                                      validator: validator,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        suffixIcon: const Icon(Icons.arrow_drop_down),
                                        labelText: "Ilçe",
                                      ),
                                    ),
                                  ),
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
                                  buildUremePadding(),
                                  buildKaynakPadding(),
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
                                  _buildRowButton(size: size, onPressed: () => save(1), onPressed2: () => save(0)),
                                ],
                              )
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildKaynakColumn() {
    return Column(
      children: [
        getTextField("Kaynak", kaynakController, () async {
          selectedKaynakTur = null;
          kaynakTurController.text = "";
          selectedIlac = null;
          ilacController.text = "";
          selectedHedefZarali = null;
          zararliController.text = "";
          var locRequest = await Permission.location.request();
          if (!locRequest.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text("Konum izni verilmedi"),
            ));
            return;
          }
          if (this.cord == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text("Konumuz bekleniyor. Konum alınmaydıysa elinizle yenileyiniz."),
            ));
            return;
          }

          KaynakGelenModel model = await Navigator.push(context, MaterialPageRoute(builder: (c) {
            return KaynakListe(user: widget.model, selectedID: pKaynakID, location: this.cord);
          }));
          if (model != null) {
            kaynakController.text = model.kaynakAdi;
            pKaynakID = model.id;
            List<KaynakTurleri> kaynakTur = await KaynakTurleriDb().getAll();
            if (kaynakTur.any((element) => element.id == model.pKaynakTurID)) {
              selectedKaynakTur = [
                new SelectedItem(
                    id: model.pKaynakTurID,
                    selected: true,
                    adi: (await KaynakTurleriDb().getAll())
                        .firstWhere((element) => element.id == model.pKaynakTurID)
                        .kaynakAdi)
              ];
              kaynakTurController.text = selectedKaynakTur.getCntText();
            }
            List<Ilaclar> ilaclar = await IlaclarDb().getAll();
            if (ilaclar.any((element) => element.id == model.sonIlac)) {
              selectedIlac = [
                new SelectedItem(
                    id: model.sonIlac,
                    selected: true,
                    adi: (await IlaclarDb().getAll()).firstWhere((element) => element.id == model.sonIlac).ilacAdi)
              ];
              ilacController.text = selectedIlac.getCntText();
            }
            List<HedefZararli> hedefZar = await HedefZararliDb().getAll();
            if (hedefZar.any((element) => element.id == model.pZararliID)) {
              selectedHedefZarali = [
                new SelectedItem(
                    id: model.pZararliID,
                    selected: true,
                    adi: (await HedefZararliDb().getAll())
                        .firstWhere((element) => element.id == model.pZararliID)
                        .zararliAdi)
              ];
              zararliController.text = selectedHedefZarali.getCntText();
            }
            if (model.uremeDurumu) {
              uremeAktif = true;
              uremePasif = false;
            } else {
              uremeAktif = false;
              uremePasif = true;
            }
            kaynakController.text = model.kaynakAdi;
            pKaynakID = model.id;
            setState(() {});
          }
        })
      ],
    );
  }

  Widget _buildRowButton({@required Size size, String text, Function onPressed, Function onPressed2}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: size.height * 0.06,
            width: size.width * 0.45,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: TextButton(
              onPressed: onPressed2 ?? () => print("Button"),
              child: Text(
                text ?? "Locale Kaydet",
              ),
            ),
          ),
          Container(
            height: size.height * 0.06,
            width: size.width * 0.45,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: TextButton(
              onPressed: onPressed ?? () => print("Button"),
              child: Text(
                text ?? "Kaydet",
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder inputFocusedBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: kRed, width: 2),
      borderRadius: BorderRadius.circular(16),
    );
  }

  OutlineInputBorder inputEnabledBorder() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: kGreen, width: 2),
      borderRadius: BorderRadius.circular(16),
    );
  }

  Column buildColumn(BuildContext context) {
    return Column(
      children: [
        // şeçilen uygulamada alanlar kısmı boş değilse alanlar field gösterir
        // diger tümü için aynı
        if (widget.selectedModel == null ? false : widget.selectedModel.alanlar.isNotEmpty)
          getTextField("Alan", alanController, () async {
            // bu fielt tıklanında
            // tüm uygulama alanlarını localdb den ceker
            // select view sayfasına gönderir
            // select view List<SelectedItem> item türünde geri data tollar
            // item.selected true ise o item seçilmiş demektir
            List alanlarlst =
                selectedAlan ?? await new AlanlarDb().getAllWithWhere(getSqlData(widget.selectedModel.alanlar));
            var m = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (c) => Dialog(
                    child: SelectView(
                        title: "Alan Seç",
                        // şeçim yapılmasını istedgimiz liste
                        // kullanıcayıa adi alanı gösteririr
                        list: alanlarlst.map((e) => e.toJson()).toList(),
                        selectedItemList: selectedAlan)));
            setState(() => selectedAlan = m);
            // şeçilen degerler arasına ; koyar ve yazar
            alanController.text = selectedAlan.getCntText();
          }),
        // hepsinde aynı işlem var
        if (widget.selectedModel == null ? false : widget.selectedModel.ekipmanlar.isNotEmpty)
          getTextField("Ekipman", ekipmanController, () async {
            List ekipmanlarlst =
                selectedEkipman ?? await EkipmanDb().getAllWithWhere(getSqlData(widget.selectedModel.ekipmanlar));
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
        if (widget.selectedModel == null ? false : widget.selectedModel.hedefZararli.isNotEmpty)
          getTextField("Hedef Zararli", zararliController, () async {
            List hedefZararlilst = selectedHedefZarali ??
                await new HedefZararliDb().getAllWithWhere(getSqlData(widget.selectedModel.hedefZararli));
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
        if (widget.selectedModel == null ? false : widget.selectedModel.ilaclar.isNotEmpty)
          getTextField("İlaç", ilacController, () async {
            List ilaclarlst =
                selectedIlac ?? await new IlaclarDb().getAllWithWhere(getSqlData(widget.selectedModel.ilaclar));

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
        if (widget.selectedModel == null ? false : widget.selectedModel.yontemler.isNotEmpty)
          getTextField("Yöntem", yontemController, () async {
            List yontemlerlst =
                selectedYontem ?? await new YontemlerDb().getAllWithWhere(getSqlData(widget.selectedModel.yontemler));
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
        if (widget.selectedModel == null ? false : widget.selectedModel.kaynakTurleri.isNotEmpty)
          getTextField("Kaynak Türü", kaynakTurController, () async {
            List kaynakTurlerilst = selectedKaynakTur ??
                await new KaynakTurleriDb().getAllWithWhere(getSqlData(widget.selectedModel.kaynakTurleri));
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
        if (widget.selectedModel == null ? false : widget.selectedModel.uygulamaAlanlari.isNotEmpty)
          getTextField("Uygulama Alanı", alanController, () async {
            List alanlarlst = selectedAlan ??
                await new AlanlarDb().getAllWithWhere(getSqlData(widget.selectedModel.uygulamaAlanlari));
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

  Padding buildKaynakPadding() {
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
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Checkbox(
                        value: kaynakAktif,
                        onChanged: (val) {
                          setState(() {
                            kaynakPasif = false;
                            kaynakAktif = true;
                          });
                        }),
                    const Text("Aktif")
                  ],
                ),
              ),
              const Text(
                "Kaynak Durumu",
              ),
              Row(
                children: [
                  const Text("Pasif"),
                  Checkbox(
                      value: kaynakPasif,
                      onChanged: (val) {
                        setState(() {
                          kaynakPasif = true;
                          kaynakAktif = false;
                        });
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding buildUremePadding() {
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
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                child: Row(
                  children: [
                    Checkbox(
                        value: uremeAktif,
                        onChanged: (val) {
                          setState(() {
                            uremePasif = false;
                            uremeAktif = true;
                          });
                        }),
                    const Text(
                      "Aktif",
                    )
                  ],
                ),
              ),
              const Text(
                "Üreme Durumu",
              ),
              Row(
                children: [
                  const Text("Pasif"),
                  Checkbox(
                      value: uremePasif,
                      onChanged: (val) {
                        setState(() {
                          uremePasif = true;
                          uremeAktif = false;
                        });
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration getUnputDecoration(text, Size size) {
    return InputDecoration(
      labelText: text,
    );
  }

  // Future<void> _showDatePicker(id) async {
  //   return await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.parse(id == 1 ? dateStartController.text.trim() : dateFinishController.text.trim()),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2022, 12),
  //   ).then((pickedDate) {
  //     if (pickedDate != null) {
  //       if (id == 1) {
  //         dateStartController.text = pickedDate.toString().substring(0, 11);
  //         setState(() {
  //           basTarih = pickedDate.toString().replaceAll(" ", "T");
  //         });
  //       } else {
  //         dateFinishController.text = pickedDate.toString().substring(0, 11);
  //         setState(() {
  //           bitTarih = pickedDate.toString().replaceAll(" ", "T");
  //         });
  //       }
  //     }
  //   });
  // }

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

  Future<void> showModal2(context, model) async {
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
                    child: isError
                        ? Text(
                            "İlçeler yüklenirken bir hata oluştu.Daha sonra tekrar deneyiniz",
                            style: TextStyle(
                              color: Theme.of(context).errorColor,
                            ),
                          )
                        : model != null
                            ? CupertinoPicker(
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    ilceController.text = model[index].ilceAdi;
                                  });
                                },
                                scrollController: FixedExtentScrollController(
                                    initialItem: model.indexWhere((element) => element.ilceAdi == ilceController.text)),
                                itemExtent: 35,
                                looping: false,
                                children: List.generate(model.length, (index) {
                                  return Text(
                                    model[index].ilceAdi,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headline5,
                                  );
                                }))
                            : const CircularProgressIndicator()),
              ],
            ),
          );
        });
  }
}
