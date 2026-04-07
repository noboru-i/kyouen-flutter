import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const routeName = '/privacy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('assets/privacy_policy.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load privacy policy.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _MarkdownText(snapshot.data!),
          );
        },
      ),
    );
  }
}

class _MarkdownText extends StatelessWidget {
  const _MarkdownText(this.content);

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
