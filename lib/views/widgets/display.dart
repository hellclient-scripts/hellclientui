import 'package:flutter/material.dart';
import 'package:hellclientui/models/message.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/views/widgets/appui.dart';
import 'package:provider/provider.dart';
import '../../workers/renderer.dart';
import '../../workers/game.dart';
import 'datagridview.dart';
import 'package:web_socket_channel/io.dart';
import 'alllines.dart';
import 'gametop.dart';
import 'overview.dart';
import 'hud.dart';
import 'userinput.dart';
import 'bottom.dart';
import 'dart:async';
import 'dart:convert';

Future<bool?> showConnectError(BuildContext context, String message) async {
  return showDialog<bool>(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return AlertDialog(
        title: const Text("连接失败"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("离开"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

Future<bool?> showDisconneted(BuildContext context) async {
  return showDialog<bool>(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return NonFullScreenDialog(
          title: '连接断开',
          summary: '你与程序被断开了，可能是通过别的页面打开/程序发生错误/程序死机，需要重连才能继续操作。',
          child: ConfirmOrCancelWidget(
            labelCancel: '退出',
            onCancal: () {
              if (context.mounted) {
                Navigator.of(context).pop(false);
              }
            },
            labelConfirm: '重新连接',
            onConfirm: () {
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ));
    },
  );
}

class Display extends StatefulWidget {
  const Display({super.key});

  @override
  State<Display> createState() => DisplayState();
}

class DisplayState extends State<Display> {
  DisplayState();
  IOWebSocketChannel? channel;
  final repaint = Repaint();
  late StreamSubscription subCommand;
  @override
  void dispose() {
    subCommand.cancel();
    super.dispose();
  }

  bool gridDisplayed = false;
  showGrid(BuildContext context, UserInput input) async {
    currentGame!.updateDatagrid(input);
    if (!gridDisplayed) {
      gridDisplayed = true;
      await showDialog(
          useRootNavigator: false,
          context: currentGame!.navigatorKey.currentState!.context,
          builder: (context) {
            return const DatagridView();
          });
      gridDisplayed = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration time) {
      if (mounted) {
        currentGame!.onPostFrame(time);
      }
    });

    subCommand = currentGame!.commandStream.stream.listen((event) async {
      if (event is GameCommand) {
        switch (event.command) {
          case "current":
            AppUI.hideUI(context);
            setState(() {});
            break;
          case "scriptMessage":
            final input = UserInput.fromJson(jsonDecode(event.data));
            if (context.mounted) {
              switch (input.name) {
                case "userinput.popup":
                  UserInputHelper.popup(context, input);
                  break;
                case "userinput.list":
                  UserInputHelper.list(context, input);
                  break;
                case "userinput.prompt":
                  UserInputHelper.prompt(context, input);
                  break;
                case "userinput.alert":
                  UserInputHelper.alert(context, input);
                  break;
                case "userinput.confirm":
                  UserInputHelper.confirm(context, input);
                  break;
                case "userinput.visualprompt":
                  UserInputHelper.visualPrompt(context, input);
                  break;
                case "userinput.note":
                  UserInputHelper.note(context, input);
                  break;
                case "hideall":
                  AppUI.hideUI(context);
                  break;
                case "userinput.datagrid":
                  showGrid(context, input);
                  break;
                case "userinput.hidedatagrid":
                case "userinput.hideall":
                  AppUI.hideUI(context);
                  break;
              }
            }
        }
      }
    });
  }

  void showErrorMessage(String msg) {
    var snackBar = SnackBar(
      content: Text(msg),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildOutput(BuildContext context) {
    var appState = context.watch<AppState>();
    return Positioned(
        height: appState.renderSettings.height,
        bottom: currentAppState.renderSettings.getDisplay().height +
            currentAppState.renderSettings.lineheight,
        left: 0,
        right: 0,
        child: GestureDetector(onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy < -40) {
            currentGame!.handleCmd("change", "");
          } else if (details.velocity.pixelsPerSecond.dy > 40) {
            currentGame!.clientQuick();
          }
        }, onTap: () {
          currentGame!.updateAlllines(null);
          currentGame!.handleCmd("allLines", null);
          showAllLines(context);
        }, onDoubleTap: () {
          currentGame!.handleCmd("assist", currentGame!.current);
        }, child:
            AbsorbPointer(child: LayoutBuilder(builder: (context, constraints) {
          var viewwidth = constraints.maxWidth;

          Widget output = Transform.scale(
              scale: 1 / appState.devicePixelRatio,
              alignment: Alignment.topLeft,
              child: CustomPaint(
                size: Size(
                    appState.renderSettings.linewidth *
                        appState.devicePixelRatio,
                    appState.renderSettings.height * appState.devicePixelRatio),
                painter: currentGame?.output,
              ));
          if (viewwidth <
              appState.renderSettings.minChars *
                  appState.renderSettings.fontSize) {
            output = FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: appState.renderSettings.minChars *
                        appState.renderSettings.fontSize,
                  ),
                  child: output,
                ));
          }
          return output;
        }))));
  }

  Widget buildPrompt(BuildContext context) {
    var appState = context.watch<AppState>();
    return Positioned(
        left: 0,
        right: 0,
        bottom: currentAppState.renderSettings.getDisplay().height,
        child: LayoutBuilder(builder: (context, constraints) {
          var viewwidth = constraints.maxWidth;
          Widget output = Transform.scale(
              scale: 1 / appState.devicePixelRatio,
              alignment: Alignment.topLeft,
              child: CustomPaint(
                size: Size(
                    appState.renderSettings.linewidth *
                        appState.devicePixelRatio,
                    appState.renderSettings.lineheight *
                        appState.devicePixelRatio),
                painter: currentGame!.prompt,
              ));
          if (viewwidth <
              appState.renderSettings.minChars *
                  appState.renderSettings.fontSize) {
            output = FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: appState.renderSettings.minChars *
                        appState.renderSettings.fontSize,
                  ),
                  child: output,
                ));
          }
          return SizedBox(
              height: appState.renderSettings.lineheight, child: output);
        }));
  }

  @override
  build(BuildContext context) {
    var appState = context.watch<AppState>();
    final List<Widget> children = [
      const GameTop(),
    ];
    if (currentGame!.current.isNotEmpty) {
      children.add(
        Expanded(
            child: Stack(children: [
          buildOutput(context),
          const Hud(),
          buildPrompt(context),
          const DisplayBottom(),
        ])),
      );
      // children.add(buildPrompt(context));
      // children.add(const DisplayBottom());
    } else {
      if (currentGame?.current == "") {
        children.add(const Expanded(child: Overview()));
      }
    }
    Widget body = Container(
        decoration: BoxDecoration(color: appState.renderSettings.background),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children));

    return body;
  }
}
