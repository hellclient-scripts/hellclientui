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
            icon: Icon(Icons.settings),
            label: '设置',
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
                  children: [
                    const SelectableText('Hellclient管理应用'),
                    const SizedBox(height: 10),
                    const SelectableText(
                        'GitHub: https://github.com/jarlyyn/hellclient'),
                    const SelectableText('社区: https://forum.hellclient.com'),
                  ],
                  applicationVersion: appState.version);
              return;
          }
          appState.currentPage = index;
          appState.updated();
        });
  }
}
