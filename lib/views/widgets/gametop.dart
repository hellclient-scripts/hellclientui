import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hellclientui/views/pages/game.dart';
import 'package:hellclientui/workers/game.dart';
import 'dart:async';

class GameTop extends StatefulWidget {
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
          buildIconButton(context, Icon(Icons.home), () {
            currentGame?.handleCmd("change", "");
          }, Colors.white, Colors.green),
        ]));
  }

  Widget buildIconButton(BuildContext context, Widget icon,
      void Function() onPressed, Color color, Color background) {
    return IconButton(
        style: ButtonStyle(
          padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(0)),
          // fixedSize: MaterialStatePropertyAll<Size>(Size(32, 32)),
          shape: MaterialStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  side: BorderSide.none)),
          backgroundColor: MaterialStatePropertyAll<Color>(background),
          iconColor: MaterialStatePropertyAll<Color>(color),
        ),
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
        ? buildIconButton(context, Icon(Icons.stop), () {
            currentGame?.handleCmd("disconnect", currentGame?.current);
          }, Colors.white, Color(0xffE6A23C))
        : buildIconButton(context, Icon(Icons.play_arrow), () {
            currentGame?.handleCmd("connect", currentGame?.current);
          }, Colors.white, Color(0xff67C23A));
    return SizedBox(height: 28, child: Row(children: [connectBtn]));
  }

  Widget buildGames(BuildContext context) {
    final client = currentGame?.currentClient;
    if (client == null) {
      return Container();
    }
    List<Widget> games = [];
    for (var clientinfo in currentGame!.clientinfos.clientInfos) {
      games.add(TextButton(
          onPressed: () {
            currentGame!.handleCmd('change', clientinfo.id);
          },
          child: Row(children: [
            Icon(clientinfo.running ? Icons.play_arrow_outlined : Icons.pause),
            Text(
              clientinfo.id,
              style: currentGame!.current == clientinfo.id
                  ? TextStyle(decoration: TextDecoration.underline)
                  : null,
            ),
          ])));
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: games);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.white),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: buildHeader(context),
          ),
          const Divider(height: 1, color: Color(0xffE4E7ED)),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal, child: buildGames(context)),
          const Divider(height: 1, color: Color(0xffE4E7ED)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
                padding: EdgeInsets.all(2), child: buildToolbar(context)),
          )
        ]));
  }
}
