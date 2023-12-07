import 'package:flutter/material.dart';
import 'package:hellclientui/forms/desktopnotificationform.dart';

class DesktopNotificationPage extends StatelessWidget {
  const DesktopNotificationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("桌面通知设置"),
        ),
        body: const DesktopNotificationForm());
  }
}
