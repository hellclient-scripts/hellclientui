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

  Widget buildToolbar(BuildContext context) {
    final client = currentGame?.currentClient;
    if (client == null) {
      return Container();
    }
    final connectBtn = client.running
        ? IconButton(
            onPressed: () {
              currentGame?.handleCmd("disconnect", currentGame?.current);
            },
            icon: Icon(Icons.stop))
        : IconButton(
            onPressed: () {
              currentGame?.handleCmd("connect", currentGame?.current);
            },
            icon: Icon(Icons.play_arrow));
    return Row(children: [connectBtn]);
  }

  @override
  Widget build(BuildContext context) {
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

    return Container(
        decoration: BoxDecoration(color: Colors.white),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: games)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: buildToolbar(context),
          )
        ]));
  }
}
