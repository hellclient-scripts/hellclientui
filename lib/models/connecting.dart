import 'package:web_socket_channel/web_socket_channel.dart';
import 'server.dart';

class Connecting {
  WebSocketChannel? channel;
  String serverhost = "";
  void connect(Server server) {
    final hosturi = Uri.parse(server.host);
    final String scheme;
    final String auth;
    final String host;
    if (hosturi.scheme == "https") {
      scheme = 'wss';
    } else {
      scheme = 'ws';
    }
    if (server.username.isNotEmpty) {
      auth = server.username + ":" + server.password;
    } else {
      auth = "";
    }
    final serveruri = Uri(
        scheme: scheme,
        host: hosturi.host,
        port: hosturi.port,
        userInfo: auth,
        path: "/ws");
    channel = WebSocketChannel.connect(serveruri);
    serverhost = hosturi.host + ":" + hosturi.port.toString();
  }
}
