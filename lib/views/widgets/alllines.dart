import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';

import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/workers/game.dart';
import '../../models/message.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'appui.dart';

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

class AllLines extends StatefulWidget {
  const AllLines({super.key});
  @override
  State<AllLines> createState() => AllLinesState();
}

final _dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

class AllLinesState extends State<AllLines> {
  Lines? lines;
  // initialized to FocusNode()
  final focusNode = FocusNode();
  late StreamSubscription subCommand;
  @override
  void initState() {
    lines = currentGame!.alllines;
    subCommand = currentGame!.alllinesUpdateStream.stream.listen((event) {
      if (event is Lines?) {
        lines = event;
        setState(() {});
      }
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
    if ((lines) == null) {
      return const Center(child: Text('Loading...'));
    }
    List<Widget> list = [];
    final renderer = currentGame!.output.renderer;
    if (lines != null) {
      for (final line in lines!.lines) {
        List<InlineSpan> linedata = [];
        var plain = "";
        final linestyle = renderer.getLineStyle(line);
        if (linestyle.icon.isNotEmpty) {
          final iconstyle = renderer.getIconStyle(1, linestyle.iconcolor,
              currentAppState.renderSettings.background);
          linedata.add(WidgetSpan(
              child: SelectionContainer.disabled(
                  child: Text(linestyle.icon, style: iconstyle))));
        }
        for (final word in line.words) {
          plain += word.text;
          final style = renderer.getWordStyle(
              word, linestyle.color, currentAppState.renderSettings.background);
          linedata.add(TextSpan(
              text: word.text,
              style: style.toTextStyle(currentAppState.renderSettings)));
        }
        if (line.triggers.isNotEmpty) {
          linedata.add(WidgetSpan(
              child: SelectionContainer.disabled(
                  child: Text(renderer.renderSettings.triggersicon,
                      style: renderer.getIconStyle(
                          1,
                          renderer.renderSettings.triggersColor,
                          renderer.background)))));
        }
        List<Widget> children = [];

        linedata.add(const TextSpan(text: '\r'));
        String tooltip = _dateFormat
            .format(DateTime.fromMillisecondsSinceEpoch(line.time * 1000));
        if (line.triggers.isNotEmpty) {
          tooltip += '\nTriggers:\n';
          for (final trigger in line.triggers) {
            tooltip += '$trigger\n';
          }
        }
        children.add(Tooltip(
            message: tooltip,
            child: SizedBox(
                width: renderer.renderSettings.width,
                child: GestureDetector(
                    onDoubleTap: () async {
                      String summary = plain.trimLeft();

                      if (summary.length > 8) {
                        summary = '${summary.substring(0, 8)}...';
                      }

                      await Clipboard.setData(ClipboardData(text: plain));
                      if (context.mounted) {
                        toastification.show(
                            context: context,
                            autoCloseDuration: const Duration(seconds: 3),
                            title: '双击复制成功',
                            type: ToastificationType.success,
                            style: ToastificationStyle.flat,
                            showProgressBar: false,
                            description: '文字“$summary”已经复制到剪贴板。');
                      }
                    },
                    child: Text.rich(
                      TextSpan(children: linedata),
                      softWrap: true,
                    )))));

        list.add(Flex(direction: Axis.horizontal, children: children));
      }
    }

    final ScrollController scrollController = ScrollController();
    final ScrollController scrollController2 = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [H1('历史输出'), Summary('双击复制一行文字')],
          ),
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
                      controller: scrollController2,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: RawScrollbar(
                          thumbColor: Colors.white,
                          thumbVisibility: true,
                          controller: scrollController,
                          child: SizedBox(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              child: SingleChildScrollView(
                                  controller: scrollController,
                                  reverse: true,
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: scrollController2,
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
