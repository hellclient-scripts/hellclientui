import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../../models/server.dart';
import '../../workers/game.dart';

Future<bool?> showConnectError(BuildContext context, String message) async {
  return showDialog<bool>(
    context: context,
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

Future<bool?> showDeleteConfirmDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
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

class ServerList extends StatelessWidget {
  const ServerList({super.key, required this.servers});
  final List<Server> servers;
  Widget buildList(BuildContext context) {
    var appState = context.watch<AppState>();
    appState.devicePixelRatio = appState.renderSettings.hidpi
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;

    final List<Widget> list = [];
    for (final server in appState.config.servers) {
      list.add(Card(
        key: Key(server.host),
        child: ListTile(
          leading: Tooltip(
              message: "连接服务器",
              child: IconButton(
                icon: Icon(Icons.cast_connected_outlined),
                onPressed: () async {
                  appState.currentServer = server;
                  try {
                    await appState.connecting.connect(server);
                    currentGame = Game.create();

                    if (context.mounted) {
                      Navigator.pushNamed(context, "/game");
                    }
                  } catch (e) {
                    showConnectError(context, e.toString());
                  }
                  // appState.connect(server);
                },
              )),
          title: Text(server.name.isNotEmpty ? server.name : "<未命名>"),
          subtitle: Text(
            server.host,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
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

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (servers.isEmpty) {
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
              icon: const Icon(Icons.settings),
              tooltip: '设置',
              onPressed: () {
                // showAboutDialog(
                //     context: context,
                //     applicationName: "Hellclient UI",
                //     applicationVersion: "0.0.1");
                // return;
              },
            ),
          ],
        ),
        body: body);
  }
}
