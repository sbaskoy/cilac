import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as p;

// import '../../../constant/component/global_component.dart';

class GetPhoto extends StatefulWidget {
  const GetPhoto({Key key}) : super(key: key);
  @override
  _GetPhotoState createState() => _GetPhotoState();
}

class _GetPhotoState extends State<GetPhoto> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  CameraDescription camera;
  String imagePath = "";
  bool showCamera = true;
  @override
  void initState() {
    super.initState();
    getCamera();
  }

  Future<void> getCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.low,
      );

      _initializeControllerFuture = _controller.initialize();
      setState(() {
        camera = firstCamera;
      });
    } catch (_) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !showCamera
          ? buildImagePanel()
          : Stack(
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      return SizedBox(height: MediaQuery.of(context).size.height, child: CameraPreview(_controller));
                    } else {
                      return const Center(
                          child: CircularProgressIndicator(
                        backgroundColor: Colors.black,
                      ));
                    }
                  },
                ),
                Positioned(
                    bottom: 20,
                    right: 10,
                    left: 10,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () => Navigator.pop(context, null),
                          ),
                          IconButton(
                            icon: const Icon(Icons.done),
                            onPressed: takePicture,
                          )
                        ],
                      ),
                    ))
              ],
            ),
    );
  }

  Future<void> takePicture() async {
    try {
      Directory appDocDir = await p.getApplicationDocumentsDirectory();

      String appDocPath = appDocDir.path + "/media";
      await Directory(appDocPath).create(recursive: true);
      await _initializeControllerFuture;
      // String path = getRandomString(20) + ".jpeg";
      XFile file = await _controller.takePicture();
      setState(() {
        imagePath = file.path;
        showCamera = false;
      });
    // ignore: empty_catches
    } catch (e) {
     
    }
  }

  Widget buildImagePanel() {
    return Stack(
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            )),
        Positioned(
            bottom: 20,
            right: 10,
            left: 10,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        imagePath = "";
                        showCamera = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.done),
                    onPressed: () => Navigator.pop(context, imagePath),
                  )
                ],
              ),
            ))
      ],
    );
  }
}
