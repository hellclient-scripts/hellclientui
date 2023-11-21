import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../../workers/renderer.dart';
import '../../workers/game.dart';
import 'package:web_socket_channel/io.dart';
import 'alllines.dart';
import 'gametop.dart';
import 'overview.dart';
import 'hud.dart';
import 'dart:async';

Future<bool?> showAllLines(BuildContext context) async {
  if (!context.mounted) {
    return false;
  }
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return Material(
            type: MaterialType.transparency,
            child: Flex(direction: Axis.horizontal, children: [
              const Expanded(
                flex: 1,
                child: Center(),
              ),
              Expanded(
                  flex: 9,
                  child: Container(
                      height: double.infinity,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: const AllLines())),
            ]));
      });
}

Future<bool?> showConnectError(BuildContext context, String message) async {
  return showDialog<bool>(
    context: context,
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

Future<bool?> showDisconneded(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("连接断开"),
        content: const Text('你与程序被断开了，可能是通过别的页面打开/程序发生错误/程序死机，需要重连才能继续操作。'),
        actions: <Widget>[
          TextButton(
            child: const Text("退出"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("重新连接"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration time) {
      if (mounted) {
        currentGame!.onPostFrame(time);
      }
    });

    subCommand = currentGame!.commandStream.stream.listen((event) {
      if (event is GameCommand) {
        switch (event.command) {
          case "current":
            setState(() {});
            break;
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
        bottom: 0,
        left: 0,
        right: 0,
        child: GestureDetector(onTap: () {
          currentGame!.handleCmd("allLines", null);
          showAllLines(context);
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
    return LayoutBuilder(builder: (context, constraints) {
      var viewwidth = constraints.maxWidth;
      Widget output = Transform.scale(
          scale: 1 / appState.devicePixelRatio,
          alignment: Alignment.topLeft,
          child: CustomPaint(
            size: Size(
                appState.renderSettings.linewidth * appState.devicePixelRatio,
                appState.renderSettings.lineheight * appState.devicePixelRatio),
            painter: currentGame!.prompt,
          ));
      if (viewwidth <
          appState.renderSettings.minChars * appState.renderSettings.fontSize) {
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
    });
  }

  Widget buildBottom(BuildContext context) {
    var inputController = TextEditingController();
    var focusNode = FocusNode();
    focusNode.requestFocus();
    return SizedBox(
      height: 30,
      child: material.Row(
        children: [
          const SizedBox(
            width: 80,
            child: Text("test"),
          ),
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: TextField(
                    controller: inputController,
                    textInputAction: TextInputAction.next,
                    focusNode: focusNode,
                    maxLines: 1,
                    autofocus: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: currentAppState.renderSettings.fontSize,
                    ),
                    decoration: (const InputDecoration(
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(8), // Added this
                        hintText: "输入指令",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          gapPadding: 0,
                        ))),
                    onSubmitted: (value) {
                      currentGame?.handleSend(value);
                      focusNode.requestFocus();
                      inputController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: inputController.value.text.length);
                    },
                  ))),
          const SizedBox(
            width: 80,
            child: Text("test2"),
          ),
        ],
      ),
    );
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
        ])),
      );
      children.add(buildPrompt(context));
      children.add(buildBottom(context));
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
