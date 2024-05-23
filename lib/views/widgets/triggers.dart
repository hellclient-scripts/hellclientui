import 'package:flutter/material.dart';
import '../../models/message.dart' as message;
import 'appui.dart';
import 'userinput.dart';
import '../../forms/triggerform.dart';
import 'package:hellclientui/workers/game.dart';
import 'dart:async';

showCreateTrigger(BuildContext context, bool byUser) async {
  showDialog(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return Dialog.fullscreen(
          child: FullScreenDialog(
              title: byUser ? '创建游戏触发器' : '创建脚本触发器',
              child: TriggerForm(
                trigger: message.Trigger(),
                onSubmit: (trigger) {
                  final createtirgger = message.CreateTrigger(trigger);
                  createtirgger.byUser = byUser;
                  createtirgger.world = currentGame!.current;
                  currentGame!.handleCmd('createTrigger', createtirgger);
                  Navigator.of(context).pop();
                },
              )));
    },
  );
}

showUpdateTrigger(
    BuildContext context, message.Trigger trigger, bool byUser) async {
  showDialog(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return Dialog.fullscreen(
          child: FullScreenDialog(
              title: byUser ? '修改游戏触发器' : '修改脚本触发器',
              child: TriggerForm(
                trigger: trigger,
                onSubmit: (trigger) {
                  final updatetrigger = message.UpdateTrigger(trigger);
                  updatetrigger.byUser = byUser;
                  updatetrigger.world = currentGame!.current;
                  currentGame!.handleCmd('updateTrigger', updatetrigger);
                  Navigator.of(context).pop();
                },
              )));
    },
  );
}

class Triggers extends StatefulWidget {
  const Triggers({super.key, required this.byUser});
  final bool byUser;
  @override
  State<StatefulWidget> createState() => TriggersState();
}

class TriggersState extends State<Triggers> {
  final TextEditingController filter = TextEditingController();
  final _scrollconrtoller = ScrollController();

  message.Triggers? triggers;
  late StreamSubscription subCommand;
  @override
  void initState() {
    super.initState();
    triggers = currentGame!.triggers;
    subCommand = currentGame!.dataUpdateStream.stream.listen((event) {
      if (event is message.Triggers?) {
        triggers = event;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    subCommand.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (triggers == null) {
      return AppUI.loading;
    }
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
    for (final trigger in triggers!.list) {
      if (filter.text.isEmpty ||
          trigger.match.contains(filter.text) ||
          trigger.group.contains(filter.text) ||
          trigger.send.contains(filter.text) ||
          trigger.script.contains(filter.text) ||
          trigger.name.contains(filter.text)) {
        void update() async {
          showUpdateTrigger(context, trigger, widget.byUser);
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
                                  TextSpan(text: '是否要删除该触发器?'),
                                ]),
                              )) ==
                          true) {
                        currentGame!.handleCmd('deleteTrigger',
                            [currentGame!.current, trigger.id]);
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
          withScroll: false,
          title: widget.byUser ? '游戏触发器' : '脚本触发器',
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
            Flexible(
                child: SingleChildScrollView(
                    controller: _scrollconrtoller,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ]))),
          ])),
      Positioned(
          right: 30,
          bottom: 30,
          child: FloatingActionButton(
            onPressed: () async {
              await showCreateTrigger(context, widget.byUser);
            },
            tooltip: widget.byUser ? '新建游戏触发器' : '新建脚本触发器',
            child: const Icon(Icons.add),
          ))
    ]));
  }
}
