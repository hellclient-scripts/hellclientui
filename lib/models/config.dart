import "server.dart";

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

  Config.fromJson(Map<String, dynamic> json) {
    servers = List<dynamic>.from(json['servers'])
        .map((e) => Server.fromJson(e))
        .toList();
  }
  Map<String, dynamic> toJson() => {
        'servers': servers,
      };
}
