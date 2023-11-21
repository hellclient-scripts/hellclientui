import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hellclientui/states/appstate.dart';
import '..//widgets/fullscreen.dart';
import 'dart:async';
import 'dart:convert';
import '../widgets/display.dart';
import '../widgets/notopened.dart';
import '../../workers/game.dart' as gameengine;
import '../../models/message.dart' as message;

Future<String?> showNotOpened(
    BuildContext context, message.NotOpened games) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog.fullscreen(
        child: NotOpened(games: games.games),
      );
    },
  );
}

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<Game> createState() => GameState();
}

class GameState extends State<Game> {
  late StreamSubscription disconnectSub;
  late StreamSubscription subCommand;
  @override
  void dispose() {
    disconnectSub.cancel();
    subCommand.cancel();
    gameengine.currentGame?.dispose();
    gameengine.currentGame?.close();

    super.dispose();
  }

  @override
  void initState() {
    var appState = currentAppState;
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
        if (context.mounted) {
          var nav = Navigator.of(context);
          nav.pop();
        }
      }
    });
    subCommand =
        gameengine.currentGame!.commandStream.stream.listen((event) async {
      if (event is gameengine.GameCommand) {
        switch (event.command) {
          case 'notopened':
            final dynamic jsondata = json.decode(event.data);
            final notOpened = message.NotOpened.fromJson(jsondata);
            final id = await showNotOpened(context, notOpened);
            if (id != null) {
              gameengine.currentGame!.handleCmd('open', id);
            }
            break;
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var server = appState.currentServer!;
    var focusNode = FocusNode(
      onKey: (node, event) {
        return gameengine.currentGame!.onKey(event);
      },
    );

    return RawKeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(server.name.isEmpty ? server.host : server.name),
          ),
          body: const Fullscreen(
            minWidth: 640,
            child: Display(),
          ),
        ));
  }
}
