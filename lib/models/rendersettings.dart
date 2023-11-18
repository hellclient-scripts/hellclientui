import 'package:flutter/material.dart';

class RenderConfig {
  RenderConfig();
  Color? color;
  Color? background;
  Color? black;
  Color? red;
  Color? green;
  Color? yellow;
  Color? blue;
  Color? magenta;
  Color? cyan;
  Color? white;
  Color? brightBlack;
  Color? brightRed;
  Color? brightGreen;
  Color? brightYellow;
  Color? brightBlue;
  Color? brightMagenta;
  Color? brightCyan;
  Color? brightWhite;
  RenderConfig.fromJson(Map<String, dynamic> json)
      : color = json['color'] != null ? Color(json['color']) : null,
        background =
            json['background'] != null ? Color(json['background']) : null,
        black = json['black'] != null ? Color(json['black']) : null,
        red = json['red'] != null ? Color(json['red']) : null,
        green = json['green'] != null ? Color(json['green']) : null,
        yellow = json['yellow'] != null ? Color(json['yellow']) : null,
        blue = json['blue'] != null ? Color(json['blue']) : null,
        magenta = json['magenta'] != null ? Color(json['magenta']) : null,
        cyan = json['cyan'] != null ? Color(json['cyan']) : null,
        white = json['white'] != null ? Color(json['white']) : null,
        brightBlack =
            json['brightBlack'] != null ? Color(json['brightBlack']) : null,
        brightRed = json['brightRed'] != null ? Color(json['brightRed']) : null,
        brightGreen =
            json['brightGreen'] != null ? Color(json['brightGreen']) : null,
        brightYellow =
            json['brightYellow'] != null ? Color(json['brightYellow']) : null,
        brightBlue =
            json['brightBlue'] != null ? Color(json['brightBlue']) : null,
        brightMagenta =
            json['brightMagenta'] != null ? Color(json['brightMagenta']) : null,
        brightCyan =
            json['brightCyan'] != null ? Color(json['brightCyan']) : null,
        brightWhite =
            json['brightWhite'] != null ? Color(json['brightWhite']) : null;
  Map<String, dynamic> toJson() => {
        'color': color?.value,
        'background': background?.value,
        'black': black?.value,
        'red': red?.value,
        'green': green?.value,
        'yellow': yellow?.value,
        'blue': blue?.value,
        'magenta': magenta?.value,
        'cyan': cyan?.value,
        'white': white?.value,
        'brightBlack': brightBlack?.value,
        'brightRed': brightRed?.value,
        'brightGreen': brightGreen?.value,
        'brightYellow': brightYellow?.value,
        'brightBlue': brightBlue?.value,
        'brightMagenta': brightMagenta?.value,
        'brightCyan': brightCyan?.value,
        'brightWhite': brightWhite?.value,
      };

  RenderSettings getSettings() {
    var settings = RenderSettings();
    if (color != null) {
      settings.color = color!;
    }
    if (background != null) {
      settings.background = background!;
    }
    if (black != null) {
      settings.black = black!;
    }
    if (red != null) {
      settings.red = red!;
    }
    if (green != null) {
      settings.green = green!;
    }
    if (yellow != null) {
      settings.yellow = yellow!;
    }
    if (blue != null) {
      settings.blue = blue!;
    }
    if (magenta != null) {
      settings.magenta = magenta!;
    }
    if (cyan != null) {
      settings.cyan = cyan!;
    }
    if (white != null) {
      settings.white = white!;
    }
    if (brightBlack != null) {
      settings.brightBlack = brightBlack!;
    }
    if (brightRed != null) {
      settings.brightRed = brightRed!;
    }
    if (brightGreen != null) {
      settings.brightGreen = brightGreen!;
    }
    if (brightYellow != null) {
      settings.brightYellow = brightYellow!;
    }
    if (brightBlue != null) {
      settings.brightBlue = brightBlue!;
    }
    if (brightMagenta != null) {
      settings.brightMagenta = brightMagenta!;
    }
    if (brightCyan != null) {
      settings.brightCyan = brightCyan!;
    }
    if (brightWhite != null) {
      settings.brightWhite = brightWhite!;
    }

    return settings;
  }
}

class RenderSettings {
  double fontSize = 13.0;
  double lineheight = 20.0;
  double linemiddle = 10.0;
  double width = 1120;
  double height = 2000;
  int maxLines = 100;
  late double linewidth = 80 * fontSize;
  int minChars = 40;
  var background = Colors.black;
  var color = const Color(0xffffffff);
  var black = const Color.fromARGB(255, 0, 0, 0);
  var red = const Color.fromARGB(255, 191, 0, 0);
  var green = const Color.fromARGB(255, 0, 201, 0);
  var yellow = const Color.fromARGB(255, 255, 191, 0);
  var blue = const Color.fromARGB(255, 0, 0, 191);
  var magenta = const Color.fromARGB(255, 220, 0, 220);
  var cyan = const Color.fromARGB(255, 0, 221, 221);
  var white = const Color.fromARGB(255, 225, 225, 225);
  var brightBlack = const Color.fromARGB(255, 127, 127, 127);
  var brightRed = const Color.fromARGB(255, 255, 0, 0);
  var brightGreen = const Color.fromARGB(255, 0, 252, 0);
  var brightYellow = const Color.fromARGB(255, 255, 255, 0);
  var brightBlue = const Color.fromARGB(255, 0, 0, 252);
  var brightMagenta = const Color.fromARGB(255, 255, 0, 255);
  var brightCyan = const Color.fromARGB(255, 0, 255, 255);
  var brightWhite = const Color.fromARGB(255, 255, 255, 255);
  var echocolor = const Color.fromARGB(255, 0, 255, 255);
  var echoicon = "↣";
  var echoiconcolor = Colors.teal;
  var systemcolor = Colors.red;
  var systemicon = "⯳";
  var systemiconcolor = Colors.purple;
  var printcolor = const Color(0xFF00FA9A);
  var printicon = "↢";
  var printiconcolor = Colors.green;
  var localbcinicon = "☎本地广播 ";
  var globalbcinicon = "☎全局广播 ";
  var localbcouticon = "☎本地广播出 ";
  var globalbcouticon = "☎全集广播出 ";
  var requesticon = "☎请求 ";
  var responseicon = "☎响应 ";
  var subnegicon = "☎非文本信息 ";
  var bccolor = const Color.fromARGB(255, 127, 127, 127);
  double letterSpacing = 0;
  var fontFamily = "monospace";
  bool hidpi = true;
}
