import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hellclientui/workers/game.dart';
import '../views/widgets/appui.dart';
import '../models/message.dart' as message;
import 'dart:async';

class TimerForm extends StatefulWidget {
  const TimerForm({super.key, required this.timer, required this.onSubmit});
  final message.Timer timer;
  final void Function(message.Timer) onSubmit;
  @override
  State<StatefulWidget> createState() => TimerFormState();
}

class TimerFormState extends State<TimerForm> {
  final name = TextEditingController();
  final hour = TextEditingController();
  final minute = TextEditingController();
  final second = TextEditingController();
  bool atTime = false;
  int sendTo = 0;
  final send = TextEditingController();
  final script = TextEditingController();
  final group = TextEditingController();
  bool actionWhenDisconnectd = false;
  bool enabled = false;
  bool oneShot = false;
  final variable = TextEditingController();
  bool temporary = false;
  bool omitFromOutput = false;
  bool omitFromLog = false;

  message.CreateFail? fail;
  late StreamSubscription sub;
  @override
  void initState() {
    name.text = widget.timer.name;
    hour.text = widget.timer.hour.toString();
    minute.text = widget.timer.minute.toString();
    second.text = widget.timer.second.toString();
    atTime = widget.timer.atTime;
    send.text = widget.timer.send;
    sendTo = widget.timer.sendTo;
    script.text = widget.timer.script;
    group.text = widget.timer.group;
    actionWhenDisconnectd = widget.timer.actionWhenDisconnectd;
    enabled = widget.timer.enabled;
    oneShot = widget.timer.oneShot;
    variable.text = widget.timer.variable;
    temporary = widget.timer.temporary;
    omitFromOutput = widget.timer.omitFromOutput;
    omitFromLog = widget.timer.omitFromLog;
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
    super.dispose();
    sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreateFailMessage(fail: fail),
        Row(children: [
          Text(atTime ? '触发时间' : '触发间隔'),
          Flexible(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextFormField(
                    controller: hour,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      label: Text("小时"),
                    ),
                  ))),
          Flexible(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextFormField(
                    controller: minute,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      label: Text("分钟"),
                    ),
                  ))),
          Flexible(
              flex: 1,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextFormField(
                    controller: second,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ], // Only numbers can be entered
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      label: Text("秒"),
                    ),
                  ))),
        ]),
        TextFormField(
          controller: name,
          decoration: const InputDecoration(
            label: Text("名称"),
          ),
        ),
        DropdownButtonFormField(
          value: sendTo,
          decoration: const InputDecoration(
            label: Text("发送到"),
          ),
          items: const <DropdownMenuItem>[
            DropdownMenuItem(
              value: '',
              enabled: false,
              child: Text('<未选择>'),
            ),
            DropdownMenuItem(value: 0, child: Text('0.游戏')),
            DropdownMenuItem(value: 1, child: Text('1.命令')),
            DropdownMenuItem(value: 2, child: Text('2.输出')),
            DropdownMenuItem(value: 3, child: Text('3.状态栏')),
            DropdownMenuItem(value: 4, child: Text('4.记事本')),
            DropdownMenuItem(value: 5, child: Text('5.追加到记事本')),
            DropdownMenuItem(value: 6, child: Text('6.日志')),
            DropdownMenuItem(value: 7, child: Text('7.提换记事本')),
            DropdownMenuItem(value: 8, child: Text('8.命令队列')),
            DropdownMenuItem(value: 9, child: Text('9.变量')),
            DropdownMenuItem(value: 10, child: Text('10.执行')),
            DropdownMenuItem(value: 11, child: Text('11.快速行走')),
            DropdownMenuItem(value: 12, child: Text('12.脚本')),
            DropdownMenuItem(value: 13, child: Text('13.立即发送')),
            DropdownMenuItem(value: 14, child: Text('14.脚本(过滤后)')),
          ],
          onChanged: (value) {
            sendTo = value;
            setState(() {});
          },
        ),
        Container(
            color: const Color(0xffeeeeee),
            padding: const EdgeInsets.all(4),
            child: TextFormField(
              controller: send,
              maxLines: 8,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                label: Text("发送"),
              ),
            )),
        TextFormField(
          controller: script,
          decoration: const InputDecoration(
            label: Text("调用脚本函数"),
          ),
        ),
        TextFormField(
          controller: group,
          decoration: const InputDecoration(
            label: Text("分组名"),
          ),
        ),
        sendTo == 9
            ? TextFormField(
                controller: variable,
                decoration: const InputDecoration(
                  label: Text("变量"),
                ),
              )
            : const Center(),
        Row(children: [
          Checkbox(
            value: atTime,
            onChanged: (value) {
              setState(() {
                atTime = (value == true);
              });
            },
          ),
          const Text('具体时分秒'),
        ]),
        Row(children: [
          Checkbox(
            value: enabled,
            onChanged: (value) {
              setState(() {
                enabled = (value == true);
              });
            },
          ),
          const Text('启用'),
        ]),
        Row(children: [
          Checkbox(
            value: actionWhenDisconnectd,
            onChanged: (value) {
              setState(() {
                actionWhenDisconnectd = (value == true);
              });
            },
          ),
          const Text('离线可用'),
        ]),
        Row(children: [
          Checkbox(
            value: oneShot,
            onChanged: (value) {
              setState(() {
                oneShot = (value == true);
              });
            },
          ),
          const Text('一次性'),
        ]),
        Row(children: [
          Checkbox(
            value: temporary,
            onChanged: (value) {
              setState(() {
                temporary = (value == true);
              });
            },
          ),
          const Text('临时'),
        ]),
        Row(children: [
          Checkbox(
            value: omitFromOutput,
            onChanged: (value) {
              setState(() {
                omitFromOutput = (value == true);
              });
            },
          ),
          const Text('不出现在输出'),
        ]),
        Row(children: [
          Checkbox(
            value: omitFromLog,
            onChanged: (value) {
              setState(() {
                omitFromLog = (value == true);
              });
            },
          ),
          const Text('不出现在日志'),
        ]),
        ConfirmOrCancelWidget(onConfirm: () {
          final timer = widget.timer.clone();
          timer.hour = int.tryParse(hour.text) ?? 0;
          timer.minute = int.tryParse(minute.text) ?? 0;
          timer.second = num.tryParse(second.text) ?? 0;
          timer.name = name.text;
          timer.sendTo = sendTo;
          timer.variable = variable.text;
          timer.send = send.text;
          timer.script = script.text;
          timer.group = group.text;
          timer.atTime = atTime;
          timer.enabled = enabled;
          timer.oneShot = oneShot;
          timer.actionWhenDisconnectd = actionWhenDisconnectd;
          timer.temporary = temporary;
          timer.omitFromLog = omitFromLog;
          timer.omitFromOutput = omitFromOutput;
          widget.onSubmit(timer);
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
