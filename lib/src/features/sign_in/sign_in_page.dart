import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  static const routeName = '/sign_in';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

class _SignInView extends StatelessWidget {
  const _SignInView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: _signInWithTwitter,
            child: const Text('Sign in with X (Twitter)'),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: _signInWithApple,
            child: const Text('Sign in with Apple'),
          ),
        ),
      ],
    );
  }

  Future<void> _signInWithTwitter() async {
    await FirebaseAuth.instance.signOut();
    final twitterProvider = TwitterAuthProvider();

    if (kIsWeb) {
      await FirebaseAuth.instance.signInWithPopup(twitterProvider);
    } else {
      await FirebaseAuth.instance.signInWithProvider(twitterProvider);
    }
  }

  Future<void> _signInWithApple() async {
    final appleProvider = AppleAuthProvider();

    if (kIsWeb) {
      await FirebaseAuth.instance.signInWithPopup(appleProvider);
    } else {
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
    }
  }
}

class _LogoutView extends StatelessWidget {
  const _LogoutView({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('name: ${user.displayName}'),
        ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: const Text('ログアウト'),
        ),
      ],
    );
  }
}
