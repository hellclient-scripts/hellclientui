import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:hellclientui/models/message.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../../models/server.dart';
import '../../models/rendersettings.dart';
import '../../workers/renderer.dart';
import '../../workers/game.dart';

import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:ui' as ui;

class Display extends StatefulWidget {
  const Display({super.key});

  @override
  State<Display> createState() => DisplayState();
}

class DisplayState extends State<Display> {
  DisplayState();
  RenderSettings renderSettings = RenderSettings();
  IOWebSocketChannel? channel;
  final repaint = Repaint();
  late Game game;
  late Server server;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration time) {
      game.output.renderer.draw();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    game = Game.create(appState.currentServer!, RenderSettings());
    // renderer.init();
    game.connect();
    return Container(
        decoration: BoxDecoration(color: appState.renderSettings.background),
        child: Column(children: [
          Expanded(
              child: Stack(children: [
            Positioned(
                width: appState.renderSettings.width,
                height: appState.renderSettings.height,
                bottom: 0,
                left: 0,
                child: CustomPaint(
                  painter: game.output,
                )),
          ])),
          Container(
            height: 30,
            child: material.Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text("test"),
                ),
                Expanded(
                    child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: (InputDecoration(labelText: '输入')),
                )),
                SizedBox(
                  width: 80,
                  child: Text("test2"),
                ),
              ],
            ),
          )
        ]));
  }
}
