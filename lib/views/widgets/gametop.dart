import 'package:flutter/material.dart';
import 'package:hellclientui/workers/game.dart';
import 'dart:async';

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
          buildIconButton(context, const Icon(Icons.home), () {
            currentGame?.handleCmd("change", "");
          }, "游戏一览", Colors.white, Colors.green),
        ]));
  }

  Widget buildIconButton(
      BuildContext context,
      Widget icon,
      void Function() onPressed,
      String? tooltip,
      Color color,
      Color background) {
    return IconButton(
        style: ButtonStyle(
          padding:
              const MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(0)),
          // fixedSize: MaterialStatePropertyAll<Size>(Size(32, 32)),
          shape: const MaterialStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  side: BorderSide.none)),
          backgroundColor: MaterialStatePropertyAll<Color>(background),
          iconColor: MaterialStatePropertyAll<Color>(color),
        ),
        tooltip: tooltip,
        iconSize: 16,
        splashRadius: 3,
        onPressed: onPressed,
        icon: icon);
  }

  Widget buildToolbar(BuildContext context) {
    final client = currentGame?.currentClient;
    if (client == null) {
      return Container();
    }
    final connectBtn = client.running
        ? buildIconButton(context, const Icon(Icons.stop), () {
            currentGame?.handleCmd("disconnect", currentGame?.current);
          }, "断线", Colors.white, const Color(0xffE6A23C))
        : buildIconButton(context, const Icon(Icons.play_arrow), () {
            currentGame?.handleCmd("connect", currentGame?.current);
          }, "连接", Colors.white, const Color(0xff67C23A));
    return SizedBox(height: 28, child: Row(children: [connectBtn]));
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
