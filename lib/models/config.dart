import "server.dart";

class Config {
  Config();
  List<Server> servers = [];
  Config.fromJson(Map<String, dynamic> json) : servers = json['servers'];
  Map<String, dynamic> toJson() => {
        'servers': servers,
      };
}
