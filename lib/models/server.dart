class Server {
  Server();
  String id = "";
  String host = "";
  String name = "";
  String username = "";
  String password = "";
  Server.fromJson(Map<String, dynamic> json)
      : host = json['host'],
        username = json['username'],
        password = json['password'],
        name = json['name'];
  Map<String, dynamic> toJson() => {
        'host': host,
        'username': username,
        'password': password,
        "name": name,
      };
}
