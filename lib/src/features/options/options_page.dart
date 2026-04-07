import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/features/privacy/privacy_policy_page.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  static const routeName = '/options';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('オプション'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                PrivacyPolicyPage.routeName,
              );
            },
          ),
        ],
      ),
    );
  }
}
