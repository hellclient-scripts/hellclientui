import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/workers/game.dart';
import 'package:provider/provider.dart';
import 'nav.dart';
import 'serverlist.dart';
import 'settingspage.dart';
import '../../workers/notification.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  late StreamSubscription subEnterGame;
  @override
  void initState() {
    subEnterGame = currentAppState.streamEnterGame.stream.listen((event) async {
      if (context.mounted) {
        if (event is Function()) {
          if (currentGame != null) {
            currentGame!.commandStream
                .add(const GameCommand(command: '_hideui'));
          }
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          await event();
          if (context.mounted) {
            await Navigator.of(context).pushNamed("/game");
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subEnterGame.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    Widget child;
    switch (appState.currentPage) {
      case 0:
        child = ServerList(servers: appState.config.servers);
        break;
      case 1:
        child = const SettingsPage();
        break;
      default:
        child = Center(
            child:
                TextFormField(initialValue: currentNotification.tencentToken));
    }
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Nav.build(context),
    );
  }
}
