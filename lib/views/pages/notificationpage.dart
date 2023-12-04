import 'package:flutter/material.dart';
import 'package:hellclientui/views/widgets/appui.dart';
import 'dart:io';
import '../../workers/notification.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});
  Widget buildTpush(BuildContext context) {
    return const Center();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    if (Platform.isAndroid) {
      children.add(buildTpush(context));
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      children.add(ListTile(
        leading: const Icon(Icons.desktop_windows_sharp),
        title: Text("桌面版通知"),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'update',
              child: Text('编辑'),
            ),
            const PopupMenuItem(
              value: 'test',
              child: Text('测试'),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'update':
                // Navigator.pushNamed(context, '/update', arguments: server);
                break;
              case 'test':
                currentNotification.desktopNotify('桌面推送测试', '点击测试', () {
                  AppUI.showMsgBox(context, '测试成功', '检测到点击事件', null);
                });
                break;
            }
          },
        ),
      ));
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("通知设置"),
        ),
        body: ListView(
          children: children,
        ));
  }
}
