import '../../model/ekip_konum.dart';
import '../../model/usermodel.dart';
import 'package:flutter/material.dart';



class TimelineComponent extends StatefulWidget {
  final UserModel user;
  final EkipKonum ekip;
  const TimelineComponent({
    this.user,
    this.ekip,
  });

  @override
  _TimelineComponentState createState() => _TimelineComponentState();
}

class _TimelineComponentState extends State<TimelineComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zaman Çizgisi"),
      
      ),
      body: const Center(
        child:Text("Data")
        // Timeline.tileBuilder(
        //   builder: TimelineTileBuilder.fromStyle(
        //     contentsAlign: ContentsAlign.alternating,
        //     contentsBuilder: (context, index) => Padding(
        //       padding: const EdgeInsets.all(24.0),
        //       child: Text('Timeline Event $index'),
               
              
        //     ),
        //     itemCount: 10,
        //   ),
        ),
      
    );
  }
}
