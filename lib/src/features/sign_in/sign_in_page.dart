import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/login_request.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/widgets/theme/app_theme.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  static const routeName = '/sign_in';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
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
                onPressed: () => _signInWithTwitter(ref),
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
                onPressed: () => _signInWithApple(ref),
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

  Future<void> _signInWithTwitter(WidgetRef ref) async {
    await FirebaseAuth.instance.signOut();
    final twitterProvider = TwitterAuthProvider();

    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          twitterProvider,
        );
      } else {
        userCredential = await FirebaseAuth.instance.signInWithProvider(
          twitterProvider,
        );
      }

      await _callLoginApi(userCredential.user, ref);
    } on Exception catch (e) {
      debugPrint('Twitter sign-in failed: $e');
    }
  }

  Future<void> _signInWithApple(WidgetRef ref) async {
    final appleProvider = AppleAuthProvider();

    try {
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(
          appleProvider,
        );
      } else {
        userCredential = await FirebaseAuth.instance.signInWithProvider(
          appleProvider,
        );
      }

      await _callLoginApi(userCredential.user, ref);
    } on Exception catch (e) {
      debugPrint('Apple sign-in failed: $e');
    }
  }

  Future<void> _callLoginApi(User? user, WidgetRef ref) async {
    if (user == null) {
      return;
    }

    try {
      // keep instance before awaiting
      final apiClient = ref.read(apiClientProvider);

      final idToken = await user.getIdToken();
      if (idToken == null) {
        debugPrint('ID token is null');
        return;
      }

      final loginRequest = LoginRequest(token: idToken);

      final response = await apiClient.login(loginRequest);

      if (response.isSuccessful && response.body != null) {
        debugPrint('Login successful: ${response.body!.screenName}');
      } else {
        debugPrint('Login failed: ${response.error}');
      }
    } on Exception catch (e) {
      debugPrint('Login API call failed: $e');
    }
  }
}

class _LogoutView extends StatelessWidget {
  const _LogoutView({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
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
                  FirebaseAuth.instance.signOut();
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
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
