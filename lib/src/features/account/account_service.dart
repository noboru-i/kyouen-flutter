import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/login_request.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_service.g.dart';

@riverpod
class AccountService extends _$AccountService {
  @override
  void build() {}

  Future<void> signInWithTwitter() async {
    final logger = Logger();
    await signOut();
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
      logger.e('Twitter sign-in failed: $e');
      rethrow;
    }
  }

  Future<void> signInWithApple() async {
    final logger = Logger();
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
      logger.e('Apple sign-in failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    final logger = Logger();
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.deleteAccount();

      if (response.isSuccessful) {
        logger.i('Account deleted successfully');
        // Sign out from Firebase after successful account deletion
        await signOut();
      } else {
        throw Exception('Failed to delete account: ${response.error}');
      }
    } catch (e) {
      logger.e('Error deleting account: $e');
      rethrow;
    }
  }

  Future<void> _callLoginApi(User? user) async {
    final logger = Logger();
    if (user == null) {
      return;
    }

    try {
      final apiClient = ref.read(apiClientProvider);

      final idToken = await user.getIdToken();
      if (idToken == null) {
        logger.w('ID token is null');
        return;
      }

      final loginRequest = LoginRequest(token: idToken);

      final response = await apiClient.login(loginRequest);

      if (response.isSuccessful && response.body != null) {
        logger.i('Login successful: ${response.body!.screenName}');
      } else {
        logger.e('Login failed: ${response.error}');
        throw Exception('Login failed: ${response.error}');
      }
    } on Exception catch (e) {
      logger.e('Login API call failed: $e');
      rethrow;
    }
  }
}
