import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../extansion/string_extansion.dart';

class ShowMapView extends StatefulWidget {
  final List<String> points;

  const ShowMapView({Key key, this.points}) : super(key: key);
  @override
  _ShowMapViewState createState() => _ShowMapViewState();
}

class _ShowMapViewState extends State<ShowMapView> {
  CameraPosition initCameraPos;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  @override
  void initState() {
    super.initState();
    setData();
  }

  void setData() {
    initCameraPos = new CameraPosition(target: widget.points.first.pointToLatLng, zoom: 17);
    List<LatLng> pointList = [];
    for (var i in widget.points) {
      
     
      pointList.add(i.pointToLatLng);
    }
     setState(() {
        _markers.add(new Marker(markerId: const MarkerId("start"), position: widget.points.first.pointToLatLng));
        _markers.add(new Marker(markerId: const MarkerId("stop"), position: widget.points.last.pointToLatLng));
      });
    setState(() {
      _polyLines.add(new Polyline(polylineId: const PolylineId("route1"),
      width:5 ,
       points: pointList, color: Colors.green));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uygulama Konumu"),
      ),
      body: initCameraPos == null
          ? const Text("Yükleniyor")
          : GoogleMap(
              initialCameraPosition: initCameraPos,
              polylines: _polyLines,
              markers: _markers,
              mapType: MapType.hybrid,
            ),
    );
  }
}
