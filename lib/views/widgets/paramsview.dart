import 'package:flutter/material.dart';
import '../../models/message.dart' as message;
import 'appui.dart';
import 'userinput.dart';
import 'package:hellclientui/workers/game.dart';

class ParamsView extends StatefulWidget {
  const ParamsView({super.key, required this.info});
  final message.ParamsInfo info;
  @override
  State<ParamsView> createState() => ParamsViewState();
}

class ParamsViewState extends State<ParamsView> {
  @override
  Widget build(BuildContext context) {
    final Widget body = currentGame!.showAllParams
        ? AllParams(info: widget.info)
        : RequiredParams(info: widget.info);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Tooltip(
                message: '显示不需要填写或者其他脚本试用的变量',
                child: Checkbox(
                  value: currentGame!.showAllParams,
                  onChanged: (value) {
                    setState(() {
                      currentGame!.showAllParams = (value == true);
                    });
                  },
                )),
            const Text('显示全部变量'),
          ],
        ),
        body,
      ],
    );
  }
}

class RequiredParams extends StatefulWidget {
  const RequiredParams({super.key, required this.info});
  final message.ParamsInfo info;
  @override
  State<RequiredParams> createState() => RequiredParamsState();
}

class RequiredParamsState extends State<RequiredParams> {
  final TextEditingController filter = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final List<TableRow> children = [
      createTableRow([
        const TableHead(
          '变量名',
          textAlign: TextAlign.start,
        ),
        const TableHead('变量值', textAlign: TextAlign.start),
        const TableHead('描述', textAlign: TextAlign.start),
        const TableHead('操作', textAlign: TextAlign.end),
      ])
    ];
    for (final info in widget.info.requiredParams) {
      if (filter.text.isEmpty ||
          widget.info.params[info.name] != null &&
              widget.info.params[info.name]!.contains(filter.text) ||
          info.name.contains(filter.text) ||
          info.desc.contains(filter.text)) {
        void update() async {
          final result = await AppUI.promptTextArea(context, '设置变量${info.name}',
              info.desc, info.intro, widget.info.params[info.name] ?? '');
          if (result != null) {
            currentGame!.handleCmd(
                'updateParam', [currentGame!.current, info.name, result]);
          }
        }

        children.add(createTableRow([
          TCell(TextButton(onPressed: update, child: Text(info.name))),
          TCell(Text(widget.info.params[info.name] ?? '')),
          TCell(Text.rich(TextSpan(children: [
            TextSpan(text: info.desc),
            WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: IconButton(
                  tooltip: '备注',
                  icon: const Icon(
                    Icons.chat,
                    size: 12,
                  ),
                  onPressed: () async {
                    final result = await AppUI.promptTextArea(
                        context,
                        '变量备注',
                        '可用于放被用变量值',
                        '',
                        widget.info.paramComments[info.name] ?? '');
                    if (result != null) {
                      currentGame!.handleCmd('updateParamComment',
                          [currentGame!.current, info.name, result]);
                    }
                  },
                ))
          ]))),
          TCell(
            TextButton(
                onPressed: update,
                child: const Text(
                  '设置',
                )),
          )
        ]));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const H1('可设置变量列表'),
      Row(children: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                    decoration: const InputDecoration(
                        hintText: '请输入需要过滤的关键字',
                        hintStyle: textStyleUserInputFilter),
                    controller: filter,
                    onChanged: (value) {
                      setState(() {});
                    }))),
      ]),
      Table(
        columnWidths: const {0: FixedColumnWidth(180), 3: FixedColumnWidth(80)},
        children: children,
      )
    ]);
  }
}

class AllParams extends StatefulWidget {
  const AllParams({super.key, required this.info});
  final message.ParamsInfo info;
  @override
  State<AllParams> createState() => AllParamsState();
}

class AllParamsState extends State<AllParams> {
  final TextEditingController filter = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final List<TableRow> children = [
      createTableRow([
        const TableHead(
          '变量名',
          textAlign: TextAlign.start,
        ),
        const TableHead('变量值', textAlign: TextAlign.start),
        const TableHead('操作', textAlign: TextAlign.end),
      ])
    ];
    for (final key in widget.info.params.keys) {
      if (filter.text.isEmpty ||
          key.contains(filter.text) ||
          widget.info.params[key]!.contains(filter.text)) {
        void update() async {
          final result = await AppUI.promptTextArea(
              context, '设置变量$key', '', '', widget.info.params[key] ?? '');
          if (result != null) {
            currentGame!
                .handleCmd('updateParam', [currentGame!.current, key, result]);
          }
        }

        children.add(createTableRow([
          TCell(TextButton(onPressed: update, child: Text(key))),
          TCell(Text(widget.info.params[key] ?? '')),
          TCell(
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: update,
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
                        currentGame!.handleCmd(
                            'deleteParam', [currentGame!.current, key]);
                      }
                    },
                    child: const Text(
                      '删除',
                    ))
              ],
            ),
          )
        ]));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const H1('全部变量'),
      TCell(
        AppUI.buildIconButton(context, const Icon(Icons.add), () async {
          final result = await AppUI.promptText(context, '添加变量', '', '', '');
          if (result != null && result != '') {
            currentGame!
                .handleCmd('updateParam', [currentGame!.current, result, '']);
          }
        }, "添加变量", Colors.white, const Color(0xff409EFF)),
      ),
      Row(children: [
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                    decoration: const InputDecoration(
                        hintText: '请输入需要过滤的关键字',
                        hintStyle: textStyleUserInputFilter),
                    controller: filter,
                    onChanged: (value) {
                      setState(() {});
                    }))),
      ]),
      Table(
        columnWidths: const {
          0: FixedColumnWidth(180),
          2: FixedColumnWidth(160)
        },
        children: children,
      )
    ]);
  }
}
