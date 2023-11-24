import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/rendersettings.dart';
import 'package:hellclientui/models/message.dart';
import 'package:synchronized/synchronized.dart';

class RenderPainter extends CustomPainter {
  RenderPainter({required super.repaint});
  late Renderer renderer;
  static RenderPainter create(Renderer renderer) {
    var painter = RenderPainter(repaint: renderer.repaint);
    painter.renderer = renderer;
    renderer.init();
    return painter;
  }

  @override
  void paint(Canvas canvas, ui.Size size) {
    // renderer.resetFrame();
    canvas.drawPicture(renderer.current);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Repaint extends ChangeNotifier {
  void notifyRepaint() {
    super.notifyListeners();
  }
}

class LineStyle {
  LineStyle({required this.color, required this.icon, required this.iconcolor});
  late Color color;
  late String icon;
  late Color iconcolor;
}

class WordStyle {
  var color = Colors.white;
  var background = Colors.black;
  bool bold = false;
  bool underlined = false;
  bool blinking = false;
  double fontSize = 0;
  TextStyle toTextStyle(RenderSettings settings) {
    var style = TextStyle(
      fontFamily: settings.fontFamily,
      color: color,
      backgroundColor: background,
      fontSize: fontSize,
      height: settings.lineheight / fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      decoration: underlined ? TextDecoration.underline : TextDecoration.none,
      fontStyle: blinking ? FontStyle.italic : FontStyle.normal,
      fontFeatures: const [ui.FontFeature.tabularFigures()],
    );
    return style;
  }
}

class RenderingLine {
  String id = "";
  int index = 0;
  double position = 0;
  late double devicePixelRatio;
  late RenderSettings settings;
  late Canvas canvas;
  late ui.PictureRecorder recorder;
  static RenderingLine create(Line raw, RenderSettings settings,
      double devicePixelRatio, Color background) {
    var line = RenderingLine();
    line.id = raw.id;
    line.devicePixelRatio = devicePixelRatio;
    line.recorder = ui.PictureRecorder();
    line.canvas = Canvas(line.recorder);
    var paint = Paint();
    paint.color = background;
    line.canvas.drawRect(
        Rect.fromLTWH(0, 0, settings.width * devicePixelRatio,
            settings.lineheight * devicePixelRatio),
        paint);
    line.settings = settings;
    return line;
  }

  void drawicon(TextStyle textstyle, LineStyle style, Color background) {
    final span = TextSpan(text: style.icon, style: textstyle);
    final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textScaleFactor: devicePixelRatio);
    painter.layout(minWidth: 0, maxWidth: settings.width * devicePixelRatio);
    final offset = Offset(position,
        (devicePixelRatio * settings.lineheight - painter.size.height) / 2);
    painter.paint(canvas, offset);
    position = painter.size.width;
  }

  bool addText(String text, TextStyle style) {
    final span = TextSpan(text: text, style: style);
    final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textScaleFactor: devicePixelRatio);
    painter.layout(
        minWidth: 0, maxWidth: settings.linewidth * devicePixelRatio);
    final offset = Offset(position,
        (devicePixelRatio * settings.lineheight - painter.size.height) / 2);

    var paint = Paint();
    paint.color = style.backgroundColor!;
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(position, 0, painter.size.width,
            settings.lineheight * devicePixelRatio),
        paint);
    painter.paint(canvas, offset);
    position = position + painter.width;
    return position >= settings.width * devicePixelRatio;
  }

  Future<Row> toRow() async {
    var row = Row();
    row.id = id;
    row.index = index;
    row.image = await recorder.endRecording().toImage(
        (devicePixelRatio * settings.width).floor(),
        (devicePixelRatio * settings.lineheight).floor());

    return row;
  }
}

class Row {
  String id = "";
  late ui.Image image;
  int index = 0;
  static int compare(Row a, Row b) {
    if (a.id != b.id) {
      return a.id.compareTo(b.id);
    }
    return a.index.compareTo(b.index);
  }
}

class Renderer {
  Renderer(
      {required this.renderSettings,
      required this.maxLines,
      required this.devicePixelRatio,
      required this.background,
      this.noSortLines});
  bool? noSortLines;
  final Color background;

  late ui.Picture current;
  int maxLines;
  Repaint repaint = Repaint();
  bool updated = false;
  late double devicePixelRatio;
  void init() {
    resetFrame();
    current = pictureRecorder.endRecording();
  }

  var lock = Lock();
  List<Row> rows = [];

  ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  Paint paint = Paint();
  late Canvas canvas = Canvas(pictureRecorder);
  late RenderSettings renderSettings;
  late Rect rect =
      Rect.fromLTWH(0, 0, renderSettings.width, renderSettings.lineheight);
  void resetFrame() {
    paint.color = background;
    pictureRecorder = ui.PictureRecorder();
    canvas = Canvas(pictureRecorder);
    canvas.drawRect(rect, paint);
  }

  void reset() {
    resetFrame();
    rows = [];
  }

  void draw() async {
    await lock.synchronized(() async {
      if (!updated) {
        return;
      }
      resetFrame();
      if (noSortLines != true) {
        rows.sort(Row.compare);
        if (rows.length > maxLines) {
          rows = rows.sublist(rows.length - maxLines);
        }
      }
      int index = 0;
      for (final row in rows) {
        canvas.drawImage(
            row.image,
            Offset(
                0,
                devicePixelRatio * renderSettings.lineheight * maxLines -
                    (maxLines - index) *
                        devicePixelRatio *
                        renderSettings.lineheight),
            Paint());
        index++;
      }
      current = pictureRecorder.endRecording();
      updated = false;
      repaint.notifyRepaint();
    });
  }

