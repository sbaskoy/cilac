import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  final List<String> categoryList;
  final Function(String) onPressed;

  const CategoryList({Key key, @required this.categoryList, @required this.onPressed}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
            children: List.generate(
                widget.categoryList.length,
                (index) => GestureDetector(
                      onTap: () {
                        selectedIndex = index;
                        this.widget.onPressed(widget.categoryList[index]);
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: this.selectedIndex == index ? Colors.grey : Colors.transparent,
                            border: Border.all(color: this.selectedIndex == index ? Colors.grey : Colors.transparent)),
                        width: 120,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.categoryList[index],
                            style: TextStyle(
                              color: this.selectedIndex == index ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ))),
      ),
    );
  }
}
