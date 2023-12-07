import 'package:flutter/material.dart';
import 'package:hellclientui/models/batchcommand.dart';
import 'package:hellclientui/views/widgets/appui.dart';

const _textStyleScriptLabel = TextStyle(fontSize: 14, height: 32 / 14);
const _textStyleLabel =
    TextStyle(fontSize: 14, height: 32 / 14, fontWeight: FontWeight.bold);

class PresetBatchCommandForm extends StatefulWidget {
  const PresetBatchCommandForm({super.key, required this.command});
  final BatchCommand command;
  @override
  State<StatefulWidget> createState() => PresetBatchCommandFormState();
}

class PresetBatchCommandFormState extends State<PresetBatchCommandForm> {
  final name = TextEditingController();
  final command = TextEditingController();
  List<String> scripts = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    name.text = widget.command.name;
    command.text = widget.command.command;
    scripts = widget.command.scripts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
                controller: name,
                decoration: const InputDecoration(
                  label: Text("预设名"),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '预设名不可为空';
                  }
                  return null;
                }),
            Text.rich(TextSpan(children: [
              const TextSpan(text: '发送脚本:', style: _textStyleLabel),
              WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  baseline: TextBaseline.alphabetic,
                  child: SizedBox(
                      height: 32,
                      child: IconButton(
                        iconSize: 32,
                        onPressed: () async {
                          final result = await AppUI.promptText(
                              context, '请输入要增加的教本名', '留空发送给所有脚本', '', '');
                          if (result != null) {
                            setState(() {
                              scripts.add(result);
                            });
                          }
                        },
                        tooltip: '添加',
                        icon: const Icon(
                          Icons.add,
                          size: 32,
                        ),
                      ))),
              ...scripts
                  .asMap()
                  .entries
                  .map((entry) => TextSpan(children: [
                        TextSpan(
                            text:
                                '[${entry.value.isEmpty ? "全部脚本" : entry.value}]',
                            style: _textStyleScriptLabel),
                        WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            baseline: TextBaseline.alphabetic,
                            child: SizedBox(
                                height: 32,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      scripts.removeAt(entry.key);
                                    });
                                  },
                                  tooltip: '移除',
                                  icon: const Icon(
                                    Icons.close,
                                    size: 32,
                                  ),
                                ))),
                      ]))
                  .toList()
            ])),
            Container(
                color: const Color(0xffeeeeee),
                padding: const EdgeInsets.all(4),
                child: TextFormField(
                  controller: command,
                  maxLines: 8,
                  minLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    label: Text("指令"),
                  ),
                )),
            ConfirmOrCancelWidget(
              onConfirm: () {
                if (_formKey.currentState!.validate()) {
                  final newcommand = BatchCommand();
                  newcommand.command = command.text;
                  newcommand.name = name.text;
                  newcommand.scripts = scripts;
                  Navigator.of(context).pop(newcommand);
                }
              },
              onCancal: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ));
  }
}
