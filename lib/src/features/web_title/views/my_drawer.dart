import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/features/sign_in/sign_in_page.dart';
import 'package:kyouen_flutter/src/features/title/title_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              final user = snapshot.data!;
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    user.photoURL ?? 'https://via.placeholder.com/150',
                  ),
                ),
                accountName: Text(user.displayName ?? 'ゲスト'),
                accountEmail: Text(user.email ?? ''),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('ホーム'),
            onTap: () {
              Navigator.restorablePushNamed(context, TitlePage.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('設定'),
            onTap: () {
              Navigator.restorablePushNamed(context, SignInPage.routeName);
            },
          ),
        ],
      ),
    );
  }
}
