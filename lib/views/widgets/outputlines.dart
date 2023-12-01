import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../workers/game.dart';
import '../../states/appstate.dart';

class OutputLines extends StatelessWidget {
  const OutputLines({super.key, required this.lines});
  final List<Line> lines;
  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    final renderer = currentGame!.output.renderer;
    for (final line in lines) {
      List<InlineSpan> linedata = [];
      final linestyle = renderer.getLineStyle(line);
      if (linestyle.icon.isNotEmpty) {
        final iconstyle = renderer.getIconStyle(
            1, linestyle.iconcolor, currentAppState.renderSettings.background);
        linedata.add(WidgetSpan(
            child: SelectionContainer.disabled(
                child: Text(linestyle.icon, style: iconstyle))));
      }
      for (final word in line.words) {
        final style = renderer.getWordStyle(
            word, linestyle.color, currentAppState.renderSettings.background);
        linedata.add(TextSpan(
            text: word.text,
            style: style.toTextStyle(currentAppState.renderSettings)));
      }
      if (line.triggers.isNotEmpty) {
        linedata.add(WidgetSpan(
            child: SelectionContainer.disabled(
                child: Text(renderer.renderSettings.triggersicon,
                    style: renderer.getIconStyle(
                        1,
                        renderer.renderSettings.triggersColor,
                        renderer.background)))));
      }
      List<Widget> children = [];

      linedata.add(const TextSpan(text: '\r'));
      children.add(SizedBox(
          width: renderer.renderSettings.width,
          child: Text.rich(
            TextSpan(children: linedata),
            softWrap: true,
          )));
      list.add(Flex(direction: Axis.horizontal, children: children));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: list);
  }
}
