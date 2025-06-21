import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kyouen_flutter/src/config/environment.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

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
                context.go('/stage');
              },
              child: const Text('スタート'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context.go('/sign_in');
              },
              child: const Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
