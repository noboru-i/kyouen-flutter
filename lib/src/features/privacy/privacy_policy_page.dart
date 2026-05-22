import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/markdown_text.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const routeName = '/privacy';

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Privacy Policy'),
        ),
        body: FutureBuilder<String>(
          future: rootBundle.loadString('assets/privacy_policy.md'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text('Failed to load privacy policy.'),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MarkdownText(snapshot.data!),
            );
          },
        ),
      ),
    );
  }
}
