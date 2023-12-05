import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hellclientui/models/batchcommand.dart';
import 'package:hellclientui/models/message.dart' as message;
import 'package:hellclientui/workers/notification.dart';

import 'package:web_socket_channel/io.dart';
import 'package:synchronized/synchronized.dart';

const timerDuration = Duration(minutes: 1);

class LongConnection {
  String host = "";
  String username = "";
  String password = "";
  bool updated = false;
  void dispose() {
    _disconnect();
    if (streamsub != null) {
      streamsub!.cancel();
    }
    timer.cancel();
  }

  StreamSubscription? streamsub;

  final lock = Lock();
  bool keep = false;
  late Timer timer;
  IOWebSocketChannel? channel;
  Future<void> _connect() async {
    if (host.isNotEmpty) {
      final hosturi = Uri.parse(host);
      final String scheme;
      final String auth;
      if (hosturi.scheme == "https") {
        scheme = 'wss';
      } else {
        scheme = 'ws';
      }
      if (username.isNotEmpty) {
        auth = '$username:$password';
      } else {
        auth = "";
      }
      final serveruri = Uri(
          scheme: scheme,
          host: hosturi.host,
          port: hosturi.port,
          path: "/messenger");
      final Map<String, dynamic> headers = {};
      if (auth.isNotEmpty) {
        headers['Authorization'] = 'Basic ${base64.encode(utf8.encode(auth))}';
      }
      final wschannel = IOWebSocketChannel.connect(serveruri, headers: headers);
      await wschannel.ready;
      channel = wschannel;
      _listen();
    }
  }

  Future<void> _disconnect() async {
    if (channel != null) {
      channel!.sink.close();
      channel = null;
      if (streamsub != null) {
        streamsub!.cancel();
      }
    }
  }

  void execute() async {
    lock.synchronized(() async {
      if ((updated || keep == false) && channel != null) {
        await _disconnect();
      }
      updated = false;
      if (channel == null && keep) {
        await _connect();
      }
    });
  }

  void sendBatchCommand(BatchCommand command) async {
    lock.synchronized(() async {
      if (channel == null) {
        await _connect();
      }
      var msg =
          message.Response.createBatchCommand(command.command, command.scripts);
      if (channel != null) {
        print(jsonEncode(msg.toJson()));
        channel!.sink.add(jsonEncode(msg.toJson()));
        if (!keep) {
          await _disconnect();
        }
      }
    });
  }

  void _tick() {
    execute();
  }

  void start() {
    timer = Timer(timerDuration, _tick);
    execute();
  }

  void update(bool keep, String host, String username, String password) {
    this.keep = keep;
    this.host = host;
    this.username = username;
    this.password = password;
    updated = true;
    execute();
  }

  void _listen() {
    streamsub = channel!.stream.listen(
        (event) async {
          if (event is String) {
            try {
              final req = message.Request.fromJson(json.decode(event));
              if (req.type == 'desktopnotification') {
                final noti =
                    message.DesktopNotification.fromJson(jsonDecode(req.data));
                currentNotification.ondesktopNotify(noti);
              }
            } catch (e) {
              debugPrint(e.toString());
            }
          }
        },
        onError: (error) {},
        onDone: () {
          if (streamsub != null) {
            streamsub!.cancel();
          }
          channel = null;
        },
        cancelOnError: true);
  }
}
