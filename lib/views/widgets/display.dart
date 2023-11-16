import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../../models/rendersettings.dart';
import '../../workers/renderer.dart';
import '../../workers/game.dart';
import 'package:web_socket_channel/io.dart';

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
  late RenderSettings renderSettings;
  IOWebSocketChannel? channel;
  final repaint = Repaint();
  late Game game;
  late void Function() disconnectedListener;

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    game.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration time) {
      game.onPostFrame(time);
    });
  }

  // void connect(BuildContext context) async {
  //   var nav = Navigator.of(context);
  //   var appState = context.watch<AppState>();

  //   try {
  //     await game.connect(appState, (String msg) async {
  //       await showConnectError(context, msg);
  //       nav.pop(true);
  //     });
  //   } catch (e) {
  //     await showConnectError(context, e.toString());
  //     nav.pop(true);
  //   }
  // }

  void showErrorMessage(String msg) {
    var snackBar = SnackBar(
      content: Text(msg),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget buildOutput(BuildContext context, double devicePixelRatio, Game game) {
    var appState = context.watch<AppState>();
    var renderSettings = appState.renderSettings;

    return Positioned(
        height: appState.renderSettings.height,
        bottom: 0,
        left: 0,
        right: 0,
        child: LayoutBuilder(builder: (context, constraints) {
          var viewwidth = constraints.maxWidth;

          Widget output = Transform.scale(
              scale: 1 / devicePixelRatio,
              alignment: Alignment.bottomLeft,
              child: CustomPaint(
                size: Size(appState.renderSettings.linewidth * devicePixelRatio,
                    appState.renderSettings.height * devicePixelRatio),
                painter: game.output,
              ));
          if (viewwidth <
              appState.renderSettings.minChars * renderSettings.fontSize) {
            output = FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomLeft,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: appState.renderSettings.minChars *
                        renderSettings.fontSize,
                  ),
                  child: output,
                ));
          }
          return output;
        }));
  }

  @override
  build(BuildContext context) {
    var appState = context.watch<AppState>();
    renderSettings = appState.renderSettings;
    var nav = Navigator.of(context);
    double devicePixelRatio =
        renderSettings.hidpi ? MediaQuery.of(context).devicePixelRatio : 1.0;
    game = Game.create(appState, devicePixelRatio);
    game.eventDisconnected.addListener(() async {
      if (await showDisconneded(context) == true) {
        // connectGame();
      } else {
        nav.pop();
      }
    });
    var focusNode = FocusNode();
    var inputController = TextEditingController();
    return Container(
        decoration: BoxDecoration(color: appState.renderSettings.background),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Stack(children: [
            buildOutput(context, devicePixelRatio, game),
          ])),
          Container(
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
                            fontSize: renderSettings.fontSize,
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
                            game.handleSend(value);
                            focusNode.requestFocus();
                            inputController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset:
                                    inputController.value.text.length);
                          },
                        ))),
                SizedBox(
                  width: 80,
                  child: Text("test2"),
                ),
              ],
            ),
          )
        ]));
  }
}
