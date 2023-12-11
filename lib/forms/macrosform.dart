import 'package:flutter/material.dart';
import 'package:hellclientui/models/macros.dart';
import 'package:hellclientui/states/appstate.dart';
import 'package:hellclientui/views/widgets/appui.dart';

class MacrosForm extends StatefulWidget {
  const MacrosForm({super.key});
  @override
  State<MacrosForm> createState() {
    return MacrosFormState();
  }
}

class _Macros {
  _Macros(
      {required this.label,
      required this.key,
      required this.loader,
      required this.saver});
  final String label;
  final String key;
  final Function(Macros, _Macros) loader;
  final Function(Macros, _Macros) saver;
  final controller = TextEditingController();
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            label: Text(label),
          ),
        ));
  }
}

class MacrosFormState extends State<MacrosForm> {
  late List<_Macros> _fields;
  @override
  void initState() {
    super.initState();
    _fields = [
      _Macros(
          label: 'F1',
          key: 'f1',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f1;
          },
          saver: (Macros macros, _Macros self) {
            macros.f1 = self.controller.text;
          }),
      _Macros(
          label: 'F2',
          key: 'f2',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f2;
          },
          saver: (Macros macros, _Macros self) {
            macros.f2 = self.controller.text;
          }),
      _Macros(
          label: 'F3',
          key: 'f3',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f3;
          },
          saver: (Macros macros, _Macros self) {
            macros.f3 = self.controller.text;
          }),
      _Macros(
          label: 'F4',
          key: 'f4',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f4;
          },
          saver: (Macros macros, _Macros self) {
            macros.f4 = self.controller.text;
          }),
      _Macros(
          label: 'F5',
          key: 'f5',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f5;
          },
          saver: (Macros macros, _Macros self) {
            macros.f5 = self.controller.text;
          }),
      _Macros(
          label: 'F6',
          key: 'f6',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f6;
          },
          saver: (Macros macros, _Macros self) {
            macros.f6 = self.controller.text;
          }),
      _Macros(
          label: 'F7',
          key: 'f7',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f7;
          },
          saver: (Macros macros, _Macros self) {
            macros.f7 = self.controller.text;
          }),
      _Macros(
          label: 'F8',
          key: 'f8',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f8;
          },
          saver: (Macros macros, _Macros self) {
            macros.f8 = self.controller.text;
          }),
      _Macros(
          label: 'F9',
          key: 'f9',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f9;
          },
          saver: (Macros macros, _Macros self) {
            macros.f9 = self.controller.text;
          }),
      _Macros(
          label: 'F10',
          key: 'f10',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f10;
          },
          saver: (Macros macros, _Macros self) {
            macros.f10 = self.controller.text;
          }),
      _Macros(
          label: 'F11',
          key: 'f11',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f11;
          },
          saver: (Macros macros, _Macros self) {
            macros.f11 = self.controller.text;
          }),
      _Macros(
          label: 'F12',
          key: 'f12',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.f12;
          },
          saver: (Macros macros, _Macros self) {
            macros.f12 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 0',
          key: 'numpad0',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad0;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad0 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 1',
          key: 'numpad1',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad1;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad1 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 2',
          key: 'numpad2',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad2;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad2 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 3',
          key: 'numpad3',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad3;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad3 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 4',
          key: 'numpad4',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad4;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad4 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 5',
          key: 'numpad5',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad5;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad5 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 6',
          key: 'numpad6',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad6;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad6 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 7',
          key: 'numpad7',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad7;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad7 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 8',
          key: 'numpad8',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad8;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad8 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 9',
          key: 'numpad9',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpad9;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpad9 = self.controller.text;
          }),
      _Macros(
          label: '小键盘 除号',
          key: 'numpadDivide',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpadDivide;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpadDivide = self.controller.text;
          }),
      _Macros(
          label: '小键盘 乘号',
          key: 'numpadMultiply',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpadMultiply;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpadMultiply = self.controller.text;
          }),
      _Macros(
          label: '小键盘 减号',
          key: 'numpadSubtract',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpadSubtract;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpadSubtract = self.controller.text;
          }),
      _Macros(
          label: '小键盘 加号',
          key: 'numpadAdd',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpadAdd;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpadAdd = self.controller.text;
          }),
      _Macros(
          label: '小键盘 小数点',
          key: 'numpadDecimal',
          loader: (Macros macros, _Macros self) {
            self.controller.text = macros.numpadDecimal;
          },
          saver: (Macros macros, _Macros self) {
            macros.numpadDecimal = self.controller.text;
          }),
    ];

    for (final field in _fields) {
      field.loader(currentAppState.config.macros, field);
    }
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
        title: const Text("宏键 设置"),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(30),
            child: Summary('设置FN功能区和小键盘区对应按下时发出的游戏指令。如果不为空，则脚本中onKey函数的指令将失效。'),
          ),
          ...(_fields.map((e) => e.build(context)).toList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '保存',
        onPressed: () {
          for (final field in _fields) {
            field.saver(currentAppState.config.macros, field);
          }
          currentAppState.save();
          Navigator.of(context).pop(true);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
