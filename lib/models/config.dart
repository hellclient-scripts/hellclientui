import "package:hellclientui/models/batchcommand.dart";

import "server.dart";
import "notificationconfig.dart";
import "macros.dart";

class Config {
  Config();
  List<Server> servers = [];
  List<BatchCommand> batchCommands = [];
  Macros macros = Macros();
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
    if (json['macros'] != null) {
      macros = Macros.fromJson(json['macros']);
    }
  }
  Map<String, dynamic> toJson() => {
        'servers': servers,
        'notificationConfig': notificationConfig.toJson(),
        'batchCommands': batchCommands.map((e) => e.toJson()).toList(),
        'macros': macros.toJson(),
      };
}
