import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../extansion/widget_extansion.dart';
import 'image_details_view.dart';

class ShowImageView extends StatelessWidget {
  final List<String> images;

  const ShowImageView({Key key, this.images}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Resimler"),
        ),
        body: images.isEmpty
            ? const Center(
                child: Text("Resim yok"),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200, childAspectRatio: 3 / 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      onTap(
                        context,
                        CachedNetworkImage(
                          imageUrl: "http://" + images[index],
                          placeholder: (context, url) =>
                              Container(alignment: Alignment.center, child: const CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all()),
                      child: CachedNetworkImage(
                        imageUrl: "http://" + images[index],
                        placeholder: (context, url) =>
                            Container(alignment: Alignment.center, child: const CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  );
                }).paddingAll());
  }

  onTap(context, Widget img) {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return DetailScreen(
          img: img,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }
}
