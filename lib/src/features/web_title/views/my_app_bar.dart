import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/features/sign_in/sign_in_page.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      actions: [
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return TextButton(
                onPressed: () {
                  Navigator.restorablePushNamed(context, SignInPage.routeName);
                },
                child: const Text('ログイン'),
              );
            }

            return TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Text('ログアウト'),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
