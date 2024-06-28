import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';

import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/workers/game.dart';
import '../../models/message.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'appui.dart';
import 'dart:async' as async;
import '../../workers/renderer.dart' as rendererlib;

Future<bool?> showAllLines(BuildContext context) async {
  if (!context.mounted) {
    return false;
  }
  return showDialog<bool>(
      useRootNavigator: false,
      context: currentGame!.navigatorKey.currentState!.context,
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
  final search = TextEditingController();
  late List<InlineSpan> linedata = [];
  int current = 0;
  int found = 0;
  bool scrollCurrent = false;
  double beforescale = 1;
  async.Timer? _debounce;
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollController2 = ScrollController();

  void _onSearchChange(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = async.Timer(const Duration(milliseconds: 2000), () {
      _onSearch(value);
    });
  }

  void _onSearch(String value) {
    setState(() {
      current = 1;
      scrollCurrent = true;
    });
  }

  @override
  void initState() {
    lines = currentGame!.alllines;
    subCommand = currentGame!.dataUpdateStream.stream.listen((event) {
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
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((lines) == null) {
      return const Center(child: Text('Loading...'));
    }
    List<Widget> list = [];
    found = 0;
    GlobalKey? currentkey;
    final renderer = currentGame!.output.renderer;
    if (lines != null) {
      for (final line in lines!.lines) {
        bool isCurrentLine = false;
        List<InlineSpan> linedata = [];
        var plain = line.words.map((e) => e.text).join("");
        final linestyle = renderer.getLineStyle(line);
        if (linestyle.icon.isNotEmpty) {
          final iconstyle = renderer.getIconStyle(1, linestyle.iconcolor,
              currentAppState.renderSettings.background);
          linedata.add(WidgetSpan(
              child: SelectionContainer.disabled(
                  child: Text(linestyle.icon, style: iconstyle))));
        }
        final matched = search.text.isNotEmpty && plain.contains(search.text);
        final List<Word> words = matched ? line.splitWords() : line.words;
        final allmatched = search.text.allMatches(plain).toList();
        var index = 0;
        for (final word in words) {
          var text = word.text;
          late rendererlib.RenderStyle style;
          Color? forceColor;
          Color? forceBackground;
          if (word.text == "\n") {
            linedata.add(TextSpan(text: word.text));
          } else {
            if (matched) {
              for (final (mindex, m) in allmatched.indexed) {
                if ((index >= m.start) && (index + text.length <= m.end)) {
                  forceColor = currentAppState.renderSettings.searchForceground;
                  if (mindex + found == current - 1) {
                    forceBackground =
                        currentAppState.renderSettings.searchCurrentBackground;
                    if (index == m.start) {
                      isCurrentLine = true;
                    }
                  } else {
                    forceBackground =
                        currentAppState.renderSettings.searchBackground;
                  }
                }
              }
            }
            style = renderer
                .getWordStyle(word, linestyle.color,
                    currentAppState.renderSettings.background)
                .toRenderStyle(
                  currentAppState.renderSettings,
                  forceColor: forceColor,
                  forceBackground: forceBackground,
                );
            if (isCurrentLine) {
              currentkey = GlobalKey();
            }
            linedata.add(WidgetSpan(
                child: Container(
                    key: isCurrentLine ? currentkey : null,
                    color: style.backgroundColor,
                    child: Text(text, style: style.textStyle))));
            isCurrentLine = false;
          }
          index += text.length;
        }
        found = found + allmatched.length;
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
        children.add(Row(children: [
          Tooltip(
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
                              title: const Text('双击复制成功'),
                              type: ToastificationType.success,
                              style: ToastificationStyle.flat,
                              showProgressBar: false,
                              description: Text('文字“$summary”已经复制到剪贴板。'));
                        }
                      },
                      child: Text.rich(
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        TextSpan(children: linedata),
                        softWrap: true,
                      ))))
        ]));

        list.add(Flex(direction: Axis.horizontal, children: children));
      }
    }
    if (current > 0 && scrollCurrent && currentkey != null) {
      scrollCurrent = false;
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          if (currentkey!.currentContext != null &&
              currentkey.currentContext!.mounted) {
            Scrollable.ensureVisible(
              currentkey.currentContext!,
              alignment: 0.5,
            );
          }
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  H2('历史输出'),
                  Text(
                    '双击复制行',
                    style: textStyleHint,
                  )
                ],
              ),
            ),
            const Expanded(child: Center()),
            IconButton(
              onPressed: () {
                currentGame!.alllinesZoomOut();
                setState(() {});
              },
              icon: const Icon(Icons.zoom_out_outlined),
              iconSize: 20,
            ),
            Text(
                '${(currentGame!.getAlllinesScale() * 100).floor().toString()}%'),
            IconButton(
                onPressed: () {
                  currentGame!.alllinesZoomIn();
                  setState(() {});
                },
                icon: const Icon(Icons.zoom_in_outlined),
                iconSize: 16),
          ],
        ),
        Row(children: [
          Expanded(
              child: TextFormField(
            controller: search,
            onChanged: (value) {
              _onSearchChange(value);
            },
            decoration: const InputDecoration(
              label: Text("搜索"),
            ),
          )),
          search.text.isEmpty
              ? const Center()
              : Text('${found == 0 ? 0 : current} / $found'),
          IconButton(
              onPressed: () {
                if (search.text.isNotEmpty && found > 0) {
                  setState(() {
                    current--;
                    scrollCurrent = true;
                    if (current < 1) {
                      current = found;
                    }
                  });
                }
              },
              tooltip: '上一个',
              icon: const Icon(Icons.arrow_drop_up)),
          IconButton(
              onPressed: () {
                if (search.text.isNotEmpty && found > 0) {
                  setState(() {
                    current++;
                    scrollCurrent = true;
                    if (current > found) {
                      current = 1;
                      scrollCurrent = true;
                    }
                  });
                }
              },
              tooltip: '下一个',
              icon: const Icon(Icons.arrow_drop_down))
        ]),
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
                                          child: Transform.scale(
                                              scale: currentGame!
                                                  .getAlllinesScale(),
                                              alignment: Alignment.bottomLeft,
                                              child: material.Column(
                                                children: list,
                                              ))))))));
                }))))
      ],
    );
  }
}
