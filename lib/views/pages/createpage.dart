import 'package:flutter/material.dart';
import '../../models/server.dart';
import '../../forms/createform.dart';

class CreatePage extends StatelessWidget {
  CreatePage({super.key});
  final Server server = Server();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("添加服务器"),
      ),
      body: const CreateForm(),
    );
  }
}
