import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';
import "../models/notificationconfig.dart";
import 'dart:io';
import 'package:local_notifier/local_notifier.dart';

Notification currentNotification = Notification();

class Notification {
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

  void destopNotify(String title, String body, Function() onOpen) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      LocalNotification notification = LocalNotification(
          title: title,
          body: body,
          actions: [LocalNotificationAction(text: '打开')]);
      notification.onClickAction = (value) {
        onOpen();
      };
      notification.show();
    }
  }

  void updateConfig(NotificationConfig nconfig) {
    config = nconfig;
    if (Platform.isAndroid) {
      startTpush();
    }
  }
}
