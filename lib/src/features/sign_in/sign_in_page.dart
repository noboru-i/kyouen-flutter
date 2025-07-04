import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/login_request.dart';
import 'package:kyouen_flutter/src/features/common/background_widget.dart';

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
    return BackgroundWidget(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Title
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.login,
                      size: 48,
                      color: Color(0xFF4A90E2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ログイン',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF2C3E50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ソーシャルアカウントでログイン',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Twitter Sign In Button
              Container(
                height: 56,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _signInWithTwitter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DA1F2), // Twitter blue
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
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
              // Apple Sign In Button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _signInWithApple,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
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
      ),
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
    return BackgroundWidget(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // User info card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 64,
                      color: Color(0xFF4A90E2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ログイン済み',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF2C3E50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.displayName ?? 'ユーザー',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Logout button
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C), // Red
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
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
      ),
    );
  }
}
