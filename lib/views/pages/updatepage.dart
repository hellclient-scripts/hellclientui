import 'package:flutter/material.dart';
import '../../models/server.dart';
import '../../forms/updateform.dart';

class UpdatePage extends StatelessWidget {
  UpdatePage({super.key});
  final Server server = Server();
  @override
  Widget build(BuildContext context) {
    final origin = ModalRoute.of(context)!.settings.arguments as Server;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("编辑服务器"),
      ),
      body: UpdateForm(origin: origin),
    );
  }
}
