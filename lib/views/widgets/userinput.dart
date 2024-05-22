import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hellclientui/views/widgets/outputlines.dart';

import 'package:toastification/toastification.dart';

import '../../models/message.dart';
import '../../workers/game.dart';
import 'appui.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../states/appstate.dart';

const textStyleUserInputNote = TextStyle(
  color: Colors.white,
  fontSize: 14,
  height: 20 / 14,
);

class UserInputHelper {
  static popup(BuildContext context, UserInput input) {
    final data = UserInputTitleIntroType.fromJson(input.data);
    ToastificationType? type;
    switch (data.type) {
      case 'success':
        type = ToastificationType.success;
        break;
      case 'error':
        type = ToastificationType.error;
        break;
      case 'warning':
        type = ToastificationType.warning;
        break;
      default:
        type = ToastificationType.info;
    }
    toastification.show(
        context: context,
        title: Text(data.title),
        type: type,
        autoCloseDuration: const Duration(seconds: 3),
        style: ToastificationStyle.flat,
        description: Text(data.intro),
        showProgressBar: false,
        callbacks: ToastificationCallbacks(
          onTap: (value) {
            currentGame!.handleUserInputCallback(input, -1, "ok");
          },
        ));
  }

  static list(BuildContext context, UserInput input) {
    final data = UserInputList.fromJson(input.data);
    showDialog<bool?>(
      useRootNavigator: false,
      context: currentGame!.navigatorKey.currentState!.context,
      builder: (context) {
        return DialogOverlay(
            child: FullScreenDialog(
          title: data.title,
          summary: data.intro,
          child: UserInputListWidget(
            input: input,
            list: data,
          ),
        ));
      },
    );
  }

