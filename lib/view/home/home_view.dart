import 'dart:developer';

import 'istatislik_state.dart';
import '../widgets/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/base_state.dart';
import '../../model/usermodel.dart';
import '../widgets/drawer.dart';
import 'uygulama_istatislik_view.dart';
import '../../extansion/string_extansion.dart';

class HomeView extends StatefulWidget {
  final UserModel user;

  const HomeView({Key key, this.user}) : super(key: key);
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView> {
  String start;

  String finish;

  @override
  void initState() {
    super.initState();
    setDate();
  }

  void setDate() {
    // GÜNLÜK İSTATİSLİK İÇİN TARİH AYARLAMASI
    this.start = DateTime.now().toString().dartDateToStr;
    var arr = start.split(" ");
    arr.last = "00:00";
    start = arr.join(" ");
    this.finish = DateTime.now().toString().dartDateToStr;
  }

  IstatislikState state;
  Future<void> showFilterDialog() async {
    // FİLTRE İÇİN TARİH ŞEÇME DİALOGUNU AÇAR
    if (this.start == null || this.finish == null) {
      setDate();
    }
    var filteredData = await showDialog(
            context: context,
            builder: (c) {
              return Dialog(
                child: FilterDialog(start: this.start, finish: this.finish),
              );
            }) ??
        {};

    var start = filteredData["start"];
    var finish = filteredData["finish"];
    log(start);
    log(finish);
    setState(() {
      this.start = start;
      this.finish = finish;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (state == null) {
      state = Provider.of<IstatislikState>(context);
      // KULLANICI TİPİNE GÖRE EKRANI DEĞİŞTİRİR
      if (widget.user.tipi == "Mobil Kullanıcı") {
        state.changeGrooup(3);
      } else {
        state.changeGrooup(2);
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Anasayfa"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () => state.getData(widget.user, start, finish), icon: const Icon(Icons.refresh)),
            GestureDetector(
              onTap: showFilterDialog,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Image(
                  image: AssetImage("assets/filter.png"),
                ),
              ),
            ),
          ],
        ),
        // MENU
        drawer: BuildDrawer(widget: widget),
        body: IstatisliKView(user: widget.user, start: start, finish: finish, state: state));
  }
}
