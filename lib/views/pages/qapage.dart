import 'package:flutter/material.dart';
import 'package:hellclientui/data/qa.dart';
import '../widgets/userinput.dart';
import '../widgets/appui.dart';

class QAPage extends StatefulWidget {
  const QAPage({super.key});
  @override
  State<QAPage> createState() => QAPageState();
}

class QAPageState extends State<QAPage> {
  final filter = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    for (final qa in appQAList) {
      if (filter.text.isEmpty ||
          qa.question.contains(filter.text) ||
          qa.answer.contains(filter.text)) {
        children.add(H1(qa.question));
        children.add(SelectableText(qa.answer));
      }
    }
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("常见问答"),
        ),
        body: ListView(
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                    decoration: const InputDecoration(
                        hintText: '请输入需要过滤的关键字',
                        hintStyle: textStyleUserInputFilter),
                    controller: filter,
                    onChanged: (value) {
                      setState(() {});
                    })),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                )),
            const SizedBox(
              height: 16,
            )
          ],
        ));
  }
}
