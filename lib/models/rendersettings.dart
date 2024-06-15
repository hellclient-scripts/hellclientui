import 'dart:ffi';

import 'package:flutter/material.dart';

class CommandDisplayMode {
  static const normal = 0;
  static const larger = 1;
}

class Display {
  double height;
  double iconSize;
  double fontSize;
  Display({this.height = 0, this.iconSize = 0, this.fontSize = 0});
}

class SuggestionMode {
  static const none = 0;
  static const small = 1;
  static const large = 2;
}

class ScaleSettings {
  static List<int> list = [
    25,
    50,
    75,
    100,
    125,
    150,
    175,
    200,
    250,
    300,
    350,
    400,
  ];
  static const defaultScale = 100;
}

class MinCharsSettings {
  static List<int> list = [30, 40, 60, 80];
  static const defaultMinChars = 40;
  static int loadMinChars(dynamic data) {
    return MinCharsSettings.defaultMinChars;
  }
}

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
  bool? disableHidpi;
  bool? roundDpi;
  bool? forceDesktopMode;
  int commandDisplayMode = CommandDisplayMode.normal;
  int suggestionMode = SuggestionMode.small;
  bool defaultHideInput = false;
  int defaultScale = ScaleSettings.defaultScale;
  int minChars = MinCharsSettings.defaultMinChars;
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
            json['brightWhite'] != null ? Color(json['brightWhite']) : null,
        disableHidpi = json['disableHidpi'] ?? false,
        forceDesktopMode = json['forceDesktopMode'] ?? false,
        roundDpi = json['roundDpi'] ?? false,
        commandDisplayMode =
            json['commandDisplayMode'] ?? CommandDisplayMode.normal,
        suggestionMode = json['suggestionMode'] ?? SuggestionMode.small,
        defaultHideInput = json['defaultHideInput'] ?? false,
        defaultScale = json['defaultScale'] ?? ScaleSettings.defaultScale,
        minChars = MinCharsSettings.loadMinChars(json['minChars']);

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
        'forceDesktopMode': forceDesktopMode == true,
        'disableHidpi': disableHidpi == true,
        'commandDisplayMode': commandDisplayMode,
        'roundDpi': roundDpi,
        'suggestionMode': suggestionMode,
        'defaultHideInput': defaultHideInput,
        'defaultScale': defaultScale,
        'minChars': minChars,
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
    settings.hidpi = disableHidpi != true;
    settings.roundDpi = roundDpi == true;
    settings.forceDesktopMode = forceDesktopMode == true;
    settings.commandDisplayMode = commandDisplayMode;
    settings.suggestionMode = suggestionMode;
    settings.defaultHideInput = defaultHideInput;
    settings.defaultScale = defaultScale;
    settings.minChars = minChars;
    return settings;
  }

  RenderConfig clone() {
    return RenderConfig.fromJson(toJson());
  }
}

class RenderSettings {
  RenderSettings();
  double fontSize = 14.0;
  double lineheight = 20.0;
  double linemiddle = 10.0;
  double width = 1120;
  double height = 2000;
  int maxLines = 100;
  late double linewidth = 80 * fontSize;
  int minChars = MinCharsSettings.defaultMinChars;
  var background = Colors.black;
  var hudbackground = const Color(0xff333333);
  var color = const Color(0xffffffff);
  var black = const Color.fromARGB(255, 0, 0, 0);
  var red = const Color.fromARGB(255, 127, 0, 0);
  var green = const Color.fromARGB(255, 0, 147, 0);
  var yellow = const Color.fromARGB(255, 252, 127, 0);
  var blue = const Color.fromARGB(255, 0, 0, 127);
  var magenta = const Color.fromARGB(255, 156, 0, 156);
  var cyan = const Color.fromARGB(255, 0, 147, 147);
  var white = const Color.fromARGB(255, 210, 210, 210);
  var brightBlack = const Color.fromARGB(255, 64, 64, 64);
  var brightRed = const Color.fromARGB(255, 191, 0, 0);
  var brightGreen = const Color.fromARGB(255, 0, 201, 0);
  var brightYellow = const Color.fromARGB(255, 255, 191, 0);
  var brightBlue = const Color.fromARGB(255, 0, 0, 191);
  var brightMagenta = const Color.fromARGB(255, 220, 0, 220);
  var brightCyan = const Color.fromARGB(255, 0, 221, 221);
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
  var triggersicon = "⚙";
  var bccolor = const Color.fromARGB(255, 127, 127, 127);
  var triggersColor = const Color.fromARGB(255, 0, 255, 255);
  var fontFamily = "monospace";
  Color searchForeground = const Color(0xFF333333);
  Color searchBackground = const Color(0xFFF6DBDB);
  Color searchCurrentBackground = const Color(0xFFFFF3CF);
  bool hidpi = true;
  bool roundDpi = false;
  bool forceDesktopMode = false;
  var commandDisplayMode = 0;
  int suggestionMode = 0;
  bool defaultHideInput = false;
  int defaultScale = ScaleSettings.defaultScale;
  Display getDisplay() {
    switch (commandDisplayMode) {
      case CommandDisplayMode.larger:
        return Display(height: 45, iconSize: 24, fontSize: fontSize * 1.5);
    }
    return Display(
      height: 30,
      iconSize: 16,
      fontSize: fontSize,
    );
  }

  int getSuggestionLimit() {
    switch (suggestionMode) {
      case SuggestionMode.none:
        return 0;
      case SuggestionMode.large:
        return 10;
      case SuggestionMode.small:
        break;
    }
    return 5;
  }

  int getDefaultScale() {
    for (var val in ScaleSettings.list) {
      if (defaultScale == val) {
        return val;
      }
    }
    return ScaleSettings.defaultScale;
  }
}

final defaultRenderSettings = RenderSettings();
