import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final Widget img;

  const DetailScreen({Key key, this.img}) : super(key: key);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("Dismissible widget"),
      direction: DismissDirection.vertical,
      onDismissed: (_) => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(child: widget.img),
            ),
            Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => Navigator.pop(context),
                ))
          ],
        ),
      ),
    );
  }
}
