import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'appui.dart';

class NotOpened extends StatelessWidget {
  const NotOpened({super.key, required this.games});
  final List<NotOpenedGame> games;
  @override
  Widget build(BuildContext context) {
    final List<TableRow> children = [
      createTableRow([
        const TableHead(
          '名称',
          textAlign: TextAlign.start,
        ),
        const TableHead('最后更新', textAlign: TextAlign.start),
        const TableHead('操作', textAlign: TextAlign.end),
      ])
    ];
    for (final game in games) {
      children.add(createTableRow([
        TCell(Text(game.id)),
        TCell(Text(game.lastUpdated)),
        TCell(
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(game.id);
              },
              child: const Text(
                '打开',
              )),
        )
      ]));
    }
    return FullScreenDialog(
        title: "打开游戏",
        summary: '请选择你要打开的游戏。',
        child: Table(
          columnWidths: const {2: FixedColumnWidth(80)},
          children: children,
        ));
  }
}
