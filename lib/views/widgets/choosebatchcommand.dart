import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/views/widgets/appui.dart';

class ChooseBatchCommand extends StatelessWidget {
  const ChooseBatchCommand({super.key});
  String formatTitle(int index, String title) {
    return index < 9 ? '${index + 1}.$title' : title;
  }

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();
    return KeyboardListener(
        autofocus: true,
        onKeyEvent: (value) {
          if (value is KeyDownEvent) {
            switch (value.logicalKey.keyLabel) {
              case '1':
              case '2':
              case '3':
              case '4':
              case '5':
              case '6':
              case '7':
              case '8':
              case '9':
                final index = int.parse(value.logicalKey.keyLabel) - 1;
                if (index < currentAppState.config.batchCommands.length) {
                  Navigator.of(context)
                      .pop(currentAppState.config.batchCommands[index]);
                }
                break;
            }
          }
        },
        focusNode: focusNode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...currentAppState.config.batchCommands
                .asMap()
                .entries
                .map((entry) => ListTile(
                      leading: const Icon(Icons.construction),
                      title: Text(formatTitle(entry.key, entry.value.name)),
                      subtitle: Text.rich(TextSpan(children: [
                        const TextSpan(text: '发送到脚本：'),
                        TextSpan(
                            text: entry.value.scripts
                                .map((e) => e == '' ? '[全部脚本]' : '[$e]')
                                .toList()
                                .join(','))
                      ])),
                      trailing: TextButton(
                          child: const Text('发送'),
                          onPressed: () {
                            Navigator.of(context).pop(entry.value);
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
        ));
  }
}
