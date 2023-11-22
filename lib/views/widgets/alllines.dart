import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;

import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/workers/game.dart';
import '../../models/message.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

class AllLines extends StatefulWidget {
  const AllLines({super.key});
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
        List<Widget> children = [];

        linedata.add(const TextSpan(text: '\r'));
        children.add(SizedBox(
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
                ))));

        list.add(Flex(direction: Axis.horizontal, children: children));
      }
    }

    final ScrollController scrollController = ScrollController();
    final ScrollController scrollController2 = ScrollController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 72,
          child: Text('历史输出'),
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
