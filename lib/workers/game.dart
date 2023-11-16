import 'package:hellclientui/models/server.dart';
import 'package:flutter/material.dart';
import '../models/rendersettings.dart';
import '../states/appstate.dart';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

import 'renderer.dart';
import '../models/message.dart';

class GameEvent extends ChangeNotifier {
  raise() {
    notifyListeners();
  }
}

class Game {
  late RenderSettings renderSettings;
  IOWebSocketChannel? channel;
  late Server server;
  late RenderPainter output;
  StreamSubscription? subscription;

  final eventDisconnected = GameEvent();
  static Game create(AppState appState, double devicepixelratio) {
    var game = Game();
    final settings = appState.renderSettings;
    game.server = appState.currentServer!;
    game.renderSettings = settings;
    game.output = RenderPainter.create(Renderer(
        renderSettings: settings,
        maxLines: settings.maxLines,
        devicePixelRatio: devicepixelratio));
    game.subscription =
        appState.connecting.messageStream.stream.listen((event) async {
      var msg = event as String;
      await game.onMessage(msg);
    });

    return game;
  }

  Future<void> onCmdLine(String data) async {
    final Map<String, dynamic> jsondata = json.decode(data);
    final line = Line.fromJson(jsondata);
    await output.renderer.drawLine(line);
    output.renderer.draw();
  }

  Future<void> onCmdLines(String data) async {
    final dynamic jsondata = json.decode(data);
    final lines = Lines.fromJson(jsondata);
    for (final line in lines.lines) {
      await output.renderer.drawLine(line);
    }
    output.renderer.draw();
  }

  Future<void> onMessage(String msg) async {
    final String command;
    final String data;
    var position = msg.indexOf(" ");
    if (position < 0) {
      command = msg;
      data = "";
    } else {
      command = msg.substring(0, position);
      data = msg.substring(position + 1);
    }
    switch (command) {
      case "lines":
        await onCmdLines(data);
        break;
      case "line":
        await onCmdLine(data);
        break;
    }
  }

  Future<void> connect(AppState appState, Function(String) errorhandler) async {
    // appState.connecting.connect(errorhandler, server);
    subscription =
        appState.connecting.messageStream.stream.listen((event) async {
      var msg = event as String;
      await onMessage(msg);
    });
  }

  void onPostFrame(Duration time) {
    output.renderer.draw();
  }

  void handleSend(String cmd) {
    if (channel != null) {
      channel!.sink.add("send " + json.encode(cmd));
    }
  }

  Future<void> dispose() async {
    if (subscription != null) {
      await subscription!.cancel();
    }
  }

  void start() {}
}
