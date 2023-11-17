import 'package:flutter/material.dart';
import 'dart:io';

class Notification extends StatelessWidget {
  const Notification({super.key});
  Widget buildTpush(BuildContext context) {
    return Center();
  }

  @override
  Widget build(BuildContext context) {
    late Widget body;
    if (Platform.isAndroid) {
      body = buildTpush(context);
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("通知设置"),
        ),
        body: body);
  }
}
