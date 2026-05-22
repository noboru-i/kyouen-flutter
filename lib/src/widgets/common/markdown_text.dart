import 'package:flutter/material.dart';

class MarkdownText extends StatelessWidget {
  const MarkdownText(this.content, {super.key});

  final String content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lines = content.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final TextStyle? style;
        final String text;

        if (line.startsWith('#### ')) {
          text = line.substring(5);
          style = textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
        } else if (line.startsWith('### ')) {
          text = line.substring(4);
          style = textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
        } else if (line.startsWith('## ')) {
          text = line.substring(3);
          style = textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);
        } else if (line.startsWith('# ')) {
          text = line.substring(2);
          style = textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          );
        } else {
          text = line;
          style = textTheme.bodyMedium;
        }

        return SelectableText(text, style: style);
      }).toList(),
    );
  }
}
