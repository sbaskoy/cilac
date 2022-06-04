import 'dart:async';
import '../../extansion/string_extansion.dart';
import '../../localdb/uygulama_konumlar_db.dart';
import '../home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as l;

import 'package:shared_preferences/shared_preferences.dart';

import '../../base/base_state.dart';
import '../../model/usermodel.dart';
import '../../model/uygulama_konum.dart';
import '../../model/uygulamakayit.dart';
import '../functions/global_functions.dart';

class GetAllCordinates extends StatefulWidget {
  final UserModel user;
  final ReturnModel uygulama;
  final LatLng startPos;

  const GetAllCordinates({Key key, this.user, this.uygulama, this.startPos}) : super(key: key);
  @override
  _GetAllCordinatesState createState() => _GetAllCordinatesState();
}

class _GetAllCordinatesState extends BaseState<GetAllCordinates> {
  CameraPosition cameraPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};

  // Completer<GoogleMapController> _controller = new Completer();
  List<LatLng> routesCord = [];
  l.Location location;
  UygulamaKonumlar konumlar;
  bool isLoadingData = false;
  bool goBack = false;
  bool isPaused = false;
  Timer _timer;
  var methodChannel = const MethodChannel("com.oryaz.cilac/backgroudservice");

  @override
  void initState() {
    super.initState();
    if (widget.uygulama == null && widget.startPos == null) {
      // eger uygulama kapatılıp tekrar acıldıysa
      loadLocal();

      return;
    } else {
      // baştan başlanıldıysa
      cameraPosition = new CameraPosition(
          target: new LatLng(
            widget.startPos.latitude,
            widget.startPos.longitude,
          ),
          zoom: 15);
      setState(() {
        cameraPosition = cameraPosition;
      });
      _markers.add(new Marker(
        markerId: const MarkerId("start pos"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: widget.startPos,
      ));

      getLoation();
    }
  }

  Future<void> loadLocal() async {
    // localdan uygulama id ve durdurulmuşmu okunur
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt("geziciid");
    bool _paused = prefs.getBool("isStoped") ?? false;
    isPaused = _paused;
    // java service yazdıgı konumlar okunur
    konumlar = (await UygulamaKonumlarDb().getAllWithWhere("id=$id")).first;
    var point = konumlar.data.first.geoKonum.pointToLatLng;
    cameraPosition = new CameraPosition(
        target: new LatLng(
          point.latitude,
          point.longitude,
        ),
        zoom: 15);
    setState(() {
      cameraPosition = cameraPosition;
    });
    // haritaya cizilir
    _markers.add(new Marker(
      markerId: const MarkerId("start pos"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      position: point,
    ));
    routesCord = [];
    for (var i in konumlar.data) {
      routesCord.add(i.geoKonum.pointToLatLng);
    }
    _polyLines.clear();
    if (routesCord.length > 1) {
      _polyLines
          .add(new Polyline(polylineId: const PolylineId("routes"), points: routesCord, color: Colors.green, width: 3));
    }
    setState(() {});
    _startTimer();
  }

  Future<void> getLoation() async {
    // await checkPermission();

    konumlar = new UygulamaKonumlar(widget.uygulama.iD, []);
    await new UygulamaKonumlarDb().insert(konumlar);
    // java servisi burada çalıştırır
    await methodChannel.invokeMethod("startService", {"id": konumlar.pUygulamaID});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("gezici", true);
    prefs.setInt("geziciid", konumlar.pUygulamaID);
    _startTimer();
  }

  void _startTimer() async {
    // her 500 milisanite tablo okunur harita güncellenir
    _timer = new Timer.periodic(const Duration(milliseconds: 500), (Timer timer) async {
      List<UygulamaKonumlar> list = await UygulamaKonumlarDb().getAllWithWhere("id=${konumlar.pUygulamaID}");
      routesCord = [];
      for (var i in list.first.data) {
        routesCord.add(i.geoKonum.pointToLatLng);
      }
      _polyLines.clear();
      if (routesCord.length > 1) {
        _polyLines.add(
            new Polyline(polylineId: const PolylineId("routes"), points: routesCord, color: Colors.green, width: 3));
        setState(() {});
      }
    });
  }

  void save() async {
    // kayıt işlemi
    setState(() => isLoadingData = true);
    await methodChannel.invokeMethod("stopService");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("gezici", false);
    prefs.setInt("geziciid", -999);
    if (_timer != null) _timer.cancel();
    List<UygulamaKonumlar> list = await UygulamaKonumlarDb().getAllWithWhere("id=${konumlar.pUygulamaID}");
    location ??= new l.Location();
    l.LocationData loc = await location.getLocation();
    konumlar = list.first;
    konumlar.data.add(new Konum(
        tarih: DateTime.now().toString().replaceAll(" ", "T"),
        geoKonum: "POINT(${loc.latitude} ${loc.longitude})",
        tip: true));

    ReturnModel model = await konumlar.postAPI(widget.user.token);
    setState(() => isLoadingData = false);

    if (model.durumKodu == 0) {
      await new UygulamaKonumlarDb().deleteWithID(konumlar.pUygulamaID);

      await showAlertDialog(context, "Rotanız başarılı bir şekilde kayıt edildi", Icons.done, Colors.green,
          onPressed: () {
        if (widget.uygulama == null && widget.startPos == null) {
          Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (c) => HomeView(user: widget.user)), (Route<dynamic> route) => false);
          return;
        }
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }, text: "Kapat");
    } else if (model.durumKodu > 100) {
      await showAlertDialog(context, "Bir hata oluştu.Mesaj ${model.durumMesaj}", Icons.error, Colors.red);
    } else if (model.iD > 0 && model.durumKodu == 1) {
      await showAlertDialog(context, "Bilgiler kayıt edildi ama resimler edilemedi", Icons.done, Colors.amber);
    } else {
      await showAlertDialog(context, "Bilinmeyen bir hata oluştu", Icons.error, Colors.amber);
    }
    this.goBack = true;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) _timer.cancel();
  }

  void startStop() async {
    isPaused = !isPaused;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isPaused) {
      prefs.setBool("isStoped", true);
      await methodChannel.invokeMethod("stopService");
      if (_timer != null) _timer.cancel();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konum alma durduruldu")));
    } else {
      prefs.setBool("isStoped", false);
      await methodChannel.invokeMethod("startService", {"id": konumlar.pUygulamaID});
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konum alma başlatıldı")));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => goBack,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Rotayı Kayıt Et"),
        ),
        body: cameraPosition == null
            ? const Center(
                child: Text("Yükleniyor."),
              )
            : isLoadingData
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: cameraPosition,
                        mapType: MapType.satellite,
                        markers: _markers,
                        polylines: _polyLines,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                      ),
                      const Positioned(
                        top: 10,
                        left: 10,
                        child: Text(
                          "Rotanız alınıyor",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      Positioned(
                          bottom: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: startStop,
                            child: Container(
                              width: 105,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: isPaused ? Colors.red : Colors.green, borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    isPaused
                                        ? const Icon(
                                            Icons.play_circle,
                                            color: Colors.green,
                                          )
                                        : const Icon(
                                            Icons.pause,
                                            color: Colors.red,
                                          ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        isPaused ? "Başlat" : "Durdur",
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
        floatingActionButton: Container(
          width: 150,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20)),
          child: TextButton(
            onPressed: save,
            child: const Text(
              "Bitir ve Kaydet",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
        //floatingActionButtonLocation: FloatingActionButtonLocation.CE,
      ),
    );
  }
}
