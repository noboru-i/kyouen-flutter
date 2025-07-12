import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/features/account/account_service.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/widgets/theme/app_theme.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  static const routeName = '/account';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('アカウント')),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const _SignInView();
          }

          return _LogoutView(user: snapshot.data!);
        },
      ),
    );
  }
}

class _SignInView extends ConsumerWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundWidget(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            // Twitter Sign In Button
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: () => _signInWithTwitter(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.twitterBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.alternate_email, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Sign in with X (Twitter)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Apple Sign In Button
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: () => _signInWithApple(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apple, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Sign in with Apple',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithTwitter(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(accountServiceProvider.notifier).signInWithTwitter();
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Twitter sign-in failed: $e')));
      }
    }
  }

  Future<void> _signInWithApple(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(accountServiceProvider.notifier).signInWithApple();
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Apple sign-in failed: $e')));
      }
    }
  }
}

class _LogoutView extends ConsumerWidget {
  const _LogoutView({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackgroundWidget(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            // User info section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    user.photoURL != null
                        ? CircleAvatar(
                          radius: 32,
                          backgroundImage: NetworkImage(user.photoURL!),
                        )
                        : const Icon(Icons.account_circle, size: 32),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'ユーザー',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Logout button
            SizedBox(
              height: 56,
              child: FilledButton.tonal(
                onPressed: () {
                  ref.read(accountServiceProvider.notifier).signOut();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'ログアウト',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Delete Account button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showDeleteAccountDialog(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'アカウント削除',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('アカウント削除'),
            content: const Text(
              'アカウントを削除してもよろしいですか？この操作は元に戻すことができず、すべてのデータが永久に削除されます。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteAccount(context, ref);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('削除'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      // ignore: unawaited_futures
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('アカウントを削除中...'),
                ],
              ),
            ),
      );

      await ref.read(accountServiceProvider.notifier).deleteAccount();

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('アカウントが正常に削除されました')));
        // After account deletion, user is automatically signed out
        // The StreamBuilder will detect the auth state change and show sign-in view
      }
    } on Exception catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('アカウント削除に失敗しました: $e')));
      }
    }
  }
}
