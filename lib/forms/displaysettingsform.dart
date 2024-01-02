import 'package:flutter/material.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import '../models/rendersettings.dart';

class ColorItem extends StatelessWidget {
  const ColorItem(
      {super.key,
      required this.label,
      required this.color,
      required this.defaultColor,
      required this.onSelect,
      required this.onReset});
  final String label;
  final Color? color;
  final Color defaultColor;
  final Function(Color color) onSelect;
  final Function() onReset;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 60,
              alignment: Alignment.centerLeft,
              child: Text(label),
            ),
            ColorIndicator(
              onSelectFocus: false,
              hasBorder: true,
              color: color ?? defaultColor,
              onSelect: () async {
                final pickedColor =
                    await showPickColer(context, color ?? defaultColor);
                if (pickedColor != null) {
                  onSelect(pickedColor);
                }
              },
            ),
            SizedBox(
                width: 32,
                child: color != null
                    ? IconButton(
                        tooltip: '重置',
                        onPressed: () {
                          onReset();
                        },
                        icon: const Icon(Icons.restore_sharp),
                        iconSize: 32,
                      )
                    : const Center()),
            const SizedBox(
              width: 8,
            )
          ],
        ));
  }
}

Future<Color?> showPickColer(BuildContext context, Color color) async {
  Color picked = color;
  if (await ColorPicker(
        color: picked,
        title: const Text('选择颜色'),
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.primary: true,
          ColorPickerType.accent: false,
          ColorPickerType.wheel: true,
          ColorPickerType.custom: true,
        },
        showColorCode: true,
        onColorChanged: (value) {
          picked = value;
          // Navigator.of(context).pop(value);
        },
      ).showPickerDialog(context) ==
      true) {
    return picked;
  }
  return null;
}

class DisplaySettiingsForm extends StatefulWidget {
  const DisplaySettiingsForm({super.key});
  @override
  State<StatefulWidget> createState() => DisplaySettiingsFormState();
}

