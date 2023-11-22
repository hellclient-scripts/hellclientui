import 'package:flutter/material.dart';
import 'fullscreen.dart';

const BorderRadiusGeometry _radiusBoth = BorderRadius.all(Radius.circular(4));
const BorderRadiusGeometry _radiusNone = BorderRadius.zero;
const BorderRadiusGeometry _radiusLeft =
    BorderRadius.horizontal(left: Radius.circular(4));
const BorderRadiusGeometry _radiusRight =
    BorderRadius.horizontal(right: Radius.circular(4));

class AppUI {
  static Widget buildTextButton(
    BuildContext context,
    String label,
    void Function() onPressed,
    String? tooltip,
    Color color,
    Color background, {
    IconData? icon,
    bool? radiusLeft,
    bool? radiusRight,
  }) {
    final BorderRadiusGeometry radius;
    if (radiusRight == true) {
      radius = (radiusLeft == true) ? _radiusBoth : _radiusRight;
    } else {
      radius = (radiusLeft == true) ? _radiusLeft : _radiusNone;
    }
    var text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 12,
          height: 1.3,
          color: color,
        ));
    Widget button;
    if (icon != null) {
      button = Text.rich(TextSpan(children: [
        WidgetSpan(child: Icon(size: 16, color: color, icon)),
        text,
      ]));
    } else {
      button = Text.rich(text);
    }
    Widget result = Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 1, 0),
        child: TextButton(
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
            onPressed: onPressed,
            child: button));
    if (tooltip != null) {
      result = Tooltip(
        message: tooltip,
        child: result,
      );
    }
    return result;
  }

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
    return SelectableText(
      data,
      textAlign: TextAlign.start,
      style: textStyleH1,
      maxLines: 1,
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
    return SelectableText(
      textAlign: TextAlign.start,
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

class NonFullScreenDialog extends StatelessWidget {
  const NonFullScreenDialog(
      {super.key,
      required this.title,
      this.summary = "",
      required this.child,
      this.width = 440});
  final String title;
  final String summary;
  final Widget child;
  final double width;
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
    if (summary.isNotEmpty) {
      children.add(Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: Summary(summary)));
    }
    children.add(child);
    return Material(
        type: MaterialType.transparency,
        child: Align(
            alignment: Alignment.center,
            child: Container(
                width: width,
                color: Colors.white,
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children)))));
  }
}

class FullScreenDialog extends StatelessWidget {
  const FullScreenDialog(
      {super.key, required this.title, this.summary = "", required this.child});
  final String title;
  final String summary;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

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
    if (summary.isNotEmpty) {
      children.add(Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: Summary(summary)));
    }
    children.add(Expanded(
        child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
                controller: scrollController, child: child))));
    return Fullscreen(
        minWidth: 640,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children)));
  }
}

class DialogOverray extends StatelessWidget {
  const DialogOverray(
      {super.key,
      required this.child,
      this.maxPercent = 0.8,
      this.direction = AxisDirection.down});
  final double maxPercent;
  final AxisDirection direction;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      AlignmentGeometry alignment;
      double maxHeight;
      double maxWidth;
      switch (direction) {
        case AxisDirection.up:
          maxHeight = constraints.maxHeight * maxPercent;
          maxWidth = constraints.minWidth;
          alignment = Alignment.topCenter;
          break;
        case AxisDirection.left:
          maxHeight = constraints.maxHeight;
          maxWidth = constraints.maxWidth * maxPercent;
          alignment = Alignment.centerLeft;
          break;
        case AxisDirection.right:
          maxHeight = constraints.maxHeight;
          maxWidth = constraints.maxWidth * maxPercent;
          alignment = Alignment.centerRight;
          break;
        default:
          maxHeight = constraints.maxHeight * maxPercent;
          maxWidth = constraints.minWidth;
          alignment = Alignment.bottomCenter;
      }
      return Material(
          type: MaterialType.transparency,
          child: Align(
              alignment: alignment,
              child: Container(
                color: Colors.white,
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                  maxWidth: maxWidth,
                ),
                width: maxWidth,
                height: maxHeight,
                child: child,
              )));
    });
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

class ConfirmOrCancelWidget extends StatelessWidget {
  const ConfirmOrCancelWidget(
      {super.key,
      this.labelSubmit = '确定',
      this.labelCancel = '取消',
      required this.onConfirm,
      required this.onCancal});
  final String labelSubmit;
  final String? labelCancel;
  final void Function() onConfirm;
  final void Function() onCancal;
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      const Expanded(
        child: Center(),
      ),
    ];
    if (labelCancel != null) {
      children.add(
        Container(
          width: 100,
          margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: AppUI.buildTextButton(context, labelCancel!, onCancal, null,
              const Color(0xff333333), const Color(0xffdddddd)),
        ),
      );
    }
    children.add(
      Container(
        width: 100,
        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: AppUI.buildTextButton(context, labelSubmit, onConfirm, null,
            Colors.white, const Color(0xff409EFF)),
      ),
    );
    return SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: children,
        ));
  }
}
