import 'dart:typed_data';
import 'dart:ui';

import '../../base/network_manager.dart';
import '../../extansion/string_extansion.dart';
import '../../model/ekip_konum.dart';
import '../../model/usermodel.dart';

import '../uygulamadetay/uygulama_list.dart';
import 'package:clippy_flutter/triangle.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class EkipKonumListe extends StatefulWidget {
  final UserModel user;
  const EkipKonumListe({Key key, this.user});

  @override
  _EkipKonumListeState createState() => _EkipKonumListeState();
}

class _EkipKonumListeState extends State<EkipKonumListe> {
  bool loading = true;
  String err = "";
  final Set<Marker> _markers = {};
  CameraPosition cameraPosition;
  Location location;
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  @override
  void initState() {
    super.initState();
    getData();
  }
  // custom marker oluşturma
  Future<BitmapDescriptor> createCustomMarkerBitmap(String title) async {
    TextSpan span = new TextSpan(
      style: const TextStyle(
        fontSize: 35.0,
        fontWeight: FontWeight.bold,
      ),
      text: title,
    );

    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.text = TextSpan(
      text: title,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.red,
        letterSpacing: 1.0,
        fontFamily: 'Roboto Bold',
      ),
    );

    PictureRecorder recorder = new PictureRecorder();
    Canvas c = new Canvas(recorder);

    tp.layout();
    tp.paint(c, const Offset(20.0, 10.0));

    Picture p = recorder.endRecording();
    ByteData pngBytes =
        await (await p.toImage(tp.width.toInt() + 40, tp.height.toInt() + 20)).toByteData(format: ImageByteFormat.png);

    Uint8List data = Uint8List.view(pngBytes.buffer);

    return BitmapDescriptor.fromBytes(data);
  }
// ekiplerin konumları alma
  Future<void> getData() async {
    try {
      List res = await NetworkManager.instance
          .httpPost(path: "/api/lst/ekipkonumlst", data: {}, model: new EkipKonum(), token: widget.user.token);
      List<EkipKonum> konumlar = res.map((e) => e as EkipKonum).toList();

      LocationData loc = await getLoation();

      cameraPosition = new CameraPosition(
          target: loc == null
              ? const LatLng(
                  40.985534,
                  37.880613,
                )
              : new LatLng(loc.latitude, loc.longitude),
          zoom: 15);
      for (var i in konumlar) {
        BitmapDescriptor bitmapDescriptor = await createCustomMarkerBitmap(i.ekipTanimi);
        _markers.add(new Marker(
            markerId: new MarkerId(i.id.toString()),
            position: i.geoKonum.pointToLatLng,
            icon: bitmapDescriptor,
            onTap: () {
              _customInfoWindowController.addInfoWindow(
                buildInfoWindow(i, i.geoKonum.pointToLatLng),
                i.geoKonum.pointToLatLng,
              );
            }));
      }
      loading = false;
    } catch (e) {
      loading = false;
      err = e.toString();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: const CircularProgressIndicator.adaptive(),
              ),
            )
          : err.isNotEmpty
              ? Center(
                  child: Text(err),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.satellite,
                      initialCameraPosition: cameraPosition,
                      markers: _markers,
                      onTap: (position) {
                        _customInfoWindowController.hideInfoWindow();
                      },
                      onCameraMove: (position) {
                        _customInfoWindowController.onCameraMove();
                      },
                      onMapCreated: (GoogleMapController controller) async {
                        _customInfoWindowController.googleMapController = controller;
                      },
                    ),
                    Positioned(
                      top: 40,
                      left: 10,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    CustomInfoWindow(
                      controller: _customInfoWindowController,
                      height: 100,
                      width: 150,
                      offset: 50,
                    ),
                  ],
                ),
    );
  }

  Widget buildInfoWindow(EkipKonum istasyon, LatLng pos) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => UygulamaDetayView(
                            user: widget.user,
                            sorgu:
                                " and EkipTanimi='${istasyon.ekipTanimi}' and baslangicTarihi>'${DateTime.now().add(const Duration(days: -1)).toString().dartDateToStr}' and baslangicTarihi<'${DateTime.now().toString().dartDateToStr}'",
                          )));
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      istasyon.tarih.dateToStr,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      istasyon.ekipTanimi,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        Triangle.isosceles(
          edge: Edge.BOTTOM,
          child: Container(
            color: Colors.green,
            width: 20.0,
            height: 10.0,
          ),
        ),
      ],
    );
  }

  Future<LocationData> getLoation() async {
    location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    //LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    LocationData loc = await location.getLocation();
    return loc;
  }
}
