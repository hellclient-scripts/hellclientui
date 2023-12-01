import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import 'nav.dart';
import 'serverlist.dart';
import 'settingspage.dart';
import '../../workers/notification.dart';

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
