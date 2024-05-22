import 'package:flutter/material.dart';
import 'package:hellclientui/models/batchcommand.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../../models/server.dart';
import '../../workers/game.dart';
import '../widgets/appui.dart';
import '../widgets/choosebatchcommand.dart';
import 'package:flutter/services.dart';

class ServerList extends StatefulWidget {
  const ServerList({super.key, required this.servers});
  final List<Server> servers;
  @override
  State<ServerList> createState() {
    return ServerListState();
  }
}

Future<bool?> showConnectError(BuildContext context, String message) async {
  return showDialog<bool>(
    context: currentAppState.navigatorKey.currentState!.context,
    builder: (context) {
      return AlertDialog(
        title: const Text("连接失败"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("离开"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

void connectServer(Server server, BuildContext context) async {
  try {
    // await appState.connecting.connect(ser
    // ver);
    var dpr = currentAppState.renderSettings.hidpi
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;
    if (currentAppState.renderSettings.roundDpi) {
      dpr = dpr.roundToDouble();
    }
    currentAppState.devicePixelRatio = dpr;
    currentGame = Game.create(server);

    if (context.mounted) {
      await Navigator.pushNamed(context, "/game", arguments: currentGame);
    }
  } catch (e) {
    showConnectError(context, e.toString());
  }
}

Future<bool?> showDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: currentAppState.navigatorKey.currentState!.context,
    builder: (context) {
      return AlertDialog(
        title: const Text("确认"),
        content: const Text("您确定要删除当前服务器吗?"),
        actions: <Widget>[
          TextButton(
            child: const Text("取消"),
            onPressed: () => Navigator.of(context).pop(), // 关闭对话框
          ),
          TextButton(
            child: const Text("删除"),
            onPressed: () {
              //关闭对话框并返回true
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

class ServerListState extends State<ServerList> {
  Widget buildList(BuildContext context) {
    var appState = context.watch<AppState>();

    final List<Widget> list = [];
    for (var index = 0; index < appState.config.servers.length; index++) {
      final server = appState.config.servers[index];
      var servername = server.name.isNotEmpty ? server.name : "<未命名>";
      if (index < 9) {
        servername = '${index + 1}.$servername';
      }
      var titlespan = <InlineSpan>[
        TextSpan(text: servername),
        const WidgetSpan(
            child: SizedBox(
          width: 10,
        ))
      ];
      if (server.acceptBatchCommand) {
        titlespan.add(const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.construction,
              size: 16,
              color: Color(0xff67C23A),
            )));
      }
      if (server.keepConnection) {
        titlespan.add(const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.mail,
              size: 16,
              color: Color(0xff67C23A),
            )));
      }
      list.add(Card(
        key: Key(server.host),
        child: ListTile(
          leading: Tooltip(
              message: "连接服务器",
              child: IconButton(
                icon: const Icon(Icons.cast_connected_outlined),
                onPressed: () async {
                  connectServer(server, context);
                },
              )),
          title: Text.rich(TextSpan(children: titlespan)),
          subtitle: Text(
            server.host,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'batchcommand',
                child: Text('发送批量指令'),
              ),
              const PopupMenuItem(
                child: PopupMenuDivider(),
              ),
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
                case 'batchcommand':
                  final result = await showDialog<BatchCommand?>(
                    context: currentAppState.navigatorKey.currentState!.context,
                    builder: (context) {
                      return const NonFullScreenDialog(
                          title: '选择发送的批量指令',
                          summary: '批量指令在设置中进行维护',
                          child: ChooseBatchCommand());
                    },
                  );
                  if (result != null) {
                    server.sendBatchCommand(result);
                  }
                  break;
                case 'update':
                  Navigator.pushNamed(context, '/update', arguments: server);
                  break;
                case 'remove':
                  if (await showDeleteConfirmDialog(context) == true) {
                    appState.removeServer(server);
                  }
                  break;
              }
            },
          ),
        ),
      ));
    }
    return ReorderableListView(
        children: list,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = appState.config.servers.removeAt(oldIndex);
          appState.config.servers.insert(newIndex, item);
          appState.save();
          appState.updated();
        });
  }

  KeyEventResult onKey(KeyEvent key, BuildContext context) {
    switch (key.logicalKey.keyLabel) {
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        final index = int.parse(key.logicalKey.keyLabel) - 1;
        if (index < currentAppState.config.servers.length) {
          connectServer(currentAppState.config.servers[index], context);
        }
        break;
      case 'B':
        if (HardwareKeyboard.instance.isControlPressed) {
          showBatchCommand();
        }
        break;
    }
    return KeyEventResult.ignored;
  }

  final listnode = FocusNode();
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    listnode.dispose();
    super.dispose();
  }

  void showBatchCommand() async {
    final result = await showDialog<BatchCommand?>(
      context: currentAppState.navigatorKey.currentState!.context,
      builder: (context) {
        return const NonFullScreenDialog(
            title: '选择发送的批量指令',
            summary: '批量指令在设置中进行维护',
            child: ChooseBatchCommand());
      },
    );
    if (result != null) {
      currentAppState.sendBatchCommand(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (widget.servers.isEmpty) {
      body = const Center(child: Text("还未添加服务器信息。"));
    } else {
      body = buildList(context);
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, "/create");
          },
          tooltip: '添加新服务器',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("服务器列表"),
          actions: [
            IconButton(
              onPressed: showBatchCommand,
              icon: const Icon(Icons.construction),
              tooltip: '向所有服务器发送批量指令\n快捷键:Ctrl + b',
            )
          ],
        ),
        body: KeyboardListener(
            focusNode: listnode,
            autofocus: true,
            onKeyEvent: (value) {
              if (value is KeyDownEvent) {
                onKey(value, context);
              }
            },
            child: body));
  }
}
