import 'package:flutter/material.dart';
import 'package:hellclientui/models/batchcommand.dart';
import '../../forms/presetbatchcommandform.dart';

class CreatePresetBatchCommandPage extends StatelessWidget {
  const CreatePresetBatchCommandPage({super.key});
  @override
  Widget build(BuildContext context) {
    final command = BatchCommand();
    command.scripts.add('');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("添加预设批量命令"),
      ),
      body: PresetBatchCommandForm(
        command: command,
      ),
    );
  }
}
