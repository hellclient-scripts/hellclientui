import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:hellclientui/models/feature.dart';
import '../models/rendersettings.dart';
import '../states/appstate.dart';

import 'dart:convert';
import 'dart:async';

import 'renderer.dart';
import '../models/message.dart';
import '../models/server.dart';
import '../models/connecting.dart';
import 'package:synchronized/synchronized.dart';

Game? currentGame;

class GameCommand {
  const GameCommand({required this.command, this.data = ""});
  final String command;
  final String data;
}

class Game {
  GameCommand? entryCommand;
  bool silenceQuit = false;
  String current = "";
  String status = "";
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late Server server;
  int historypos = 0;
  List<String> history = [];
  List<String> suggestion = [];
  bool hideInput = false;
  String lastInput = "";
  bool showAllParams = false;
  int alllinesScale = ScaleSettings.defaultScale;
  ClientInfo? currentClient;
  APIVersion? apiVersion;
  late RenderSettings renderSettings;
  late Connecting connecting;
  late RenderPainter output;
  late RenderPainter prompt;
  late RenderPainter hud;
  int switchStatus = 0;
  UserInput? datagrid;
  Lines? alllines;
  ParamsInfo? paramsInfos;
  Triggers? triggers;
  Aliases? aliases;
  Timers? timers;

