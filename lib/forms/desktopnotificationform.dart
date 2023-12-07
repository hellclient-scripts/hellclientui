import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/views/widgets/appui.dart';
import 'package:hellclientui/workers/notification.dart';
import 'package:file_picker/file_picker.dart';

class DesktopNotificationForm extends StatefulWidget {
  const DesktopNotificationForm({super.key});
  @override
  State<StatefulWidget> createState() {
    return DesktopNotificationFormState();
  }
}

class DesktopNotificationFormState extends State<DesktopNotificationForm> {
  bool enabled = false;
  String audio = '';
  @override
  void initState() {
    super.initState();
    enabled = !currentNotification.config.desktopNotificationDisabled;
    audio = currentNotification.config.audio;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          const Text('桌面通知：'),
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
        Row(
          children: [
            const Text('音频播放：'),
            Text(audio.isEmpty ? '<未启用>' : audio),
            ElevatedButton(
              child: const Text('选择音频'),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                    type: FileType.audio, allowedExtensions: ['.mp3', '.wav']);
                if (result != null) {
                  setState(() {
                    audio = result.files.single.path!;
                  });
                }
              },
            ),
            audio.isEmpty
                ? const Center()
                : IconButton(
                    onPressed: () {
                      setState(() {
                        audio = '';
                      });
                    },
                    tooltip: '取消音频播放',
                    icon: const Icon(Icons.close))
          ],
        ),
        ConfirmOrCancelWidget(onConfirm: () {
          currentAppState.config.notificationConfig.audio = audio;
          currentAppState
              .config.notificationConfig.desktopNotificationDisabled = !enabled;
          currentAppState.save();
          currentNotification
              .updateConfig(currentAppState.config.notificationConfig);
          Navigator.of(context).pop(true);
        }, onCancal: () {
          Navigator.of(context).pop();
        })
      ],
    );
  }
}
