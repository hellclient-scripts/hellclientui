import 'package:hellclientui/workers/game.dart';

import 'appui.dart';
import 'package:flutter/material.dart';
import '../../models/message.dart' as message;

const textStyleGameUIFieldLabel = TextStyle(
  color: Color(0xff333333),
  fontSize: 14,
  height: 20 / 14,
  fontWeight: FontWeight.bold,
);

class GameUI {
  static Widget buildFieldLine(Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 5, 2, 5),
      child: child,
    );
  }

  static List<Widget> buildFileds(List<Widget> children) {
    return children.map((e) => buildFieldLine(e)).toList();
  }

  static Widget buildTag(String text, Color color, Color background) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: color,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13, height: 20 / 13),
      ),
    );
  }

  static showAuthorized(BuildContext context, message.Authorized authorized) {
    AppUI.hideUI(context);
    showDialog<bool?>(
      context: context,
      builder: (context) {
        return DialogOverlay(
            child: FullScreenDialog(
          title: '授权',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildFileds([
              const Text(
                '游戏ID',
                style: textStyleGameUIFieldLabel,
              ),
              Text(currentGame!.current),
              const Text(
                '已授权权限',
                style: textStyleGameUIFieldLabel,
              ),
              Text.rich(TextSpan(
                  children: authorized.permissions
                      .map((e) => WidgetSpan(
                          child: buildTag(e, const Color(0xfff56c6c),
                              const Color(0xfffef0f0))))
                      .toList())),
              const Text(
                '已信任域名',
                style: textStyleGameUIFieldLabel,
              ),
              Text.rich(TextSpan(
                  children: authorized.domains
                      .map((e) => WidgetSpan(
                          child: buildTag(e, const Color(0xfff56c6c),
                              const Color(0xfffef0f0))))
                      .toList())),
              Row(
                children: [
                  const Expanded(child: Center()),
                  SizedBox(
                      width: 120,
                      child: AppUI.buildTextButton(
                        context,
                        '注销所有授权',
                        () async {
                          if (await AppUI.showConfirmBox(
                                  context,
                                  "注销权限",
                                  '',
                                  const Text.rich(TextSpan(children: [
                                    WidgetSpan(
                                        child: Icon(
                                      Icons.warning,
                                      color: Color(0xffE6A23C),
                                    )),
                                    TextSpan(text: '是否要注销所有权限?')
                                  ]))) ==
                              true) {
                            currentGame!.handleCmd(
                                'revokeAuthorized', currentGame!.current);
                          }
                        },
                        null,
                        Colors.white,
                        const Color(0xffE6A23C),
                      ))
                ],
              )
            ]),
          ),
        ));
      },
    );
  }

  static requestPermissions(
      BuildContext context, message.RequestTrust request) async {
    AppUI.hideUI(context);
    final result = await showDialog<bool?>(
        context: context,
        builder: (context) {
          return DialogOverlay(
              child: FullScreenDialog(
            title: ('请求授权'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildFileds([
                const Text(
                  '游戏ID',
                  style: textStyleGameUIFieldLabel,
                ),
                Text(currentGame!.current),
                const Text(
                  '脚本请求以下权限',
                  style: textStyleGameUIFieldLabel,
                ),
                Text.rich(TextSpan(
                    children: request.items
                        .map((e) => WidgetSpan(
                            child: buildTag(e, const Color(0xfff56c6c),
                                const Color(0xfffef0f0))))
                        .toList())),
                const Text(
                  '脚本申请授权的理由为',
                  style: textStyleGameUIFieldLabel,
                ),
                Text(request.reason),
                ConfirmOrCancelWidget(
                  onConfirm: () {
                    Navigator.of(context).pop(true);
                  },
                  onCancal: () {
                    Navigator.of(context).pop(false);
                  },
                  labelSubmit: '授权  ',
                )
              ]),
            ),
          ));
        });
    if (result == true) {
      currentGame!.handleCmd('requestPermissions', request);
    }
  }

  static requestTrustDomains(
      BuildContext context, message.RequestTrust request) async {
    AppUI.hideUI(context);
    final result = await showDialog<bool?>(
        context: context,
        builder: (context) {
          return DialogOverlay(
              child: FullScreenDialog(
            title: ('请求授权'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildFileds([
                const Text(
                  '游戏ID',
                  style: textStyleGameUIFieldLabel,
                ),
                Text(currentGame!.current),
                const Text(
                  '脚本请求信任以下域名',
                  style: textStyleGameUIFieldLabel,
                ),
                Text.rich(TextSpan(
                    children: request.items
                        .map((e) => WidgetSpan(
                            child: buildTag(e, const Color(0xfff56c6c),
                                const Color(0xfffef0f0))))
                        .toList())),
                const Text(
                  '脚本申请信任域名的理由为',
                  style: textStyleGameUIFieldLabel,
                ),
                Text(request.reason),
                ConfirmOrCancelWidget(
                  onConfirm: () {
                    Navigator.of(context).pop(true);
                  },
                  onCancal: () {
                    Navigator.of(context).pop(false);
                  },
                  labelSubmit: '授权  ',
                )
              ]),
            ),
          ));
        });
    if (result == true) {
      currentGame!.handleCmd('requestTrustDomains', request);
    }
  }
}
