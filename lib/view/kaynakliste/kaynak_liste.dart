import 'dart:developer';

import 'package:cilac/base/network_manager.dart';
import 'package:cilac/extansion/string_extansion.dart';
import 'package:cilac/extansion/widget_extansion.dart';
import 'package:cilac/model/kaynak_donus_model.dart';
import 'package:cilac/model/usermodel.dart';
import 'package:cilac/view/showimage/show_image_view.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class KaynakListe extends StatefulWidget {
  final UserModel user;
  final int selectedID;
  final LatLng location;
  const KaynakListe({Key key, this.user, this.selectedID, this.location}) : super(key: key);

  @override
  State<KaynakListe> createState() => _KaynakListeState();
}

class _KaynakListeState extends State<KaynakListe> {
  bool loading = true;
  bool showInfo = false;
  List<KaynakGelenModel> mainData;
  List<KaynakGelenModel> filteredData;
  List<Marker> markers = [];
  double bottom = -100;
  KaynakGelenModel selectedModel;
  LatLng _selectedPoint;
  final _distanceController = new TextEditingController(text: "100");
  @override
  void initState() {
    super.initState();
  }





  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getData(1);
  }

  void getData(int process) async {
    try {
      if (loading == false) {
        loading = true;
        setState(() {});
      }
      LatLng _cord = _selectedPoint ?? widget.location;
      List res = process == 0
          ? (await NetworkManager.instance.httpPost(
              path: "api/lst/kaynaklst", data: {"data": " "}, token: widget.user.token, model: KaynakGelenModel()))
          : (await NetworkManager.instance.httpPost(
              path: "api/lst/yakinkaynaklst",
              data: {
                "point": "POINT(${_cord.latitude} ${_cord.longitude})",
                "distance": int.parse(_distanceController.text)
              },
              token: widget.user.token,
              model: KaynakGelenModel()));

      mainData = res.map((e) => e as KaynakGelenModel).toList();
      log(mainData.length.toString());
      selectedModel = mainData.firstWhere((element) => element.id == widget.selectedID, orElse: () => null);
      filteredData = [...mainData];
      markers.clear();
      if (process == 1) {
        for (var element in mainData) {
          if (element.geoKonum.isNotEmpty) {
            markers.add(Marker(
              onTap: () {
                setState(() {
                  if (selectedModel != null) {
                    var o = markers
                        .firstWhere((marker) => marker.markerId == MarkerId("${selectedModel.id}"), orElse: () => null)
                        .copyWith(iconParam: _getMarkerColor(selectedModel));
                    markers.removeWhere((marker) => marker.markerId == MarkerId("${selectedModel.id}"));
                    markers.add(o);
                  }

                  selectedModel = element;
                  showInfo = true;
                  var m = markers
                      .firstWhere((marker) => marker.markerId == MarkerId("${element.id}"), orElse: () => null)
                      .copyWith(iconParam: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));
                  markers.removeWhere((marker) => marker.markerId == MarkerId("${element.id}"));
                  markers.add(m);

                  bottom = 10;
                });
              },
              icon: selectedModel?.id == element.id
                  ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
                  : _getMarkerColor(element),
              markerId: MarkerId(element.id.toString()),
              position: element.geoKonum.pointToLatLng,
              infoWindow: new InfoWindow(
                title: element.kaynakAdi,
              ),
            ));
          }
        }
      }

      loading = false;
      setState(() {});
    } catch (e) {
      log(e);
      loading = false;
      setState(() {});
    }
  }

  BitmapDescriptor _getMarkerColor(KaynakGelenModel model) {
    return ((model.sonIlacAdi?.isNotEmpty ?? false)
        ? DateTime.parse(model.gelecekUygulamaTarihi).difference(DateTime.now()).inDays > 0
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, selectedModel);
        return false;
      },
      child: Scaffold(
        body: Center(
            child: loading
                ? const CircularProgressIndicator.adaptive()
                : mainData == null
                    ? const Text("Kaynaklar yüklenirken bir hata oluştu")
                    : buildList(context)),
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                placeholder: "Kaynaklarda Ara",
                onChanged: (val) {
                  List<KaynakGelenModel> res =
                      mainData.where((element) => element.adres.toLowerCase().contains(val.toLowerCase())).toList();
                  filteredData = val.isNotEmpty ? [...res] : mainData;
                  markers.clear();
                  for (var element in filteredData) {
                    if (element.geoKonum.isNotEmpty) {
                      markers.add(Marker(
                        onTap: () {
                          setState(() {
                            selectedModel = element;
                            bottom = 10;
                          });
                        },
                        icon: selectedModel.id == element.id
                            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
                            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                        markerId: MarkerId(element.id.toString()),
                        position: element.geoKonum.pointToLatLng,
                      ));
                    }
                  }
                  setState(() {});
                },
              )),
          CupertinoSearchTextField(
            controller: _distanceController,
            placeholder: "Yakın kaynak mesafesi",
            prefixIcon: const Icon(CupertinoIcons.metronome),
            suffixIcon: const Icon(CupertinoIcons.search),
            onSuffixTap: () {
              try {
                int.parse(_distanceController.text);
                getData(1);
              } catch (_) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Geçerli bir mesafe girmediniz")));
              }
            },
          ).paddingAll()
        ],
      ),
    );
  }

  Widget buildList(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.location,
                    zoom: 18,
                  ),
                  onTap: (LatLng p) {
                    _selectedPoint = p;
                    setState(() {
                      showInfo = false;
                    });
                  },
                  myLocationEnabled: true,
                  markers: Set<Marker>.from(markers)),
              Positioned(
                child: buildSearchBar(),
                top: 30,
                left: 0,
                right: 0,
              ),
            ],
          ),
        ),
        if (selectedModel != null && showInfo)
          Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Text(
                  "Kaynak Detayı",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ).paddingAll(),
                buildRowText("Kaynak Adı", selectedModel.kaynakAdi ?? ""),
                buildRowText("Kaynak Acıklaması", selectedModel.aciklama ?? ""),
                buildRowText("Adres", selectedModel.adres),
                if (selectedModel.sonIlacAdi?.isNotEmpty ?? false)
                  buildRowText("Son K. İlaç", selectedModel.sonIlacAdi ?? ""),
                if (selectedModel.donguGun == 0)
                  buildRowText("İlaçlama Sıklığı", (selectedModel.donguGun?.toString() ?? "") + " gün"),
                buildRowText("G. İlaçlama Tarihi", (selectedModel.gelecekUygulamaTarihi?.split("T")?.first ?? "")),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (cONTEXT) {
                                return ShowImageView(images: selectedModel.resimler);
                              }));
                            },
                            child: const Text("Kaynak resimleri"))
                        .paddingAll(),
                    ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
                            onPressed: () {
                              Navigator.of(context).pop(selectedModel);
                            },
                            child: const Text("Şeç"))
                        .paddingAll(),
                  ],
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
// ListView(
//             controller: scrollController,
//             children: [
//               ...List.generate(
//                 filteredData.length,
//                 (index) {
//                   KaynakGelenModel c = filteredData[index];
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.of(context).pop(c);
//                     },
//                     child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Material(
//                           elevation: 20,
//                           child: Container(
//                             color: widget.selectedID == c.id ? Colors.grey.shade400 : null,
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     filteredData[index].kaynakAdi,
//                                     style: const TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                                 const Divider(),
//                                 if (c.aciklama?.isNotEmpty ?? false) buildRowText("Acıklama: ", c.aciklama),
//                                 if (c.ekAciklama?.isNotEmpty ?? false) buildRowText("Ek Acıklama: ", c.ekAciklama),
//                                 if (c.gelecekUygulamaTarihi?.isNotEmpty ?? false)
//                                   buildRowText("Sonraki Uy. Tarihi: ", c.gelecekUygulamaTarihi.dateToStr),
//                                 if (c.sonIlacAdi?.isNotEmpty ?? false)
//                                   buildRowText("Son kullanılan ilaç: ", c.sonIlacAdi),
//                                 buildRowText("Üreme Durumu: ", c.uremeDurumu ? "Aktif" : "Pasif"),
//                                 if (c.metreKare != null)
//                                   buildRowText("Büyüklük: ", c.metreKare.toString() + " metre kare"),
//                                 const Divider(),
//                                 if (c.adres?.isNotEmpty ?? false)
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       c.adres,
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                   children: [
//                                     TextButton(
//                                         onPressed: () {
//                                           Navigator.push(context, MaterialPageRoute(builder: (cONTEXT) {
//                                             return ShowImageView(images: c.resimler);
//                                           }));
//                                         },
//                                         child: const Text("Resimler")),
//                                     TextButton(
//                                         onPressed: () {
//                                           Navigator.push(context, MaterialPageRoute(builder: (cONTEXT) {
//                                             return ShowMapView(
//                                               points: [c.geoKonum],
//                                             );
//                                           }));
//                                         },
//                                         child: const Text("Haritada Göster")),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )),
//                   );
//                 },
//               )
//             ],
//           ),