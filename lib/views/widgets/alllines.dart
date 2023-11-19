import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;

import 'package:flutter/rendering.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/workers/game.dart';
import 'package:hellclientui/workers/renderer.dart';
import 'package:path/path.dart';
import '../../models/message.dart';
import 'dart:async';
import 'dart:convert';

class AllLines extends StatefulWidget {
  @override
  State<AllLines> createState() => AllLinesState();
}

class AllLinesState extends State<AllLines> {
  Lines? lines;
  // initialized to FocusNode()
  final focusNode = FocusNode();
  late StreamSubscription subCommand;
  @override
  void initState() {
    super.initState();
    subCommand = currentGame!.commandStream.stream.listen((event) {
      if (event is GameCommand) {
        switch (event.command) {
          case 'allLines':
            final dynamic jsondata = json.decode(event.data);
            lines = Lines.fromJson(jsondata);
            setState(() {});
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    subCommand.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    final renderer = currentGame!.output.renderer;
    if (lines != null) {
      for (final line in lines!.lines) {
        List<InlineSpan> linedata = [];
        final linestyle = renderer.getLineStyle(line);

        for (final word in line.words) {
          final style = renderer.getWordStyle(
              word, linestyle.color, currentAppState.renderSettings.background);
          linedata.add(TextSpan(
              text: word.text,
              style: style.toTextStyle(currentAppState.renderSettings, 1)));
        }
        List<Widget> children = [];
        if (linestyle.icon.isNotEmpty) {
          final iconstyle = renderer.getIconStyle(1, linestyle.iconcolor,
              currentAppState.renderSettings.background);
          children.add(SelectionContainer.disabled(
              child: Text(linestyle.icon, style: iconstyle)));
        }
        linedata.add(TextSpan(text: '\r'));
        children.add(Text.rich(TextSpan(children: linedata)));

        list.add(Flex(direction: Axis.horizontal, children: children));
      }
    }

    final ScrollController _scrollController = ScrollController();
    final ScrollController _scrollController2 = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 72,
          child: (Text('历史输出')),
        ),
        Expanded(
            child: Container(
                decoration: BoxDecoration(
                    color: currentAppState.renderSettings.background),
                child: SelectionArea(child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return RawScrollbar(
                      thumbColor: Colors.white,
                      thumbVisibility: true,
                      controller: _scrollController2,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: RawScrollbar(
                          thumbColor: Colors.white,
                          thumbVisibility: true,
                          controller: _scrollController,
                          child: SizedBox(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              child: SingleChildScrollView(
                                  controller: _scrollController,
                                  reverse: true,
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _scrollController2,
                                      child: SizedBox(
                                          width:
                                              renderer.renderSettings.linewidth,
                                          child: material.Column(
                                            children: list,
                                          )))))));
                }))))
      ],
    );
  }
}