  static prompt(BuildContext context, UserInput input) async {
    final data = UserInputTitleIntroValue.fromJson(input.data);
    final controller =
        TextEditingController.fromValue(TextEditingValue(text: data.value));
    final result = await showDialog<bool?>(
      useRootNavigator: false,
      context: currentGame!.navigatorKey.currentState!.context,
      builder: (context) {
        return NonFullScreenDialog(
          title: data.title,
          summary: data.intro,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              onSubmitted: (value) {
                currentGame!.handleUserInputCallback(input, 0, value);
                Navigator.pop(context, true);
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xffeeeeee),
              ),
              controller: controller,
              autofocus: true,
            ),
            ConfirmOrCancelWidget(
              onConfirm: () {
                currentGame!.handleUserInputCallback(input, 0, controller.text);
                Navigator.pop(context, true);
              },
              onCancal: () {
                Navigator.pop(context, null);
              },
            )
          ]),
        );
      },
    );
    if (result != true) {
      currentGame!.handleUserInputCallback(input, -1, '');
    }
  }

  static alert(BuildContext context, UserInput input) async {
    final data = UserInputTitleIntro.fromJson(input.data);
    final result = await showDialog<bool?>(
      useRootNavigator: false,
      context: currentGame!.navigatorKey.currentState!.context,
      builder: (context) {
        return NonFullScreenDialog(
            title: data.title,
            summary: data.intro,
            child: ConfirmOrCancelWidget(
              labelCancel: null,
              onConfirm: () {
                currentGame!.handleUserInputCallback(input, 0, '');
                Navigator.pop(context, true);
              },
              onCancal: () {},
            ));
      },
    );
    if (result != true) {
      currentGame!.handleUserInputCallback(input, -1, '');
    }
  }

  static confirm(BuildContext context, UserInput input) async {
    final data = UserInputTitleIntro.fromJson(input.data);
    final result = await showDialog<bool?>(
      useRootNavigator: false,
      context: currentGame!.navigatorKey.currentState!.context,
      builder: (context) {
        return NonFullScreenDialog(
            title: data.title,
            summary: data.intro,
            child: ConfirmOrCancelWidget(
              onConfirm: () {
                currentGame!.handleUserInputCallback(input, 0, '');
                Navigator.pop(context, true);
              },
              onCancal: () {
                Navigator.pop(context);
              },
            ));
      },
    );
    if (result != true) {
      currentGame!.handleUserInputCallback(input, -1, '');
    }
  }

  static visualPrompt(BuildContext context, UserInput input) async {
    final data = VisualPrompt.fromJson(input.data);
    final result = await showDialog<bool?>(
        useRootNavigator: false,
        context: currentGame!.navigatorKey.currentState!.context,
        builder: (context) {
          return UserInputVisualPromptWidget(input: input, visualPrompt: data);
        });
    if (result != true) {
      currentGame!.handleUserInputCallback(input, -1, '');
    }
  }

  static note(BuildContext context, UserInput input) async {
    final data = UserInputTitleBodyType.fromJson(input.data);
    final controller = ScrollController();
    late Widget body;
    switch (data.type) {
      case "md":
        body = Container(
            width: double.infinity,
            color: Colors.white,
            child: RawScrollbar(
                thumbColor: const Color(0xff333333),
                thumbVisibility: true,
                controller: controller,
                child: Markdown(
                    controller: controller,
                    selectable: true,
                    onTapLink: (text, href, title) {
                      currentGame!
                          .handleUserInputCallback(input, 0, href ?? "");
                    },
                    data: data.body)));
        break;
      case "output":
        final lines = Lines.fromJson(jsonDecode(data.body));
        body = Container(
            width: double.infinity,
            color: Colors.black,
            child: RawScrollbar(
                thumbColor: Colors.white,
                thumbVisibility: true,
                controller: controller,
                child: SingleChildScrollView(
                    controller: controller,
                    child: OutputLines(
                      lines: lines.lines,
                    ))));
        break;
      default:
        body = Container(
            width: double.infinity,
            color: Colors.black,
            child: RawScrollbar(
                thumbColor: Colors.white,
                thumbVisibility: true,
                controller: controller,
                child: SingleChildScrollView(
                    controller: controller,
                    child: SelectableText.rich(
                      TextSpan(text: data.body),
                      style: textStyleUserInputNote,
                    ))));
    }
    final content = Container(
        width: double.infinity,
        color: Colors.black,
        child: RawScrollbar(
            thumbColor: Colors.white,
            thumbVisibility: true,
            controller: controller,
            child: body));
    final result = await showDialog<bool?>(
      useRootNavigator: false,
      context: currentGame!.navigatorKey.currentState!.context,
      builder: (context) {
        return DialogOverlay(
            child: FullScreenDialog(
                withScroll: false,
                title: data.title,
                summary: '',
                child: content));
      },
    );
    if (result != true) {
      currentGame!.handleUserInputCallback(input, -1, '');
    }
  }
}

const textStyleUserInputFilter = TextStyle(
  fontSize: 14,
  height: 1.3,
  color: Color(0xff909399),
);

class UserInputListWidget extends StatefulWidget {
  const UserInputListWidget(
      {super.key, required this.input, required this.list});
  final UserInput input;
  final UserInputList list;
  @override
  State<UserInputListWidget> createState() => UserInputListWidgetState();
}

