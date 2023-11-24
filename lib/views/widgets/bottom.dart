import 'package:flutter/material.dart';
import '../../workers/game.dart';
import '../../states/appstate.dart';

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
          const SizedBox(
            width: 80,
            child: Text("test"),
          ),
          MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    currentGame!.handleCmd("assist", currentGame!.current);
                  },
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
                  ))),
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
          const SizedBox(
            width: 80,
            child: Text("test2"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildBottom(context);
  }
}
