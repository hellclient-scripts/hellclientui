import 'package:flutter/material.dart';
import '../../workers/game.dart';
import '../../states/appstate.dart';
import 'appui.dart';

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
    context: context,
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
                    labelSubmit: '发送',
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

var inputController = TextEditingController();

class DisplayBottomState extends State<DisplayBottom> {
  DisplayBottomState();
  Widget buildBottom(BuildContext context) {
    var focusNode = FocusNode();
    focusNode.requestFocus();
    inputController.selection = TextSelection(
        baseOffset: 0, extentOffset: inputController.value.text.length);

    return SizedBox(
      height: 30,
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
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffDCDFE6), width: 1)),
                          child: const Icon(
                            Icons.person_2_outlined,
                            color: Color(
                              0xff909399,
                            ),
                            size: 16,
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
                      fontSize: currentAppState.renderSettings.fontSize,
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
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xffDCDFE6), width: 1)),
                          child: const Icon(
                            Icons.archive_outlined,
                            color: Color(
                              0xff909399,
                            ),
                            size: 16,
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
