import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hellclientui/workers/game.dart';
import '../views/widgets/appui.dart';
import '../models/message.dart' as message;
import 'dart:async';

class CreateScriptForm extends StatefulWidget {
  const CreateScriptForm({super.key});
  @override
  State<StatefulWidget> createState() => CreateScriptFormState();
}

class CreateScriptFormState extends State<CreateScriptForm> {
  late TextEditingController id;
  late String type;
  message.CreateFail? fail;
  late StreamSubscription sub;

  @override
  void initState() {
    id = TextEditingController();
    type = "";
    sub = currentGame!.createFailStream.stream.listen((event) {
      final newfail = message.CreateFail.fromJson(jsonDecode(event));
      setState(() {
        fail = newfail;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreateFailMessage(fail: fail),
        TextFormField(
          controller: id,
          decoration: const InputDecoration(
            label: Text("名称"),
          ),
        ),
        DropdownButtonFormField(
          value: type,
          decoration: const InputDecoration(
            label: Text("类型"),
          ),
          items: const <DropdownMenuItem>[
            DropdownMenuItem(
              value: '',
              enabled: false,
              child: Text('<未选择>'),
            ),
            DropdownMenuItem(value: 'lua', child: Text('Lua')),
            DropdownMenuItem(value: 'jscript', child: Text('JavaScript')),
          ],
          onChanged: (value) {
            type = value;
          },
        ),
        ConfirmOrCancelWidget(onConfirm: () {
          currentGame!.handleCmd(
              'createScript',
              message.CreateScriptForm(
                id: id.text,
                type: type,
              ));
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
