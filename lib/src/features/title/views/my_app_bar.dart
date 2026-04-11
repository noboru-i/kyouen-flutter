import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/features/account/account_page.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      actions: [
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return TextButton(
                onPressed: () {
                  Navigator.restorablePushNamed(context, AccountPage.routeName);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('ログイン'),
              );
            }

            return TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
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
