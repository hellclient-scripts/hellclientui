import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hellclientui/views/widgets/scriptinfolistview.dart';
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
import '../../forms/sendbatchcommandform.dart';

Future<void> showSendBatchCommand(
    BuildContext context, message.BatchCommandScripts scripts) async {
  await showDialog(
    useRootNavigator: false,
    context: gameengine.currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return DialogOverlay(
          child: FullScreenDialog(
              title: '批量发送',
              child: SendBatchCommandForm(scripts: scripts.scripts)));
    },
  );
}

Future<String?> showNotOpened(
    BuildContext context, message.NotOpened games) async {
  return showDialog<String>(
    useRootNavigator: false,
    context: gameengine.currentGame!.navigatorKey.currentState!.context,
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
    useRootNavigator: false,
    context: gameengine.currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return Dialog.fullscreen(
        child: ScriptInfoListView(list: list.list),
      );
    },
  );
}

class Game extends StatefulWidget {
  const Game({super.key, required this.game});
  @override
  State<Game> createState() => GameState();
  final gameengine.Game game;
}

class GameState extends State<Game> {
  late StreamSubscription disconnectSub;
  late StreamSubscription subCommand;
  late StreamSubscription subConnectError;
  var _refreshKey = UniqueKey();
  Future<void> reconnect(bool closeFirst) async {
    await cancel();
    widget.game.unbind();
    if (closeFirst) {
      await currentAppState.connecting.close();
    }
    widget.game.init();
    await widget.game.dial(listen);
    if (context.mounted) {
      AppUI.hideUI(context);
    }
    setState(() {
      _refreshKey = UniqueKey();
    });
  }

  @override
  void dispose() {
    cancel();
    currentAppState.inGame = false;
    widget.game.dispose();
    widget.game.close();

    super.dispose();
  }

  Future<void> cancel() async {
    await disconnectSub.cancel();
    await subCommand.cancel();
    await subConnectError.cancel();
  }

  Future<void> listen() async {
    subConnectError =
        widget.game.streamConnectError.stream.listen((data) async {
      if (data is Exception) {
        if (await showConnectError(context, data.toString()) == true) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    });
    disconnectSub = widget.game.disconnectStream.stream.listen((data) async {
      if (!mounted) {
        return;
      }
      if (widget.game.silenceQuit) {
        widget.game.silenceQuit = false;
        return;
      }
      if (currentAppState.navigatorKey.currentState != null) {
        final result = await showDisconneted(
            gameengine.currentGame!.navigatorKey.currentState!.context);
        if (result == true) {
          try {
            if (context.mounted) {
              AppUI.hideUI(context);
            }
            await (reconnect(false));
          } catch (e) {
            if (context.mounted) {
              showConnectError(
                  gameengine.currentGame!.navigatorKey.currentState!.context,
                  e.toString());
            }
          }
        } else if (result == false) {
          if (context.mounted) {
            var nav = Navigator.of(context);
            nav.pop();
          }
        }
      }
    });
    subCommand = widget.game.commandStream.stream.listen((event) async {
      if (event is gameengine.GameCommand) {
        switch (event.command) {
          case '_reconnect':
            reconnect(true);
            break;
          case '_quit':
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
            break;
          case 'notopened':
            final dynamic jsondata = json.decode(event.data);
            final notOpened = message.NotOpened.fromJson(jsondata);
            final id = await showNotOpened(context, notOpened);
            if (id != null) {
              widget.game.handleCmd('open', id);
            }
            break;
          case 'scriptinfoList':
            final dynamic jsondata = json.decode(event.data);
            final list = message.ScriptInfoList.fromJson(jsondata);
            final id = await showScriptInfoList(context, list);
            if (id != null) {
              widget.game
                  .handleCmd('usescript', <dynamic>[widget.game.current, id]);
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
            gameengine.currentGame!.paramsInfos = paramsinfo;
            gameengine.currentGame!.dataUpdateStream.add(paramsinfo);
            break;
          case 'requiredParams':
            final dynamic jsondata = json.decode(event.data);
            final requiredParams = message.RequiredParams.fromJson(jsondata);
            GameUI.showUpdateRequiredParams(context, requiredParams);
            break;
          case 'scripttriggers':
            final dynamic jsondata = json.decode(event.data);
            final triggers = message.Triggers.fromJson(jsondata);
            gameengine.currentGame!.triggers = triggers;
            gameengine.currentGame!.dataUpdateStream.add(triggers);
            break;
          case 'usertriggers':
            final dynamic jsondata = json.decode(event.data);
            final triggers = message.Triggers.fromJson(jsondata);
            gameengine.currentGame!.triggers = triggers;
            gameengine.currentGame!.dataUpdateStream.add(triggers);
            break;
          case 'scriptaliases':
            final dynamic jsondata = json.decode(event.data);
            final aliases = message.Aliases.fromJson(jsondata);
            gameengine.currentGame!.aliases = aliases;
            gameengine.currentGame!.dataUpdateStream.add(aliases);
            break;
          case 'useraliases':
            final dynamic jsondata = json.decode(event.data);
            final aliases = message.Aliases.fromJson(jsondata);
            gameengine.currentGame!.aliases = aliases;
            gameengine.currentGame!.dataUpdateStream.add(aliases);

            break;
          case 'scripttimers':
            final dynamic jsondata = json.decode(event.data);
            final timers = message.Timers.fromJson(jsondata);
            gameengine.currentGame!.timers = timers;
            gameengine.currentGame!.dataUpdateStream.add(timers);
            break;
          case 'usertimers':
            final dynamic jsondata = json.decode(event.data);
            final timers = message.Timers.fromJson(jsondata);
            gameengine.currentGame!.timers = timers;
            gameengine.currentGame!.dataUpdateStream.add(timers);
            break;
          case 'batchcommandscripts':
            final dynamic jsondata = json.decode(event.data);
            final scripts = message.BatchCommandScripts.fromJson(jsondata);
            showSendBatchCommand(context, scripts);
            break;
        }
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    currentAppState.inGame = true;
    widget.game.dial(listen);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var server = widget.game.server;
    return Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            return widget.game.onKey(event);
          }
          return KeyEventResult.ignored;
        },
        key: _refreshKey,
        focusNode: gameengine.currentGame!.focusNode,
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
            body: Navigator(
                key: widget.game.navigatorKey,
                initialRoute: '/',
                onGenerateRoute: (route) => MaterialPageRoute(
                      settings: route,
                      builder: (context) => Fullscreen(
                        minWidth:
                            currentAppState.renderSettings.forceDesktopMode
                                ? 1200
                                : 640,
                        child: currentAppState.connecting.connected
                            ? const Display()
                            : Container(
                                color:
                                    currentAppState.renderSettings.background,
                              ),
                      ),
                    ))));
  }
}
