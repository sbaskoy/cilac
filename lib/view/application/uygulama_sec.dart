import 'package:cilac/view/kaynakkayit/kaynak_kayit_view.dart';

import '../../localdb/uygulama_tanim_db.dart';
import '../../model/usermodel.dart';
import '../../model/uygulamatanim.dart';
import '../savelocalview.dart/save_local_view.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'make_application_view.dart';

class UygulamaSec extends StatefulWidget {
  final UserModel model;
  final int sikayetID;
  final LatLng cord;
  final int kaynakID;
  const UygulamaSec({Key key, this.model, this.sikayetID, this.cord, this.kaynakID}) : super(key: key);

  @override
  _UygulamaSecState createState() => _UygulamaSecState();
}

class _UygulamaSecState extends State<UygulamaSec> {
  List<UygulamaTanim> tanimList;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    List list = await new UygulamaTanimDb().getAll();

    if (widget.kaynakID == null) {
      tanimList = list.map((e) => e as UygulamaTanim).toList();

      tanimList.removeWhere((element) => element.uygulamaTanimi == "KARASİNEK KAYNAĞI");
      tanimList.removeWhere((element) => element.uygulamaTanimi == "SİVRİSİNEK KAYNAĞI");
    } else {
      tanimList = list.map((e) => e as UygulamaTanim).where((element) => (element.ilaclar ?? "") != "").toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Uygulama Seç"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: tanimList == null
              ? const CircularProgressIndicator()
              : tanimList.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Uygulama Bulunamadı"),
                        TextButton(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SaveLocalView(
                                            user: widget.model,
                                          )));
                              setState(() {
                                tanimList = null;
                              });
                              getData();
                            },
                            child: const Text("Uygulama Tanımlarımı Güncelle"))
                      ],
                    )
                  : Column(
                      children: List.generate(
                      tanimList.length,
                      (index) => GestureDetector(
                        onTap: () {
                          if (tanimList[index].uygulamaTanimi == "KAYNAK KAYDI") {
                            
                            Navigator.push(context, MaterialPageRoute(builder: (c) {
                              return KaynakKayitView(user: widget.model);
                            }));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MakeApplicationView(
                                        model: widget.model,
                                        sikayetID: widget.sikayetID,
                                        cord: widget.cord,
                                        selectedModel: tanimList[index])));
                          }
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(tanimList[index].uygulamaTanimi),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    )),
        ),
      ),
    );
  }
}
