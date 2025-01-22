import "../models/notificationconfig.dart";
import 'dart:io';
import 'package:local_notifier/local_notifier.dart';
import '../models/message.dart' as message;
import 'package:window_manager/window_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import "../workers/game.dart";
import 'package:app_links/app_links.dart';

Notification currentNotification = Notification();
const tpushPrefix = '/notify/';
final appLinks = AppLinks();

class Notification {
  bool desktopNotificationDisabled = false;
  late NotificationConfig config;

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
      appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          if (uri.path.startsWith(tpushPrefix)) {
            final server = uri.path.replaceFirst(tpushPrefix, '');
            onTPushNofity(server, uri.fragment);
          }
        }
      });
    }
  }
}
