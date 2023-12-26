import 'package:hellclientui/models/feature.dart';
import 'package:hellclientui/workers/game.dart';

import 'appui.dart';
import 'package:flutter/material.dart';
import '../../models/message.dart' as message;
import '../../forms/worldsettingsform.dart';
import '../../forms/scriptsettingsform.dart';
import 'package:hellclientui/views/widgets/paramsview.dart';
import 'updaterequiredparams.dart';
import 'triggers.dart';
import 'aliases.dart';
import 'timers.dart';
import '../../states/appstate.dart';

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

  static showUpdateRequiredParams(
      BuildContext context, message.RequiredParams params) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return UpdateRequiredParams(params: params);
        });
  }

  static showScriptTimers(BuildContext context) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return const Timers(
            byUser: false,
          );
        });
  }

  static showUserTimers(BuildContext context) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return const Timers(byUser: true);
        });
  }

  static showScriptTriggers(BuildContext context) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return const Triggers(
            byUser: false,
          );
        });
  }

  static showUserTriggers(BuildContext context) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return const Triggers(byUser: true);
        });
  }

  static showScriptAliases(BuildContext context) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return const Aliases(
            byUser: false,
          );
        });
  }

  static showUserAliases(BuildContext context) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return const Aliases(byUser: true);
        });
  }

  static showParamsInfo(BuildContext context) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return const ParamsView();
        });
  }

  static showScript(BuildContext context, message.ScriptInfo scriptinfo) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return Dialog.fullscreen(
              child: FullScreenDialog(
                  title: '脚本信息',
                  child: SizedBox(
                      width: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: buildFileds([
                            const Text(
                              '游戏ID',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(currentGame!.current),
                            const Text(
                              '脚本	',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Row(children: [
                              Text(scriptinfo.id),
                              const SizedBox(
                                width: 8,
                                child: Center(),
                              ),
                              SizedBox(
                                  height: 32,
                                  child: AppUI.buildTextButton(context,
                                      scriptinfo.id.isEmpty ? '选择' : '已选择', () {
                                    currentGame!.handleCmd(
                                        'listScriptinfo', currentGame!.current);
                                  }, "选择游戏脚本", Colors.white,
                                      const Color(0xff409EFF))),
                              scriptinfo.id.isEmpty
                                  ? const Center()
                                  : SizedBox(
                                      height: 32,
                                      child: AppUI.buildIconButton(
                                          context, const Icon(Icons.close), () {
                                        currentGame!.handleCmd(
                                            'usescript', <dynamic>[
                                          currentGame!.current,
                                          ''
                                        ]);
                                      }, "取消脚本", const Color(0xffE6A23C),
                                          const Color(0xfffdf6ec))),
                            ]),
                            const Text(
                              '类型		',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(scriptinfo.type),
                            const Text(
                              '描述			',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(scriptinfo.desc),
                            const Text(
                              '介绍',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(scriptinfo.intro),
                          ])))));
        });
  }

  static updateWorldSettings(
      BuildContext context, message.WorldSettings worldSettings) {
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return Dialog.fullscreen(
              child: FullScreenDialog(
                  title: '编辑游戏设置',
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: buildFileds([
                        const Text(
                          '游戏ID',
                          style: textStyleGameUIFieldLabel,
                        ),
                        Text(currentGame!.current),
                        const Text(
                          '服务器地址	',
                          style: textStyleGameUIFieldLabel,
                        ),
                        WorldSettingsForm(settings: worldSettings)
                      ]))));
        });
  }

  static showWorldSettings(
      BuildContext context, message.WorldSettings worldSettings) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return Dialog.fullscreen(
            child: Stack(children: [
              FullScreenDialog(
                  title: '游戏设置',
                  child: SizedBox(
                      width: double.infinity,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: buildFileds([
                            const Text(
                              '游戏ID',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.id),
                            const Text(
                              '服务器地址	',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.host),
                            const Text(
                              '服务器端口		',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.port),
                            const Text(
                              '字符集			',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.charset),
                            const Text(
                              '代理服务器				',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.proxy),
                            const Text(
                              '名称',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.name),
                            const Text(
                              '脚本前缀',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.scriptPrefix),
                            const Text(
                              '命令分割符',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.commandStackCharacter),
                            const Text(
                              '调试广播信息',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.showBroadcast ? "是" : "否"),
                            const Text(
                              '调试非文字信息',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.showSubneg ? "是" : "否"),
                            const Text(
                              '脚本模组(Mod)',
                              style: textStyleGameUIFieldLabel,
                            ),
                            Text(worldSettings.modEnabled ? "是" : "否"),
                            currentGame!.support(Features.batchcommand)
                                ? const Text(
                                    '跳过批量指令',
                                    style: textStyleGameUIFieldLabel,
                                  )
                                : const Center(),
                            currentGame!.support(Features.batchcommand)
                                ? Text(worldSettings.ignoreBatchCommand
                                    ? "是"
                                    : "否")
                                : const Center(),
                            currentGame!.support(Features.autoSave)
                                ? const Text(
                                    '自动保存',
                                    style: textStyleGameUIFieldLabel,
                                  )
                                : const Center(),
                            currentGame!.support(Features.autoSave)
                                ? Text(worldSettings.autoSave ? "是" : "否")
                                : const Center(),
                            const SizedBox(
                              height: 150,
                            )
                          ])))),
              Positioned(
                  right: 30,
                  bottom: 30,
                  child: FloatingActionButton(
                    onPressed: () {
                      updateWorldSettings(context, worldSettings);
                    },
                    tooltip: '编辑游戏设置',
                    child: const Icon(Icons.edit),
                  ))
            ]),
          );
        });
  }

  static updateScriptSettings(
      BuildContext context, message.ScriptSettings scriptSettings) {
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return Dialog.fullscreen(
              child: FullScreenDialog(
                  title: '编辑脚本设置',
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: buildFileds([
                        const Text(
                          '脚本名',
                          style: textStyleGameUIFieldLabel,
                        ),
                        Text(scriptSettings.name),
                        const Text(
                          '脚本类型	',
                          style: textStyleGameUIFieldLabel,
                        ),
                        Text(scriptSettings.type),
                        ScriptSettingsForm(settings: scriptSettings)
                      ]))));
        });
  }

  static showScriptSettings(
      BuildContext context, message.ScriptSettings scriptSettings) {
    AppUI.hideUI(context);
    showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return Dialog.fullscreen(
              child: Stack(children: [
            FullScreenDialog(
                title: '脚本设置',
                child: SizedBox(
                    width: double.infinity,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: buildFileds([
                          const Text(
                            '脚本名',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.name),
                          const Text(
                            '类型',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.type),
                          const Text(
                            '广播频道',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.channel),
                          const Text(
                            '助理触发函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onAssist),
                          const Text(
                            '快捷键触发函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onKeyUp),
                          const Text(
                            '广播触发函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onBroadcast),
                          const Text(
                            '响应触发函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onResponse),
                          const Text(
                            '加载触发函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onOpen),
                          const Text(
                            '关闭触发函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onClose),
                          const Text(
                            '连线触发函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onConnect),
                          const Text(
                            '掉线触发函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onDisconnect),
                          const Text(
                            'HUD点击函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onHUDClick),
                          const Text(
                            'Buffer处理函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onBuffer),
                          const Text(
                            'Buffer处理函数最小响应字数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onBufferMin.toString()),
                          const Text(
                            'Buffer处理函数最大响应字数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onBufferMax.toString()),
                          const Text(
                            'SubNegotiation处理函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onSubneg),
                          const Text(
                            '获取焦点函数',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.onFocus),
                          const Text(
                            '描述',
                            style: textStyleGameUIFieldLabel,
                          ),
                          Text(scriptSettings.desc),
                          const SizedBox(
                            height: 150,
                          )
                        ])))),
            Positioned(
                right: 30,
                bottom: 30,
                child: FloatingActionButton(
                  onPressed: () {
                    updateScriptSettings(context, scriptSettings);
                  },
                  tooltip: '编辑脚本设置',
                  child: const Icon(Icons.edit),
                ))
          ]));
        });
  }

  static showAuthorized(BuildContext context, message.Authorized authorized) {
    AppUI.hideUI(context);
    showDialog<bool?>(
      context: currentAppState.navigatorKey.currentState!.context,
      builder: (context) {
        return DialogOverlay(
            child: SizedBox(
                width: double.infinity,
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
                                    currentGame!.handleCmd('revokeAuthorized',
                                        currentGame!.current);
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
                )));
      },
    );
  }

  static requestPermissions(
      BuildContext context, message.RequestTrust request) async {
    AppUI.hideUI(context);
    final result = await showDialog<bool?>(
        context: currentAppState.navigatorKey.currentState!.context,
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
                  labelConfirm: '授权  ',
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
        context: currentAppState.navigatorKey.currentState!.context,
        builder: (context) {
          return DialogOverlay(
              child: FullScreenDialog(
                  title: ('请求授权'),
                  child: SizedBox(
                    width: double.infinity,
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
                          labelConfirm: '授权  ',
                        )
                      ]),
                    ),
                  )));
        });
    if (result == true) {
      currentGame!.handleCmd('requestTrustDomains', request);
    }
  }
}
