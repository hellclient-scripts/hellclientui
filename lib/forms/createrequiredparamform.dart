import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hellclientui/workers/game.dart';
import '../views/widgets/appui.dart';
import '../models/message.dart' as message;
import 'dart:async';

class CreateRequiredParamForm extends StatefulWidget {
  const CreateRequiredParamForm({super.key});
  @override
  State<StatefulWidget> createState() => CreateRequiredParamFormState();
}

class CreateRequiredParamFormState extends State<CreateRequiredParamForm> {
  final TextEditingController name = TextEditingController();
  final TextEditingController desc = TextEditingController();
  final TextEditingController intro = TextEditingController();
  message.CreateFail? fail;
  late StreamSubscription sub;

  @override
  void initState() {
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
          controller: name,
          decoration: const InputDecoration(
            label: Text("名称"),
          ),
        ),
        TextFormField(
          controller: desc,
          decoration: const InputDecoration(
            label: Text("描述"),
          ),
        ),
        Container(
            color: const Color(0xffeeeeee),
            padding: const EdgeInsets.all(4),
            child: TextFormField(
              controller: intro,
              maxLines: 8,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                label: Text("简介"),
              ),
            )),
        ConfirmOrCancelWidget(onConfirm: () {
          Navigator.of(context).pop(message.RequiredParam(
              name: name.text, desc: desc.text, intro: intro.text));
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
