import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hellclientui/workers/game.dart';
import '../views/widgets/appui.dart';
import '../models/message.dart' as message;
import 'dart:async';

class WorldSettingsForm extends StatefulWidget {
  const WorldSettingsForm({super.key, required this.settings});
  final message.WorldSettings settings;
  @override
  State<StatefulWidget> createState() => WorldSettingsFormState();
}

class WorldSettingsFormState extends State<WorldSettingsForm> {
  late TextEditingController host;
  late TextEditingController port;
  late String charset;
  late TextEditingController proxy;
  late TextEditingController name;
  late TextEditingController scriptPrefix;
  late TextEditingController commandStackCharacter;
  late bool showBroadcast;
  late bool showSubneg;
  late bool modEnabled;
  message.CreateFail? fail;

  late StreamSubscription sub;

  @override
  void initState() {
    host = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.host));
    port = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.port));
    charset = widget.settings.charset.toUpperCase();
    proxy = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.proxy));
    name = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.name));
    scriptPrefix = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.scriptPrefix));
    commandStackCharacter = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.commandStackCharacter));
    showBroadcast = widget.settings.showBroadcast;
    showSubneg = widget.settings.showSubneg;
    modEnabled = widget.settings.modEnabled;

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
            setState(() {});
          },
        ),
        TextFormField(
          controller: proxy,
          decoration: const InputDecoration(
            label: Text("代理服务器"),
          ),
        ),
        TextFormField(
          controller: name,
          decoration: const InputDecoration(
            label: Text("名称"),
          ),
        ),
        TextFormField(
          controller: scriptPrefix,
          decoration: const InputDecoration(
            label: Text("脚本前缀"),
          ),
        ),
        TextFormField(
          controller: commandStackCharacter,
          decoration: const InputDecoration(
            label: Text("命令分割符"),
          ),
        ),
        Row(children: [
          Checkbox(
              value: showBroadcast,
              onChanged: (value) {
                setState(() {
                  showBroadcast = (value == true);
                });
              }),
          const Text('调试广播信息')
        ]),
        Row(children: [
          Checkbox(
              value: showSubneg,
              onChanged: (value) {
                setState(() {
                  showSubneg = (value == true);
                });
              }),
          const Text('调试非文字信息')
        ]),
        Row(children: [
          Checkbox(
              value: modEnabled,
              onChanged: (value) {
                setState(() {
                  modEnabled = (value == true);
                });
              }),
          const Text('脚本模组(Mod)')
        ]),
        ConfirmOrCancelWidget(onConfirm: () {
          final settings = message.WorldSettings(
            id: widget.settings.id,
            host: host.text,
            port: port.text,
            charset: charset,
            proxy: proxy.text,
            name: name.text,
            scriptPrefix: scriptPrefix.text,
            commandStackCharacter: commandStackCharacter.text,
            showBroadcast: showBroadcast,
            showSubneg: showSubneg,
            modEnabled: modEnabled,
          );
          currentGame!.handleCmd('updateWorldSettings', settings);
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
