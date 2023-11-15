import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../models/server.dart';

class UpdateForm extends StatefulWidget {
  const UpdateForm({super.key});

  @override
  State<UpdateForm> createState() => UpdateFormState();
}

class UpdateFormState extends State<UpdateForm> {
  late Server origin;
  final host = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    host.dispose();
    username.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    origin = ModalRoute.of(context)!.settings.arguments as Server;
    name.text = origin.name;
    host.text = origin.host;
    username.text = origin.username;
    password.text = origin.password;
    print(origin);
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
                    if (value != origin.host &&
                        appState.config.hasServer(value)) {
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
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      child: const Text("提交"),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          origin.host = host.value.text;
                          origin.username = username.value.text;
                          origin.password = password.value.text;
                          origin.name = name.value.text;
                          appState.updated();
                          appState.save();
                          Navigator.pop(context, true);
                        }
                      },
                    ))
              ],
            )));
  }
}
