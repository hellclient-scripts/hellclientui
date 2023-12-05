import 'package:flutter/material.dart';
import 'package:hellclientui/models/batchcommand.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/views/pages/createpresetbatchcommand.dart';
import 'package:hellclientui/views/pages/updatepresetbatchcommand.dart';
import 'package:hellclientui/views/widgets/appui.dart';
import 'package:provider/provider.dart';

class PresetBatchCommands extends StatelessWidget {
  const PresetBatchCommands({super.key});
  Widget buildList(BuildContext context) {
    return ReorderableListView(
        children: currentAppState.config.batchCommands
            .asMap()
            .entries
            .map((entry) => ListTile(
                  leading: const Icon(Icons.construction),
                  key: Key(entry.key.toString()),
                  title: Text(entry.value.name),
                  subtitle: Text.rich(TextSpan(children: [
                    const TextSpan(text: '发送到脚本：'),
                    TextSpan(
                        text: entry.value.scripts
                            .map((e) => e == '' ? '[全部脚本]' : '[$e]')
                            .toList()
                            .join(','))
                  ])),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'update',
                        child: Text('编辑'),
                      ),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('删除'),
                      ),
                    ],
                    onSelected: (value) async {
                      switch (value) {
                        case 'update':
                          final result = await Navigator.push(context,
                              MaterialPageRoute<BatchCommand>(
                                  builder: (context) {
                            return UpdatePresetBatchCommandPage(
                              command: entry.value,
                            );
                          }));
                          if (result != null) {
                            currentAppState.config.batchCommands[entry.key] =
                                result;
                            await currentAppState.save();
                            currentAppState.updated();
                          }

                          break;
                        case 'remove':
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
                                      TextSpan(text: '是否要删除该预设批量指令?'),
                                    ]),
                                  )) ==
                              true) {
                            currentAppState.config.batchCommands
                                .removeAt(entry.key);
                            currentAppState.save();
                            currentAppState.updated();
                          }
                          break;
                      }
                    },
                  ),
                ))
            .toList(),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = currentAppState.config.batchCommands.removeAt(oldIndex);
          currentAppState.config.batchCommands.insert(newIndex, item);
          currentAppState.save();
          currentAppState.updated();
        });
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    Widget body;
    if (currentAppState.config.batchCommands.isEmpty) {
      body = const Center(child: Text("还未添加预设批量指令。"));
    } else {
      body = buildList(context);
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(context,
                MaterialPageRoute<BatchCommand>(builder: (context) {
              return const CreatePresetBatchCommandPage();
            }));
            if (result != null) {
              currentAppState.config.batchCommands.add(result);
              await currentAppState.save();
              appState.updated();
            }
          },
          tooltip: '添加预设批量指令',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("预设批量指令"),
        ),
        body: body);
  }
}
