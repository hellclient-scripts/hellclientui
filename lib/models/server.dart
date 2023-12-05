import 'longconnection.dart';

class Server {
  Server();
  String host = "";
  String name = "";
  String username = "";
  String password = "";
  bool keepConnection = false;
  bool acceptBatchCommand = false;
  final LongConnection _longConnection = LongConnection();
  void start() {
    _longConnection.start();
  }

  void dispose() {
    _longConnection.dispose();
  }

  void onUpdate() {
    _longConnection.update(keepConnection, host, username, password);
  }

  void sendBatchCommand(String cmd) {
    _longConnection.sendBatchCommand(cmd);
  }

  Server.fromJson(Map<String, dynamic> json)
      : host = json['host'],
        username = json['username'],
        password = json['password'],
        name = json['name'],
        keepConnection = (json['keepConnection'] == true),
        acceptBatchCommand = (json['acceptBatchCommand'] == true);
  Map<String, dynamic> toJson() => {
        'host': host,
        'username': username,
        'password': password,
        "name": name,
        "keepConnection": keepConnection,
        "acceptBatchCommand": acceptBatchCommand,
      };
}
