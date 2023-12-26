import 'package:flutter/material.dart';
import '../../models/message.dart' as message;
import 'appui.dart';
import 'userinput.dart';
import 'package:hellclientui/workers/game.dart';
import 'dart:async';

class ParamsView extends StatefulWidget {
  const ParamsView({super.key});
  @override
  State<ParamsView> createState() => ParamsViewState();
}

class ParamsViewState extends State<ParamsView> {
  @override
  Widget build(BuildContext context) {
    final Widget body =
        currentGame!.showAllParams ? const AllParams() : const RequiredParams();
    return Dialog.fullscreen(
        child: Stack(children: [
      FullScreenDialog(
        title: currentGame!.showAllParams ? '变量设置-全部变量' : '变量设置-可设置变量',
        withScroll: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: body),
          ],
        ),
      ),
      Positioned(
          right: 30,
          bottom: 30,
          child: Row(children: [
            currentGame!.showAllParams
                ? Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        final result =
                            await AppUI.promptText(context, '添加变量', '', '', '');
                        if (result != null && result != '') {
                          currentGame!.handleCmd('updateParam',
                              [currentGame!.current, result, '']);
                        }
                      },
                      tooltip: '添加变量',
                      child: const Icon(Icons.add),
                    ))
                : const Center(),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  currentGame!.showAllParams = !currentGame!.showAllParams;
                });
              },
              tooltip: currentGame!.showAllParams
                  ? '显示脚本使用的变量'
                  : '显示不需要填写或者其他脚本试用的变量',
              child: Icon(currentGame!.showAllParams
                  ? Icons.zoom_in_map_sharp
                  : Icons.zoom_out_map_sharp),
            ),
          ]))
    ]));
  }
}

class RequiredParams extends StatefulWidget {
  const RequiredParams({super.key});
  @override
  State<RequiredParams> createState() => RequiredParamsState();
}

class RequiredParamsState extends State<RequiredParams> {
  final TextEditingController filter = TextEditingController();
  final _scrollconrtoller = ScrollController();
  message.ParamsInfo? paramsInfo;
  late StreamSubscription subCommand;
  @override
  void initState() {
    super.initState();
    paramsInfo = currentGame!.paramsInfos;
    subCommand = currentGame!.dataUpdateStream.stream.listen((event) {
      if (event is message.ParamsInfo?) {
        paramsInfo = event;
        setState(() {});
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
    if (paramsInfo == null) {
      return const Center(child: Text('加载中……'));
    }
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
    for (final info in paramsInfo!.requiredParams) {
      if (filter.text.isEmpty ||
          paramsInfo!.params[info.name] != null &&
              paramsInfo!.params[info.name]!.contains(filter.text) ||
          info.name.contains(filter.text) ||
          info.desc.contains(filter.text)) {
        void update() async {
          final result = await AppUI.promptTextArea(context, '设置变量${info.name}',
              info.desc, info.intro, paramsInfo!.params[info.name] ?? '');
          if (result != null) {
            currentGame!.handleCmd(
                'updateParam', [currentGame!.current, info.name, result]);
          }
        }

        children.add(createTableRow([
          TCell(TextButton(onPressed: update, child: Text(info.name))),
          TCell(Text(paramsInfo!.params[info.name] ?? '')),
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
                  color: ((paramsInfo!.paramComments[info.name] ?? '') != '')
                      ? const Color(0xff67C23A)
                      : null,
                  onPressed: () async {
                    final result = await AppUI.promptTextArea(
                        context,
                        '变量备注',
                        '可用于放被用变量值',
                        '',
                        paramsInfo!.paramComments[info.name] ?? '');
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
      Flexible(
          child: SingleChildScrollView(
              controller: _scrollconrtoller,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      columnWidths: const {
                        0: FixedColumnWidth(180),
                        3: FixedColumnWidth(80)
                      },
                      children: children,
                    ),
                    const SizedBox(
                      height: 150,
                    )
                  ]))),
    ]);
  }
}

class AllParams extends StatefulWidget {
  const AllParams({super.key});
  @override
  State<AllParams> createState() => AllParamsState();
}

class AllParamsState extends State<AllParams> {
  final TextEditingController filter = TextEditingController();
  final _scrollconrtoller = ScrollController();
  message.ParamsInfo? paramsInfo;
  late StreamSubscription subCommand;
  @override
  void initState() {
    super.initState();
    paramsInfo = currentGame!.paramsInfos;
    subCommand = currentGame!.dataUpdateStream.stream.listen((event) {
      if (event is message.ParamsInfo?) {
        paramsInfo = event;
        setState(() {});
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
    if (paramsInfo == null) {
      return const Center(child: Text('加载中……'));
    }

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
    for (final key in paramsInfo!.params.keys) {
      if (filter.text.isEmpty ||
          key.contains(filter.text) ||
          paramsInfo!.params[key]!.contains(filter.text)) {
        void update() async {
          final result = await AppUI.promptTextArea(
              context, '设置变量$key', '', '', paramsInfo!.params[key] ?? '');
          if (result != null) {
            currentGame!
                .handleCmd('updateParam', [currentGame!.current, key, result]);
          }
        }

        children.add(createTableRow([
          TCell(TextButton(onPressed: update, child: Text(key))),
          TCell(Text(paramsInfo!.params[key] ?? '')),
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
      Flexible(
          child: SingleChildScrollView(
              controller: _scrollconrtoller,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      columnWidths: const {
                        0: FixedColumnWidth(180),
                        2: FixedColumnWidth(180)
                      },
                      children: children,
                    ),
                    const SizedBox(
                      height: 150,
                    )
                  ])))
    ]);
  }
}
