import '../../model/usermodel.dart';
import '../../model/uygulamadetay.model.dart';
import '../showimage/show_image_view.dart';
import '../showmap/show_map_view.dart';
import '../uygulamadetay/sikayet_dialog.dart';
import 'package:flutter/material.dart';
import '../../extansion/string_extansion.dart';
import '../../extansion/widget_extansion.dart';

class UygulamaDetayCard extends StatelessWidget {
  final UygulamaDetay d;
  final UserModel user;
  const UygulamaDetayCard(this.d, this.user);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 20,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            d.uygulamaTanimi,
            style: const TextStyle(fontSize: 16),
          ).paddingAll(),
          Text(
            d.adres,
            style: const TextStyle(fontSize: 15),
          ).paddingAll(),
         const Divider(
            height: 1,
            thickness: 1,
          ),
          Container(
              margin: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: SizedBox(
                        child: Column(
                          children: [
                            buildRowText("Yapan Personel:", d.adiSoyadi).paddingAll(),
                            if (d.pSikayetID != -1) buildRowText("Şikayeti Yapan:", d.sikayetEden).paddingAll(),
                            if (d.pSikayetID != -1) buildRowText("Şikayeti Tarihi:", d.sikayetTarihi).paddingAll(),
                            if (d.baslangicTarihi.isNotEmpty)
                              buildRowText("Uygulama Tarihi:", d.baslangicTarihi.dateToStr).paddingAll(),

                            buildRowText("Ekip Tanımı:", d.ekipTanimi).paddingAll(),
                            if (d.aciklama.nullOrEmpty) buildRowText("Acıklama:", d.aciklama).paddingAll(),
                            if (d.kaynakTurleri.nullOrEmpty)
                              buildRowText("Kaynak Türleri:", d.kaynakTurleri).paddingAll(),
                            if (d.ilaclar.nullOrEmpty) buildRowText("İlaçlar:", d.ilaclar).paddingAll(),
                            if (d.ekipmanlar.nullOrEmpty) buildRowText("Ekipmanlar:", d.ekipmanlar).paddingAll(),
                            if (d.yontemler.nullOrEmpty) buildRowText("Yöntemler:", d.yontemler).paddingAll(),
                            if (d.alanlar.nullOrEmpty) buildRowText("Alanlar:", d.alanlar).paddingAll(),
                            if (d.hedefZararli.nullOrEmpty) buildRowText("Hedef Zararlı:", d.hedefZararli).paddingAll(),
                            if (d.mucadeleSekli.nullOrEmpty)
                              buildRowText("Mücadele Şekli:", d.mucadeleSekli).paddingAll(),

                            // buildRowText("Konu:", d).paddingAll(),
                          ],
                        ),
                      )),
                ],
              )),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) {
                      return ShowImageView(
                        images: d.resimler,
                      );
                    }));
                  },
                  child: const Text("Resimler")),
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) {
                      return ShowMapView(
                        points: d.konumlar,
                      );
                    }));
                  },
                  child: const Text("Haritada Göster")),
              if (d.pSikayetID != -1)
                TextButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (c) {
                            return Dialog(
                              child: SikayetDialog(
                                sikayetID: d.pSikayetID,
                                user: user,
                              ),
                            );
                          });
                    },
                    child: const Text("Şikayet Detayı"))
            ],
          ),
        ],
      ),
    ).paddingAll();
  }

  Widget buildRowText(String str1, String str2) {
    return Row(
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
    );
  }
}
