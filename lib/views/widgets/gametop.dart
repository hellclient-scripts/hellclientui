import 'package:flutter/material.dart';
import 'package:hellclientui/models/feature.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/workers/game.dart';
import 'dart:async';
import 'appui.dart';
import 'alllines.dart';
import 'gameui.dart';
import '../../forms/passwordform.dart';

Future<bool?> showUpdatePassowrd(BuildContext context) async {
  return showDialog<bool>(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
    builder: (context) {
      return const NonFullScreenDialog(title: '修改客户端密码', child: PasswordForm());
    },
  );
}

Future<bool?> showCloseGame(BuildContext context) async {
  return showDialog<bool>(
    useRootNavigator: false,
    context: currentGame!.navigatorKey.currentState!.context,
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
    final statusText =
        currentGame!.status.isEmpty ? '' : '    [${currentGame!.status}]';
    final List<Widget> children = [
      AppUI.buildIconButton(context, const Icon(Icons.home), () {
        currentGame!.handleCmd("change", "");
      }, "游戏一览", Colors.white, const Color(0xff67C23A), radiusLeft: true),
      AppUI.buildIconButton(context, const Icon(Icons.folder_open), () {
        currentGame!.openGames();
      }, "打开游戏", Colors.white, const Color(0xff409EFF)),
      AppUI.buildIconButton(context, const Icon(Icons.lock_outline), () {
        showUpdatePassowrd(context);
      }, "修改密码", const Color(0xff606266), Colors.white,
          borderColor: const Color(0xffDCDFE6)),
      AppUI.buildIconButton(context, const Icon(Icons.info), () {
        currentGame!.handleCmd("about", "");
      }, "关于", const Color(0xff606266), Colors.white,
          borderColor: const Color(0xffDCDFE6)),
      currentGame!.support(Features.batchcommand)
          ? AppUI.buildIconButton(
              context, const Icon(Icons.assignment_outlined), () {
              currentGame!.handleCmd("batchcommandscripts", "");
            }, "批量命令", const Color(0xff606266), Colors.white,
              borderColor: const Color(0xffDCDFE6))
          : const Center(),
      Expanded(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: currentGame!.current.isEmpty
                  ? const Center()
                  : GestureDetector(
                      onTap: () {
                        AppUI.showMsgBox(
                            context,
                            '游戏 ${currentGame!.current} 状态',
                            currentGame!.status,
                            null);
                      },
                      child: Text.rich(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          TextSpan(children: [
                            TextSpan(
                                text: '当前游戏:${currentGame!.current}$statusText')
                          ]))))),
    ];
    if (currentGame!.switchStatus != 0) {
      children.add(Tooltip(
          message: currentGame!.switchStatus == 2
              ? "已连接到Hellclient网络"
              : "未连接到Hellclient网络",
          child: Icon(Icons.connect_without_contact,
              color: currentGame!.switchStatus == 2
                  ? const Color(0xff67C23A)
                  : const Color(0xffE6A23C))));
    }
    return SizedBox(height: 28, child: Row(children: children));
  }

  Widget buildToolbar(BuildContext context, bool large) {
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
    if (large) {
      children.add(AppUI.buildIconButton(
          context, const Icon(Icons.chat_outlined), () async {
        currentGame!.handleCmd("allLines", null);
        showAllLines(context);
      }, '历史输出', const Color(0xff606266), Colors.white,
          borderColor: const Color(0xffDCDFE6)));
    }

    children.add(const SizedBox(
      width: 5,
    ));
    if (large) {
      children.add(AppUI.buildIconButton(
          context, const Icon(Icons.display_settings), () async {
        currentGame!.handleCmd("worldSettings", currentGame!.current);
      }, '游戏设置', const Color(0xff606266), Colors.white,
          borderColor: const Color(0xffDCDFE6)));
      children.add(AppUI.buildIconButton(
          context, const Icon(Icons.memory_sharp), () async {
        currentGame!.handleCmd("scriptinfo", currentGame!.current);
      }, '脚本', const Color(0xff606266), Colors.white,
          borderColor: const Color(0xffDCDFE6)));
    }
    children.add(AppUI.buildIconButton(
      context,
      const Icon(Icons.key),
      () async {
        currentGame!.handleCmd("authorized", currentGame!.current);
      },
      '授权',
      Colors.white,
      const Color(0xffE6A23C),
    ));

    children.add(const SizedBox(
      width: 5,
    ));
    children.add(AppUI.buildIconButton(context, const Icon(Icons.bar_chart),
        () async {
      currentGame!.paramsInfos = null;
      GameUI.showParamsInfo(context);
      currentGame!.handleCmd("params", currentGame!.current);
    }, '变量', const Color(0xff606266), Colors.white,
        borderColor: const Color(0xffDCDFE6)));
    if (large) {
      children.add(AppUI.buildIconButton(context, const Icon(Icons.settings),
          () async {
        currentGame!.triggers = null;
        GameUI.showUserTriggers(context);
        currentGame!.handleCmd("triggers", [currentGame!.current, 'byuser']);
      }, '游戏触发器', const Color(0xff606266), Colors.white,
          borderColor: const Color(0xffDCDFE6)));
      children.add(AppUI.buildIconButton(
          context, const Icon(Icons.timer_outlined), () async {
        currentGame!.timers = null;
        GameUI.showUserTimers(context);
        currentGame!.handleCmd("timers", [currentGame!.current, 'byuser']);
      }, '游戏计时器', const Color(0xff606266), Colors.white,
          borderColor: const Color(0xffDCDFE6)));
      children.add(AppUI.buildIconButton(context, const Icon(Icons.send),
          () async {
        currentGame!.aliases = null;
        GameUI.showUserAliases(context);
        currentGame!.handleCmd("aliases", [currentGame!.current, 'byuser']);
      }, '游戏别名', const Color(0xff606266), Colors.white,
          borderColor: const Color(0xffDCDFE6)));
    }

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

    if (large) {
      children.add(AppUI.buildIconButton(
        context,
        const Icon(Icons.lock_outline),
        () async {
          if (currentAppState.showMore) {
            currentAppState.showMore = false;
            setState(() {});
          } else {
            final result = await AppUI.showConfirmBox(context, '提示',
                '是否开启脚本编辑模式?在脚本编辑模式中可以对脚本的触发器，计时器和别名进行编辑。', null);
            if (result == true) {
              currentAppState.showMore = true;
              setState(() {});
            }
          }
        },
        currentAppState.showMore ? '关闭脚本编辑模式' : '开启脚本编辑模式',
        Colors.white,
        currentAppState.showMore
            ? const Color(0xff909399)
            : const Color(0xffE6A23C),
      ));
    }
    if (large && currentAppState.showMore) {
      children.add(const SizedBox(
        width: 5,
      ));
      children.add(AppUI.buildIconButton(
          context, const Icon(Icons.display_settings), () async {
        currentGame!.handleCmd("scriptSettings", currentGame!.current);
      }, '脚本设置', const Color(0xffE6A23C), const Color(0xfffdf6ec),
          borderColor: const Color(0xfff5dab1)));

      children.add(AppUI.buildIconButton(context, const Icon(Icons.bar_chart),
          () async {
        currentGame!.handleCmd("requiredParams", currentGame!.current);
      }, '编辑变量说明', const Color(0xffE6A23C), const Color(0xfffdf6ec),
          borderColor: const Color(0xfff5dab1)));
      children.add(AppUI.buildIconButton(context, const Icon(Icons.settings),
          () async {
        currentGame!.triggers = null;
        GameUI.showScriptTriggers(context);
        currentGame!.handleCmd("triggers", [currentGame!.current, '']);
      }, '脚本触发器', const Color(0xffE6A23C), const Color(0xfffdf6ec),
          borderColor: const Color(0xfff5dab1)));
      children.add(AppUI.buildIconButton(
          context, const Icon(Icons.timer_outlined), () async {
        currentGame!.timers = null;
        GameUI.showScriptTimers(context);
        currentGame!.handleCmd("timers", [currentGame!.current, '']);
      }, '脚本计时器', const Color(0xffE6A23C), const Color(0xfffdf6ec),
          borderColor: const Color(0xfff5dab1)));
      children.add(AppUI.buildIconButton(context, const Icon(Icons.send),
          () async {
        currentGame!.aliases = null;
        GameUI.showScriptAliases(context);
        currentGame!.handleCmd("aliases", [currentGame!.current, '']);
      }, '脚本别名', const Color(0xffE6A23C), const Color(0xfffdf6ec),
          borderColor: const Color(0xfff5dab1)));

      children.add(AppUI.buildIconButton(
        context,
        const Icon(Icons.save_outlined),
        () async {
          final result = await AppUI.showConfirmBox(
              context, '提示', '原脚本将被覆盖，是否要保存脚本?', null);
          if (result == true) {
            currentGame!.handleCmd("savescript", currentGame!.current);
          }
        },
        '保存脚本',
        const Color(0xfff56C6C),
        const Color(0xfffef0f0),
        borderColor: const Color(0xfffbc4c4),
      ));
    }
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
            backgroundColor: WidgetStatePropertyAll<Color>(
                isCurrent ? const Color(0xff409EFF) : Colors.white),
          ),
          onPressed: () {
            currentGame!.handleCmd('change', clientinfo.id);
          },
          child: Row(children: [
            Icon(
                color: isCurrent
                    ? Colors.white
                    : (clientinfo.running
                        ? const Color(0xff67C23A)
                        : const Color(0xffE6A23C)),
                size: 14,
                clientinfo.running ? Icons.play_arrow : Icons.pause),
            Text(
              clientinfo.id,
              style: isCurrent
                  ? const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                  : TextStyle(
                      color: (clientinfo.running
                          ? const Color(0xff303133)
                          : const Color(0xff666666)),
                      fontWeight: (clientinfo.running
                          ? FontWeight.bold
                          : FontWeight.normal),
                    ),
            ),
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
      final large = constraints.maxWidth >= 1121;
      final List<Widget> children = [
        buildHeader(context),
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
              padding: const EdgeInsets.all(2),
              child: buildToolbar(context, large)),
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
