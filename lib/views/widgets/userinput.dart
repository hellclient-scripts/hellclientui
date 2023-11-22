import 'package:flutter/material.dart';
import 'package:path/path.dart';
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
        final List<TableRow> children = [];
        for (final row in data.items) {
          children.add(createTableRow([
            TCell(
              AppUI.buildTextButton(context, "选择", () {
                currentGame!.handleUserInputCallback(input, 0, row.key);
                Navigator.pop(context, true);
              }, null, Colors.white, const Color(0xff67C23A),
                  radiusLeft: true, radiusRight: true),
            ),
            TCell(Text(row.value))
          ]));
        }
        return DialogOverray(
            child: FullScreenDialog(
                title: data.title,
                summary: data.intro,
                child: Table(
                  columnWidths: const {0: FixedColumnWidth(100)},
                  children: children,
                )));
      },
    );
  }
}
