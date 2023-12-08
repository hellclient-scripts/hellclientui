import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/views/widgets/appui.dart';
import '../workers/notification.dart';

class TPushForm extends StatefulWidget {
  const TPushForm({super.key});
  @override
  State<TPushForm> createState() {
    return TPushFromState();
  }
}

class TPushFromState extends State<TPushForm> {
  late bool enabled;
  final accessID = TextEditingController();
  final accessKey = TextEditingController();
  @override
  void initState() {
    super.initState();
    enabled = currentAppState.config.notificationConfig.tencentEnabled;
    accessID.text = currentAppState.config.notificationConfig.tencentAccessID;
    accessKey.text = currentAppState.config.notificationConfig.tencentAccessKey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        const Text('手机通知：'),
        Checkbox(
          value: enabled,
          onChanged: (value) {
            setState(() {
              enabled = (value == true);
            });
          },
        ),
        const Text('启用'),
      ]),
      TextFormField(
        controller: accessID,
        decoration: const InputDecoration(
          label: Text("AccessID"),
        ),
      ),
      TextFormField(
        controller: accessKey,
        decoration: const InputDecoration(
          label: Text("AccessKey"),
        ),
      ),
      ConfirmOrCancelWidget(onConfirm: () {
        currentAppState.config.notificationConfig.tencentEnabled = enabled;
        currentAppState.config.notificationConfig.tencentAccessID =
            accessID.text;
        currentAppState.config.notificationConfig.tencentAccessKey =
            accessKey.text;
        currentAppState.save();
        currentNotification
            .updateConfig(currentAppState.config.notificationConfig);

        if (currentAppState.navigatorKey.currentState != null) {
          Navigator.of(currentAppState.navigatorKey.currentState!.context)
              .pop();
        }
      }, onCancal: () {
        if (currentAppState.navigatorKey.currentState != null) {
          Navigator.of(currentAppState.navigatorKey.currentState!.context)
              .pop();
        }
      })
    ]);
  }
}
