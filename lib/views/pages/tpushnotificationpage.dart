import 'package:flutter/material.dart';
import 'package:hellclientui/forms/tpushform.dart';

class TPushNotificationPage extends StatelessWidget {
  const TPushNotificationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("腾讯通知设置"),
        ),
        body: const TPushForm());
  }
}
