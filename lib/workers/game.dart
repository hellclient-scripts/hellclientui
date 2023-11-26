import 'package:flutter/material.dart';
import 'package:hellclientui/models/server.dart';
import 'package:hellclientui/views/widgets/appui.dart';
import '../models/rendersettings.dart';
import '../states/appstate.dart';

import 'dart:convert';
import 'dart:async';

import 'renderer.dart';
import '../models/message.dart';
import '../models/connecting.dart';
import 'package:synchronized/synchronized.dart';

Game? currentGame;

class GameFormFail {
  const GameFormFail({required this.formID, required this.data});
  final String formID;
  final dynamic data;
}

class GameCommand {
  const GameCommand({required this.command, this.data = ""});
  final String command;
  final String data;
}

class Game {
  String current = "";
  String status = "";
  int historypos = -1;
  ClientInfo? currentClient;
  late RenderSettings renderSettings;
  late Connecting connecting;
  late Server server;
  late RenderPainter output;
  late RenderPainter prompt;
  late RenderPainter hud;
  int switchStatus = 0;
  var hudLock = Lock();
  List<Line> hudContent = [];
  ClientInfos clientinfos = ClientInfos();
  late StreamSubscription subscription;
  late StreamSubscription disconnectSub;
  final commandStream = StreamController.broadcast();
  final clientsUpdateStream = StreamController.broadcast();
  final hudUpdateStream = StreamController.broadcast();
  final disconnectStream = StreamController.broadcast();
  final createFailStream = StreamController.broadcast();
  static Game create(Connecting connecting) {
    connecting = connecting;
    var game = Game();
    final appState = currentAppState;
    final settings = appState.renderSettings;
    game.server = appState.currentServer!;
    game.renderSettings = settings;
    game.output = RenderPainter.create(Renderer(
        renderSettings: settings,
        maxLines: settings.maxLines,
        devicePixelRatio: appState.devicePixelRatio,
        background: settings.background));
    game.prompt = RenderPainter.create(Renderer(
        renderSettings: settings,
        maxLines: 1,
        devicePixelRatio: appState.devicePixelRatio,
        background: settings.background));
    game.hud = RenderPainter.create(Renderer(
      renderSettings: settings,
      maxLines: 0,
      devicePixelRatio: appState.devicePixelRatio,
      background: settings.hudbackground,
      noSortLines: true,
    ));
    game.subscription = connecting.messageStream.stream.listen((event) async {
      var msg = event as String;
      await game.onMessage(msg);
    });
    game.disconnectSub =
        connecting.eventDisconnected.stream.listen((event) async {
      game.disconnectStream.add(event);
    });
    game.connecting = connecting;
    game.handleCmd("current", null);
    return game;
  }

  String decodeString(String data) {
    final dynamic jsondata = json.decode(data);
    return jsondata as String;
  }

  Future<void> onCmdSwitchStatus(String data) async {
    switchStatus = int.parse(decodeString(data));
    clientsUpdateStream.add(null);
  }

  Future<void> onCmdLine(String data) async {
    final Map<String, dynamic> jsondata = json.decode(data);
    final line = Line.fromJson(jsondata);
    await output.renderer.drawLine(line);
    output.renderer.draw();
  }

  Future<void> onCmdPrompt(String data) async {
    final Map<String, dynamic>? jsondata = json.decode(data);
    if (jsondata != null) {
      final line = Line.fromJson(jsondata);
      prompt.renderer.reset();
      await prompt.renderer.renderline(
          renderSettings, line, true, true, renderSettings.background);
      prompt.renderer.draw();
    } else {
      prompt.renderer.reset();
      prompt.renderer.draw();
    }
  }

  void drawHud() async {
    hud.renderer.maxLines = hudContent.length;
    hud.renderer.reset();
    for (final line in hudContent) {
      await hud.renderer.renderline(
          renderSettings, line, true, true, renderSettings.hudbackground);
    }
    hud.renderer.draw();
    hudUpdateStream.add(null);
  }

  Future<void> onCmdHudContent(String data) async {
    hudLock.synchronized(() async {
      final dynamic jsondata = json.decode(data);
      if (jsondata != null) {
        final lines = Lines.fromJson(jsondata);
        hudContent = lines.lines;
        drawHud();
      }
    });
  }

  Future<void> onCmdHudUpdate(String data) async {
    hudLock.synchronized(() async {
      final dynamic jsondata = json.decode(data);
      if (jsondata != null) {
        final diffllines = DiffLines.fromJson(jsondata);
        var start = diffllines.start;
        for (final line in diffllines.content) {
          if (hudContent.length > start) {
            hudContent[start] = line;
          } else {
            hudContent.add(line);
          }
          start++;
        }
        drawHud();
      }
    });
  }

  Future<void> onCmdLines(String data) async {
    final dynamic jsondata = json.decode(data);
    final lines = Lines.fromJson(jsondata);
    for (final line in lines.lines) {
      await output.renderer.drawLine(line);
    }
    output.renderer.draw();
  }

  Future<void> onCmdClients(String data) async {
    final dynamic jsondata = json.decode(data);
    final infos = ClientInfos.fromJson(jsondata);
    clientinfos = infos;
    for (var info in clientinfos.clientInfos) {
      if (info.id == current) {
        currentClient = info;
        break;
      }
    }

    clientsUpdateStream.add(null);
  }

  Future<void> onCmdClientinfo(String data) async {
    final dynamic jsondata = json.decode(data);
    final clientinfo = ClientInfo.fromJson(jsondata);
    for (int i = 0; i < clientinfos.clientInfos.length; i++) {
      if (clientinfos.clientInfos[i].id == clientinfo.id) {
        clientinfos.clientInfos[i] = clientinfo;
        break;
      }
    }
    output.renderer.reset();
    clientsUpdateStream.add(null);
  }

