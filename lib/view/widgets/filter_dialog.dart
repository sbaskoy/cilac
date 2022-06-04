import '../../extansion/string_extansion.dart';
import '../../extansion/widget_extansion.dart';

import 'package:flutter/material.dart';

class FilterDialog extends StatefulWidget {
  final String start;
  final String finish;
   const FilterDialog({Key key,this.start, this.finish});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  final startController = TextEditingController();
  final finishController = TextEditingController();
  String startTime;
  String finishTime;
  String startDate;
  String finishDate;
  @override
  void initState() {
    super.initState();
    var dateNow = DateTime.now();
    
    startController.text = widget.start ?? dateNow.toString().dartDateToStr;
    finishController.text = widget.finish ?? dateNow.add(const Duration(days: 7)).toString().dartDateToStr;
    startTime = startController.text.split(" ")[1];
    finishTime = finishController.text.split(" ")[1];

    startDate = startController.text.split(" ")[0];
    finishDate = finishController.text.split(" ")[0];
  }

  Future<DateTime> _showDatePicker(String helpText,int a) async {
    DateTime selected = await showDatePicker(
        //locale: new Locale("tr-TR"),
        locale: const Locale('tr', 'TR'),
        context: context,
        initialDate: DateTime.tryParse(a ==0 ? startDate :finishDate),
        firstDate: new DateTime(2010),
        lastDate: new DateTime(2100),
        cancelText: "İptal",
        confirmText: "Tamam",
        helpText: helpText);
    return selected;
  }

  Future<TimeOfDay> _showTimePicker(String heplText, int a) async {
    TimeOfDay initailTime;

    var b = a == 0 ? startTime.split(":") : finishTime.split(":");
    initailTime = new TimeOfDay(hour: int.parse(b[0]), minute: int.parse(b[1]));

    TimeOfDay time = await showTimePicker(
      
      context: context,
      initialTime: initailTime,
      helpText: heplText,
      cancelText: "İptal",
      confirmText: "Tamam",
    );
    return time;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: startController,
                  readOnly: true,
                  onTap: () async {
                    var date = await _showDatePicker("Başlangıç tarihi şeçin",0);
                    if (date != null) {
                      startDate = date.toString().split(" ")[0];
                      startController.text = "$startDate $startTime";
                    }
                  },
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: "Başlangıc tarihi",
                    border: OutlineInputBorder(),
                  ),
                ).paddingAll(),
              ),
              SizedBox(
                
                //decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                child: IconButton(
                  onPressed: () async {
                    TimeOfDay time = await _showTimePicker("Başlangıç zamanı şeç", 0);
                    if (time != null) {
                      startTime = "${time.hour}:${time.minute}";
                      startController.text = "$startDate $startTime";
                    }
                  },
                  icon: const Icon(Icons.lock_clock),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                        controller: finishController,
                        readOnly: true,
                        onTap: () async {
                          var date = await _showDatePicker("Bitiş tarihi şeçin",1);
                          if (date != null) {
                            finishDate= date.toString().split(" ")[0];
                             finishController.text = "$finishDate $finishTime";
                          }
                        },
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(labelText: "Bitiş tarihi", border: OutlineInputBorder()))
                    .paddingAll(),
              ),
              SizedBox(
                //decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                child: IconButton(
                  onPressed: () async {
                    TimeOfDay time = await _showTimePicker("Bitiş zamanı şeç", 1);
                    if (time != null) {
                      finishTime = "${time.hour}:${time.minute}";
                      finishController.text = "$finishDate $finishTime";
                    }
                  },
                  icon: const Icon(Icons.lock_clock),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({"start": startController.text, "finish": finishController.text});
                  },
                  child: const Text("Filtrele")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text("Tüm zamanlar")),
            ],
          )
        ],
      ),
    ));
  }
}
