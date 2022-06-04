import 'package:flutter/material.dart';

import '../../model/selecteditem.dart';

class SelectView extends StatefulWidget {
  final String title;
  final List list;
  final List<SelectedItem> selectedItemList;
  const SelectView({Key key, this.title, this.list, this.selectedItemList}) : super(key: key);
  @override
  _SelectViewState createState() => _SelectViewState();
}

class _SelectViewState extends State<SelectView> {
  List<SelectedItem> selectedItemList;
  @override
  void initState() {
    super.initState();
    selectedItemList = widget.selectedItemList ?? [];
    if (widget.selectedItemList == null) {
      for (Map map in widget.list) {
        int id;
        String value;
        for (String key in map.keys) {
          if (key == "id") {
            id = map[key];
          }
          if (key.contains("Adi")) {
            value = map[key];
          }
        }
        selectedItemList.add(new SelectedItem(id: id, adi: value, selected: false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void changed(int i) {
      var item = selectedItemList.firstWhere((element) => element.id == selectedItemList[i].id);
      setState(() {
        selectedItemList[i].selected = selectedItemList[i].selected ? false : true;
        item.selected = selectedItemList[i].selected;
      });
    }

    return SizedBox(
     height: 400,
      child: selectedItemList == null
          ? const CircularProgressIndicator()
          : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: selectedItemList.length,
                        itemBuilder: (c, i) {
                          return GestureDetector(
                            onTap: () {
                              changed(i);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(width: 1), borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                title: Text(
                                  selectedItemList[i].adi,
                                ),
                                leading: Checkbox(
                                  value: selectedItemList[i].selected,
                                  onChanged: (val) {
                                    var item =
                                        selectedItemList.firstWhere((element) => element.id == selectedItemList[i].id);
                                    setState(() {
                                      item.selected = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(selectedItemList);
                      },
                      child: const Text("Kapat"))
                ],
              ),
          ),
    );
  }
}
