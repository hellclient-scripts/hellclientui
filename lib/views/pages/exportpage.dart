import 'package:flutter/material.dart';
import 'dart:convert';
import '../widgets/appui.dart';
import '../../states/appstate.dart';
import '../../models/rendersettings.dart';
import '../../models/config.dart';

class ExportPage extends StatelessWidget {
  const ExportPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("导入导出"),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(
                Icons.display_settings,
                color: Color(0xff67C23A),
              ),
              title: const Text('导出显示设置'),
              subtitle: const Text('导出颜色等显示设置'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                final String export = base64Encode(utf8
                    .encode(jsonEncode(currentAppState.renderConfig.toJson())));
                AppUI.showAppMsgBox(context, '导出当前设置', '',
                    SelectableText('hcui-config:$export'));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.display_settings, color: Color(0xffE6A23C)),
              title: const Text('导入显示设置'),
              subtitle: const Text('导入hcui-config:开头的颜色等显示设置'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final result = await AppUI.showAppConfirmBox(
                    currentAppState.navigatorKey.currentState!.context,
                    '确认导入',
                    '您确认要导入显示设置吗？导入后您现有的显示设置会全部失效。',
                    null);
                if (result != true) {
                  return;
                }
                final context =
                    currentAppState.navigatorKey.currentState!.context;
                if (context.mounted) {
                  final input = await AppUI.promptAppTextArea(
                      currentAppState.navigatorKey.currentState!.context,
                      '导入显示设置',
                      '请导入hcui-config:开头的显示设置',
                      '',
                      '');
                  if (input != null) {
                    if (input.startsWith('hcui-config:')) {
                      try {
                        final import = RenderConfig.fromJson(jsonDecode(
                            utf8.decode(base64Decode(
                                input.replaceFirst('hcui-config:', '')))));
                        currentAppState.renderConfig = import;
                        currentAppState.renderSettings =
                            currentAppState.renderConfig.getSettings();
                        currentAppState.saveColors();

                        return;
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }
                    if (context.mounted) {
                      AppUI.showAppMsgBox(context, '导入数据失败', '导入的数据格式错误',
                          SelectableText(input));
                    }
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.key,
                color: Color(0xff67C23A),
              ),
              title: const Text('导出系统设置'),
              subtitle: const Text('导出服务器信息，批量命令等系统设置'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final result = await AppUI.showAppConfirmBox(
                    currentAppState.navigatorKey.currentState!.context,
                    '确认导出',
                    '您确认要导出系统设置吗？系统设置包含服务器密码和各种密钥，需要妥善保护。',
                    null);
                if (result != true) {
                  return;
                }
                final context =
                    currentAppState.navigatorKey.currentState!.context;
                if (context.mounted) {
                  final sc = ScrollController();
                  final String export = base64Encode(
                      utf8.encode(jsonEncode(currentAppState.config.toJson())));
                  AppUI.showAppMsgBox(
                      context,
                      '导出系统设置',
                      '注意，导出的数据钟中括密码等敏感信息',
                      Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: RawScrollbar(
                              controller: sc,
                              child: SingleChildScrollView(
                                  controller: sc,
                                  child: SelectableText(
                                      'hcsystem-config-include-PASSWORD!:$export')))));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.key, color: Color(0xffE6A23C)),
              title: const Text('导入系统设置'),
              subtitle:
                  const Text('导入hcsystem-config-include-PASSWORD!:开头的系统设置'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                final result = await AppUI.showAppConfirmBox(
                    currentAppState.navigatorKey.currentState!.context,
                    '确认导入',
                    '您确认要导入系统设置吗？导入后您现有的系统设置会全部失效。',
                    null);
                if (result != true) {
                  return;
                }
                final context =
                    currentAppState.navigatorKey.currentState!.context;
                if (context.mounted) {
                  final input = await AppUI.promptAppTextArea(
                      currentAppState.navigatorKey.currentState!.context,
                      '导入系统设置',
                      '请导入hcsystem-config-include-PASSWORD!:开头的显示设置',
                      '',
                      '');
                  if (input != null) {
                    if (input
                        .startsWith('hcsystem-config-include-PASSWORD!:')) {
                      try {
                        final import = Config.fromJson(jsonDecode(utf8.decode(
                            base64Decode(input.replaceFirst(
                                'hcsystem-config-include-PASSWORD!:', '')))));
                        await currentAppState.unbind();
                        currentAppState.config = import;
                        currentAppState.save();
                        await currentAppState.bind();
                        currentAppState.updated();
                        return;
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }
                    if (context.mounted) {
                      AppUI.showAppMsgBox(context, '导入数据失败', '导入的数据格式错误',
                          SelectableText(input));
                    }
                  }
                }
              },
            ),
          ],
        ));
  }
}
