import 'package:flutter/material.dart';
import '../../models/message.dart' as message;
import 'appui.dart';
import 'userinput.dart';
import 'package:hellclientui/workers/game.dart';
import '../../forms/createrequiredparamform.dart';
import '../../forms/updaterequiredparamform.dart';

Future<message.RequiredParam?> showCreateReqiredParam(
    BuildContext context) async {
  return showDialog<message.RequiredParam?>(
    context: context,
    builder: (context) {
      return const NonFullScreenDialog(
          title: '创建脚本', child: CreateRequiredParamForm());
    },
  );
}

Future<bool?> showUpdateReqiredParam(
    BuildContext context, message.RequiredParam param) async {
  return showDialog<bool?>(
    context: context,
    builder: (context) {
      return NonFullScreenDialog(
          title: '创建脚本', child: UpdateRequiredParamForm(param: param));
    },
  );
}

class UpdateRequiredParams extends StatefulWidget {
  const UpdateRequiredParams({super.key, required this.params});
  final message.RequiredParams params;
  @override
  State<UpdateRequiredParams> createState() => UpdateRequiredParamsState();
}

class UpdateRequiredParamsState extends State<UpdateRequiredParams> {
  final TextEditingController filter = TextEditingController();
  void submit() {
    currentGame!.handleCmd(
        'updateRequiredParams',
        message.UpdateRequiredParams(
            current: currentGame!.current, params: widget.params));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    for (var i = 0; i < widget.params.list.length; i++) {
      final param = widget.params.list[i];
      if (filter.text.isEmpty ||
          param.name.contains(filter.text) ||
          param.intro.contains(filter.text) ||
          param.desc.contains(filter.text)) {
        children.add(Container(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xffeeeeee)))),
          key: Key(param.name),
          child: Row(children: [
            SizedBox(
                width: 32,
                child: Tooltip(
                  message: '拖动调整顺序',
                  child: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(
                      Icons.drag_handle,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                )),
            SizedBox(
                width: 180,
                child: Text(param.name, textAlign: TextAlign.start)),
            Expanded(
                child: Flex(direction: Axis.horizontal, children: [
              Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(param.desc, textAlign: TextAlign.start)),
              Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Text(param.intro, textAlign: TextAlign.start)),
            ])),
            SizedBox(
              width: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () async {
                        final result =
                            await showUpdateReqiredParam(context, param);
                        if (result != null) {
                          submit();
                        }
                      },
                      child: const Text(
                        '设置',
                      )),
                  TextButton(
                      onPressed: () async {
                        if (await AppUI.showConfirmBox(
                                context,
                                '删除',
                                '',
                                const Text.rich(
                                  TextSpan(children: [
                                    WidgetSpan(
                                        child: Icon(
                                      Icons.warning,
                                      color: Color(0xffE6A23C),
                                    )),
                                    TextSpan(text: '是否要删除该变量?'),
                                  ]),
                                )) ==
                            true) {
                          widget.params.list.remove(param);
                          submit();
                          setState(() {});
                        }
                      },
                      child: const Text(
                        '删除',
                      ))
                ],
              ),
            ),
          ]),
        ));
      }
    }

    return Dialog.fullscreen(
        child: Stack(children: [
      FullScreenDialog(
          withScroll: false,
          title: '变量说明',
          summary: '编辑脚本中使用的变量的说明文字。注意，这是修改机器，不是设置变量。',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                    decoration: const InputDecoration(
                        hintText: '请输入需要过滤的关键字',
                        hintStyle: textStyleUserInputFilter),
                    controller: filter,
                    onChanged: (value) {
                      setState(() {});
                    })),
            Container(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xffeeeeee)))),
                child: const Row(children: [
                  SizedBox(
                    width: 32,
                  ),
                  SizedBox(
                      width: 180,
                      child: Text('变量名',
                          style: textStyleTableHead,
                          textAlign: TextAlign.start)),
                  Expanded(
                      child: Flex(direction: Axis.horizontal, children: [
                    Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text('描述',
                            style: textStyleTableHead,
                            textAlign: TextAlign.start)),
                    Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text('介绍',
                            style: textStyleTableHead,
                            textAlign: TextAlign.start)),
                  ])),
                  SizedBox(
                      width: 200,
                      child: Text('操作',
                          style: textStyleTableHead,
                          textAlign: TextAlign.center)),
                ])),
            Expanded(
                child: ReorderableListView(
              buildDefaultDragHandles: false,
              children: children,
              onReorder: (oldIndex, newIndex) async {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                if (await AppUI.showConfirmBox(
                        context,
                        '交换变量位置',
                        '',
                        Text.rich(
                          TextSpan(children: [
                            const WidgetSpan(
                                child: Icon(
                              Icons.warning,
                              color: Color(0xffE6A23C),
                            )),
                            TextSpan(
                                text:
                                    '是否要交换变量[${widget.params.list[oldIndex].name}]和[${widget.params.list[newIndex].name}]]的位置?'),
                          ]),
                        )) ==
                    true) {
                  final item = widget.params.list.removeAt(oldIndex);
                  widget.params.list.insert(newIndex, item);
                  submit();
                }
              },
            )),
          ])),
      Positioned(
          right: 30,
          bottom: 30,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await showCreateReqiredParam(context);
              if (result != null) {
                widget.params.list.add(result);
                submit();
              }
            },
            tooltip: '新建脚本变量',
            child: const Icon(Icons.add),
          ))
    ]));
  }
}
