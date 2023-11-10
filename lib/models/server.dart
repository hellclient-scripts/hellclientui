class Server {
  String id = "";
  String host = "";
  String username = "";
  String password = "";
  Server.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        host = json['host'],
        username = json['username'],
        password = json['password'];
  Map<String, dynamic> toJson() => {
        'id': id,
        'host': host,
        'username': username,
        'password': password,
      };
}
