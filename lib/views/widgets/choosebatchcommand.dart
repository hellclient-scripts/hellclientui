import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/views/widgets/appui.dart';

class ChooseBatchCommand extends StatelessWidget {
  const ChooseBatchCommand({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...currentAppState.config.batchCommands
            .map((e) => ListTile(
                  leading: const Icon(Icons.construction),
                  title: Text(e.name),
                  subtitle: Text.rich(TextSpan(children: [
                    const TextSpan(text: '发送到脚本：'),
                    TextSpan(
                        text: e.scripts
                            .map((e) => e == '' ? '[全部脚本]' : '[$e]')
                            .toList()
                            .join(','))
                  ])),
                  trailing: TextButton(
                      child: const Text('发送'),
                      onPressed: () {
                        Navigator.of(context).pop(e);
                      }),
                ))
            .toList(),
        ConfirmOrCancelWidget(
            labelConfirm: null,
            onConfirm: () {},
            onCancal: () {
              Navigator.of(context).pop();
            })
      ],
    );
  }
}
