import '../../model/grupmodel.dart';
import '../../model/usermodel.dart';
import '../home/istatislik_state.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _SalesData {
  _SalesData(this.name, this.value);

  final String name;
  final double value;
}

class ChartView extends StatefulWidget {
  final UserModel user;
  final IstatislikState state;
  const ChartView({Key key, this.user, this.state}) : super(key: key);

  @override
  _ChartViewState createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  List<_SalesData> data = [];
  int selectedIndex = 1;
  var loading = true;
  String chartTitle = "Ekiplere göre yapılan uygulamalar";
  @override
  void initState() {
    super.initState();
    setChartData();
    loading = false;
  }

  void setChartData() {
    List<GrupModel> _data = widget.state.getDataList;
    data = [];
    data = getDistinct(_data, selectedIndex);
  }

  List<_SalesData> getDistinct(List<GrupModel> list, int index) {
    var idSet = <String>{};
    var distinct = <_SalesData>[];
    for (var d in list) {
      String val = "";
      if (index == 0) {
        val = d.grpAdi;
      } else if (index == 1) {
        val = d.grpAdi2;
      } else {
        val = d.grpAdi3;
      }

      if (idSet.add(val)) {
        var a = list.where((e) {
          if (index == 0) {
            return e.grpAdi == val;
          } else if (index == 1) {
            return e.grpAdi2 == val;
          } else {
            return e.grpAdi3 == val;
          }
        }).toList();
        double toplam = a.fold(0, (previousValue, element) => previousValue + element.sayi);
        distinct.add(new _SalesData(val, toplam));
      }
    }
    return distinct;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Grafikler'),
        ),
        body: loading
            ? const Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator.adaptive(),
                ),
              )
            : Column(children: [
                Row(
                  children: [
                    buildToogleButton("İlce", 0),
                    buildToogleButton("Ekip", 1),
                    buildToogleButton("Uygulama", 2),
                  ],
                ),
                Expanded(
                  child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      primaryYAxis: NumericAxis(
                        majorGridLines: const MajorGridLines(width: 0),
                      ),
                      title: ChartTitle(text: chartTitle),
                      //legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                      ),
                      series: <ChartSeries<_SalesData, String>>[
                        ColumnSeries<_SalesData, String>(
                            width: 0.6, // Width of the bars
                            spacing: 0.3,
                            dataSource: data,
                            xValueMapper: (_SalesData sales, _) => sales.name,
                            yValueMapper: (_SalesData sales, _) => sales.value,
                            name: 'Uygulama',
                            dataLabelSettings: const DataLabelSettings(isVisible: true))
                      ]),
                ),
              ]));
  }

  Widget buildToogleButton(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          selectedIndex = index;

          if (selectedIndex == 0) {
            chartTitle = "İlcelere göre yapılan uygulamalar";
          } else if (selectedIndex == 1) {
            chartTitle = "Ekiplere göre yapılan uygulamalar";
          } else {
            chartTitle = "Yapılan uygulamalar";
          }
          setChartData();
          setState(() {});
        },
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: selectedIndex == index ? Colors.grey : Colors.transparent, border: Border.all(color: Colors.grey)),
          child: Text(
            text,
            style: TextStyle(color: selectedIndex == index ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
