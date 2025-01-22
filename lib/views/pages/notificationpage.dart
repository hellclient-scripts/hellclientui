import 'package:flutter/material.dart';
import 'package:hellclientui/views/widgets/appui.dart';
import 'dart:io';
import '../../workers/notification.dart';
import 'desktopnotificationpage.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() {
    return NotificationPageState();
  }
}

class NotificationPageState extends State<NotificationPage> {
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
        title: const Text("桌面版通知"),
        subtitle: Text.rich(TextSpan(children: [
          const TextSpan(text: '启用通知：'),
          TextSpan(
              text: currentNotification.config.desktopNotificationDisabled
                  ? '否'
                  : '是'),
          const WidgetSpan(
              child: SizedBox(
            width: 30,
          )),
          const TextSpan(text: '播放提示音：'),
          TextSpan(text: currentNotification.config.audio.isEmpty ? '否' : '是'),
        ])),
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
                final result = await Navigator.push(context,
                    MaterialPageRoute<bool>(builder: (context) {
                  return const DesktopNotificationPage();
                }));
                if (result == true) {
                  setState(() {});
                }
                break;
              case 'test':
                currentNotification.desktopNotify('桌面推送测试', '点击测试', () {
                  AppUI.showAppMsgBox(context, '测试成功', '检测到点击事件', null);
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
