import 'package:flutter/material.dart';
import '../../models/message.dart' as message;
import 'appui.dart';
import 'userinput.dart';
import '../../forms/triggerform.dart';
import 'package:hellclientui/workers/game.dart';

Future<message.RequiredParam?> showCreateTrigger(BuildContext context) async {
  showDialog<bool?>(
    context: context,
    builder: (context) {
      return const Dialog.fullscreen(
          child: FullScreenDialog(
              title: '创建脚本触发器',
              child: TriggerForm(
                byUser: false,
              )));
    },
  );
}

class ScriptTriggers extends StatefulWidget {
  const ScriptTriggers({super.key, required this.triggers});
  final message.Triggers triggers;
  @override
  State<StatefulWidget> createState() => ScriptTriggersState();
}

class ScriptTriggersState extends State<ScriptTriggers> {
  final TextEditingController filter = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<TableRow> children = [
      createTableRow([
        const TableHead(
          '触发',
          textAlign: TextAlign.start,
        ),
        const TableHead('有效', textAlign: TextAlign.start),
        const TableHead('名称', textAlign: TextAlign.start),
        const TableHead('脚本', textAlign: TextAlign.end),
        const TableHead('分组', textAlign: TextAlign.end),
        const TableHead('发送', textAlign: TextAlign.end),
        const TableHead('操作', textAlign: TextAlign.end),
      ])
    ];
    for (final trigger in widget.triggers.list) {
      if (filter.text.isEmpty ||
          trigger.match.contains(filter.text) ||
          trigger.group.contains(filter.text) ||
          trigger.send.contains(filter.text) ||
          trigger.script.contains(filter.text) ||
          trigger.name.contains(filter.text)) {
        void update() async {
          // final result = await AppUI.promptTextArea(
          //     context, '设置变量$key', '', '', widget.info.params[key] ?? '');
          // if (result != null) {
          //   currentGame!
          //       .handleCmd('updateParam', [currentGame!.current, key, result]);
          // }
        }

        children.add(createTableRow([
          TCell(Text(trigger.match)),
          TCell(Text(trigger.enabled ? "是" : "否")),
          TCell(Text(trigger.name)),
          TCell(Text(trigger.script)),
          TCell(Text(trigger.group)),
          TCell(Text(trigger.send)),
          TCell(
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: update,
                    child: const Text(
                      '设置',
                    )),
                TextButton(
                    onPressed: () async {
                      if (await AppUI.showConfirmBox(
                              context,
                              '删除',
                              '',
                              const Text.rich(
                                TextSpan(children: [
                                  WidgetSpan(
                                      child: Icon(
                                    Icons.warning,
                                    color: Color(0xffE6A23C),
                                  )),
                                  TextSpan(text: '是否要删除该变量?'),
                                ]),
                              )) ==
                          true) {
                        // currentGame!.handleCmd(
                        //     'deleteParam', [currentGame!.current, key]);
                      }
                    },
                    child: const Text(
                      '删除',
                    ))
              ],
            ),
          )
        ]));
      }
    }
    return Dialog.fullscreen(
        child: Stack(children: [
      FullScreenDialog(
          title: '脚本触发器',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                          decoration: const InputDecoration(
                              hintText: '请输入需要过滤的关键字',
                              hintStyle: textStyleUserInputFilter),
                          controller: filter,
                          onChanged: (value) {
                            setState(() {});
                          }))),
            ]),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(180),
                6: FixedColumnWidth(180)
              },
              children: children,
            ),
            const SizedBox(
              height: 150,
            )
          ])),
      Positioned(
          right: 30,
          bottom: 30,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await showCreateTrigger(context);
            },
            tooltip: '新建脚本变量',
            child: const Icon(Icons.add),
          ))
    ]));
  }
}
