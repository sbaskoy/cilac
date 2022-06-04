import 'package:cilac/base/network_manager.dart';
import 'package:cilac/extansion/string_extansion.dart';
import 'package:cilac/model/kaynak_donus_model.dart';
import 'package:cilac/model/usermodel.dart';
import 'package:cilac/view/kaynakkayit/kaynak_kayit_view.dart';
import 'package:cilac/view/showimage/show_image_view.dart';
import 'package:cilac/view/showmap/show_map_view.dart';
import 'package:cilac/view/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class KaynakListeFilter extends StatefulWidget {
  final UserModel user;
  const KaynakListeFilter({Key key, this.user}) : super(key: key);

  @override
  State<KaynakListeFilter> createState() => _KaynakListeFilterState();
}

class _KaynakListeFilterState extends State<KaynakListeFilter> {
  bool loading = true;
  List<KaynakGelenModel> mainData;
  List<KaynakGelenModel> filteredData;
  ScrollController scrollController = new ScrollController();

  var startController = new TextEditingController();
  var finishController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Future<List<KaynakGelenModel>> getList() async {
    List res = (await NetworkManager.instance
        .httpPost(path: "api/lst/kaynaklst", data: {"data": " "}, token: widget.user.token, model: KaynakGelenModel()));

    return Future.value(res.map((e) => e as KaynakGelenModel).toList());
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  String dateToStr(DateTime val) => "${val.year}-${val.month}-${val.day} ";
  void getData({String start, String finish}) async {
    try {
      if (loading == false) {
        loading = true;
        setState(() {});
      }
      var today = DateTime.now();
      var _start = dateToStr(today) + "00:00";
      var last = dateToStr(today) + "23:59";
      // var last = today.add(new Duration(days: -1));
     
      List res = (await NetworkManager.instance.httpPost(
          path: "api/lst/kaynaklst",
          data: {"data": " and tarih<'${finish ?? last}' and tarih> '${start ?? _start}' "},
          token: widget.user.token,
          model: KaynakGelenModel()));

      mainData = res.map((e) => e as KaynakGelenModel).toList().reversed.toList();

      filteredData = [...mainData];

      loading = false;
      setState(() {});
    } catch (e) {
      loading = false;
      setState(() {});
    }
  }

  bool value = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kaynak Listesi"),
        centerTitle: true,
      ),
      body: Center(
          child: loading
              ? const CircularProgressIndicator.adaptive()
              : mainData == null
                  ? const Text("Kaynaklar yüklenirken bir hata oluştu")
                  : buildList(context)),
    );
  }

  Future<DateTime> _showDatePicker(BuildContext context, String sel) async {
    DateTime initialDate = DateTime.tryParse(sel);
    return await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: DateTime(1880),
        lastDate: DateTime(2100));
  }

  Widget buildSearchBar() {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormField(
                onChanged: (val) {
                  List<KaynakGelenModel> res =
                      mainData.where((element) => element.adres.toLowerCase().contains(val.toLowerCase())).toList();
                  filteredData = [...res];
                  setState(() {});
                },
                labelText: "Birşeyler ara",
                suffixIcon: Icons.close,
                suffixOnTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
              ),
              CustomFormField(
                  labelText: "Başlangıç Tarihi",
                  controller: startController,
                  validator: (val) {
                    if (val.isEmpty) {
                      return "Bu alan zorunludur";
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime sel = await _showDatePicker(context, startController.text);
                    if (sel != null) {
                      startController.text = dateToStr(sel);
                    }
                  },
                  readOnly: true),
              CustomFormField(
                  labelText: "Bitiş Tarihi",
                  controller: finishController,
                  validator: (val) {
                    if (val.isEmpty) {
                      return "Bu alan zorunludur";
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime sel = await _showDatePicker(context, finishController.text);
                    if (sel != null) {
                      finishController.text = dateToStr(sel);
                    }
                  },
                  readOnly: true),
              TextButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      getData(start: startController.text, finish: finishController.text);
                    }
                  },
                  child: const Text("Sorgula"))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildList(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(title: const Text("Filtrele"), children: [
          buildSearchBar(),
        ]),
        Expanded(
          child: filteredData.isEmpty
              ? const Center(
                  child: Text("Kaynak Bulunamadı."),
                )
              : ListView(
                  controller: scrollController,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        child: Text("Bulunan toplam sayı: ${filteredData.length}",
                            style: const TextStyle(fontWeight: FontWeight.bold))),
                    const Divider(),
                    ...List.generate(
                      filteredData.length,
                      (index) {
                        KaynakGelenModel c = filteredData[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) {
                              return KaynakKayitView(
                                user: widget.user,
                                model:c
                              );
                            }));
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Material(
                                elevation: 20,
                                child: SizedBox(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          filteredData[index].kaynakAdi,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const Divider(),
                                      if (c.aciklama?.isNotEmpty ?? false) buildRowText("Acıklama: ", c.aciklama),
                                      if (c.ekAciklama?.isNotEmpty ?? false)
                                        buildRowText("Ek Acıklama: ", c.ekAciklama),
                                      if (c.gelecekUygulamaTarihi?.isNotEmpty ?? false)
                                        buildRowText("Sonraki Uy. Tarihi: ", c.gelecekUygulamaTarihi.dateToStr),
                                      if (c.sonIlacAdi?.isNotEmpty ?? false)
                                        buildRowText("Son kullanılan ilaç: ", c.sonIlacAdi),
                                      buildRowText("Üreme Durumu: ", c.uremeDurumu ? "Aktif" : "Pasif"),
                                      if (c.metreKare != null)
                                        buildRowText("Büyüklük: ", c.metreKare.toString() + " metre kare"),
                                      const Divider(),
                                      if (c.adres?.isNotEmpty ?? false)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            c.adres,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (cONTEXT) {
                                                  return ShowImageView(images: c.resimler);
                                                }));
                                              },
                                              child: const Text("Resimler")),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.push(context, MaterialPageRoute(builder: (cONTEXT) {
                                                  return ShowMapView(
                                                    points: [c.geoKonum],
                                                  );
                                                }));
                                              },
                                              child: const Text("Haritada Göster")),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        );
                      },
                    )
                  ],
                ),
        )
      ],
    );
  }

  Widget buildRowText(String str1, String str2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
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
      ),
    );
  }
}
