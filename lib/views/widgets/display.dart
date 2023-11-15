import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:hellclientui/states/appstate.dart';
import 'package:provider/provider.dart';
import '../../models/server.dart';
import '../../models/rendersettings.dart';
import '../../workers/renderer.dart';
import '../../workers/game.dart';
import 'package:web_socket_channel/io.dart';

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
  late Server server;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration time) {
      game.onPostFrame(time);
    });
    super.initState();
  }

  void connect() async {
    try {
      await game.connect((String msg) {
        showErrorMessage(msg);
      });
    } catch (e) {
      showErrorMessage(e.toString());
    }
  }

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
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    renderSettings = appState.renderSettings;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    game =
        Game.create(appState.currentServer!, renderSettings, devicePixelRatio);
    // renderer.init();
    var focusNode = FocusNode();
    var inputController = TextEditingController();
    connect();
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
                SizedBox(
                  width: 80,
                  child: Text("test"),
                ),
                Expanded(
                    child: TextField(
                  controller: inputController,
                  focusNode: focusNode,
                  autofocus: true,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: renderSettings.fontSize,
                      height:
                          renderSettings.lineheight / renderSettings.fontSize),
                  decoration: (InputDecoration(
                    hintText: "输入指令",
                    border: OutlineInputBorder(),
                  )),
                  onSubmitted: (value) {
                    game.handleSend(value);
                    focusNode.requestFocus();
                    inputController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: inputController.value.text.length);
                  },
                )),
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
