import 'dart:convert';
import 'dart:async';

import 'server.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';

class Connecting {
  Connecting();
  IOWebSocketChannel? channel;
  final eventDisconnected = StreamController.broadcast();
  final messageStream = StreamController.broadcast();
  final errorStream = StreamController.broadcast();

  Future<void> connect(Server server) async {
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
      auth = server.username + ":" + server.password;
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
      headers['Authorization'] = 'Basic ' + base64.encode(utf8.encode(auth));
    }
    final wschannel = IOWebSocketChannel.connect(serveruri, headers: headers);
    await wschannel.ready;
    wschannel.stream.listen((event) async {
      messageStream.add(event);
    }, onError: (error) {
      errorStream.add(error);
    }, onDone: () {
      eventDisconnected.add(null);
      channel = null;
    }, cancelOnError: true);
    channel = wschannel;
  }
}
