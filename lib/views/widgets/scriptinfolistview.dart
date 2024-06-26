import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'appui.dart';
import 'userinput.dart';
import '../../forms/createscriptform.dart' as createscriptform;
import '../../workers/game.dart';

Future<bool?> showCreateScript(BuildContext context) async {
  return showDialog<bool>(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return const NonFullScreenDialog(
          title: '创建脚本', child: createscriptform.CreateScriptForm());
    },
  );
}

class ScriptInfoListView extends StatefulWidget {
  const ScriptInfoListView({super.key, required this.list});
  final List<ScriptInfo> list;
  @override
  State<StatefulWidget> createState() => ScriptInfoListViewState();
}

class ScriptInfoListViewState extends State<ScriptInfoListView> {
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
        const TableHead('描述', textAlign: TextAlign.start),
        const TableHead('介绍', textAlign: TextAlign.start),
        const TableHead('操作', textAlign: TextAlign.end),
      ])
    ];
    for (final info in widget.list) {
      if (filter!.text.isEmpty ||
          info.id.contains(filter!.text) ||
          info.desc.contains(filter!.text) ||
          info.intro.contains(filter!.text)) {
        children.add(createTableRow([
          TCell(TextButton(
              onPressed: () {
                Navigator.of(context).pop(info.id);
              },
              child: Text(info.id))),
          TCell(Text(info.desc)),
          TCell(Text(info.intro)),
          TCell(
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(info.id);
                },
                child: const Text(
                  '选择',
                )),
          )
        ]));
      }
    }
    return Stack(children: [
      FullScreenDialog(
          title: "选择脚本",
          summary: '请选择你要使用的脚本',
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
              columnWidths: const {
                0: FixedColumnWidth(180),
                3: FixedColumnWidth(80)
              },
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
              await showCreateScript(context);
            },
            tooltip: '新建脚本',
            child: const Icon(Icons.add),
          ))
    ]);
  }
}
