import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'appui.dart';
import 'userinput.dart';
import '../../forms/creategameform.dart' as creategameform;

Future<bool?> showCreateGame(BuildContext context) async {
  return showDialog<bool>(
    context: context,
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
  @override
  Widget build(BuildContext context) {
    filter ??= const TextEditingValue();
    final controller = TextEditingController.fromValue(filter);
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
    for (final game in widget.games) {
      if (filter!.text.isEmpty || game.id.contains(filter!.text)) {
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
    }
    return FullScreenDialog(
        title: "打开游戏",
        summary: '请选择你要打开的游戏。',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            AppUI.buildIconButton(context, const Icon(Icons.add), () async {
              await showCreateGame(context);
            }, "新建游戏", Colors.white, const Color(0xff409EFF)),
            Expanded(
                child: Padding(
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
                        }))),
          ]),
          Table(
            columnWidths: const {2: FixedColumnWidth(80)},
            children: children,
          )
        ]));
  }
}
