import 'package:flutter/material.dart';

const BorderRadiusGeometry _radiusBoth = BorderRadius.all(Radius.circular(4));
const BorderRadiusGeometry _radiusNone = BorderRadius.zero;
const BorderRadiusGeometry _radiusLeft =
    BorderRadius.horizontal(left: Radius.circular(4));
const BorderRadiusGeometry _radiusRight =
    BorderRadius.horizontal(right: Radius.circular(4));

class AppUI {
  static Widget buildIconButton(
    BuildContext context,
    Widget icon,
    void Function() onPressed,
    String? tooltip,
    Color color,
    Color background, {
    bool? radiusLeft,
    bool? radiusRight,
  }) {
    final BorderRadiusGeometry radius;
    if (radiusRight == true) {
      radius = (radiusLeft == true) ? _radiusBoth : _radiusRight;
    } else {
      radius = (radiusLeft == true) ? _radiusLeft : _radiusNone;
    }
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 1, 0),
        child: IconButton(
            style: ButtonStyle(
              padding:
                  const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(0)),
              // fixedSize: MaterialStatePropertyAll<Size>(Size(32, 32)),
              shape: MaterialStatePropertyAll<OutlinedBorder>(
                  RoundedRectangleBorder(
                      borderRadius: radius, side: BorderSide.none)),
              backgroundColor: MaterialStatePropertyAll<Color>(background),
              iconColor: MaterialStatePropertyAll<Color>(color),
            ),
            tooltip: tooltip,
            iconSize: 16,
            splashRadius: 3,
            onPressed: onPressed,
            icon: icon));
  }
}

const textStyleH1 = TextStyle(
  fontSize: 18,
  height: 24 / 18,
  fontWeight: FontWeight.bold,
  color: Color(0xff303133),
);

class H1 extends StatelessWidget {
  const H1(this.data, {super.key});
  final String data;
  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: TextAlign.start,
      style: textStyleH1,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

const textStyleSummary = TextStyle(
  fontSize: 14,
  height: 1.3,
  color: Color(0xff303133),
);

class Summary extends StatelessWidget {
  const Summary(this.data, {super.key});
  final String data;
  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: textStyleSummary,
    );
  }
}

const textStyleTableHead = TextStyle(
  fontSize: 14,
  height: 1.3,
  color: Color(0xff909399),
  fontWeight: FontWeight.bold,
);

class TableHead extends StatelessWidget {
  const TableHead(this.data, {super.key, required this.textAlign});
  final String data;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return TCell(Text(
      textAlign: textAlign,
      data,
      style: textStyleTableHead,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ));
  }
}

class FullScreenDialog extends StatelessWidget {
  const FullScreenDialog(
      {super.key,
      required this.title,
      required,
      this.summary,
      required this.child});
  final String title;
  final String? summary;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Row(
            children: [
              Expanded(child: H1(title)),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  icon: const Icon(Icons.close)),
            ],
          )),
    ];
    if (summary != null) {
      children.add(Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: Summary(summary!)));
    }
    children.add(Expanded(child: SingleChildScrollView(child: child)));
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }
}

class TCell extends StatelessWidget {
  const TCell(this.child, {super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: child,
    );
  }
}

TableRow createTableRow(List<Widget> children) {
  return TableRow(
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1, color: Color(0xffEBEEF5)))),
      children: children);
}
