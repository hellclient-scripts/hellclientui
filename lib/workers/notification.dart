import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';
import "../models/notificationconfig.dart";
import 'dart:io';

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

  void updateConfig(NotificationConfig nconfig) {
    config = nconfig;
    if (Platform.isAndroid) {
      startTpush();
    }
  }
}
