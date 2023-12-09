import 'package:flutter/material.dart';
import 'package:flutter_boring_avatars/flutter_boring_avatars.dart';
import 'package:hellclientui/states/appstate.dart';
import '../../workers/game.dart';
import '../../models/message.dart';
import 'dart:async';

class Overview extends StatefulWidget {
  const Overview({super.key});
  @override
  State<Overview> createState() => OverviewState();
}

const List<Color> avatarColors = [
  Color(0xff92A1C6),
  Color(0xff146A7C),
  Color(0xfff0AB3D),
  Color(0xffC271B4),
  Color(0xffC20D90)
];
const labelStyle = TextStyle(
  fontFamily: 'monospace',
  color: Colors.white,
  fontSize: 16,
  height: 1.3,
);
const indexStyle = TextStyle(
  fontFamily: 'monospace',
  color: Color(0xff333333),
  fontSize: 13,
  height: 20 / 13,
  textBaseline: TextBaseline.alphabetic,
);
const idStyle = TextStyle(
  fontFamily: 'monospace',
  color: Color(0xff333333),
  fontSize: 18,
  fontWeight: FontWeight.bold,
  height: 20 / 18,
  textBaseline: TextBaseline.alphabetic,
);
const scriptStyle = TextStyle(
  fontFamily: 'monospace',
  color: Color.fromARGB(255, 95, 156, 160),
  fontSize: 13,
  fontStyle: FontStyle.italic,
  height: 20 / 13,
  textBaseline: TextBaseline.alphabetic,
);
const tagStyle = TextStyle(
  fontFamily: 'monospace',
  color: Color(0xff333333),
  fontSize: 13,
  height: 20 / 13,
  textBaseline: TextBaseline.alphabetic,
);

class OverviewState extends State<Overview> {
  late StreamSubscription subClients;
  @override
  void initState() {
    super.initState();
    subClients = currentGame!.clientsUpdateStream.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    subClients.cancel();
    super.dispose();
  }

