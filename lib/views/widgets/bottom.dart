import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hellclientui/models/message.dart';
import 'package:hellclientui/models/rendersettings.dart';
import '../../workers/game.dart';
import '../../states/appstate.dart';
import 'appui.dart';
import 'dart:async';
import 'dart:convert';

const textStyleBottomGameName = TextStyle(
  color: Colors.white,
  fontSize: 14,
  height: 20 / 14,
  decoration: TextDecoration.underline,
);
const textStyleBottomMasSendHint = TextStyle(
  color: Color(0xff909399),
  fontSize: 14,
  height: 20 / 14,
);
const textStyleBottomMasSend = TextStyle(
  color: Colors.white,
  fontSize: 14,
  height: 20 / 14,
);
Future<bool?> showMassSend(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<bool>(
    context: currentAppState.navigatorKey.currentState!.context,
    builder: (context) {
      return DialogOverlay(
          child: FullScreenDialog(
              title: '批量输入',
              summary: '批量输入数据，会将数据直接发送给MUD,不出发任何别名和解析，不会记录在发送历史内',
              child: Column(
                children: [
                  Container(
                      color: Colors.black,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            hintText: '请输入你需要批量输入的数据',
                            hintStyle: textStyleBottomMasSendHint),
                        maxLines: null,
                        style: textStyleBottomMasSend,
                        controller: controller,
                        autofocus: true,
                        keyboardType: TextInputType.multiline,
                        minLines: 25,
                      )),
                  ConfirmOrCancelWidget(
                    onConfirm: () {
                      currentGame!.handleCmd('masssend', controller.text);
                      Navigator.of(context).pop(true);
                    },
                    onCancal: () {},
                    labelCancel: null,
                    labelConfirm: '发送',
                    autofocus: true,
                  )
                ],
              )));
    },
  );
}

class DisplayBottom extends StatefulWidget {
  const DisplayBottom({super.key});
  @override
  State<StatefulWidget> createState() => DisplayBottomState();
}

class DisplayBottomState extends State<DisplayBottom> {
  DisplayBottomState();
  late StreamSubscription subCommand;
  late TextEditingController inputController;
  late FocusNode focusNode;
  @override
  void initState() {
    inputController = TextEditingController();
    focusNode = FocusNode(
      onKeyEvent: (node, value) {
        if (value is KeyDownEvent) {
          switch (value.logicalKey.keyLabel) {
            case 'Arrow Up':
              currentGame!
                  .handleCmd("findhistory", currentGame!.historypos + 1);
              return KeyEventResult.handled;
            case 'Arrow Down':
              if (currentGame!.historypos <= 0) {
                currentGame!.historypos = -1;
                inputController.text = "";
                return KeyEventResult.handled;
              }
              currentGame!
                  .handleCmd("findhistory", currentGame!.historypos - 1);
              return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
    );
    subCommand = currentGame!.commandStream.stream.listen((event) async {
      if (event is GameCommand) {
        switch (event.command) {
          case "foundhistory":
            final data = FoundHistory.fromJson(jsonDecode(event.data));
            inputController.value = TextEditingValue(text: data.command);
            inputController.selection = TextSelection(
                baseOffset: 0, extentOffset: inputController.value.text.length);
            currentGame!.historypos = data.position;
            break;
          case "current":
            focusNode.requestFocus();
            setState(() {});
            break;
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    subCommand.cancel();
  }

  Widget buildBottom(BuildContext context) {
    focusNode.requestFocus();
    inputController.selection = TextSelection(
        baseOffset: 0, extentOffset: inputController.value.text.length);
    late double height;
    late double iconsize;
    late double fontsize;
    switch (currentAppState.renderSettings.commandDisplayMode) {
      case CommandDisplayMode.larger:
        height = 45;
        iconsize = 24;
        fontsize = currentAppState.renderSettings.fontSize * 1.5;
        break;
      default:
        height = 30;
        iconsize = 16;
        fontsize = currentAppState.renderSettings.fontSize;
        break;
    }
    return SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              currentGame!.current,
              style: textStyleBottomGameName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    currentGame!.handleCmd("assist", currentGame!.current);
                  },
                  child: Tooltip(
                      message: '助理',
                      child: SizedBox(
                        width: 54,
                        height: height,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffDCDFE6), width: 1)),
                          child: Icon(
                            Icons.person_2_outlined,
                            color: const Color(
                              0xff909399,
                            ),
                            size: iconsize,
                          ),
                        ),
                      )))),
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
                      fontSize: fontsize,
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
                      currentGame?.handleSend(value);
                      focusNode.requestFocus();
                      inputController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: inputController.value.text.length);
                    },
                  ))),
          MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    showMassSend(context);
                  },
                  child: Tooltip(
                      message: '批量输入',
                      child: SizedBox(
                        width: 54,
                        height: height,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffDCDFE6), width: 1)),
                          child: Icon(
                            Icons.archive_outlined,
                            color: const Color(
                              0xff909399,
                            ),
                            size: iconsize,
                          ),
                        ),
                      )))),
          Container(
              width: 80,
              height: 32,
              alignment: Alignment.centerRight,
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      currentGame!.handleCmd("change", '');
                    },
                    child: const Tooltip(
                      message: '游戏一览',
                      child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.home,
                            size: 16,
                            color: Color(
                              0xff909399,
                            ),
                          )),
                    ),
                  )))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildBottom(context);
  }
}
