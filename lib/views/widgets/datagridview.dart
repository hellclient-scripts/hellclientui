import 'package:flutter/material.dart';
import 'userinput.dart';
import 'package:hellclientui/models/message.dart';
import '../../workers/game.dart';
import 'appui.dart';
import 'dart:async';
import 'package:number_paginator/number_paginator.dart';

class DatagridView extends StatefulWidget {
  const DatagridView({super.key});
  @override
  State<DatagridView> createState() => DatagridViewState();
}

class DatagridViewState extends State<DatagridView> {
  UserInput? input;
  Datagrid? data;
  late StreamSubscription subDatagrid;
  updateGrid(UserInput? datagrid) {
    input = datagrid;
    data = (datagrid == null)
        ? null
        : Datagrid.fromJson(input!.data as Map<String, dynamic>);
    if (data != null && filter.text != data!.filter) {
      filter.text = data!.filter;
    }
  }

  final TextEditingController filter = TextEditingController();
  @override
  void initState() {
    super.initState();
    updateGrid(currentGame!.datagrid);
    subDatagrid =
        currentGame!.datagridUpdateStream.stream.listen((event) async {
      updateGrid(event as UserInput?);
      setState(() {});
    });
  }

  @override
  void dispose() {
    subDatagrid.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (input == null || data == null) {
      return const Center(child: Text('Loading...'));
    }
    final List<TableRow> children = [];
    children.add(createTableRow([
      const TableHead(
        '数据',
        textAlign: TextAlign.start,
      ),
      const TableHead('操作', textAlign: TextAlign.end),
    ]));
    for (final item in data!.items) {
      children.add(createTableRow([
        TCell(SelectableText(
          item.value,
          textAlign: TextAlign.start,
        )),
        TCell(Row(
          children: [
            data!.onSelect.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: AppUI.buildIconButton(
                      context,
                      const Icon(Icons.check),
                      () async {
                        currentGame!.handleUserInputScriptCallback(
                            input!, data!.onSelect, 0, item.key);
                      },
                      '选择',
                      Colors.white,
                      const Color(0xff409EFF),
                    ))
                : const Center(),
            data!.onView.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: AppUI.buildIconButton(
                      context,
                      const Icon(Icons.remove_red_eye_outlined),
                      () async {
                        currentGame!.handleUserInputScriptCallback(
                            input!, data!.onView, 0, item.key);
                      },
                      '查看',
                      Colors.white,
                      const Color(0xff67C23A),
                    ))
                : const Center(),
            data!.onUpdate.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: AppUI.buildIconButton(
                      context,
                      const Icon(Icons.edit),
                      () async {
                        currentGame!.handleUserInputScriptCallback(
                            input!, data!.onUpdate, 0, item.key);
                      },
                      '编辑',
                      Colors.white,
                      const Color(0xffE6A23C),
                    ))
                : const Center(),
            data!.onDelete.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: AppUI.buildIconButton(
                      context,
                      const Icon(Icons.delete),
                      () async {
                        if (await AppUI.showConfirmBox(context, '删除该数？',
                                '请确认是否删除以下数据', SelectableText(item.value)) ==
                            true) {
                          currentGame!.handleUserInputScriptCallback(
                              input!, data!.onDelete, 0, item.key);
                        }
                      },
                      '删除',
                      Colors.white,
                      const Color(0xffF56C6C),
                    ))
                : const Center(),
          ],
        )),
      ]));
    }
    return DialogOverlay(
        child: FullScreenDialog(
            title: data!.title,
            summary: data!.intro,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                data!.onFilter.isNotEmpty
                    ? Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: TextField(
                              decoration: const InputDecoration(
                                  hintText: '请输入需要搜索的内容',
                                  hintStyle: textStyleUserInputFilter),
                              controller: filter,
                            )))
                    : const Center(),
                data!.onFilter.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: AppUI.buildIconButton(
                          context,
                          const Icon(Icons.search),
                          () async {
                            currentGame!.handleUserInputScriptCallback(
                                input!, data!.onFilter, 0, filter.text);
                          },
                          '搜索',
                          Colors.white,
                          const Color(0xff409EFF),
                        ))
                    : const Center(),
                data!.onCreate.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                        child: AppUI.buildIconButton(
                          context,
                          const Icon(Icons.add),
                          () async {
                            currentGame!.handleUserInputScriptCallback(
                                input!, data!.onCreate, 0, '');
                          },
                          '创建',
                          Colors.white,
                          const Color(0xff67C23A),
                        ))
                    : const Center(),
              ]),
              Table(
                columnWidths: const {1: FixedColumnWidth(240)},
                children: children,
              ),
              data!.onPage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                      child: NumberPaginator(
                        numberPages: data!.maxPage > 0 ? data!.maxPage : 1,
                        initialPage: data!.page > 0 ? data!.page - 1 : 0,
                        onPageChange: (page) {
                          currentGame!.handleUserInputScriptCallback(
                              input!, data!.onPage, 0, (page + 1).toString());
                        },
                      ))
                  : const Center(),
            ])));
  }
}
