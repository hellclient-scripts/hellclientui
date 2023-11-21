import 'package:flutter/material.dart';

class Fullscreen extends StatelessWidget {
  const Fullscreen(
      {super.key, required this.child, required this.minWidth, this.height});
  final Widget child;
  //fixed raw widget height
  //Use constraints.maxHeight if null.
  final double? height;
  final double minWidth;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (cotext, constraints) {
      Widget body = child;
      final widgetHeight =
          height ?? constraints.maxHeight / constraints.maxWidth * minWidth;
      if (constraints.maxWidth < minWidth) {
        body = FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: minWidth,
              height: widgetHeight,
              child: child,
            ));
      }
      return body;
    });
  }
}
