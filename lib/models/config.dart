import "server.dart";
import "notificationconfig.dart";

class Config {
  Config();
  List<Server> servers = [];
  bool hasServer(String host) {
    for (final server in servers) {
      if (server.host == host) {
        return true;
      }
    }
    return false;
  }

  NotificationConfig notificationConfig = NotificationConfig();
  Config.fromJson(Map<String, dynamic> json) {
    servers = List<dynamic>.from(json['servers'])
        .map((e) => Server.fromJson(e))
        .toList();
    if (json['notificationConfig'] != null) {
      notificationConfig =
          NotificationConfig.fromJson(json['notificationConfig']);
    }
  }
  Map<String, dynamic> toJson() => {
        'servers': servers,
        'notificationConfig': notificationConfig,
      };
}
