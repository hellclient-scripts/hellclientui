import 'package:flutter/material.dart';
import '../../models/message.dart' as message;
import 'appui.dart';
import 'userinput.dart';
import '../../forms/timerform.dart';
import 'package:hellclientui/workers/game.dart';
import 'dart:async';

showCreateTimer(BuildContext context, bool byUser) async {
  showDialog(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return Dialog.fullscreen(
          child: FullScreenDialog(
              title: byUser ? '创建游戏计时器' : '创建脚本计时器',
              child: TimerForm(
                timer: message.Timer(),
                onSubmit: (timer) {
                  final createtirgger = message.CreateTimer(timer);
                  createtirgger.byUser = byUser;
                  createtirgger.world = currentGame!.current;
                  currentGame!.handleCmd('createTimer', createtirgger);
                  Navigator.of(context).pop();
                },
              )));
    },
  );
}

showUpdateTimer(BuildContext context, message.Timer timer, bool byUser) async {
  showDialog(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return Dialog.fullscreen(
          child: FullScreenDialog(
              title: byUser ? '修改游戏计时器' : '修改脚本计时器',
              child: TimerForm(
                timer: timer,
                onSubmit: (timer) {
                  final updatetimer = message.UpdateTimer(timer);
                  updatetimer.byUser = byUser;
                  updatetimer.world = currentGame!.current;
                  currentGame!.handleCmd('updateTimer', updatetimer);
                  Navigator.of(context).pop();
                },
              )));
    },
  );
}

class Timers extends StatefulWidget {
  const Timers({super.key, required this.byUser});
  final bool byUser;
  @override
  State<StatefulWidget> createState() => TimersState();
}

class TimersState extends State<Timers> {
  final TextEditingController filter = TextEditingController();
  final _scrollconrtoller = ScrollController();
  late StreamSubscription subCommand;
  message.Timers? timers;
  @override
  void initState() {
    super.initState();
    timers = currentGame!.timers;
    subCommand = currentGame!.dataUpdateStream.stream.listen((event) {
      if (event is message.Timers?) {
        timers = event;
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
    if (timers == null) {
      return AppUI.loading;
    }
    final List<TableRow> children = [
      createTableRow([
        const TableHead('时间', textAlign: TextAlign.start),
        const TableHead('固定时间', textAlign: TextAlign.start),
        const TableHead('有效', textAlign: TextAlign.start),
        const TableHead('名称', textAlign: TextAlign.start),
        const TableHead('脚本', textAlign: TextAlign.end),
        const TableHead('分组', textAlign: TextAlign.end),
        const TableHead('发送', textAlign: TextAlign.end),
        const TableHead('操作', textAlign: TextAlign.end),
      ])
    ];
    for (final timer in timers!.list) {
      if (filter.text.isEmpty ||
          timer.group.contains(filter.text) ||
          timer.send.contains(filter.text) ||
          timer.script.contains(filter.text) ||
          timer.name.contains(filter.text)) {
        void update() async {
          showUpdateTimer(context, timer, widget.byUser);
        }

        children.add(createTableRow([
          TCell(Text('${timer.hour}:${timer.minute}:${timer.second}')),
          TCell(Text(timer.atTime ? "是" : "否")),
          TCell(Text(timer.enabled ? "是" : "否")),
          TCell(Text(timer.name)),
          TCell(Text(timer.script)),
          TCell(Text(timer.group)),
          TCell(Text(timer.send)),
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
                                  TextSpan(text: '是否要删除该计时器?'),
                                ]),
                              )) ==
                          true) {
                        currentGame!.handleCmd(
                            'deleteTimer', [currentGame!.current, timer.id]);
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
          title: widget.byUser ? '游戏计时器' : '脚本计时器',
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
                              7: FixedColumnWidth(180)
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
              await showCreateTimer(context, widget.byUser);
            },
            tooltip: widget.byUser ? '新建游戏变量' : '新建脚本变量',
            child: const Icon(Icons.add),
          ))
    ]));
  }
}
