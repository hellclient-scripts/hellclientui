import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hellclientui/states/appstate.dart';
import 'dart:async';
import '../widgets/display.dart';
import '../../workers/game.dart' as gameengine;

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<Game> createState() => GameState();
}

class GameState extends State<Game> {
  @override
  void dispose() {
    disconnectSub.cancel();
    gameengine.currentGame?.dispose();
    gameengine.currentGame?.close();

    super.dispose();
  }

  late StreamSubscription disconnectSub;
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var server = appState.currentServer!;

    var nav = Navigator.of(context);
    disconnectSub =
        appState.connecting.eventDisconnected.stream.listen((data) async {
      if (await showDisconneded(context) == true) {
        try {
          disconnectSub.cancel();
          await gameengine.currentGame?.dispose();
          await appState.connecting.connect(appState.currentServer!);
          gameengine.currentGame = gameengine.Game.create();
          setState(() {});
        } catch (e) {
          if (context.mounted) {
            showConnectError(context, e.toString());
          }
        }
      } else {
        nav.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("服务器 " + (server.name.isEmpty ? server.host : server.name)),
      ),
      body: Display(),
    );
  }
}
