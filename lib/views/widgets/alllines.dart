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

final _dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

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

class SearchData {
  SearchData();
  String text = "";
  int current = 0;
  int found = 0;
  bool scrollCurrent = false;
}

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget(
      {super.key, required this.data, required this.doSearch});
  final SearchData data;
  final Function doSearch;
  @override
  State<StatefulWidget> createState() => SearchBarWidgettState();
}

class SearchBarWidgettState extends State<SearchBarWidget> {
  final focusNode = FocusNode();
  final search = TextEditingController();
  void _onSearch(String value) {
    focusNode.requestFocus();
    search.selection =
        TextSelection(baseOffset: 0, extentOffset: search.value.text.length);
    widget.data.text = value;
    widget.data.current = 1;
    widget.data.scrollCurrent = true;
    widget.doSearch();
    setState(() {});
  }

  void searchNext() {
    if (widget.data.text.isNotEmpty && widget.data.found > 0) {
      setState(() {
        widget.data.current++;
        widget.data.scrollCurrent = true;
        if (widget.data.current > widget.data.found) {
          widget.data.current = 1;
          widget.data.scrollCurrent = true;
        }
        widget.doSearch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: TextFormField(
        controller: search,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (value) {
          if (widget.data.text != value) {
            _onSearch(value);
          } else {
            focusNode.requestFocus();
            searchNext();
          }
        },
        decoration: InputDecoration(
          label:
              Text(widget.data.text.isEmpty ? "搜索" : "搜索 ${widget.data.text}"),
        ),
      )),
      widget.data.text.isEmpty
          ? const Center()
          : Text(
              '${widget.data.found == 0 ? 0 : widget.data.current} / ${widget.data.found}'),
      IconButton(
          onPressed: () {
            if (widget.data.text.isNotEmpty && widget.data.found > 0) {
              setState(() {
                widget.data.current--;
                widget.data.scrollCurrent = true;
                if (widget.data.current < 1) {
                  widget.data.current = widget.data.found;
                }
                widget.doSearch();
              });
            }
          },
          tooltip: '上一个',
          icon: const Icon(Icons.arrow_drop_up)),
      IconButton(
          onPressed: searchNext,
          tooltip: '下一个',
          icon: const Icon(Icons.arrow_drop_down)),
      IconButton(
          onPressed: () {
            search.text = "";
            _onSearch("");
          },
          tooltip: '清除',
          icon: const Icon(Icons.delete)),
    ]);
  }
}

class LineWidget extends StatefulWidget {
  const LineWidget({super.key, required this.line, required this.searchData});
  final Line line;
  final SearchData searchData;
  @override
  State<LineWidget> createState() => LineWidgetState();
}

class LineWidgetState extends State<LineWidget> {
  bool matched = false;
  late String plain;
  String lastSearch = "";
  int currentFound = 0;
  List<Match> allmatched = [];
  void cleanSearch() {
    setState(() {
      lastSearch = "";
      matched = false;
      allmatched = [];
      currentFound = 0;
    });
  }

  void setSearch(List<Match> allmatched) {
    setState(() {
      matched = true;
      lastSearch = widget.searchData.text;
      currentFound = widget.searchData.found;
      this.allmatched = allmatched;
    });
  }

  @override
  Widget build(BuildContext context) {
    final renderer = currentGame!.output.renderer;
    bool isCurrentLine = false;
    GlobalKey? currentkey;
    List<InlineSpan> linedata = [];
    plain = widget.line.words.map((e) => e.text).join("");
    final linestyle = renderer.getLineStyle(widget.line);
    if (linestyle.icon.isNotEmpty) {
      final iconstyle = renderer.getIconStyle(
          1, linestyle.iconcolor, currentAppState.renderSettings.background);
      linedata.add(WidgetSpan(
          child: SelectionContainer.disabled(
              child: Text(linestyle.icon, style: iconstyle))));
    }
    final List<Word> words =
        matched ? widget.line.splitWords() : widget.line.words;
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
              if (mindex + currentFound == widget.searchData.current - 1) {
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
    if (widget.line.triggers.isNotEmpty) {
      linedata.add(WidgetSpan(
          child: SelectionContainer.disabled(
              child: Text(renderer.renderSettings.triggersicon,
                  style: renderer.getIconStyle(
                      1,
                      renderer.renderSettings.triggersColor,
                      renderer.background)))));
    }
    linedata.add(const TextSpan(text: '\r'));
    String tooltip = _dateFormat
        .format(DateTime.fromMillisecondsSinceEpoch(widget.line.time * 1000));
    if (widget.line.triggers.isNotEmpty) {
      tooltip += '\nTriggers:\n';
      for (final trigger in widget.line.triggers) {
        tooltip += '$trigger\n';
      }
    }
    if (widget.searchData.current > 0 &&
        widget.searchData.scrollCurrent &&
        currentkey != null) {
      widget.searchData.scrollCurrent = false;
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

    return Row(children: [
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
    ]);
  }
}

class AllLines extends StatefulWidget {
  const AllLines({super.key});
  @override
  State<AllLines> createState() => AllLinesState();
}

class AllLinesState extends State<AllLines> {
  Lines? lines;
  late StreamSubscription subCommand;
  late List<InlineSpan> linedata = [];
  double beforescale = 1;
  async.Timer? _debounce;
  final ScrollController scrollController = ScrollController();
  final ScrollController scrollController2 = ScrollController();
  List<GlobalKey> lineKeys = [];
  final SearchData searchData = SearchData();
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

  void doSearch() {
    searchData.found = 0;
    for (final key in lineKeys) {
      if (key.currentContext != null && key.currentContext!.mounted) {
        final state = key.currentState as LineWidgetState;
        if (state.matched && searchData.text != state.lastSearch) {
          state.cleanSearch();
          continue;
        }
        if (searchData.text.isNotEmpty) {
          final matched = state.plain.contains(searchData.text);
          if (matched) {
            final allmatched = searchData.text.allMatches(state.plain).toList();
            state.setSearch(allmatched);
            searchData.found = searchData.found + allmatched.length;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((lines) == null) {
      return const Center(child: Text('Loading...'));
    }
    List<Widget> list = [];
    searchData.found = 0;
    final renderer = currentGame!.output.renderer;
    if (lines != null) {
      for (final line in lines!.lines) {
        final key = GlobalKey();
        final linewidget = LineWidget(
          key: key,
          line: line,
          searchData: searchData,
        );
        list.add(linewidget);
        lineKeys.add(key);
      }
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
        SearchBarWidget(
          data: searchData,
          doSearch: () {
            doSearch();
          },
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
                      notificationPredicate: (notification) =>
                          notification.depth == 1,
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
                                          width: renderer
                                                  .renderSettings.linewidth *
                                              currentGame!.getAlllinesScale(),
                                          child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              alignment: Alignment.bottomLeft,
                                              child: material.Column(
                                                children: list,
                                              ))))))));
                }))))
      ],
    );
  }
}
