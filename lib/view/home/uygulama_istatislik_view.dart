import 'dart:developer';

import '../chart/chart_view.dart';
import '../widgets/category_list.dart';
import 'package:flutter/material.dart';
import '../../extansion/widget_extansion.dart';
import '../../mixins/helper.dart';
import '../../model/grupmodel.dart';
import '../../model/usermodel.dart';
import '../uygulamadetay/uygulama_list.dart';
import 'istatislik_state.dart';
import 'toggle_buttons.dart';

class IstatisliKView extends StatelessWidget {
  final UserModel user;
  final String start;
  final String finish;
  final IstatislikState state;
  const IstatisliKView({Key key, this.user, this.start, this.finish, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    state.getData(user, start, finish);

    return RefreshIndicator(
      onRefresh: () => state.getData(user, start, finish),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // MOBIL KULLANICI DEĞİLSE 
              if (user.tipi != "Mobil Kullanıcı")
                CustomToggleButton(
                  state: state,
                  selectedIndex: state.getGroup,
                ),
                // BELİRLETİGİMİZ DEĞİŞKENİ DİNLER 
                // DEĞİŞKENDE DEĞİŞİKLİK OLDUGU ZAMAN BUİLDER METODU İÇERİSİNİ YENİDEN RENDER EDER
              StreamBuilder(
                stream: state.group,
                builder: (context, snap) {
                  if (snap.hasError) {
                    if (snap.hasError) {
                      return Helper.customError(snap.error);
                    }
                  }
                  if (snap.hasData) {
                    if (snap.data == 3) {
                      return buildListViewEkip(state, context);
                    }
                    return buildListStream(state);
                  }
                  return const Text("");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListViewEkip(IstatislikState state, BuildContext context) {
    return Column(
      children: [
        buildTotalRow(context),
        StreamBuilder<List<String>>(
            stream: state.ekipler,
            initialData: const [],
            builder: (context, snapshot) {
              return CategoryList(categoryList: snapshot.data ?? [], onPressed: state.filterGropedData);
            }),
        StreamBuilder<List<String>>(
            stream: state.ekipler2,
            initialData: const [],
            builder: (context, snapshot) {
              var d = snapshot.data ?? [];
              // d.sort((String a, String b) => a.compareTo(b));
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: CategoryList(categoryList: d, onPressed: state.filterGropedData2),
              );
            }),
        buildListViewAll(state),
      ],
    );
  }

  Widget buildListViewAll(IstatislikState state) {
    return StreamBuilder(
        stream: state.ekipGrup,
        builder: (context, snap) {
          if (snap.hasError) {
            return Helper.customError(snap.error);
          }
          if (snap.hasData) {
            List<GrupModel> data = snap.data;
            if (data.isEmpty) {
              return Helper.emptyMessage("Uygulama bulunamadı.");
            }
            return Column(children: [
              BuildCard(user, new GrupModel(grpAdi3: "TÜMÜ", sayi: state.getFilterTotal.toInt()),
                  color: Colors.green,
                  sorgu: start == null || finish == null
                      ? " and EkipTanimi='${state.filter2.value}'"
                      : " and EkipTanimi='${state.filter2.value}' and baslangicTarihi>'$start' and baslangicTarihi<'$finish'"),
              ...List.generate(data.length, (index) {
                return BuildCard(
                  user,
                  data[index],
                  start: start,
                  finish: finish,
                );
              })
            ]);
          }
          return const CircularProgressIndicator();
        });
  }

  Widget buildListStream(state) {
    return StreamBuilder(
        stream: state.grupedDataList,
        builder: (context, snap) {
          if (snap.hasError) {
            return Helper.customError(snap.error);
          }
          if (snap.hasData) {
            List<Ilce> list = snap.data;
            if (list.isEmpty) {
              return Helper.emptyMessage("Uygulama bulunamadı.");
            }
            return buildListViewGroup(list, state, context);
          }
          return const CircularProgressIndicator();
        });
  }

  Widget buildListViewGroup(List<Ilce> list, IstatislikState state, context) {
    return Column(children: [
      buildTotalRow(context),
      ...List.generate(list.length, (index) {
        var toplam = 0;
        for (var element in list[index].data) {
          for (var e in element.data) {
            toplam += e.sayi;
          }
        }
        return Card(
          elevation: 20,
          child: ExpansionTile(
            title: Text(list[index].adi),
            subtitle: Text("$toplam tane"),
            children: [
              // for (int ekip = 0; ekip < list[index].data.length; ekip++)
              ...List.generate(list[index].data.length, (ekip) {
                var toplam2 = 0;
                for (var element in list[index].data[ekip].data) {
                  toplam2 += element.sayi;
                }
                return Card(
                  elevation: 15,
                  child: ExpansionTile(
                          title: Text(list[index].data[ekip].adi),
                          subtitle: Text("$toplam2 tane"),
                          children: List.generate(list[index].data[ekip].data.length, (i) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) {
                                  return UygulamaDetayView(
                                      user: user, model: list[index].data[ekip].data[i], start: start, finish: finish);
                                }));
                              },
                              child: Card(
                                      elevation: 10,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Text(state.getGroup != 1
                                                ? list[index].data[ekip].data[i].grpAdi2
                                                : list[index].data[ekip].data[i].grpAdi3),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(list[index].data[ekip].data[i].sayi.toString() + " tane "),
                                          ),
                                          const Expanded(
                                            flex: 1,
                                            child: Icon(Icons.arrow_forward_ios),
                                          ),
                                        ],
                                      ).paddingOnly(top: 16.0, bottom: 16.0, left: 5.0, right: 5.0))
                                  .paddingAll(),
                            );
                          }).toList())
                      .paddingAll(),
                );
              }),
            ],
          ).paddingAll(),
        ).paddingAll();
      }).toList()
    ]);
  }

  Widget buildTotalRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text("Toplam Yapılan Uygulama ${state.toplam.value}").paddingAll()),
        GestureDetector(
          onTap: () {
            Navigator.push(context, new MaterialPageRoute(builder: (c) {
              return ChartView(
                user: user,
                state: state,
              );
            }));
          },
          child: const SizedBox(
            width: 30,
            height: 30,
            child: Image(
              image: AssetImage("assets/chart.png"),
            ),
          ),
        )
      ],
    ).paddingAll();
  }
}

class BuildCard extends StatelessWidget {
  final UserModel user;
  final GrupModel data;
  final String start;
  final String finish;
  final Color color;
  final String sorgu;
  const BuildCard(this.user, this.data, {this.start, this.finish, this.color, this.sorgu});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) {
          return UygulamaDetayView(
            user: user,
            model: data,
            start: start,
            finish: finish,
            sorgu: sorgu,
          );
        }));
      },
      child: Card(
          elevation: 10,
          color: color,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.grpAdi3).paddingAll(),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //         flex: 1,
                    //         child: Text(
                    //           "İlçe:",
                    //           style: TextStyle(fontWeight: FontWeight.bold),
                    //         )),
                    //     Expanded(flex: 5, child: Text(data[index].grpAdi)),
                    //   ],
                    // ).paddingAll(),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //         flex: 1,
                    //         child: Text(
                    //           "Ekip:",
                    //           style: TextStyle(fontWeight: FontWeight.bold),
                    //         )),
                    //     Expanded(flex: 5, child: Text(data[index].grpAdi2)),
                    //   ],
                    // ).paddingAll(),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text("${data.sayi.toString()} tane"),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ],
          ).paddingOnly(top: 16.0, bottom: 16.0, left: 8.0, right: 8.0)),
    );
  }
}
