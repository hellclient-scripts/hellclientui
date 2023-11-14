import 'package:hellclientui/models/server.dart';
import 'package:flutter/material.dart';
import '../models/rendersettings.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'renderer.dart';
import '../models/message.dart';

class Game {
  late RenderSettings renderSettings;
  IOWebSocketChannel? channel;
  late Server server;
  late RenderPainter output;
  static Game create(Server server, RenderSettings settings) {
    var game = Game();
    game.server = server;
    game.renderSettings = settings;
    game.output = RenderPainter.create(
        Renderer(renderSettings: settings, maxLines: settings.maxLines));
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

  void connect() {
    final hosturi = Uri.parse(server.host);
    final String scheme;
    final String auth;
    if (hosturi.scheme == "https") {
      scheme = 'wss';
    } else {
      scheme = 'ws';
    }
    if (server.username.isNotEmpty) {
      auth = server.username + ":" + server.password;
    } else {
      auth = "";
    }
    final serveruri = Uri(
        scheme: scheme,
        host: hosturi.host,
        port: hosturi.port,
        // userInfo: auth,
        path: "/ws");
    final Map<String, dynamic> headers = {};
    if (auth.isNotEmpty) {
      headers['Authorization'] = 'Basic ' + base64.encode(utf8.encode(auth));
    }
    channel = IOWebSocketChannel.connect(serveruri, headers: headers);
    channel!.stream.listen((event) async {
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

  void start() {}
}
