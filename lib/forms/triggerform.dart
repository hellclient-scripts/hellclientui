import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hellclientui/workers/game.dart';
import '../views/widgets/appui.dart';
import '../models/message.dart' as message;
import 'dart:async';

class TriggerForm extends StatefulWidget {
  const TriggerForm({super.key, required this.trigger, required this.onSubmit});
  final message.Trigger trigger;
  final void Function(message.Trigger) onSubmit;
  @override
  State<StatefulWidget> createState() => TriggerFormState();
}

class TriggerFormState extends State<TriggerForm> {
  final match = TextEditingController();
  final name = TextEditingController();
  int sendTo = 0;
  final send = TextEditingController();
  final sequence = TextEditingController();
  final script = TextEditingController();
  final group = TextEditingController();
  final variable = TextEditingController();

  bool ignoreCase = false;
  bool enabled = false;
  bool regexp = false;
  bool keepEvaluating = false;
  bool repeat = false;
  bool expandVariables = false;
  bool oneShot = false;
  bool temporary = false;
  bool multiLine = false;
  final linesToMatch = TextEditingController();
  bool wildcardLowerCase = false;
  bool omitFromOutput = false;
  bool omitFromLog = false;
  message.CreateFail? fail;
  late StreamSubscription sub;
  @override
  void initState() {
    match.text = widget.trigger.match;
    name.text = widget.trigger.name;
    sendTo = widget.trigger.sendTo;
    send.text = widget.trigger.send;
    sequence.text = widget.trigger.sequence.toString();
    script.text = widget.trigger.script;
    group.text = widget.trigger.group;
    ignoreCase = widget.trigger.ignoreCase;
    enabled = widget.trigger.enabled;
    regexp = widget.trigger.regexp;
    keepEvaluating = widget.trigger.keepEvaluating;
    repeat = widget.trigger.repeat;
    expandVariables = widget.trigger.expandVariables;
    oneShot = widget.trigger.oneShot;
    temporary = widget.trigger.temporary;
    multiLine = widget.trigger.multiLine;
    linesToMatch.text = widget.trigger.linesToMatch.toString();
    wildcardLowerCase = widget.trigger.wildcardLowerCase;
    omitFromOutput = widget.trigger.omitFromOutput;
    omitFromLog = widget.trigger.omitFromLog;
    variable.text = widget.trigger.variable;
    sequence.text = '100';
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
        TextFormField(
          controller: match,
          decoration: const InputDecoration(
            label: Text("匹配"),
          ),
        ),
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
          controller: sequence,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ], // Only numbers can be entered
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            label: Text("优先级"),
          ),
        ),
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
        !multiLine
            ? const Center()
            : TextFormField(
                controller: linesToMatch,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  label: Text("匹配行数(0-100)"),
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
            value: ignoreCase,
            onChanged: (value) {
              setState(() {
                ignoreCase = (value == true);
              });
            },
          ),
          const Text('不区分大小写'),
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
            value: keepEvaluating,
            onChanged: (value) {
              setState(() {
                keepEvaluating = (value == true);
              });
            },
          ),
          const Text('继续执行'),
        ]),
        Row(children: [
          Checkbox(
            value: repeat,
            onChanged: (value) {
              setState(() {
                repeat = (value == true);
              });
            },
          ),
          const Text('重复触发'),
        ]),
        Row(children: [
          Checkbox(
            value: expandVariables,
            onChanged: (value) {
              setState(() {
                expandVariables = (value == true);
              });
            },
          ),
          const Text('展开变量'),
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
            value: multiLine,
            onChanged: (value) {
              setState(() {
                multiLine = (value == true);
              });
            },
          ),
          const Text('多行匹配'),
        ]),
        Row(children: [
          Checkbox(
            value: wildcardLowerCase,
            onChanged: (value) {
              setState(() {
                wildcardLowerCase = (value == true);
              });
            },
          ),
          const Text('匹配内容转小写'),
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
          final trigger = widget.trigger.clone();
          trigger.match = match.text;
          trigger.name = name.text;
          trigger.send = send.text;
          trigger.sequence = int.tryParse(sequence.text) ?? 0;
          trigger.script = script.text;
          trigger.group = group.text;
          trigger.linesToMatch = int.tryParse(linesToMatch.text) ?? 0;
          trigger.ignoreCase = ignoreCase;
          trigger.regexp = regexp;
          trigger.keepEvaluating = keepEvaluating;
          trigger.repeat = repeat;
          trigger.expandVariables = expandVariables;
          trigger.oneShot = oneShot;
          trigger.temporary = temporary;
          trigger.multiLine = multiLine;
          trigger.wildcardLowerCase = wildcardLowerCase;
          trigger.variable = variable.text;
          widget.onSubmit(trigger);
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
