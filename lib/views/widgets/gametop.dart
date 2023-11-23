import 'package:flutter/material.dart';
import 'package:hellclientui/workers/game.dart';
import 'dart:async';
import 'appui.dart';
import 'alllines.dart';

Future<bool?> showCloseGame(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("关闭游戏"),
        content: const Text("是否要关闭本游戏?"),
        actions: <Widget>[
          TextButton(
            child: const Text("取消"),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            child: const Text("关闭"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

class GameTop extends StatefulWidget {
  const GameTop({super.key});
  @override
  State<GameTop> createState() => GameTopState();
}

class GameTopState extends State<GameTop> {
  late StreamSubscription subClients;

  @override
  void initState() {
    super.initState();
    subClients = currentGame!.clientsUpdateStream.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    subClients.cancel();
    super.dispose();
  }

  Widget buildHeader(BuildContext context) {
    return SizedBox(
        height: 28,
        child: Row(children: [
          AppUI.buildIconButton(context, const Icon(Icons.home), () {
            currentGame?.handleCmd("change", "");
          }, "游戏一览", Colors.white, const Color(0xff67C23A), radiusLeft: true),
          AppUI.buildIconButton(context, const Icon(Icons.folder_open), () {
            currentGame?.openGames();
          }, "打开游戏", Colors.white, const Color(0xff409EFF)),
        ]));
  }

  Widget buildToolbar(BuildContext context) {
    final client = currentGame?.currentClient;
    if (client == null) {
      return Container();
    }
    final List<Widget> children = [];
    final connectBtn = client.running
        ? AppUI.buildIconButton(context, const Icon(Icons.stop), () {
            currentGame?.handleCmd("disconnect", currentGame?.current);
          }, "断线", Colors.white, const Color(0xffE6A23C), radiusLeft: true)
        : AppUI.buildIconButton(context, const Icon(Icons.play_arrow), () {
            currentGame?.handleCmd("connect", currentGame?.current);
          }, "连接", Colors.white, const Color(0xff67C23A), radiusLeft: true);
    children.add(connectBtn);
    children
        .add(AppUI.buildIconButton(context, const Icon(Icons.close), () async {
      if (await showCloseGame(context) == true) {
        currentGame!.handleCmd('close', currentGame!.current);
      }
    }, '关闭游戏', Colors.white, const Color(0xffF56C6C)));
    children.add(AppUI.buildIconButton(
        context, const Icon(Icons.document_scanner), () async {
      currentGame!.handleCmd("allLines", null);
      showAllLines(context);
    }, '历史输出', const Color(0xff606266), Colors.white,
        borderColor: const Color(0xffDCDFE6)));

    children.add(const SizedBox(
      width: 5,
    ));
    children.add(AppUI.buildIconButton(
      context,
      const Icon(Icons.save_outlined),
      () async {
        final result =
            await AppUI.showConfirmBox(context, '提示', '原游戏将被覆盖，是否要保存游戏?', null);
        if (result == true) {
          currentGame!.handleCmd("save", currentGame!.current);
        }
      },
      '保存',
      Colors.white,
      const Color(0xff409EFF),
    ));

    children.add(const SizedBox(
      width: 5,
    ));
    children.add(AppUI.buildIconButton(
        context, const Icon(Icons.replay_outlined), () async {
      final result = await AppUI.showConfirmBox(
          context, '提示', '脚本所有的修改将丢失，进行中的程序也将停止，是否要重新加载脚本?', null);
      if (result == true) {
        currentGame!.handleCmd("reloadScript", currentGame!.current);
      }
    }, '重新加载', const Color(0xff606266), Colors.white,
        borderColor: const Color(0xffDCDFE6)));

    return SizedBox(height: 28, child: Row(children: children));
  }

  Widget buildGames(BuildContext context) {
    final client = currentGame?.currentClient;
    if (client == null) {
      return Container();
    }
    List<Widget> games = [];
    for (var clientinfo in currentGame!.clientinfos.clientInfos) {
      bool isCurrent = currentGame!.current == clientinfo.id;
      games.add(TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll<Color>(
                isCurrent ? const Color(0xff409EFF) : Colors.white),
          ),
          onPressed: () {
            currentGame!.handleCmd('change', clientinfo.id);
          },
          child: Row(children: [
            Icon(
                color: isCurrent ? Colors.white : const Color(0xff303133),
                size: 14,
                clientinfo.running ? Icons.play_arrow_outlined : Icons.pause),
            Text(
              clientinfo.id,
              style: isCurrent
                  ? const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                  : const TextStyle(
                      color: Color(0xff303133),
                    ),
            )
          ])));
    }
    return SizedBox(
        height: 36,
        child:
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: games));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // final large = constraints.maxWidth >= 1121;
      final List<Widget> children = [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: buildHeader(context),
        ),
        const Divider(height: 1, color: Color(0xffE4E7ED)),
      ];
      final client = currentGame?.currentClient;
      if (client != null) {
        children.add(
          SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: buildGames(context)),
        );
        children.add(const Divider(height: 1, color: Color(0xffE4E7ED)));
        children.add(SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
              padding: const EdgeInsets.all(2), child: buildToolbar(context)),
        ));
      }

      Widget body = Container(
          decoration: const BoxDecoration(color: Colors.white),
          alignment: Alignment.centerLeft,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children));
      return body;
    });
  }
}
