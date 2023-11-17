import 'package:hellclientui/states/appstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Nav {
  static Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    return BottomNavigationBar(
        currentIndex: appState.currentPage,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '控制台',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '通知',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '关于',
          )
        ],
        onTap: (int index) {
          switch (index) {
            case 2:
              showAboutDialog(
                  context: context,
                  applicationName: "Hellclient UI",
                  applicationVersion: "0.0.1");
              return;
          }
          appState.currentPage = index;
          appState.updated();
        });
  }
}
