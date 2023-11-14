import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hellclientui/states/appstate.dart';
import '../widgets/display.dart';

class Game extends StatelessWidget {
  Game({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var server = appState.currentServer!;
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
