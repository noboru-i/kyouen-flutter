import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/config/environment.dart';
import 'package:kyouen_flutter/src/features/sign_in/sign_in_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Text(
              Environment.appName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.restorablePushNamed(context, StagePage.routeName);
              },
              child: const Text('スタート'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.restorablePushNamed(context, SignInPage.routeName);
              },
              child: const Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
