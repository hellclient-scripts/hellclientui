import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // TRY THIS: Try changing the color here to a specific color (to
            // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
            // change color while the other colors stay the same.
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: const Text("设置")),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.display_settings),
              title: const Text('显示设置'),
              subtitle: const Text('进行颜色等显示设置'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(context, "/displaysettings");
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('通知设置'),
              subtitle: const Text('进行游戏的通知设置'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(context, "/notification");
              },
            ),
            ListTile(
              leading: const Icon(Icons.construction),
              title: const Text('指令设置'),
              subtitle: const Text('管理能快速发送到服务器的指令'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.question_answer_outlined),
              title: const Text('常见问题'),
              subtitle: const Text('一些关于本程序使用的常见问题和解释'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(context, "/qa");
              },
            )
          ],
        ));
  }
}
