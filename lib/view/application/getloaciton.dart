import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GetLocation extends StatefulWidget {
  final LatLng cord;
  final double heigth;
  const GetLocation({Key key, this.cord, this.heigth});
  @override
  _GetLocationState createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> {
  CameraPosition cameraPosition;
  final Set<Marker> _markers = {};
  final Completer<GoogleMapController> _controller = new Completer();
  LatLng selectedCord;
  final key = GlobalKey<ScaffoldState>();
  Location location;
  @override
  void initState() {
    super.initState();

    _getLocation();
  }

  Future<void> _getLocation() async {
    LocationData loc = await getLoation();
    cameraPosition = new CameraPosition(
        target: widget.cord ??
            (loc == null
                ? const LatLng(
                    40.985534,
                    37.880613,
                  )
                : new LatLng(loc.latitude, loc.longitude)),
        zoom: 15);
    setState(() {
      cameraPosition = cameraPosition;
    });
    if (widget.cord != null) {
      setState(() {
        selectedCord = widget.cord;
        _markers.add(new Marker(
          markerId: const MarkerId("selectedPos"),
          position: widget.cord,
          infoWindow: new InfoWindow(
              title: "Şeçili Konum", snippet: "lat: ${widget.cord.latitude}\n\nlng:${widget.cord.longitude}"),
        ));
      });
    } else {
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.heigth ?? 400,
      child: cameraPosition != null
          ? Column(
              children: [
                Expanded(
                  child: GoogleMap(
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
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(selectedCord);
                    },
                    child: const Text("Kapat"))
              ],
            )
          : const Center(
              child: Text("Konum Bekleniyor"),
            ),
    );
  }
}