class UserInputListWidgetState extends State<UserInputListWidget> {
  UserInputListWidgetState();
  TextEditingValue filter = const TextEditingValue();
  Map<String, bool> selected = {};
  bool? allSelected;
  @override
  void initState() {
    for (final value in widget.list.values) {
      selected[value] = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var textController = TextEditingController.fromValue(filter);
    final data = UserInputList.fromJson(widget.input.data);
    final List<TableRow> children = [];
    if (widget.list.withFilter) {
      children.add(createTableRow([
        const TCell(Center()),
        TCell(TextField(
          decoration: const InputDecoration(
              hintText: '请输入需要过滤的关键字', hintStyle: textStyleUserInputFilter),
          controller: textController,
          onChanged: (value) {
            setState(() {
              filter = textController.value;
            });
          },
        ))
      ]));
    }
    if (widget.list.mutli) {
      bool hasTrue = false;
      bool hasFalse = false;
      for (final row in data.items) {
        if (selected[row.key] == true) {
          hasTrue = true;
        } else {
          hasFalse = true;
        }
      }
      if (hasTrue != hasFalse) {
        allSelected = hasTrue;
      } else {
        allSelected = null;
      }
      children.add(createTableRow([
        TCell(Checkbox(
            tristate: true,
            value: allSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  for (final row in data.items) {
                    selected[row.key] = true;
                  }
                  return;
                }
                selected.clear();
              });
            })),
        const TCell(Center()),
      ]));
    }
    for (final row in data.items) {
      if (filter.text.isEmpty || row.value.contains(filter.text)) {
        if (widget.list.mutli) {
          children.add(createTableRow([
            TCell(Checkbox(
              value: selected[row.key] == true,
              onChanged: (value) {
                setState(() {
                  selected[row.key] = (value == true);
                });
              },
            )),
            TCell(Text(row.value))
          ]));
        } else {
          children.add(createTableRow([
            TCell(
              AppUI.buildTextButton(context, "选择", () {
                currentGame!.handleUserInputCallback(widget.input, 0, row.key);
                Navigator.pop(context, true);
              }, null, Colors.white, const Color(0xff67C23A),
                  radiusLeft: true, radiusRight: true),
            ),
            TCell(Text(row.value))
          ]));
        }
      }
    }
    final table = Table(
      columnWidths: const {0: FixedColumnWidth(100)},
      children: children,
    );
    Widget body;
    if (widget.list.withFilter || widget.list.mutli) {
      List<Widget> listchildren = [];

      listchildren.add(table);
      if (widget.list.mutli) {
        listchildren.add(ConfirmOrCancelWidget(
          onConfirm: () {
            final List<String> data = [];
            for (var item in selected.keys) {
              if (selected[item] == true) {
                data.add(item);
              }
            }
            currentGame!
                .handleUserInputCallback(widget.input, 0, jsonEncode(data));
            Navigator.pop(context, true);
          },
          onCancal: () {
            Navigator.pop(context, null);
          },
        ));
      }
      body = Column(
        children: listchildren,
      );
    } else {
      body = table;
    }
    return body;
  }
}

class UserInputVisualPromptWidget extends StatefulWidget {
  const UserInputVisualPromptWidget(
      {super.key, required this.input, required this.visualPrompt});
  final UserInput input;
  final VisualPrompt visualPrompt;
  @override
  State<UserInputVisualPromptWidget> createState() =>
      UserInputVisualPromptWidgetState();
}

class UserInputVisualPromptWidgetState
    extends State<UserInputVisualPromptWidget> {
  final next = Event();
  final prev = Event();
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController.fromValue(
        TextEditingValue(text: widget.visualPrompt.value));
    final List<Widget> children = [];
    late Widget visual;

    if (widget.visualPrompt.refreshCallback.isNotEmpty) {
      children.add(Padding(
          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
          child: Align(
              alignment: Alignment.centerRight,
              child: AppUI.buildIconButton(
                context,
                const Icon(Icons.refresh),
                () async {
                  currentGame!.handleUserInputScriptCallback(
                      widget.input, widget.visualPrompt.refreshCallback, 0, '');
                },
                '刷新',
                Colors.white,
                const Color(0xff409EFF),
              ))));
    }
    switch (widget.visualPrompt.mediaType) {
      case "base64slide":
        visual = UserInputVisualPromptBase64SlideWidget(
          rawdata: widget.visualPrompt.source,
          next: next,
          prev: prev,
        );
      case "output":
        final lines = Lines.fromJson(jsonDecode(widget.visualPrompt.source));
        visual = Container(
            width: double.infinity,
            color: Colors.black,
            child: OutputLines(
              lines: lines.lines,
            ));
        break;
      case "text":
        visual = Text(widget.visualPrompt.source);
        break;
      case "image":
        visual = Image.network(widget.visualPrompt.source);
        break;
      default:
        visual = const Text("不支持的媒体类型");
    }
    children.add(visual);

    if (widget.visualPrompt.items.isEmpty) {
      children.add(TextField(
        onSubmitted: (value) {
          currentGame!.handleUserInputCallback(widget.input, 0, value);
          Navigator.pop(context, true);
        },
        focusNode: FocusNode(onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            switch (event.logicalKey.keyLabel) {
              case 'Page Down':
                next.raise();
                return KeyEventResult.handled;
              case 'Page Up':
                prev.raise();
                return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        }),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xffeeeeee),
        ),
        controller: controller,
        autofocus: true,
      ));
      children.add(ConfirmOrCancelWidget(
        onConfirm: () {
          currentGame!
              .handleUserInputCallback(widget.input, 0, controller.text);
          Navigator.pop(context, true);
        },
        onCancal: () {
          Navigator.pop(context, null);
        },
      ));
    } else {
      final List<TableRow> listchildren = [];
      for (final row in widget.visualPrompt.items) {
        listchildren.add(createTableRow([
          TCell(
            AppUI.buildTextButton(context, "选择", () {
              currentGame!.handleUserInputCallback(widget.input, 0, row.key);
              Navigator.pop(context, true);
            }, null, Colors.white, const Color(0xff67C23A),
                radiusLeft: true, radiusRight: true),
          ),
          TCell(Text(row.value))
        ]));
      }
      final table = Table(
        columnWidths: const {0: FixedColumnWidth(100)},
        children: listchildren,
      );
      children.add(table);
    }
    return DialogOverlay(
        child: FullScreenDialog(
            title: widget.visualPrompt.title,
            summary: widget.visualPrompt.intro,
            child: Column(children: children)));
  }
}