class DisplaySettiingsFormState extends State<DisplaySettiingsForm> {
  late RenderConfig config;
  late RenderSettings defaultSettings;
  @override
  void initState() {
    super.initState();
    config = currentAppState.renderConfig.clone();
    defaultSettings = config.getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("显示设置"),
          actions: [
            IconButton(
                tooltip: '重置所有选项',
                onPressed: () {
                  setState(() {
                    config = RenderConfig();
                  });
                },
                icon: const Icon(Icons.restore)),
          ]),
      body: ListView(scrollDirection: Axis.vertical, children: [
        Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColorItem(
                    label: '前景色',
                    color: config.color,
                    defaultColor: defaultSettings.color,
                    onSelect: (color) {
                      setState(() {
                        config.color = color;
                      });
                    },
                    onReset: () {
                      setState(() {
                        config.color = null;
                      });
                    }),
                ColorItem(
                    label: '背景色',
                    color: config.background,
                    defaultColor: defaultSettings.background,
                    onSelect: (color) {
                      setState(() {
                        config.background = color;
                      });
                    },
                    onReset: () {
                      setState(() {
                        config.background = null;
                      });
                    }),
                const SizedBox(
                  height: 16,
                ),
                Row(children: [
                  ColorItem(
                      label: '黑色',
                      color: config.black,
                      defaultColor: defaultSettings.black,
                      onSelect: (color) {
                        setState(() {
                          config.black = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.black = null;
                        });
                      }),
                  ColorItem(
                      label: '亮黑色',
                      color: config.brightBlack,
                      defaultColor: defaultSettings.brightBlack,
                      onSelect: (color) {
                        setState(() {
                          config.brightBlack = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.brightBlack = null;
                        });
                      }),
                ]),
                Row(children: [
                  ColorItem(
                      label: '红色',
                      color: config.red,
                      defaultColor: defaultSettings.red,
                      onSelect: (color) {
                        setState(() {
                          config.red = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.red = null;
                        });
                      }),
                  ColorItem(
                      label: '亮红色',
                      color: config.brightRed,
                      defaultColor: defaultSettings.brightRed,
                      onSelect: (color) {
                        setState(() {
                          config.brightRed = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.brightRed = null;
                        });
                      }),
                ]),
                Row(children: [
                  ColorItem(
                      label: '绿色',
                      color: config.green,
                      defaultColor: defaultSettings.green,
                      onSelect: (color) {
                        setState(() {
                          config.green = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.green = null;
                        });
                      }),
                  ColorItem(
                      label: '亮绿色',
                      color: config.brightGreen,
                      defaultColor: defaultSettings.brightGreen,
                      onSelect: (color) {
                        setState(() {
                          config.brightGreen = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.brightGreen = null;
                        });
                      }),
                ]),
                Row(children: [
                  ColorItem(
                      label: '黄色',
                      color: config.yellow,
                      defaultColor: defaultSettings.yellow,
                      onSelect: (color) {
                        setState(() {
                          config.yellow = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.yellow = null;
                        });
                      }),
                  ColorItem(
                      label: '亮黄色',
                      color: config.brightYellow,
                      defaultColor: defaultSettings.brightYellow,
                      onSelect: (color) {
                        setState(() {
                          config.brightYellow = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.brightYellow = null;
                        });
                      }),
                ]),
                Row(children: [
                  ColorItem(
                      label: '蓝色',
                      color: config.blue,
                      defaultColor: defaultSettings.blue,
                      onSelect: (color) {
                        setState(() {
                          config.blue = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.blue = null;
                        });
                      }),
                  ColorItem(
                      label: '亮蓝色',
                      color: config.brightBlue,
                      defaultColor: defaultSettings.brightBlue,
                      onSelect: (color) {
                        setState(() {
                          config.brightBlue = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.brightBlue = null;
                        });
                      }),
                ]),
                Row(children: [
                  ColorItem(
                      label: '紫色',
                      color: config.magenta,
                      defaultColor: defaultSettings.magenta,
                      onSelect: (color) {
                        setState(() {
                          config.magenta = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.magenta = null;
                        });
                      }),
                  ColorItem(
                      label: '亮紫色',
                      color: config.brightMagenta,
                      defaultColor: defaultSettings.brightMagenta,
                      onSelect: (color) {
                        setState(() {
                          config.brightMagenta = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.brightMagenta = null;
                        });
                      }),
                ]),
                Row(children: [
                  ColorItem(
                      label: '青色',
                      color: config.cyan,
                      defaultColor: defaultSettings.cyan,
                      onSelect: (color) {
                        setState(() {
                          config.cyan = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.cyan = null;
                        });
                      }),
                  ColorItem(
                      label: '亮青色',
                      color: config.brightCyan,
                      defaultColor: defaultSettings.brightCyan,
                      onSelect: (color) {
                        setState(() {
                          config.brightCyan = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.brightCyan = null;
                        });
                      }),
                ]),
                Row(children: [
                  ColorItem(
                      label: '白色',
                      color: config.white,
                      defaultColor: defaultSettings.white,
                      onSelect: (color) {
                        setState(() {
                          config.white = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.white = null;
                        });
                      }),
                  ColorItem(
                      label: '白色',
                      color: config.brightWhite,
                      defaultColor: defaultSettings.brightWhite,
                      onSelect: (color) {
                        setState(() {
                          config.brightWhite = color;
                        });
                      },
                      onReset: () {
                        setState(() {
                          config.brightWhite = null;
                        });
                      }),
                ]),
                DropdownButtonFormField(
                  value: config.commandDisplayMode,
                  decoration: const InputDecoration(
                    label: Text("命令框样式"),
                  ),
                  items: const <DropdownMenuItem>[
                    DropdownMenuItem(
                      value: '',
                      enabled: false,
                      child: Text('<未选择>'),
                    ),
                    DropdownMenuItem(
                        value: CommandDisplayMode.normal, child: Text('默认')),
                    DropdownMenuItem(
                        value: CommandDisplayMode.larger, child: Text('略大')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      config.commandDisplayMode = value;
                    });
                  },
                ),
                Row(
                  children: [
                    Checkbox(
                        value: config.disableHidpi == true,
                        onChanged: (value) {
                          setState(() {
                            config.disableHidpi = (value == true);
                          });
                        }),
                    const Text('禁用Hidpi文字渲染', softWrap: true)
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                        value: config.roundDpi == true,
                        onChanged: (value) {
                          setState(() {
                            config.roundDpi = (value == true);
                          });
                        }),
                    const Text('缩放比例取整，取消可改善非整数缩倍放效果', softWrap: true)
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                        value: config.forceDesktopMode == true,
                        onChanged: (value) {
                          setState(() {
                            config.forceDesktopMode = (value == true);
                          });
                        }),
                    const Text(
                      '强制使用桌面模式',
                      softWrap: true,
                    )
                  ],
                ),
                const SizedBox(
                  height: 150,
                )
              ],
            ))
      ]),
      floatingActionButton: FloatingActionButton(
        tooltip: '保存',
        onPressed: () {
          currentAppState.renderConfig = config;
          currentAppState.renderSettings = config.getSettings();
          currentAppState.saveColors();
          Navigator.of(context).pop(true);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
