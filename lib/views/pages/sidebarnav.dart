import 'package:hellclientui/states/appstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class sidebarNav extends StatelessWidget {
  sidebarNav({
    required this.onSelect,
    required selected,
  });
  Function(int index)? onSelect;
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      selectedIndex: selected,
      onDestinationSelected: onSelect,
      trailing: IconButton(
        icon: Icon(Icons.info),
        onPressed: () => {
          showAboutDialog(
              context: context,
              applicationName: "Hellclient UI",
              applicationVersion: "0.0.1")
        },
      ),
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('控制台'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          selectedIcon: Icon(Icons.settings),
          label: Text('设置'),
        ),
      ],
    );
  }
}
