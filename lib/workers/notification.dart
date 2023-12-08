import 'package:flutter/material.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';
import "../models/notificationconfig.dart";
import 'dart:io';
import 'package:local_notifier/local_notifier.dart';
import '../models/message.dart' as message;
import 'package:window_manager/window_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import "../workers/game.dart";
import "dart:async";
import 'package:uni_links/uni_links.dart';

Notification currentNotification = Notification();
const tpushPrefix = '/notify/';

class Notification {
  bool desktopNotificationDisabled = false;
  String tencentToken = "";
  late NotificationConfig config;
  XgFlutterPlugin? tpush;
  StreamSubscription? _sub;
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

  void onTPushNofity(String host, String id) {
    Game.enterGame(host, id);
  }

  void updateConfig(NotificationConfig nconfig) async {
    config = nconfig;
    if (Platform.isAndroid) {
      if (tpush != null) {
        tpush!.stopXg();
      }
      if (_sub != null) {
        await _sub!.cancel();
      }
      startTpush();
      _sub = uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          debugPrint(uri.path);
          if (uri.path.startsWith(tpushPrefix)) {
            final server = uri.path.replaceFirst(tpushPrefix, '');
            onTPushNofity(server, uri.fragment);
          }
        }
      });
    }
  }
}
