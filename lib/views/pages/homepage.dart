import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import 'nav.dart';
import 'serverlist.dart';
import 'settingspage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
        child = const Center();
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
