import "package:hellclientui/models/batchcommand.dart";

import "server.dart";
import "notificationconfig.dart";

class Config {
  Config();
  List<Server> servers = [];
  List<BatchCommand> batchCommands = [];
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
    if (json['batchCommands'] != null) {
      batchCommands = List<dynamic>.from(json['batchCommands'])
          .map((e) => BatchCommand.fromJson(e))
          .toList();
    }
  }
  Map<String, dynamic> toJson() => {
        'servers': servers,
        'notificationConfig': notificationConfig.toJson(),
        'batchCommands': batchCommands.map((e) => e.toJson()).toList(),
      };
}