  Future<void> onCmdCurrent(String data) async {
    current = decodeString(data);
    currentClient = null;
    for (var info in clientinfos.clientInfos) {
      if (info.id == current) {
        currentClient = info;
        break;
      }
    }
    historypos = -1;
    output.renderer.reset();
    clientsUpdateStream.add(null);
  }

  Future<void> onCmdConnected(String data) async {
    final id = decodeString(data);
    for (var info in clientinfos.clientInfos) {
      if (info.id == id) {
        info.running = true;
        break;
      }
    }
    clientsUpdateStream.add(null);
  }

  Future<void> onCmdDisconnected(String data) async {
    final id = decodeString(data);
    for (var info in clientinfos.clientInfos) {
      if (info.id == id) {
        info.running = false;
        break;
      }
    }
    clientsUpdateStream.add(null);
  }

  Future<void> onMessage(String msg) async {
    final String command;
    final String data;
    var position = msg.indexOf(" ");
    if (position < 0) {
      command = msg;
      data = "";
    } else {
      command = msg.substring(0, position);
      data = msg.substring(position + 1);
    }
    switch (command) {
      case "lines":
        await onCmdLines(data);
        break;
      case "line":
        await onCmdLine(data);
        break;
      case "allLines":
        commandStream.add(GameCommand(command: command, data: data));
        break;
      case "clients":
        await onCmdClients(data);
        commandStream.add(GameCommand(command: command, data: data));
        break;
      case "current":
        await onCmdCurrent(data);
        commandStream.add(GameCommand(command: command, data: data));
        break;
      case "connected":
        await onCmdConnected(data);
        break;
      case "disconnected":
        await onCmdDisconnected(data);
        break;
      case 'prompt':
        await onCmdPrompt(data);
        break;
      case 'hudcontent':
        await onCmdHudContent(data);
        break;
      case 'hudupdate':
        await onCmdHudUpdate(data);
        break;
      case 'notopened':
      case 'scriptMessage':
        commandStream.add(GameCommand(command: command, data: data));
        break;
      case 'clientinfo':
        onCmdClientinfo(data);
        break;
      case 'switchStatus':
        onCmdSwitchStatus(data);
        break;
      case 'createFail':
        createFailStream.add(data);
        break;
      case 'version':
        commandStream.add(GameCommand(command: command, data: data));
        break;
      case 'status':
        status = decodeString(data);
        clientsUpdateStream.add(null);
        break;
      case 'foundhistory':
        commandStream.add(GameCommand(command: command, data: data));
        break;
      case 'defaultCharset':
      case 'defaultServer':
      case 'createSuccess':
      case 'authorized':
      case 'requestTrustDomains':
      case 'requestPermissions':
        commandStream.add(GameCommand(command: command, data: data));
        break;
    }
  }

  Future<void> connect(AppState appState, Function(String) errorhandler) async {
    subscription = connecting.messageStream.stream.listen((event) async {
      var msg = event as String;
      await onMessage(msg);
    });
  }

  Future<void> close() async {
    await connecting.close();
  }

  void onPostFrame(Duration time) {
    output.renderer.draw();
  }

  void handleSend(String cmd) {
    if (connecting.channel != null) {
      connecting.channel!.sink.add('send ${json.encode(cmd)}');
      historypos = 0;
    }
  }

  void handleCmd(String cmd, dynamic data) {
    if (connecting.channel != null) {
      if (data == null) {
        connecting.channel!.sink.add(cmd);
      } else {
        final wsdata = '$cmd ${json.encode(data)}';
        debugPrint(wsdata);
        connecting.channel!.sink.add(wsdata);
      }
    }
  }

  void handleUserInputCallback(UserInput input, int code, dynamic data) {
    handleCmd('callback', [
      currentGame!.current,
      jsonEncode(input.callback(code, data).toJson())
    ]);
  }

  Future<void> dispose() async {
    subscription.cancel();
    disconnectSub.cancel();
  }

  void clientQuick() {
    final clients = [...clientinfos.clientInfos];
    if (clients.isNotEmpty) {
      clients.sort((a, b) {
        return a.lastActive.compareTo(b.lastActive);
      });
      handleCmd('change', clients[0].id);
    }
  }

  void openGames() {
    handleCmd('notopened', null);
  }

  KeyEventResult onKey(RawKeyEvent key) {
    switch (key.logicalKey.keyLabel) {
      case 'Escape':
        if (!key.isControlPressed) {
          break;
        }
        handleCmd("change", "");
        break;
      case "Pause":
        handleCmd("change", "");
        break;
      case "1":
      case "2":
      case "3":
      case "4":
      case "5":
      case "6":
      case "7":
      case "8":
      case "9":
        if (current == "") {
          final index = int.parse(key.logicalKey.keyLabel) - 1;
          if (index >= 0 && index < clientinfos.clientInfos.length) {
            handleCmd('change', clientinfos.clientInfos[index].id);
          }
        }
        break;
      case "`":
        if (current == "" || key.isControlPressed) {
          clientQuick();
        }
        break;
      case "Scroll Lock":
        clientQuick();
        break;
      case "Numpad 0":
      case "Numpad 1":
      case "Numpad 2":
      case "Numpad 3":
      case "Numpad 4":
      case "Numpad 5":
      case "Numpad 6":
      case "Numpad 7":
      case "Numpad 8":
      case "Numpad 9":
      case "Numpad Divide":
      case "Numpad Multiply":
      case "Numpad Subtract":
      case "Numpad Add":
      case "Numpad Decimal":
        handleCmd('keyup', key.logicalKey.keyLabel.replaceFirst(" ", ""));
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void start() {}
}
