import 'package:flutter/material.dart';

import 'istatislik_state.dart';

class CustomToggleButton extends StatefulWidget {
  final IstatislikState state;
  final int selectedIndex;
  const CustomToggleButton({Key key, @required this.state, this.selectedIndex}) : super(key: key);
  @override
  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  List<bool> isSelected = [false, false, false];

  FocusNode focusNodeButton1 = FocusNode();
  FocusNode focusNodeButton2 = FocusNode();
  FocusNode focusNodeButton3 = FocusNode();
  List<FocusNode> focusToggle;

  @override
  void initState() {
    super.initState();
    focusToggle = [focusNodeButton1, focusNodeButton2, focusNodeButton3];
    isSelected[widget.selectedIndex - 1] = true;
  }

  @override
  void dispose() {
    focusNodeButton1.dispose();
    focusNodeButton2.dispose();
    focusNodeButton3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ToggleButtons(
        children: [
          Container(width: size.width * 0.31, alignment: Alignment.center, child: const Text("Ilceye Göre")),
          Container(width: size.width * 0.31, alignment: Alignment.center, child: const Text("Uygulamaya Göre")),
          Container(width: size.width * 0.31, alignment: Alignment.center, child: const Text("Ekipler"))
        ],
        isSelected: isSelected,
        focusNodes: focusToggle,
        onPressed: (index) {
          setState(() {
            for (int indexBtn = 0; indexBtn < isSelected.length; indexBtn++) {
              if (indexBtn == index) {
                isSelected[indexBtn] = true;
              } else {
                isSelected[indexBtn] = false;
              }
            }
          });
          if (index == 0) {
            widget.state.changeGrooup(1);
            widget.state.ilceyeGore();
          } else if (index == 1) {
            widget.state.changeGrooup(2);
            widget.state.uygulamayaGore();
          } else {
            widget.state.changeGrooup(3);
            widget.state.ekipeGore();
          }
        });
  }
}
