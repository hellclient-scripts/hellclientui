import 'package:flutter/material.dart';
import '../../models/message.dart' as message;
import 'appui.dart';
import 'userinput.dart';
import '../../forms/aliasform.dart';
import 'package:hellclientui/workers/game.dart';
import 'dart:async';

showCreateAlias(BuildContext context, bool byUser) async {
  showDialog(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return Dialog.fullscreen(
          child: FullScreenDialog(
              title: byUser ? '创建游戏别名' : '创建脚本别名',
              child: AliasForm(
                alias: message.Alias(),
                onSubmit: (alias) {
                  final createtirgger = message.CreateAlias(alias);
                  createtirgger.byUser = byUser;
                  createtirgger.world = currentGame!.current;
                  currentGame!.handleCmd('createAlias', createtirgger);
                  Navigator.of(context).pop();
                },
              )));
    },
  );
}

showUpdateAlias(BuildContext context, message.Alias alias, bool byUser) async {
  showDialog(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return Dialog.fullscreen(
          child: FullScreenDialog(
              title: byUser ? '修改游戏别名' : '修改脚本别名',
              child: AliasForm(
                alias: alias,
                onSubmit: (alias) {
                  final updatealias = message.UpdateAlias(alias);
                  updatealias.byUser = byUser;
                  updatealias.world = currentGame!.current;
                  currentGame!.handleCmd('updateAlias', updatealias);
                  Navigator.of(context).pop();
                },
              )));
    },
  );
}

class Aliases extends StatefulWidget {
  const Aliases({super.key, required this.byUser});
  final bool byUser;
  @override
  State<StatefulWidget> createState() => AliasesState();
}

class AliasesState extends State<Aliases> {
  final TextEditingController filter = TextEditingController();
  final _scrollconrtoller = ScrollController();
  late StreamSubscription subCommand;
  message.Aliases? aliases;
  @override
  void initState() {
    super.initState();
    aliases = currentGame!.aliases;
    subCommand = currentGame!.dataUpdateStream.stream.listen((event) {
      if (event is message.Aliases?) {
        aliases = event;
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
    if (aliases == null) {
      return AppUI.loading;
    }
    final List<TableRow> children = [
      createTableRow([
        const TableHead(
          '别名',
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
    for (final alias in aliases!.list) {
      if (filter.text.isEmpty ||
          alias.match.contains(filter.text) ||
          alias.group.contains(filter.text) ||
          alias.send.contains(filter.text) ||
          alias.script.contains(filter.text) ||
          alias.name.contains(filter.text)) {
        void update() async {
          showUpdateAlias(context, alias, widget.byUser);
        }

        children.add(createTableRow([
          TCell(Text(alias.match)),
          TCell(Text(alias.enabled ? "是" : "否")),
          TCell(Text(alias.name)),
          TCell(Text(alias.script)),
          TCell(Text(alias.group)),
          TCell(Text(alias.send)),
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
                                  TextSpan(text: '是否要删除该别名?'),
                                ]),
                              )) ==
                          true) {
                        currentGame!.handleCmd(
                            'deleteAlias', [currentGame!.current, alias.id]);
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
          title: widget.byUser ? '游戏别名' : '脚本别名',
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
                        ])))
          ])),
      Positioned(
          right: 30,
          bottom: 30,
          child: FloatingActionButton(
            onPressed: () async {
              await showCreateAlias(context, widget.byUser);
            },
            tooltip: widget.byUser ? '新建游戏变量' : '新建脚本变量',
            child: const Icon(Icons.add),
          ))
    ]));
  }
}