  Widget buildTooltip(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4))),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: const Text(
            "按数字键进入游戏。按Ctrl+`或ScrollLock快速进入游戏。按Ctrl+Esc或 Pause返回本页。"));
  }

  Widget buildSummary(BuildContext context, ClientInfo info) {
    if (info.summary.isEmpty) {
      return const Center();
    }
    final List<Widget> list = [];
    final renderer = currentGame!.output.renderer;
    var summary = info.summary;
    if (summary.length > 2) {
      summary = summary.sublist(0, 2);
    }
    for (final line in summary) {
      List<InlineSpan> linedata = [];
      for (final word in line.words) {
        final style = renderer.getWordStyle(
            word,
            currentAppState.renderSettings.color,
            currentAppState.renderSettings.background);
        linedata.add(TextSpan(
            text: word.text,
            style: style.toTextStyle(currentAppState.renderSettings)));
      }
      List<Widget> children = [];
      linedata.add(const TextSpan(text: '\r'));
      children.add(
          Text.rich(overflow: TextOverflow.clip, TextSpan(children: linedata)));

      list.add(SizedBox(
          width: 364,
          child: Flex(direction: Axis.horizontal, children: children)));
    }
    return Container(
        color: currentAppState.renderSettings.background,
        margin: const EdgeInsets.fromLTRB(0, 2, 0, 2),
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        ));
  }

  Widget buildGame(BuildContext context, ClientInfo info, int index) {
    late String tag;
    switch (info.priority) {
      case 2:
        tag = '紧急';
        break;
      case 1:
        tag = '故障';
        break;
      default:
        tag = '普通';
    }
    return Row(children: [
      SizedBox(
          width: 64,
          height: 64,
          child: AnimatedBoringAvatars(
            duration: Duration.zero,
            name: info.id,
            type: BoringAvatarsType.beam,
            colors: avatarColors,
          )),
      Column(children: [
        SizedBox(
            height: 20,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(
                  width: 310,
                  child: Text.rich(
                      overflow: TextOverflow.clip,
                      TextSpan(children: [
                        WidgetSpan(
                            baseline: TextBaseline.alphabetic,
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                child:
                                    Text(index.toString(), style: indexStyle))),
                        WidgetSpan(
                            baseline: TextBaseline.alphabetic,
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                child: Text(info.id, style: idStyle))),
                        WidgetSpan(
                            baseline: TextBaseline.alphabetic,
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                child: Text('[${info.scriptID}]',
                                    style: scriptStyle))),
                      ]))),
              SizedBox(
                width: 66,
                child: Text.rich(
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.clip,
                    TextSpan(children: [
                      WidgetSpan(
                          baseline: TextBaseline.alphabetic,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                              child: Text(tag, style: tagStyle))),
                      WidgetSpan(
                          baseline: TextBaseline.alphabetic,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                              child: Text(info.running ? "在线" : "离线",
                                  style: tagStyle))),
                    ])),
              )
            ])),
        buildSummary(context, info),
      ])
    ]);
  }

  Widget buildButton(BuildContext context, Color bgcolor, Widget child,
      void Function() onTap, double opacity, bool large) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Opacity(
            opacity: opacity,
            child: SizedBox(
                width: 600,
                height: large ? 136 : 91,
                child: GestureDetector(
                    onTap: onTap,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: EdgeInsets.all(large ? 20 : 10),
                        color: bgcolor,
                        child: SizedBox(
                          width: 440,
                          height: 66,
                          child: child,
                        ),
                      ),
                    )))));
  }

  Widget buildButtons(BuildContext context, bool large) {
    List<Widget> buttons = [];
    buttons.add(buildButton(
        context,
        const Color(0xffe6a23c),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                size: 30,
                Icons.lightbulb,
                color: Colors.white,
              )),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: const Text('快速开始', style: labelStyle)),
        ]), () {
      currentGame!.clientQuick();
    }, 1, large));
    List<ClientInfo> infos = currentGame!.clientinfos.clientInfos;
    int index = 0;
    for (final info in infos) {
      late Color bgcolor;
      switch (info.priority) {
        case 1:
          bgcolor = const Color(0xffffdba5);
          break;
        case 2:
          bgcolor = const Color(0xfffbc4c4);
        default:
          bgcolor = Colors.white;
      }
      final button = buildButton(
          context, bgcolor, buildGame(context, info, index + 1), () {
        currentGame!.handleCmd("change", info.id);
      }, info.running ? 1 : 0.7, large);
      final buttonIndex = index;
      buttons.add(DragTarget<int>(
        builder: (context, candidateData, rejectedData) {
          return Draggable<int>(
            data: buttonIndex,
            dragAnchorStrategy: (draggable, context, position) {
              return const Offset(32, 32);
            },
            feedback: SizedBox(
                width: 64,
                height: 64,
                child: AnimatedBoringAvatars(
                  duration: Duration.zero,
                  name: info.id,
                  type: BoringAvatarsType.beam,
                  colors: avatarColors,
                )),
            child: button,
          );
        },
        onAccept: (data) {
          if (data >= 0 && data < currentGame!.clientinfos.clientInfos.length) {
            final info = currentGame!.clientinfos.clientInfos[data];
            currentGame!.clientinfos.clientInfos[data] =
                currentGame!.clientinfos.clientInfos[buttonIndex];
            currentGame!.clientinfos.clientInfos[buttonIndex] = info;
            final List<String> idlist =
                currentGame!.clientinfos.clientInfos.map((e) => e.id).toList();
            currentGame!.handleCmd('sortclients', idlist);
          }
        },
      ));
      index++;
    }
    buttons.add(buildButton(
        context,
        const Color(0xff409EFF),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(
              width: 30,
              height: 30,
              child: Icon(
                size: 30,
                Icons.lightbulb,
                color: Colors.white,
              )),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              child: const Text('打开游戏', style: labelStyle)),
        ]), () {
      currentGame!.openGames();
    }, 1, large));
    final scrollController = ScrollController();
    return Expanded(
        child: RawScrollbar(
            controller: scrollController,
            thumbColor: Colors.white,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                        controller: scrollController,
                        child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            direction: Axis.horizontal,
                            children: buttons))))));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onVerticalDragEnd: (details) {
      if (details.velocity.pixelsPerSecond.dy > 40) {
        currentGame!.clientQuick();
      }
    }, child: LayoutBuilder(builder: (context, constraints) {
      final List<Widget> children = [];
      final large = constraints.maxWidth >= 1121;
      if (large) {
        children.add(buildTooltip(context));
      }
      children.add(buildButtons(context, large));
      Widget body = Container(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            children: children,
          ));
      return body;
    }));
  }
}
