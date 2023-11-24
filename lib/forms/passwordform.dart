import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hellclientui/views/pages/nav.dart';
import 'package:hellclientui/workers/game.dart';
import '../views/widgets/appui.dart';
import '../models/message.dart';
import 'dart:async';

class PasswordForm extends StatefulWidget {
  const PasswordForm({super.key});
  @override
  State<StatefulWidget> createState() => PasswordFormState();
}

class PasswordFormState extends State<PasswordForm> {
  TextEditingController? username;
  TextEditingController? password;
  TextEditingController? repeatpassword;
  CreateFail? fail;
  late StreamSubscription sub;
  @override
  void initState() {
    username ??= TextEditingController();
    password ??= TextEditingController();
    repeatpassword ??= TextEditingController();
    sub = currentGame!.createFailStream.stream.listen((event) {
      final newfail = CreateFail.fromJson(jsonDecode(event));
      final oldusername = username;
      final oldpassword = password;
      final oldrepeatpassword = repeatpassword;
      setState(() {
        username = oldusername;
        password = oldpassword;
        repeatpassword = oldrepeatpassword;
        fail = newfail;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CreateFailMessage(fail: fail),
        TextFormField(
          controller: username,
          decoration: const InputDecoration(
            label: Text("用户名"),
          ),
        ),
        TextFormField(
          obscureText: true,
          controller: password,
          decoration: const InputDecoration(
            label: Text("密码"),
          ),
        ),
        TextFormField(
          obscureText: true,
          controller: repeatpassword,
          decoration: const InputDecoration(
            label: Text("重复密码"),
          ),
        ),
        ConfirmOrCancelWidget(onConfirm: () {
          currentGame!.handleCmd(
              'updatepassword',
              UpdatePasswordForm(
                  username: username!.text,
                  password: password!.text,
                  repeatPassword: repeatpassword!.text));
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
