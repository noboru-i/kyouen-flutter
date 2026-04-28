import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/features/account/account_page.dart';
import 'package:kyouen_flutter/src/features/privacy/privacy_policy_page.dart';
import 'package:kyouen_flutter/src/features/title/native_title_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1C2334),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 16);
              }

              final user = snapshot.data!;
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1C2334), Color(0xFF0D1117)],
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    user.photoURL ?? 'https://via.placeholder.com/150',
                  ),
                ),
                accountName: Text(
                  user.displayName ?? 'ゲスト',
                  style: const TextStyle(color: Colors.white),
                ),
                accountEmail: Text(
                  user.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white70),
            title: const Text('ホーム', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.restorablePushNamed(context, TitlePage.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white70),
            title: const Text('設定', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.restorablePushNamed(context, AccountPage.routeName);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'プライバシーポリシー',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                PrivacyPolicyPage.routeName,
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.white70,
            ),
            title: const Text(
              'ライセンス',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              showLicensePage(context: context);
            },
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData
                  ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                  : '';
              return ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white70),
                title: const Text(
                  'バージョン',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  version,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
