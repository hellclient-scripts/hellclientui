import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';
import "../models/notificationconfig.dart";
import 'dart:io';
import 'package:local_notifier/local_notifier.dart';
import '../models/message.dart' as message;
import 'package:window_manager/window_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import "../workers/game.dart";

Notification currentNotification = Notification();

class Notification {
  bool desktopNotificationDisabled = false;
  String tencentToken = "";
  late NotificationConfig config;
  XgFlutterPlugin? tpush;
  void startTpush() {
    if (config.tencentAccessID == "" ||
        config.tencentAccessKey == "" ||
        config.tencentEnabled == false) {
      return;
    }
    tpush = XgFlutterPlugin();
    tpush!.addEventHandler(
      onRegisteredDeviceToken: (String msg) async {
        tencentToken = msg;
      },

      /// TPNS注册成功会走此回调
      onRegisteredDone: (String msg) async {
        tencentToken = msg;
      },
    );
    tpush!.configureClusterDomainName("tpns.sh.tencent.com");
    tpush!.startXg(config.tencentAccessID, config.tencentAccessKey);
  }

  void desktopNotify(String title, String body, Function() onOpen) {
    if (config.audio.isNotEmpty) {
      final player = AudioPlayer();
      player.play(DeviceFileSource(config.audio));
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      LocalNotification notification = LocalNotification(
          title: title,
          body: body,
          actions: [LocalNotificationAction(text: '打开')]);
      notification.onClickAction = (value) async {
        await WindowManager.instance.show();
        await WindowManager.instance.focus();
        onOpen();
      };
      notification.onClick = () async {
        await WindowManager.instance.show();
        await WindowManager.instance.focus();
        onOpen();
      };
      notification.show();
    }
  }

  void ondesktopNotify(
      String host, String id, message.DesktopNotification msg) {
    desktopNotify(msg.title, msg.body, () {
      Game.enterGame(host, id);
    });
  }

  void updateConfig(NotificationConfig nconfig) {
    config = nconfig;
    if (Platform.isAndroid) {
      startTpush();
    }
  }
}
