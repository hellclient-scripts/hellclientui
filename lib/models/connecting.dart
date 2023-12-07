import 'dart:convert';
import 'dart:async';

import 'package:hellclientui/workers/game.dart';

import 'server.dart';
import 'package:web_socket_channel/io.dart';
import 'package:synchronized/synchronized.dart';

class Connecting {
  Connecting();
  IOWebSocketChannel? channel;
  final lock = Lock();
  Server? currentServer;
  final eventDisconnected = StreamController.broadcast();
  final messageStream = StreamController.broadcast();
  final errorStream = StreamController.broadcast();
  Future<void> _close() async {
    if (channel == null) {
      return;
    }
    await channel!.sink.close();
    channel = null;
  }

  Future<void> close() async {
    await lock.synchronized(() async {
      await _close();
    });
  }

  Future<void> _connect(Server server) async {
    if (channel != null) {
      return;
    }
    final hosturi = Uri.parse(server.host);
    final String scheme;
    final String auth;
    if (hosturi.scheme == "https") {
      scheme = 'wss';
    } else {
      scheme = 'ws';
    }
    if (server.username.isNotEmpty) {
      auth = '${server.username}:${server.password}';
    } else {
      auth = "";
    }
    final serveruri = Uri(
        scheme: scheme,
        host: hosturi.host,
        port: hosturi.port,
        // userInfo: auth,
        path: "/ws");
    final Map<String, dynamic> headers = {};
    if (auth.isNotEmpty) {
      headers['Authorization'] = 'Basic ${base64.encode(utf8.encode(auth))}';
    }
    final wschannel = IOWebSocketChannel.connect(serveruri, headers: headers);
    await wschannel.ready;
    channel = wschannel;
    currentServer = server;
    _listen();
  }

  Future<void> connect(Server server) async {
    await lock.synchronized(() async {
      await _connect(server);
    });
  }

  Future<void> enterGame(Server server, String gameid) async {
    await lock.synchronized(() async {
      if (channel != null) {
        if (currentServer != null && currentServer!.host != server.host) {
          if (currentGame != null) {
            currentGame!.silenceQuit = true;
            currentGame!.dispose();
          }
          await _close();
        }
      }
      if (channel == null) {
        await _connect(server);
        currentGame = Game.create(this);
      }
      if (channel != null && currentGame != null) {
        currentGame!.handleCmd('change', gameid);
      }
    });
  }

  void _listen() {
    late StreamSubscription streamsub;
    streamsub = channel!.stream.listen((event) async {
      messageStream.add(event);
    }, onError: (error) {
      errorStream.add(error);
    }, onDone: () {
      eventDisconnected.add(null);
      streamsub.cancel();
      channel = null;
    }, cancelOnError: true);
  }
}
