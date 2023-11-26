import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hellclientui/workers/game.dart';
import '../views/widgets/appui.dart';
import '../models/message.dart' as message;
import 'dart:async';

class CreateGameForm extends StatefulWidget {
  const CreateGameForm({super.key});
  @override
  State<StatefulWidget> createState() => CreateGameFormState();
}

class CreateGameFormState extends State<CreateGameForm> {
  TextEditingController? id;
  TextEditingController? host;
  TextEditingController? port;
  String? charset;
  message.CreateFail? fail;
  late StreamSubscription sub;
  late StreamSubscription cmd;

  @override
  void initState() {
    id ??= TextEditingController();
    host ??= TextEditingController();
    port ??= TextEditingController();
    charset ??= "";
    sub = currentGame!.createFailStream.stream.listen((event) {
      final newfail = message.CreateFail.fromJson(jsonDecode(event));
      setState(() {
        fail = newfail;
      });
    });
    cmd = currentGame!.commandStream.stream.listen((event) {
      if (event is GameCommand) {
        switch (event.command) {
          case "defaultServer":
            final data = (jsonDecode(event.data) as String).split(':');
            host!.value = TextEditingValue(text: data[0]);
            port!.value = TextEditingValue(text: data[1]);
            setState(() {});

            break;
          case "defaultCharset":
            charset = (jsonDecode(event.data) as String).toUpperCase();
            setState(() {});
            break;
          case "createSuccess":
            AppUI.hideUI(context);
            currentGame!.handleCmd('change', jsonDecode(event.data) as String);
            break;
        }
      }
    });
    currentGame!.handleCmd('defaultServer', '');
    currentGame!.handleCmd('defaultCharset', '');

    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    cmd.cancel();
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
        TextFormField(
          controller: host,
          decoration: const InputDecoration(
            label: Text("网址"),
          ),
        ),
        TextFormField(
          controller: port,
          decoration: const InputDecoration(
            label: Text("端口"),
          ),
        ),
        DropdownButtonFormField(
          value: charset,
          decoration: const InputDecoration(
            label: Text("字符编码"),
          ),
          items: const <DropdownMenuItem>[
            DropdownMenuItem(
              value: '',
              enabled: false,
              child: Text('<未选择>'),
            ),
            DropdownMenuItem(value: 'GBK', child: Text('GBK')),
            DropdownMenuItem(value: 'UTF8', child: Text('UTF8')),
          ],
          onChanged: (value) {
            charset = value;
          },
        ),
        ConfirmOrCancelWidget(onConfirm: () {
          currentGame!.handleCmd(
              'createGame',
              message.CreateGameForm(
                  id: id!.text,
                  host: host!.text,
                  port: port!.text,
                  charset: charset!));
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
