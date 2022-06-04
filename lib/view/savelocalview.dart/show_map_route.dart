import '../../extansion/string_extansion.dart';
import '../../model/uygulama_konum.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShowMap extends StatefulWidget {
  final UygulamaKonumlar route;
  const ShowMap({Key key, this.route}) : super(key: key);

  @override
  _ShowMapState createState() => _ShowMapState();
}

class _ShowMapState extends State<ShowMap> {
  final Set<Polyline> _polyLines = {};
  final Set<Marker> _markers = {};
  CameraPosition cameraPosition;
  @override
  void initState() {
    super.initState();
    LatLng start = widget.route.data.first.geoKonum.pointToLatLng;
    cameraPosition = new CameraPosition(target: new LatLng(start.latitude, start.longitude), zoom: 15);
    setState(() {
      cameraPosition = cameraPosition;
    });
    List<LatLng> points = [];
    for (var i in widget.route.data) {
      points.add(i.geoKonum.pointToLatLng);
    }
    _markers.add(new Marker(
        markerId: const MarkerId("start"),
        position: points.first,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Başlangıç")));
    _markers.add(new Marker(
        markerId: const MarkerId("last"),
        position: points.last,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "Bitiş")));
    _polyLines.add(new Polyline(polylineId: const PolylineId("route"), points: points, color: Colors.green, width: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uygulama Rotası"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: cameraPosition == null
          ? const Center(
              child: Text("Yükleniyor"),
            )
          : GoogleMap(
              initialCameraPosition: cameraPosition,
              polylines: _polyLines,
              markers: _markers,
            ),
    );
  }
}
