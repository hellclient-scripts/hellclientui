import 'package:flutter/material.dart';
import 'package:hellclientui/views/widgets/appui.dart';
import 'package:hellclientui/workers/game.dart';
import '../views/widgets/bottom.dart';
import '../models/message.dart' as message;

const _textStyleScriptLabel = TextStyle(fontSize: 14, height: 32 / 14);
const _textStyleLabel =
    TextStyle(fontSize: 14, height: 32 / 14, fontWeight: FontWeight.bold);

class BatchCommandScript {
  BatchCommandScript({required this.label, required this.key});
  String label = "";
  String key = "";
  bool value = false;
}

class SendBatchCommandForm extends StatefulWidget {
  const SendBatchCommandForm({super.key, required this.scripts});
  final List<String> scripts;
  @override
  State<SendBatchCommandForm> createState() => SendBatchCommandFormState();
}

class SendBatchCommandFormState extends State<SendBatchCommandForm> {
  List<BatchCommandScript> scriptlabels = [];
  final command = TextEditingController();
  @override
  void initState() {
    scriptlabels.add(BatchCommandScript(label: '所有游戏', key: ''));
    for (final scriptid in widget.scripts) {
      scriptlabels.add(BatchCommandScript(key: scriptid, label: scriptid));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(TextSpan(children: [
          const TextSpan(text: '选择脚本', style: _textStyleLabel),
          ...scriptlabels
              .map((e) => TextSpan(children: [
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        baseline: TextBaseline.alphabetic,
                        child: SizedBox(
                            height: 32,
                            child: Checkbox(
                              value: e.value,
                              onChanged: (value) {
                                setState(() {
                                  e.value = (value == true);
                                });
                              },
                            ))),
                    TextSpan(text: '[${e.label}]', style: _textStyleScriptLabel)
                  ]))
              .toList()
        ])),
        Container(
            color: Colors.black,
            child: TextFormField(
              decoration: const InputDecoration(
                  hintText: '请输入你需要批量输入的数据',
                  hintStyle: textStyleBottomMasSendHint),
              maxLines: null,
              style: textStyleBottomMasSend,
              controller: command,
              autofocus: true,
              keyboardType: TextInputType.multiline,
              minLines: 25,
            )),
        ConfirmOrCancelWidget(
          onConfirm: () {
            final cmd = message.BatchCommand();
            cmd.command = command.text;
            for (final label in scriptlabels) {
              if (label.value) {
                cmd.scripts.add(label.key);
              }
            }
            currentGame!.handleCmd('batchcommand', cmd);
            Navigator.of(context).pop();
          },
          onCancal: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
