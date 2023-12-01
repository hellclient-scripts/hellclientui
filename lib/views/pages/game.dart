import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hellclientui/views/widgets/scriptinfolistview.dart';
import 'package:provider/provider.dart';
import 'package:hellclientui/states/appstate.dart';
import '..//widgets/fullscreen.dart';
import 'dart:async';
import 'dart:convert';
import '../widgets/display.dart';
import '../widgets/notopened.dart';
import '../../workers/game.dart' as gameengine;
import '../../models/message.dart' as message;
import '../widgets/appui.dart';
import '../widgets/gameui.dart';

Future<String?> showNotOpened(
    BuildContext context, message.NotOpened games) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog.fullscreen(
        child: NotOpened(games: games.games),
      );
    },
  );
}

Future<String?> showScriptInfoList(
    BuildContext context, message.ScriptInfoList list) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog.fullscreen(
        child: ScriptInfoListView(list: list.list),
      );
    },
  );
}

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<Game> createState() => GameState();
}

class GameState extends State<Game> {
  late StreamSubscription disconnectSub;
  late StreamSubscription subCommand;
  late gameengine.Game game;
  var _refreshKey = UniqueKey();
  Future<void> reconnect() async {
    await cancel();
    game.dispose();
    await currentAppState.connecting.connect(currentAppState.currentServer!);
    gameengine.currentGame = gameengine.Game.create(currentAppState.connecting);
    await listen();
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  void dispose() {
    cancel();
    game.dispose();
    game.close();

    super.dispose();
  }

  Future<void> cancel() async {
    await disconnectSub.cancel();
    await subCommand.cancel();
  }

  Future<void> listen() async {
    game = gameengine.currentGame!;
    disconnectSub = game.disconnectStream.stream.listen((data) async {
      if (await showDisconneded(context) == true) {
        try {
          if (context.mounted) {
            AppUI.hideUI(context);
          }
          await (reconnect());
        } catch (e) {
          if (context.mounted) {
            showConnectError(context, e.toString());
          }
        }
      } else {
        if (context.mounted) {
          var nav = Navigator.of(context);
          nav.pop();
        }
      }
    });
    subCommand = game.commandStream.stream.listen((event) async {
      if (event is gameengine.GameCommand) {
        switch (event.command) {
          case 'notopened':
            final dynamic jsondata = json.decode(event.data);
            final notOpened = message.NotOpened.fromJson(jsondata);
            final id = await showNotOpened(context, notOpened);
            if (id != null) {
              game.handleCmd('open', id);
            }
            break;
          case 'scriptinfoList':
            final dynamic jsondata = json.decode(event.data);
            final list = message.ScriptInfoList.fromJson(jsondata);
            final id = await showScriptInfoList(context, list);
            if (id != null) {
              game.handleCmd('usescript', <dynamic>[game.current, id]);
            }
            break;

          case 'version':
            AppUI.showMsgBox(
                context,
                "关于",
                '',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SelectableText('Hellclient'),
                    const SelectableText(
                        'https://github.com/jarlyyn/hellclient'),
                    const SizedBox(
                      height: 10,
                    ),
                    SelectableText(
                        '服务器版本: ${jsonDecode(event.data) as String}'),
                  ],
                ));
            break;
          case 'authorized':
            final dynamic jsondata = json.decode(event.data);
            final authorized = message.Authorized.fromJson(jsondata);
            GameUI.showAuthorized(context, authorized);
            break;
          case 'requestPermissions':
            final dynamic jsondata = json.decode(event.data);
            final request = message.RequestTrust.fromJson(jsondata);
            GameUI.requestPermissions(context, request);
            break;
          case 'requestTrustDomains':
            final dynamic jsondata = json.decode(event.data);
            final request = message.RequestTrust.fromJson(jsondata);
            GameUI.requestTrustDomains(context, request);
            break;
          case 'worldSettings':
            final dynamic jsondata = json.decode(event.data);
            final settings = message.WorldSettings.fromJson(jsondata);
            GameUI.showWorldSettings(context, settings);
            break;
          case 'scriptSettings':
            final dynamic jsondata = json.decode(event.data);
            final settings = message.ScriptSettings.fromJson(jsondata);
            GameUI.showScriptSettings(context, settings);
            break;
          case 'scriptinfo':
            final dynamic jsondata = json.decode(event.data);
            final scriptinfo = message.ScriptInfo.fromJson(jsondata);
            GameUI.showScript(context, scriptinfo);
            break;
          case 'paramsinfo':
            final dynamic jsondata = json.decode(event.data);
            final paramsinfo = message.ParamsInfo.fromJson(jsondata);
            GameUI.showParamsInfo(context, paramsinfo);
            break;
          case 'requiredParams':
            final dynamic jsondata = json.decode(event.data);
            final requiredParams = message.RequiredParams.fromJson(jsondata);
            GameUI.showUpdateRequiredParams(context, requiredParams);
            break;
          case 'scripttriggers':
            final dynamic jsondata = json.decode(event.data);
            final triggers = message.Triggers.fromJson(jsondata);
            GameUI.showScriptTriggers(context, triggers);
            break;
          case 'usertriggers':
            final dynamic jsondata = json.decode(event.data);
            final triggers = message.Triggers.fromJson(jsondata);
            GameUI.showUserTriggers(context, triggers);
            break;
          case 'scriptaliases':
            final dynamic jsondata = json.decode(event.data);
            final aliases = message.Aliases.fromJson(jsondata);
            GameUI.showScriptAliases(context, aliases);
            break;
          case 'useraliases':
            final dynamic jsondata = json.decode(event.data);
            final aliases = message.Aliases.fromJson(jsondata);
            GameUI.showUserAliases(context, aliases);
            break;
          case 'scripttimers':
            final dynamic jsondata = json.decode(event.data);
            final timers = message.Timers.fromJson(jsondata);
            GameUI.showScriptTimers(context, timers);
            break;
          case 'usertimers':
            final dynamic jsondata = json.decode(event.data);
            final timers = message.Timers.fromJson(jsondata);
            GameUI.showUserTimers(context, timers);
            break;
        }
      }
    });
  }

  @override
  void initState() {
    listen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var server = appState.currentServer!;
    var focusNode = FocusNode(
      onKey: (node, event) {
        if (event is RawKeyDownEvent && event.repeat == false) {
          return game.onKey(event);
        }
        return KeyEventResult.ignored;
      },
    );

    return RawKeyboardListener(
        key: _refreshKey,
        focusNode: focusNode,
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  AppUI.showMsgBox(
                      context,
                      "快捷键帮助",
                      "在游戏主界面可以使用如下快捷键",
                      const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("单击:显示历史输出"),
                            Text("双击:调用助手按纽"),
                            Text("上划:进入游戏一览"),
                            Text("下划:快速进入游戏"),
                            Text("ctrl+数字快速进入游戏"),
                            Text("ctrl+k 连接当前游戏"),
                            Text("ctrl+shfit+k 断开前游戏"),
                          ]));
                },
                tooltip: '快捷键帮助',
                icon: const Icon(Icons.help_outline),
              )
            ], // This trailing comma makes auto-formatting nicer for build methods.

            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(server.name.isEmpty ? server.host : server.name),
          ),
          body: Fullscreen(
            minWidth:
                currentAppState.renderSettings.forceDesktopMode ? 1200 : 640,
            child: const Display(),
          ),
        ));
  }
}