  Future<void> drawLine(Line line) async {
    await renderline(
        renderSettings, line, false, false, renderSettings.background);
  }

  TextStyle getIconStyle(
      double devicePixelRatio, Color iconcolor, Color background) {
    var textstyle = TextStyle(
      fontFamily: renderSettings.fontFamily,
      color: iconcolor,
      backgroundColor: background,
      fontSize: renderSettings.fontSize,
      fontWeight: FontWeight.normal,
      decoration: TextDecoration.none,
      fontStyle: FontStyle.normal,
      fontFeatures: const [ui.FontFeature.tabularFigures()],
    );
    return textstyle;
  }

  Future<void> renderline(RenderSettings settings, Line line, bool withouticon,
      bool nocr, Color? bcolor) async {
    await lock.synchronized(() async {
      bcolor ??= background;
      var linestyle = getLineStyle(line);
      var rendering =
          RenderingLine.create(line, settings, devicePixelRatio, background);
      var index = 0;
      if (!withouticon) {
        rendering.drawicon(
            getIconStyle(devicePixelRatio, linestyle.color, bcolor!),
            linestyle,
            bcolor!);
      }
      for (final word in line.words) {
        final textStyle = getWordStyle(word,
                withouticon ? renderSettings.color : linestyle.color, bcolor!)
            .toTextStyle(settings);
        for (final char in word.text.characters) {
          if (char == "\n" && nocr) {
            continue;
          }
          if (char == "\n" || rendering.addText(char, textStyle)) {
            index++;
            rows.add(await rendering.toRow());
            rendering = RenderingLine.create(
                line, settings, devicePixelRatio, background);
            rendering.index = index;
          }
        }
      }
      if (rendering.position > 0) {
        rows.add(await rendering.toRow());
      }
    });
    updated = true;
  }

  LineStyle getLineStyle(Line line) {
    switch (line.type) {
      case 0:
        return LineStyle(
            color: renderSettings.printcolor,
            icon: renderSettings.printicon,
            iconcolor: renderSettings.printiconcolor);
      case 1:
        return LineStyle(
            color: renderSettings.systemcolor,
            icon: renderSettings.systemicon,
            iconcolor: renderSettings.systemiconcolor);
      case 3:
        return LineStyle(
            color: renderSettings.echocolor,
            icon: renderSettings.echoicon,
            iconcolor: renderSettings.echoiconcolor);
      case 5:
        return LineStyle(
            color: renderSettings.bccolor,
            icon: renderSettings.localbcouticon,
            iconcolor: renderSettings.bccolor);
      case 6:
        return LineStyle(
            color: renderSettings.bccolor,
            icon: renderSettings.globalbcouticon,
            iconcolor: renderSettings.bccolor);
      case 7:
        return LineStyle(
            color: renderSettings.bccolor,
            icon: renderSettings.localbcinicon,
            iconcolor: renderSettings.bccolor);
      case 8:
        return LineStyle(
            color: renderSettings.bccolor,
            icon: renderSettings.globalbcinicon,
            iconcolor: renderSettings.bccolor);

      case 9:
        return LineStyle(
            color: renderSettings.bccolor,
            icon: renderSettings.requesticon,
            iconcolor: renderSettings.bccolor);

      case 10:
        return LineStyle(
            color: renderSettings.bccolor,
            icon: renderSettings.responseicon,
            iconcolor: renderSettings.bccolor);
      case 11:
        return LineStyle(
            color: renderSettings.bccolor,
            icon: renderSettings.subnegicon,
            iconcolor: renderSettings.bccolor);
    }
    return LineStyle(
        color: renderSettings.color, icon: "", iconcolor: renderSettings.color);
  }

  Color getColorByName(colorname, defaultcolor) {
    switch (colorname) {
      case "Black":
        return renderSettings.black;
      case "Red":
        return renderSettings.red;
      case "Green":
        return renderSettings.green;
      case "Yellow":
        return renderSettings.yellow;
      case "Blue":
        return renderSettings.blue;
      case "Magenta":
        return renderSettings.magenta;
      case "Cyan":
        return renderSettings.cyan;
      case "White":
        return renderSettings.white;
      case "BrightBlack":
        return renderSettings.brightBlack;
      case "BrightRed":
        return renderSettings.brightRed;
      case "BrightGreen":
        return renderSettings.brightGreen;
      case "BrightYellow":
        return renderSettings.brightYellow;
      case "BrightBlue":
        return renderSettings.brightBlue;
      case "BrightMagenta":
        return renderSettings.brightMagenta;
      case "BrightCyan":
        return renderSettings.brightCyan;
      case "BrightWhite":
        return renderSettings.brightWhite;
    }
    return defaultcolor;
  }

  WordStyle getWordStyle(Word word, Color fontcolor, Color backgroundColor) {
    var result = WordStyle();
    var color = word.inverse ? word.background : word.color;
    var background = word.inverse ? word.color : word.background;
    result.color = getColorByName(color, fontcolor);
    result.background = getColorByName(background, backgroundColor);
    result.bold = word.bold;
    result.blinking = word.blinking;
    result.underlined = word.underlined;
    result.fontSize = renderSettings.fontSize;
    return result;
  }
}