class Event extends ChangeNotifier {
  void raise() {
    notifyListeners();
  }
}

class UserInputVisualPromptBase64SlideWidget extends StatefulWidget {
  const UserInputVisualPromptBase64SlideWidget(
      {super.key,
      required this.rawdata,
      this.height = 250,
      required this.next,
      required this.prev});
  final String rawdata;
  final double height;
  final Event next;
  final Event prev;
  @override
  State<UserInputVisualPromptBase64SlideWidget> createState() =>
      UserInputVisualPromptBase64SlideWidgetState();
}

class UserInputVisualPromptBase64SlideWidgetState
    extends State<UserInputVisualPromptBase64SlideWidget> {
  double maxWidth = 0;
  double maxHeight = 0;
  final List<Widget> children = [];
  void loadImages() async {
    final picturesdata = widget.rawdata.split('|');
    for (final picturedata in picturesdata) {
      try {
        final raw = picturedata.split(',');
        if (raw.length > 1) {
          final rawbytes = base64Decode(raw[1].trimLeft());
          final id = await ui.ImageDescriptor.encoded(
              await ui.ImmutableBuffer.fromUint8List(rawbytes));
          if (maxWidth < id.width) {
            maxWidth = id.width * 1.0;
          }
          if (maxHeight < id.height) {
            maxHeight = id.height * 1.0;
          }
          children.add(LayoutBuilder(builder: (context, constraints) {
            return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: FittedBox(child: Image.memory(rawbytes)));
          }));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    setState(() {});
  }

  onNext() {
    carouselController.nextPage();
  }

  onPrev() {
    carouselController.previousPage();
  }

  @override
  void dispose() {
    super.dispose();
    widget.next.removeListener(onNext);
    widget.prev.removeListener(onPrev);
  }

  @override
  void initState() {
    super.initState();
    widget.prev.addListener(
      onPrev,
    );
    widget.next.addListener(
      onNext,
    );
    loadImages();
  }

  int page = 0;
  CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    if (maxHeight == 0) {
      return const Center();
    }
    return Column(
      children: [
        CarouselSlider(
          carouselController: carouselController,
          options: CarouselOptions(
            initialPage: page,
            height: widget.height > maxHeight ? widget.height : maxHeight,
            aspectRatio: maxWidth / maxHeight,
            onPageChanged: (index, reason) {
              setState(() {
                page = index;
              });
            },
          ),
          items: children,
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            IconButton(
              onPressed: () {
                carouselController.previousPage();
              },
              icon: const Icon(Icons.arrow_left),
            ),
            Expanded(
                child: Center(
                    child: Text(
                        '${(page + 1).toString()}/${children.length.toString()}'))),
            IconButton(
              onPressed: () {
                carouselController.nextPage();
              },
              icon: const Icon(Icons.arrow_right),
            ),
          ]),
        )
      ],
    );
  }
}
