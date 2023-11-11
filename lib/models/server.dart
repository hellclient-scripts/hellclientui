class Server {
  Server();
  String id = "";
  String host = "";
  String username = "";
  String password = "";
  Server.fromJson(Map<String, dynamic> json)
      : host = json['host'],
        username = json['username'],
        password = json['password'];
  Map<String, dynamic> toJson() => {
        'host': host,
        'username': username,
        'password': password,
      };
}
