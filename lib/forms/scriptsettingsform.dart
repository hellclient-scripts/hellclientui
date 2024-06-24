import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import '../models/feature.dart';

import 'package:hellclientui/workers/game.dart';
import '../views/widgets/appui.dart';
import '../models/message.dart' as message;
import 'dart:async';

class ScriptSettingsForm extends StatefulWidget {
  const ScriptSettingsForm({super.key, required this.settings});
  final message.ScriptSettings settings;
  @override
  State<StatefulWidget> createState() => ScriptSettingsFormState();
}

class ScriptSettingsFormState extends State<ScriptSettingsForm> {
  late TextEditingController desc;
  late TextEditingController channel;
  late TextEditingController onAssist;
  late TextEditingController onKeyUp;
  late TextEditingController onBroadcast;
  late TextEditingController onResponse;
  late TextEditingController onOpen;
  late TextEditingController onClose;
  late TextEditingController onConnect;
  late TextEditingController onDisconnect;
  late TextEditingController onHUDClick;
  late TextEditingController onBuffer;
  late TextEditingController onBufferMin;
  late TextEditingController onBufferMax;
  late TextEditingController onSubneg;
  late TextEditingController onFocus;
  late TextEditingController onLoseFocus;
  late TextEditingController intro;

  message.CreateFail? fail;

  late StreamSubscription sub;

  @override
  void initState() {
    desc = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.desc));
    channel = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.channel));
    onAssist = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onAssist));
    onKeyUp = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onKeyUp));
    onBroadcast = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onBroadcast));
    onResponse = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onResponse));
    onOpen = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onOpen));
    onClose = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onClose));
    onConnect = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onConnect));
    onDisconnect = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onDisconnect));
    onHUDClick = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onHUDClick));
    onBuffer = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onBuffer));
    onBufferMin = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onBufferMin.toString()));
    onBufferMax = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onBufferMax.toString()));
    onSubneg = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onSubneg));
    onFocus = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onFocus));
    onLoseFocus = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.onLoseFocus));
    intro = TextEditingController.fromValue(
        TextEditingValue(text: widget.settings.intro));

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
        Container(
            color: const Color(0xffeeeeee),
            padding: const EdgeInsets.all(4),
            child: TextFormField(
              controller: desc,
              maxLines: null,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                label: Text("描述"),
              ),
            )),
        TextFormField(
          controller: channel,
          decoration: const InputDecoration(
            label: Text("广播频道"),
          ),
        ),
        TextFormField(
          controller: onAssist,
          decoration: const InputDecoration(
            label: Text("助理触发函数"),
          ),
        ),
        TextFormField(
          controller: onKeyUp,
          decoration: const InputDecoration(
            label: Text("快捷键触发函数"),
          ),
        ),
        TextFormField(
          controller: onBroadcast,
          decoration: const InputDecoration(
            label: Text("广播触发函数"),
          ),
        ),
        TextFormField(
          controller: onResponse,
          decoration: const InputDecoration(
            label: Text("响应触发函数"),
          ),
        ),
        TextFormField(
          controller: onOpen,
          decoration: const InputDecoration(
            label: Text("加载触发函数"),
          ),
        ),
        TextFormField(
          controller: onClose,
          decoration: const InputDecoration(
            label: Text("关闭触发函数"),
          ),
        ),
        TextFormField(
          controller: onConnect,
          decoration: const InputDecoration(
            label: Text("连线触发函数"),
          ),
        ),
        TextFormField(
          controller: onDisconnect,
          decoration: const InputDecoration(
            label: Text("掉线触发函数"),
          ),
        ),
        TextFormField(
          controller: onHUDClick,
          decoration: const InputDecoration(
            label: Text("HUD点击函数"),
          ),
        ),
        TextFormField(
          controller: onBuffer,
          decoration: const InputDecoration(
            label: Text("Buffer处理函数"),
          ),
        ),
        TextFormField(
          controller: onBufferMin,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ], // Only numbers can be entered
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            label: Text("Buffer处理函数最小响应字数"),
          ),
        ),
        TextFormField(
          controller: onBufferMax,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ], // Only numbers can be entered
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            label: Text("Buffer处理函数最小响应字数"),
          ),
        ),
        TextFormField(
          controller: onSubneg,
          decoration: const InputDecoration(
            label: Text("SubNegotiation处理函数"),
          ),
        ),
        TextFormField(
          controller: onFocus,
          decoration: const InputDecoration(
            label: Text("获得焦点函数"),
          ),
        ),
        currentGame!.support(Features.onLoseFocus)
            ? TextFormField(
                controller: onLoseFocus,
                decoration: const InputDecoration(
                  label: Text("失去焦点函数"),
                ),
              )
            : const Center(),
        Container(
            color: const Color(0xffeeeeee),
            padding: const EdgeInsets.all(4),
            child: TextFormField(
              controller: intro,
              maxLines: null,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                label: Text("简介"),
              ),
            )),
        ConfirmOrCancelWidget(onConfirm: () {
          final form = message.UpdateScriptSettingsForm();
          form.name = widget.settings.name;
          form.type = widget.settings.type;
          form.desc = desc.text;
          form.channel = channel.text;
          form.onAssist = onAssist.text;
          form.onKeyUp = onKeyUp.text;
          form.onBroadcast = onBroadcast.text;
          form.onResponse = onResponse.text;
          form.onOpen = onOpen.text;
          form.onClose = onClose.text;
          form.onConnect = onConnect.text;
          form.onDisconnect = onDisconnect.text;
          form.onHUDClick = onHUDClick.text;
          form.onBuffer = onBuffer.text;
          form.onBufferMin = int.tryParse(onBufferMin.text) ?? 0;
          form.onBufferMax = int.tryParse(onBufferMax.text) ?? 0;
          form.onSubneg = onSubneg.text;
          form.onFocus = onFocus.text;
          form.onLoseFocus = onLoseFocus.text;
          form.intro = intro.text;
          form.id = currentGame!.current;
          currentGame!.handleCmd('updateScriptSettings', form);
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
