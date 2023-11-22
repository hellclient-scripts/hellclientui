import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../models/message.dart';
import '../../workers/game.dart';
import 'appui.dart';

class UserInputHelper {
  static popup(BuildContext context, UserInput input) {
    final data = UserInputTitleIntroType.fromJson(input.data);
    ToastificationType? type;
    switch (data.type) {
      case 'success':
        type = ToastificationType.success;
        break;
      case 'error':
        type = ToastificationType.error;
        break;
      case 'info':
        type = ToastificationType.info;
        break;
      case 'warning':
        type = ToastificationType.warning;
        break;
    }
    toastification.show(
        context: context,
        title: data.title,
        type: type,
        autoCloseDuration: const Duration(seconds: 5),
        style: ToastificationStyle.flat,
        description: data.intro,
        showProgressBar: false,
        callbacks: ToastificationCallbacks(
          onTap: (value) {
            currentGame!.handleUserInputCallback(input, -1, "ok");
          },
        ));
  }

  static list(BuildContext context, UserInput input) {
    final data = UserInputList.fromJson(input.data);
    showDialog<bool?>(
      context: context,
      builder: (context) {
        return DialogOverray(
            child: FullScreenDialog(
          title: data.title,
          summary: data.intro,
          child: UserInputListWidget(
            input: input,
            list: data,
          ),
        ));
      },
    );
  }

  static prompt(BuildContext context, UserInput input) async {
    final data = UserInputTitleIntroValue.fromJson(input.data);
    final controller =
        TextEditingController.fromValue(TextEditingValue(text: data.value));
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return NonFullScreenDialog(
          title: data.title,
          summary: data.intro,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xffeeeeee),
              ),
              controller: controller,
            ),
            ConfirmOrCancelWidget(
              onConfirm: () {
                currentGame!.handleUserInputCallback(input, 0, controller.text);
                Navigator.pop(context, true);
              },
              onCancal: () {
                Navigator.pop(context, null);
              },
            )
          ]),
        );
      },
    );
    if (result != true) {
      currentGame!.handleUserInputCallback(input, -1, '');
    }
  }

  static alert(BuildContext context, UserInput input) async {
    final data = UserInputTitleIntro.fromJson(input.data);
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return NonFullScreenDialog(
            title: data.title,
            summary: data.intro,
            child: ConfirmOrCancelWidget(
              labelCancel: null,
              onConfirm: () {
                currentGame!.handleUserInputCallback(input, 0, '');
                Navigator.pop(context, true);
              },
              onCancal: () {},
            ));
      },
    );
    if (result != true) {
      currentGame!.handleUserInputCallback(input, -1, '');
    }
  }

  static confirm(BuildContext context, UserInput input) async {
    final data = UserInputTitleIntro.fromJson(input.data);
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) {
        return NonFullScreenDialog(
            title: data.title,
            summary: data.intro,
            child: ConfirmOrCancelWidget(
              onConfirm: () {
                currentGame!.handleUserInputCallback(input, 0, '');
                Navigator.pop(context, true);
              },
              onCancal: () {
                Navigator.pop(context);
              },
            ));
      },
    );
    if (result != true) {
      currentGame!.handleUserInputCallback(input, -1, '');
    }
  }
}

const textStyleUserInputFilter = TextStyle(
  fontSize: 14,
  height: 1.3,
  color: Color(0xff909399),
);

class UserInputListWidget extends StatefulWidget {
  const UserInputListWidget(
      {super.key, required this.input, required this.list});
  final UserInput input;
  final UserInputList list;
  @override
  State<UserInputListWidget> createState() => UserInputListWidgetState();
}

class UserInputListWidgetState extends State<UserInputListWidget> {
  UserInputListWidgetState();
  TextEditingValue filter = const TextEditingValue();
  Map<String, bool> selected = {};
  @override
  void initState() {
    for (final value in widget.list.values) {
      selected[value] = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textController = TextEditingController.fromValue(filter);
    final data = UserInputList.fromJson(widget.input.data);
    final List<TableRow> children = [];
    if (widget.list.withFilter) {
      children.add(createTableRow([
        const TCell(Center()),
        TCell(TextFormField(
          decoration: const InputDecoration(
              hintText: '请输入需要过滤的关键字', hintStyle: textStyleUserInputFilter),
          controller: textController,
          onChanged: (value) {
            setState(() {
              filter = textController.value;
            });
          },
        ))
      ]));
    }
    for (final row in data.items) {
      if (filter.text.isEmpty || row.key.contains(filter.text)) {
        if (widget.list.mutli) {
          children.add(createTableRow([
            TCell(Checkbox(
              value: selected[row.key] == true,
              onChanged: (value) {
                setState(() {
                  selected[row.key] = (value == true);
                });
              },
            )),
            TCell(Text(row.value))
          ]));
        } else {
          children.add(createTableRow([
            TCell(
              AppUI.buildTextButton(context, "选择", () {
                currentGame!.handleUserInputCallback(widget.input, 0, row.key);
                Navigator.pop(context, true);
              }, null, Colors.white, const Color(0xff67C23A),
                  radiusLeft: true, radiusRight: true),
            ),
            TCell(Text(row.value))
          ]));
        }
      }
    }
    final table = Table(
      columnWidths: const {0: FixedColumnWidth(100)},
      children: children,
    );
    Widget body;
    if (widget.list.withFilter || widget.list.mutli) {
      List<Widget> listchildren = [];

      listchildren.add(table);
      if (widget.list.mutli) {
        listchildren.add(ConfirmOrCancelWidget(
          onConfirm: () {
            final List<String> data = [];
            for (var item in selected.keys) {
              data.add(item);
            }
            currentGame!
                .handleUserInputCallback(widget.input, 0, jsonEncode(data));
            Navigator.pop(context, true);
          },
          onCancal: () {
            Navigator.pop(context, null);
          },
        ));
      }
      body = Column(
        children: listchildren,
      );
    } else {
      body = table;
    }
    return body;
  }
}

class UserInputVisualPromptWidget extends StatefulWidget {
  const UserInputVisualPromptWidget(
      {super.key, required this.input, required this.visualPrompt});
  final UserInput input;
  final VisualPrompt visualPrompt;
  @override
  State<UserInputVisualPromptWidget> createState() =>
      UserInputVisualPromptWidgetState();
}

class UserInputVisualPromptWidgetState
    extends State<UserInputVisualPromptWidget> {
  TextEditingValue value = const TextEditingValue();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
