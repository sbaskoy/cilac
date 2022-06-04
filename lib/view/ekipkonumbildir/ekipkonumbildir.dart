import 'dart:async';

import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../base/network_manager.dart';
import '../../model/ekipinfomodel.dart';
import '../../model/usermodel.dart';
import '../../model/uygulamakayit.dart';
import '../functions/global_functions.dart';
import '../home/home_view.dart';

class EkipKonumBildir extends StatefulWidget {
  final UserModel user;

  const EkipKonumBildir({Key key, this.user}) : super(key: key);
  @override
  _EkipKonumBildirState createState() => _EkipKonumBildirState();
}

class _EkipKonumBildirState extends State<EkipKonumBildir> {
  CameraPosition cameraPosition;
  final Set<Marker> _markers = {};
  final Completer<GoogleMapController> _controller = new Completer();
  LatLng selectedCord;
  bool sending = false;
  Location location;
  @override
  void initState() {
    super.initState();

    _getLocation();
  }

// konumu POİNT OLARAK alma
  Future<void> _getLocation() async {
   LocationData loc = await getLoation();
    cameraPosition = new CameraPosition(
        target: loc == null
            ? const LatLng(
                40.985534,
                37.880613,
              )
            : new LatLng(loc.latitude, loc.longitude),
        zoom: 15);
    setState(() {
      cameraPosition = cameraPosition;
    });
          if (loc != null) {
        var pos = new LatLng(loc.latitude, loc.longitude);
        setState(() {
          selectedCord = pos;
          _markers.add(new Marker(
            markerId: const MarkerId("selectedPos"),
            position: pos,
            infoWindow: new InfoWindow(title: "Şeçili Konum", snippet: "lat: ${pos.latitude}\n\nlng:${pos.longitude}"),
          ));
        });
      }
  }
// konum iznini alma
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

  void getCord(LatLng cord) {
    setState(() {
      selectedCord = cord;

      _markers.clear();

      _markers.add(new Marker(
        markerId: const MarkerId("selectedPos"),
        position: cord,
        infoWindow: new InfoWindow(title: "Şeçili Konum", snippet: "lat: ${cord.latitude}\n\nlng:${cord.longitude}"),
      ));
    });
  }
// KAyıt etme
  void sendCord() async {
    try {
      setState(() {
        sending = true;
      });
      String deviceInfoString = "";
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        deviceInfoString =
            "Platform IOS -- Baglanılan model ${iosDeviceInfo.model} -- Name ${iosDeviceInfo.name} -- System version ${iosDeviceInfo.systemVersion} -- System Name ${iosDeviceInfo.systemName} ";
      } else {
        AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
        deviceInfoString =
            "Platform ANDROID -- Baglanılan CİHAZ ${androidDeviceInfo.device} -- AndroidID ${androidDeviceInfo.androidId} -- Model ${androidDeviceInfo.model} ";
      }

      EkipKonum konum = new EkipKonum(
          id: -1,
          pEkipID: -1,
          pPersonID: widget.user.id,
          tarih: new DateTime.now().toString().replaceAll(" ", "T"),
          geoKonum: "POINT(${selectedCord.latitude} ${selectedCord.longitude})",
          cihazInfo: deviceInfoString);

      ReturnModel model = await NetworkManager.instance
          .httpPost(path: "api/act/PEKonum", model: ReturnModel(), data: konum.toJson(), token: widget.user.token);
      setState(() {
        sending = false;
      });

      if (model.durumKodu == 0) {
        await showAlertDialog(context, "Başarılı bir şekilde kayıt edildi", Icons.done, Colors.green, onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => HomeView(user: widget.user)));
        });
      } else if (model.durumKodu > 100) {
        await showAlertDialog(context, "Bir hata oluştu.Mesaj ${model.durumMesaj}", Icons.error, Colors.red);
      } else if (model.iD > 0 && model.durumKodu == 1) {
        await showAlertDialog(context, "Bilgiler kayıt edildi ama resimler edilemedi", Icons.done, Colors.amber);
      } else {
        await showAlertDialog(context, "Bilinmeyen bir hata oluştu", Icons.error, Colors.amber);
      }
    } catch (e) {
      setState(() {
        sending = false;
      });
      await showAlertDialog(context, "Bir hata oluştu.Hata $e", Icons.done, Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: const Text(
          "Konum Seçiniz",
        ),
      ),
      body: Container(
        child: cameraPosition != null
            ? Stack(
                children: [
                  GoogleMap(
                    //key:_scaffoldKey ,
                    initialCameraPosition: cameraPosition,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    mapType: MapType.satellite,
                    markers: _markers,
                    myLocationButtonEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _controller.complete(controller);
                      });
                    },
                    onTap: (cord) {
                      getCord(cord);
                    },
                  ),
                ],
              )
            : const Center(
                child: Text("Konum Bekleniyor"),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sending ? null : sendCord,
        child: const Icon(Icons.send),
      ),
    );
  }
}
