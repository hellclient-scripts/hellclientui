import 'package:flutter/material.dart';
import 'package:hellclientui/workers/game.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../states/appstate.dart';

class Hud extends StatefulWidget {
  const Hud({super.key});
  @override
  State<Hud> createState() => HudState();
}

class HudState extends State<Hud> {
  HudState();
  late StreamSubscription subCommand;

  @override
  void initState() {
    subCommand = currentGame!.hudUpdateStream.stream.listen((event) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    subCommand.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    if (currentGame!.hudContent.isEmpty) {
      return const Center();
    }
    return Positioned(
        height: appState.renderSettings.lineheight *
                currentGame!.hudContent.length +
            2,
        top: 0,
        left: 0,
        right: 0,
        child: Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
            color: const Color(0xff666666),
            child: Container(
                color: appState.renderSettings.hudbackground,
                child: LayoutBuilder(builder: (context, constraints) {
                  var viewwidth = constraints.maxWidth;

                  Widget output = Transform.scale(
                      scale: 1 / appState.devicePixelRatio,
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                          onTapUp: (details) {
                            var xpostion = (details.localPosition.dx) /
                                (appState.renderSettings.linewidth *
                                    appState.devicePixelRatio);
                            var ypostion = (details.localPosition.dy) /
                                (currentGame!.hudContent.length *
                                    appState.renderSettings.lineheight *
                                    appState.devicePixelRatio);
                            if (0 < xpostion &&
                                xpostion < 1 &&
                                0 < ypostion &&
                                ypostion < 1) {
                              currentGame!.handleCmd(
                                  'hudclick', {'X': xpostion, 'Y': ypostion});
                            }
                          },
                          child: AbsorbPointer(
                              child: CustomPaint(
                            size: Size(
                                appState.renderSettings.linewidth *
                                    appState.devicePixelRatio,
                                currentGame!.hudContent.length *
                                    appState.renderSettings.lineheight *
                                    appState.devicePixelRatio),
                            painter: currentGame!.hud,
                          ))));
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
}
