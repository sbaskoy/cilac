
import 'package:flutter/material.dart';

import '../../global/global_function.dart';
import 'selectedimage.dart';

// ignore: must_be_immutable
class SelectPhotoView extends StatefulWidget {
 final List<SelectedImageModel> selectedImage;
  const SelectPhotoView({Key key,this.selectedImage});
  @override
  _SelectPhotoViewState createState() => _SelectPhotoViewState();
}

class _SelectPhotoViewState extends State<SelectPhotoView> {
  List<SelectedImageModel> imageList;

  @override
  void initState() {
    super.initState();
    imageList = widget.selectedImage ?? [new SelectedImageModel()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Resim Seç"),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.of(context).pop(imageList),
        ),
        // brightness: Platform.isIOS ? Brightness.dark : Brightness.light
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, childAspectRatio: 3 / 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
            itemCount: imageList.length,
            itemBuilder: (BuildContext ctx, index) {
              return GestureDetector(
                  onTap: () => showPicker(context, imageList[index]),
                  child: imageList[index].getWidget(() {
                    if (imageList[index].imagePath != null) {
                      setState(() {
                        imageList.remove(imageList[index]);
                        if (!imageList.any((element) => element.imagePath == null)) {
                          imageList.add(new SelectedImageModel());
                        }
                      });
                    }
                  }));
            }),
      ),
    );
  }

  void showPicker(context, SelectedImageModel currentImage) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: SizedBox(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Galeriden'),
                      onTap: () async {
                        String path = await imgFromGallery(context, 1);
                        if (path == null) {
                          Navigator.of(context).pop();
                          return;
                        }
                        setImage(path, currentImage);
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Kameradan'),
                    onTap: () async {
                      String path = await imgFromCamera(context);
                      if (path == null) {
                        Navigator.of(context).pop();
                        return;
                      }
                      setImage(path, currentImage);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void setImage(String path, SelectedImageModel currentImage) {
    if (currentImage.imagePath != null) {
      setState(() {
        currentImage.imagePath = path;
      });
      return;
    }
    setState(() {
      if (imageList[imageList.length - 1].imagePath == null) {
        imageList[imageList.length - 1].imagePath = path;
      } else {
        imageList.add(new SelectedImageModel(imagePath: path));
      }
    });
    if (imageList.isNotEmpty && imageList.length < 3) {
      setState(() {
        imageList.add(new SelectedImageModel());
      });
    }
  }
}
