import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'appui.dart';
import 'userinput.dart';
import '../../models/feature.dart';
import '../../forms/creategameform.dart' as creategameform;
import '../../workers/game.dart';

const int renderModeNormal = 0;
const int renderModeWithName = 1;
Future<bool?> showCreateGame(BuildContext context) async {
  return showDialog<bool>(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return const NonFullScreenDialog(
          title: '创建游戏', child: creategameform.CreateGameForm());
    },
  );
}

class NotOpened extends StatefulWidget {
  const NotOpened({super.key, required this.games});
  final List<NotOpenedGame> games;
  @override
  State<StatefulWidget> createState() => NotOpenedState();
}

class NotOpenedState extends State<NotOpened> {
  TextEditingValue? filter;
  List<TableHead> renderHead(int mode) {
    switch (mode) {
      case 1:
        return const [
          TableHead(
            'ID',
            textAlign: TextAlign.start,
          ),
          TableHead(
            '名称',
            textAlign: TextAlign.start,
          ),
          TableHead('最后更新', textAlign: TextAlign.start),
          TableHead('操作', textAlign: TextAlign.end),
        ];
    }
    return const [
      TableHead(
        '名称',
        textAlign: TextAlign.start,
      ),
      TableHead('最后更新', textAlign: TextAlign.start),
      TableHead('操作', textAlign: TextAlign.end),
    ];
  }

  List<Widget> renderItem(NotOpenedGame game, int mode) {
    switch (mode) {
      case renderModeWithName:
        return [
          TCell(TextButton(
              onPressed: () {
                Navigator.of(context).pop(game.id);
              },
              child: Text(game.id))),
          TCell(TextButton(
              onPressed: () {
                Navigator.of(context).pop(game.name);
              },
              child: Text(game.name))),
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
        ];
    }
    return [
      TCell(TextButton(
          onPressed: () {
            Navigator.of(context).pop(game.id);
          },
          child: Text(game.id))),
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    filter ??= const TextEditingValue();
    final controller = TextEditingController.fromValue(filter);
    int renderMode = 0;
    if (currentGame!.support(Features.notOpenedName)) {
      renderMode = 1;
    }
    var headlist = renderHead(renderMode);
    final List<TableRow> children = [createTableRow(headlist)];
    for (final game in widget.games) {
      if (filter!.text.isEmpty ||
          game.id.contains(filter!.text) ||
          game.name.contains(filter!.text)) {
        children.add(createTableRow(renderItem(game, renderMode)));
      }
    }
    return Stack(children: [
      FullScreenDialog(
          title: "打开游戏",
          summary: '请选择你要打开的游戏。',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                    decoration: const InputDecoration(
                        hintText: '请输入需要过滤的关键字',
                        hintStyle: textStyleUserInputFilter),
                    controller: controller,
                    onChanged: (value) {
                      setState(() {
                        filter = controller.value;
                      });
                    })),
            Table(
              columnWidths: {headlist.length - 1: const FixedColumnWidth(80)},
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
              await showCreateGame(context);
            },
            tooltip: '新建游戏',
            child: const Icon(Icons.add),
          ))
    ]);
  }
}
