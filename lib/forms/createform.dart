import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../models/server.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({super.key});

  @override
  State<CreateForm> createState() => CreateFormState();
}

class CreateFormState extends State<CreateForm> {
  final host = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool keepConnection = false;
  bool acceptBatchCommand = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    host.dispose();
    username.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  void submit() {}
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();

    return Form(
        key: _formKey,
        child: Padding(
            padding: const EdgeInsets.all(29),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("服务器名"),
                    hintText: "服务器名，选填",
                  ),
                  controller: name,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("服务器地址"),
                    hintText: "请输入http/https开头带端口的网址。比如http://127.0.0.1:4355",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '服务器不可为空';
                    }
                    if (!value.startsWith("http://") &&
                        !value.startsWith("https://")) {
                      return '服务器地址必须以http://或https://开头';
                    }
                    if (value.endsWith("/")) {
                      return '服务器地址不应该以/结尾';
                    }
                    if (appState.config.hasServer(value)) {
                      return '服务器已存在';
                    }
                    return null;
                  },
                  controller: host,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("用户名"),
                    hintText: "输入用户名，未加密请留空",
                  ),
                  controller: username,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    label: Text("密码"),
                    hintText: "输入密码，未加密请留空",
                  ),
                  controller: password,
                ),
                Row(children: [
                  Checkbox(
                    value: keepConnection,
                    onChanged: (value) {
                      setState(() {
                        keepConnection = (value == true);
                      });
                    },
                  ),
                  const Text('保持长连接，手机端使用会耗费更多电量和流量。'),
                ]),
                Row(children: [
                  Checkbox(
                    value: acceptBatchCommand,
                    onChanged: (value) {
                      setState(() {
                        acceptBatchCommand = (value == true);
                      });
                    },
                  ),
                  const Text('接受执行批量命令'),
                ]),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      child: const Text("提交"),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          var server = Server();
                          server.host = host.value.text;
                          server.username = username.value.text;
                          server.password = password.value.text;
                          server.name = name.value.text;
                          server.keepConnection = keepConnection;
                          server.acceptBatchCommand = acceptBatchCommand;
                          server.onUpdate();
                          server.start();
                          Navigator.pop(context, appState.addServer(server));
                        }
                      },
                    ))
              ],
            )));
  }
}
