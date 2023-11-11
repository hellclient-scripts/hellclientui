import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../../models/server.dart';

class ServerList extends StatelessWidget {
  const ServerList({super.key, required this.servers});
  final List<Server> servers;
  Widget buildList(AppState appState) {
    final List<Widget> list = [];
    for (final server in appState.config.servers) {
      list.add(Card(
        child: ListTile(
          leading: IconButton(
            icon: Icon(Icons.cast_connected_outlined),
            onPressed: () => {},
          ),
          title: Text("服务器地址 " + server.host),
          subtitle: Text(
            "用户名 :" +
                (server.username.isEmpty ? '无' : server.username) +
                " 密码 :" +
                (server.password.isEmpty ? '无' : '******'),
            textAlign: TextAlign.left,
          ),
          isThreeLine: true,
          trailing: Icon(Icons.more_vert),
        ),
      ));
    }
    return ListView(children: list);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    Widget body;
    if (servers.isEmpty) {
      body = const Center(child: Text("还未添加服务器信息。"));
    } else {
      body = buildList(appState);
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
        ),
        body: body);
  }
}
