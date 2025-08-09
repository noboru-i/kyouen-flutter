import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/features/account/account_page.dart';

class AccountButton extends StatelessWidget {
  const AccountButton({
    super.key,
    this.height = 56,
    this.style,
    this.textStyle,
  });

  final double height;
  final ButtonStyle? style;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    try {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.hasData;
          return SizedBox(
            height: height,
            child: FilledButton.tonal(
              style: style,
              onPressed: () {
                Navigator.restorablePushNamed(context, AccountPage.routeName);
              },
              child: Text(
                isLoggedIn ? 'アカウント' : 'ログイン',
                style:
                    textStyle ??
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      );
    } on Exception {
      // Fallback for test environment where Firebase is not initialized
      return SizedBox(
        height: height,
        child: FilledButton.tonal(
          style: style,
          onPressed: () {
            Navigator.restorablePushNamed(context, AccountPage.routeName);
          },
          child: Text(
            'ログイン',
            style:
                textStyle ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }
}

class OutlinedAccountButton extends StatelessWidget {
  const OutlinedAccountButton({
    super.key,
    this.height = 48,
    this.style,
    this.textStyle,
  });

  final double height;
  final ButtonStyle? style;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    try {
      return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final isLoggedIn = snapshot.hasData;
          return SizedBox(
            height: height,
            child: OutlinedButton(
              style: style,
              onPressed: () {
                Navigator.restorablePushNamed(context, AccountPage.routeName);
              },
              child: Text(
                isLoggedIn ? 'アカウント' : 'ログイン',
                style:
                    textStyle ??
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      );
    } on Exception {
      // Fallback for test environment where Firebase is not initialized
      return SizedBox(
        height: height,
        child: OutlinedButton(
          style: style,
          onPressed: () {
            Navigator.restorablePushNamed(context, AccountPage.routeName);
          },
          child: Text(
            'ログイン',
            style:
                textStyle ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }
}