  var hudLock = Lock();
  List<Line> hudContent = [];
  ClientInfos clientinfos = ClientInfos();
  late StreamSubscription subscription;
  late StreamSubscription disconnectSub;
  late StreamSubscription subConnectError;
  final commandStream = StreamController.broadcast();
  final clientsUpdateStream = StreamController.broadcast();
  final hudUpdateStream = StreamController.broadcast();
  final streamConnectError = StreamController.broadcast();
  final disconnectStream = StreamController.broadcast(sync: true);
  final createFailStream = StreamController.broadcast();
  final datagridUpdateStream = StreamController.broadcast();
  final dataUpdateStream = StreamController.broadcast();
  late FocusNode focusNode;
  static Game create(Server connectingserver, {GameCommand? entryCommand}) {
    var game = Game();
    game.server = connectingserver;
    game.focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          return game.onKey(event);
        }
        return KeyEventResult.ignored;
      },
    );
    game.init();
    return game;
  }

  void init() {
    final appState = currentAppState;
    final settings = appState.renderSettings;

    renderSettings = settings;
    entryCommand = entryCommand;
    output = RenderPainter.create(Renderer(
        renderSettings: settings,
        maxLines: settings.maxLines,
        devicePixelRatio: appState.devicePixelRatio,
        background: settings.background));
    prompt = RenderPainter.create(Renderer(
        renderSettings: settings,
        maxLines: 1,
        devicePixelRatio: appState.devicePixelRatio,
        background: settings.background));
    hud = RenderPainter.create(Renderer(
      renderSettings: settings,
      maxLines: 0,
      devicePixelRatio: appState.devicePixelRatio,
      background: settings.hudbackground,
      noSortLines: true,
    ));
    hideInput = renderSettings.defaultHideInput;
    alllinesScale = renderSettings.getDefaultScale();
  }

  void unbind() {
    subscription.cancel();
    disconnectSub.cancel();
    subConnectError.cancel();
  }

  Future<void> dial(Function() callback) async {
    connecting = currentAppState.connecting;
    bind(connecting);
    callback();
    await connecting.connect(server);
    if (entryCommand != null) {
      handleCmd(entryCommand!.command, entryCommand!.data);
      entryCommand = null;
    }
  }

  void bind(Connecting newconnecting) {
    connecting = newconnecting;
    subscription = connecting.messageStream.stream.listen((event) async {
      var msg = event as String;
      await onMessage(msg);
    });
    disconnectSub = connecting.eventDisconnected.stream.listen((event) {
      disconnectStream.add(event);
    });
    subConnectError = connecting.errorStream.stream.listen((event) {
      streamConnectError.add(event);
    });
    connecting = connecting;
    handleCmd("current", null);
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
  }

  Future<void> onCmdPrompt(String data) async {
    final Map<String, dynamic>? jsondata = json.decode(data);
    if (jsondata != null) {
      final line = Line.fromJson(jsondata);
      prompt.renderer.reset();
      await prompt.renderer.renderline(
          renderSettings, line, true, true, renderSettings.background);
    } else {
      prompt.renderer.reset();
    }
  }

  void onCmdAlllines(String data) {
    final dynamic jsondata = json.decode(data);
    final lines = Lines.fromJson(jsondata);
    alllines = lines;
    updateAlllines(lines);
  }

  void drawHud() async {
    hud.renderer.maxLines = hudContent.length;
    await hud.renderer.renderlines(
        renderSettings, hudContent, true, true, renderSettings.hudbackground);
    hudUpdateStream.add(null);
  }

  void updateDatagrid(UserInput? grid) {
    datagrid = grid;
    datagridUpdateStream.add(grid);
  }

  void updateAlllines(Lines? lines) {
    alllines = lines;
    dataUpdateStream.add(lines);
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
    await output.renderer.drawLines(lines.lines);
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
    // output.renderer.reset();
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
    historypos = 0;
    history = [];
    suggestion = [];
    output.renderer.reset();
    hud.renderer.reset();
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
    if (currentClient != null && currentClient!.id == id) {
      currentClient!.running = true;
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
    if (currentClient != null && currentClient!.id == id) {
      currentClient!.running = false;
    }
    clientsUpdateStream.add(null);
  }

  Future<void> onCmdHistory(String data) async {
    historypos = 0;
    final dynamic jsondata = json.decode(data);
    history = [];
    suggestion = [];
    history = List<dynamic>.from(jsondata)
        .map((e) => e == null ? "" : e as String)
        .skipWhile((value) => value == "")
        .toList();
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
        onCmdAlllines(data);
        break;
      case "clients":
        await onCmdClients(data);
        commandStream.add(GameCommand(command: command, data: data));
        break;
      case "current":
        await onCmdCurrent(data);
        commandStream.add(GameCommand(command: command, data: data));
        break;
      case "history":
        onCmdHistory(data);
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
      case 'createScriptFail':
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
      case 'apiversion':
        final dynamic jsondata = json.decode(data);
        apiVersion = APIVersion.fromJson(jsondata);
        break;
      case 'defaultCharset':
      case 'defaultServer':
      case 'createSuccess':
      case 'authorized':
      case 'requestTrustDomains':
      case 'requestPermissions':
      case 'worldSettings':
      case 'scriptinfo':
      case 'scriptinfoList':
      case 'scriptSettings':
      case 'paramsinfo':
      case 'requiredParams':
      case 'scripttriggers':
      case 'usertriggers':
      case 'scriptaliases':
      case 'useraliases':
      case 'scripttimers':
      case 'usertimers':
      case 'hideall':
      case 'batchcommandscripts':
        commandStream.add(GameCommand(command: command, data: data));
        break;
    }
  }

  bool support(Feature featureToCheck) {
    if (apiVersion == null) {
      return false;
    }
    return featureToCheck.isSupportedBy(apiVersion!);
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

  void handleSend(String cmd) {
    if (connecting.channel != null) {
      connecting.channel!.sink.add('send ${json.encode(cmd)}');
      historypos = 0;
      lastInput = "";
      suggestion = [];
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

  void handleUserInputScriptCallback(
      UserInput input, String script, int code, dynamic data) {
    handleCmd('callback', [
      currentGame!.current,
      jsonEncode(input.callbackScript(script, code, data).toJson())
    ]);
  }

  Future<void> dispose() async {
    subscription.cancel();
    disconnectSub.cancel();
    subConnectError.cancel();
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

  KeyEventResult onKey(KeyEvent key) {
    switch (key.logicalKey.keyLabel) {
      case 'Backspace':
        if (!HardwareKeyboard.instance.isControlPressed) {
          break;
        }
        handleCmd("change", "");
        break;
      case "Pause":
        handleCmd("change", "");
        break;
      case "K":
        if (currentClient != null &&
            HardwareKeyboard.instance.isControlPressed) {
          if (currentClient!.running) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              handleCmd("disconnect", currentGame?.current);
            }
          } else {
            if (!HardwareKeyboard.instance.isShiftPressed) {
              handleCmd("connect", currentGame?.current);
            }
          }
        }
        break;
      case "W":
        if (HardwareKeyboard.instance.isControlPressed) {
          commandStream.add(const GameCommand(command: '_quit'));
        }
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
        if (current == "" || HardwareKeyboard.instance.isControlPressed) {
          final index = int.parse(key.logicalKey.keyLabel) - 1;
          if (index >= 0 && index < clientinfos.clientInfos.length) {
            handleCmd('change', clientinfos.clientInfos[index].id);
          }
        }
        break;
      case "`":
        if (current == "" || HardwareKeyboard.instance.isControlPressed) {
          clientQuick();
        }
        break;
      case "Scroll Lock":
        clientQuick();
        break;
      case "F1":
        final macro = currentAppState.config.macros.f1;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F1');
        }
        return KeyEventResult.handled;
      case "F2":
        final macro = currentAppState.config.macros.f2;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F2');
        }
        return KeyEventResult.handled;
      case "F3":
        final macro = currentAppState.config.macros.f3;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F3');
        }
        return KeyEventResult.handled;
      case "F4":
        final macro = currentAppState.config.macros.f4;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F4');
        }
        return KeyEventResult.handled;
      case "F5":
        final macro = currentAppState.config.macros.f5;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F5');
        }
        return KeyEventResult.handled;
      case "F6":
        final macro = currentAppState.config.macros.f6;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F6');
        }
        return KeyEventResult.handled;
      case "F7":
        final macro = currentAppState.config.macros.f7;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F7');
        }
        return KeyEventResult.handled;
      case "F8":
        final macro = currentAppState.config.macros.f8;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F8');
        }
        return KeyEventResult.handled;
      case "F9":
        final macro = currentAppState.config.macros.f9;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F9');
        }
        return KeyEventResult.handled;
      case "F10":
        final macro = currentAppState.config.macros.f10;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F10');
        }
        return KeyEventResult.handled;
      case "F11":
        final macro = currentAppState.config.macros.f11;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F11');
        }
        return KeyEventResult.handled;
      case "F12":
        final macro = currentAppState.config.macros.f12;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'F12');
        }
        return KeyEventResult.handled;
      case "Numpad 0":
        final macro = currentAppState.config.macros.numpad0;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad0');
        }
        return KeyEventResult.handled;
      case "Numpad 1":
        final macro = currentAppState.config.macros.numpad1;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad1');
        }
        return KeyEventResult.handled;
      case "Numpad 2":
        final macro = currentAppState.config.macros.numpad2;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad2');
        }
        return KeyEventResult.handled;
      case "Numpad 3":
        final macro = currentAppState.config.macros.numpad3;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad3');
        }
        return KeyEventResult.handled;
      case "Numpad 4":
        final macro = currentAppState.config.macros.numpad4;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad4');
        }
        return KeyEventResult.handled;
      case "Numpad 5":
        final macro = currentAppState.config.macros.numpad5;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad5');
        }
        return KeyEventResult.handled;
      case "Numpad 6":
        final macro = currentAppState.config.macros.numpad6;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad6');
        }
        return KeyEventResult.handled;

      case "Numpad 7":
        final macro = currentAppState.config.macros.numpad7;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad7');
        }
        return KeyEventResult.handled;
      case "Numpad 8":
        final macro = currentAppState.config.macros.numpad8;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad8');
        }
        return KeyEventResult.handled;
      case "Numpad 9":
        final macro = currentAppState.config.macros.numpad9;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'Numpad9');
        }
        return KeyEventResult.handled;
      case "Numpad Divide":
        final macro = currentAppState.config.macros.numpadDivide;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'NumpadDivide');
        }
        return KeyEventResult.handled;
      case "Numpad Multiply":
        final macro = currentAppState.config.macros.numpadMultiply;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'NumpadMultiply');
        }
        return KeyEventResult.handled;
      case "Numpad Subtract":
        final macro = currentAppState.config.macros.numpadSubtract;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'NumpadSubtract');
        }
        return KeyEventResult.handled;
      case "Numpad Add":
        final macro = currentAppState.config.macros.numpadAdd;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'NumpadAdd');
        }
        return KeyEventResult.handled;
      case "Numpad Decimal":
        final macro = currentAppState.config.macros.numpadDecimal;
        if (macro.isNotEmpty) {
          handleSend(macro);
        } else {
          handleCmd('keyup', 'NumpadDecimal');
        }
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void alllinesZoomIn() {
    for (var val in ScaleSettings.list) {
      if (val > alllinesScale) {
        alllinesScale = val;
        return;
      }
    }
  }

  void alllinesZoomOut() {
    var min = alllinesScale;
    for (var val in ScaleSettings.list) {
      if (val < alllinesScale) {
        min = val;
      }
    }
    alllinesScale = min;
  }

  double getAlllinesScale() {
    return alllinesScale.toDouble() / 100;
  }

  static enterGame(String serverhost, String gameid) async {
    for (final server in currentAppState.config.servers) {
      if (server.host == serverhost) {
        if (!currentAppState.inGame) {
          final context = currentAppState.navigatorKey.currentState!.context;
          var dpr = currentAppState.renderSettings.hidpi
              ? MediaQuery.of(context).devicePixelRatio
              : 1.0;
          if (currentAppState.renderSettings.roundDpi) {
            dpr = dpr.roundToDouble();
          }
          currentAppState.devicePixelRatio = dpr;
          final game = Game.create(server,
              entryCommand: GameCommand(command: 'change', data: gameid));
          currentGame = game;
          await Navigator.of(context).pushNamed('/game', arguments: game);
        } else {
          if (currentGame != null) {
            currentGame!.server = server;
            currentGame!.entryCommand =
                GameCommand(command: 'change', data: gameid);
            currentGame!.commandStream
                .add(const GameCommand(command: '_reconnect'));
          }
        }
        return;
      }
    }
  }

  void start() {}
}
