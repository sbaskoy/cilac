import 'dart:developer';

import '../widgets/category_list.dart';
import '../widgets/uygulama_details_card.dart';
import 'package:flutter/material.dart';

import 'package:timelines/timelines.dart';

import '../../extansion/string_extansion.dart';
import '../../extansion/widget_extansion.dart';
import '../../mixins/helper.dart';
import '../../model/usermodel.dart';
import '../../model/uygulamadetay.model.dart';

import 'uygulama_detay_state.dart';

class UygulamaDetayWidget extends StatelessWidget {
  final UserModel user;
  final String sorgu;
  UygulamaDetayWidget({Key key, this.user, this.sorgu}) : super(key: key);
  final UygulamaDetayState state = new UygulamaDetayState();
  @override
  Widget build(BuildContext context) {
    log("UYGULAMA DETAY");
    state.getData(user, data: sorgu);
    return Center(
      child: StreamBuilder(
          stream: state.sikayetList,
          builder: (context, snap) {
            if (snap.hasError) {
              return Helper.customError(snap.error).paddingAll();
            }
            if (snap.hasData) {
              List<UygulamaDetay> data = snap.data;
              if (data.isEmpty) {
                return const Text("Henüz uygulama yapılmamış");
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CategoryList(categoryList: const ["Tümü", "Zaman Çizgisi"], onPressed: state.onChangeTab),
                  ),
                  StreamBuilder<DetayState>(
                      stream: state.pageState,
                      initialData: DetayState.ALL,
                      builder: (context, snapshot) {
                        if (snapshot.data == DetayState.ALL) {
                          return Expanded(child: buildListView(data));
                        }
                        return Expanded(child: buildTimeLine(data));
                      }),
                ],
              );
            }
            return const CircularProgressIndicator();
          }),
    );
  }

  Widget buildTimeLine(List<UygulamaDetay> data) {
    return Timeline.tileBuilder(
      builder: TimelineTileBuilder.fromStyle(
        contentsAlign: ContentsAlign.alternating,
        connectorStyle: ConnectorStyle.dashedLine,
        contentsBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (c) => Dialog(
                          child: UygulamaDetayCard(data[index], user),
                        ));
              },
              child: Container(
                child: ListTile(
                    title: Text(
                      data[index].baslangicTarihi.dateToStr,
                      style: const TextStyle(fontSize: 18),
                    ),
                    subtitle: Text(data[index].uygulamaTanimi)),
              ),
            )),
        itemCount: data.length,
      ),
    );
  }

  Widget buildListView(List<UygulamaDetay> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var d = data[index];
        return UygulamaDetayCard(d, user);
      },
    );
  }
}
