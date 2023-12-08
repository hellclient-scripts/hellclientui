import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';

import 'server.dart';
import 'package:web_socket_channel/io.dart';
import 'package:synchronized/synchronized.dart';

class Connecting {
  Connecting();
  bool connected = false;
  IOWebSocketChannel? channel;
  final lock = Lock();
  Server? currentServer;
  var eventDisconnected = StreamController.broadcast(sync: true);
  final messageStream = StreamController.broadcast();
  final errorStream = StreamController.broadcast();
  StreamSubscription? streamsub;
  Future<void> _close() async {
    if (channel == null) {
      return;
    }
    await channel!.sink.close();
    await channel!.sink.done;
    channel = null;
  }

  Future<void> close() async {
    await lock.synchronized(() async {
      if (streamsub != null) {
        streamsub!.cancel();
      }
      await _close();
    });
  }

  Future<void> _connect() async {
    if (channel != null || currentServer == null) {
      return;
    }
    connected = false;
    final server = currentServer!;
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
    try {
      final wschannel = IOWebSocketChannel.connect(serveruri, headers: headers);
      await wschannel.ready;
      channel = wschannel;
      currentServer = server;
      connected = true;
      _listen();
    } catch (e) {
      errorStream.add(e);
    }
  }

  Future<void> connect(Server server) async {
    currentServer = server;
    await lock.synchronized(() async {
      await _connect();
    });
  }

  void _listen() {
    debugPrint('listen');
    streamsub = channel!.stream.listen((event) async {
      messageStream.add(event);
    }, onError: (error) {
      errorStream.add(error);
    }, onDone: () {
      debugPrint('done');
      eventDisconnected.add(null);
      if (streamsub != null) {
        streamsub!.cancel();
        streamsub = null;
      }
      channel = null;
    }, cancelOnError: true);
  }
}
