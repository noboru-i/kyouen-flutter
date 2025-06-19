import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/login_request.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  static const routeName = '/sign_in';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _SignInView(ref: ref);
          }

          return _LogoutView(user: snapshot.data!);
        },
      ),
    );
  }
}

class _SignInView extends StatelessWidget {
  const _SignInView({required this.ref});

  final WidgetRef ref;

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

      await _callLoginApi(userCredential.user);
    } on Exception catch (e) {
      debugPrint('Twitter sign-in failed: $e');
    }
  }

  Future<void> _signInWithApple() async {
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

      await _callLoginApi(userCredential.user);
    } on Exception catch (e) {
      debugPrint('Apple sign-in failed: $e');
    }
  }

  Future<void> _callLoginApi(User? user) async {
    if (user == null) {
      return;
    }

    try {
      final idToken = await user.getIdToken();
      if (idToken == null) {
        debugPrint('ID token is null');
        return;
      }

      final apiClient = ref.read(apiClientProvider);
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
