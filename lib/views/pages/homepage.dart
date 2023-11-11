import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import 'sidebarnav.dart';
import 'serverlist.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    Widget child;
    switch (appState.currentPage) {
      case 0:
        child = ServerList(servers: appState.config.servers);
        break;
      default:
        child = Text("empty");
    }
    sidebarNav nav = sidebarNav(
      onSelect: (int index) {
        appState.currentPage = index;
        appState.notifyListeners();
      },
      selected: appState.currentPage,
    );
    return Scaffold(
      body: Row(
        children: <Widget>[
          nav,
          Expanded(child: child),
        ],
      ),
    );
  }
}
