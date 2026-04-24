import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:kyouen_flutter/src/data/api/api_client.dart';
import 'package:kyouen_flutter/src/data/api/entity/login_request.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_service.g.dart';

@riverpod
class AccountService extends _$AccountService {
  @override
  void build() {}

  Future<void> signInWithTwitter() async {
    final logger = Logger();
    final link = ref.keepAlive();
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

      if (!ref.mounted) {
        logger.w('Ref not mounted after Twitter sign-in');
        return;
      }
      await _callLoginApi(userCredential.user);
    } on Exception catch (e) {
      logger.e('Twitter sign-in failed: $e');
      rethrow;
    } finally {
      link.close();
    }
  }

  Future<void> signInWithApple() async {
    final logger = Logger();
    final link = ref.keepAlive();
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

      if (!ref.mounted) {
        logger.w('Ref not mounted after Apple sign-in');
        return;
      }
      await _callLoginApi(userCredential.user);
    } on Exception catch (e) {
      logger.e('Apple sign-in failed: $e');
      rethrow;
    } finally {
      link.close();
    }
  }

  Future<void> signOut() async {
    final logger = Logger();
    final link = ref.keepAlive();
    try {
      final stageRepository = await ref.read(stageRepositoryProvider.future);
      await stageRepository.resetClearData();
      if (!ref.mounted) {
        logger.w('Ref not mounted after resetClearData');
        return;
      }
      ref
        ..invalidate(clearedStageNumbersProvider)
        ..invalidate(clearedStageCountProvider);
      await FirebaseAuth.instance.signOut();
    } on Exception catch (e) {
      logger.e('Sign-out failed: $e');
      rethrow;
    } finally {
      link.close();
    }
  }

  Future<void> deleteAccount() async {
    final logger = Logger();
    final link = ref.keepAlive();
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.deleteAccount();

      if (response.isSuccessful) {
        logger.i('Account deleted successfully');
        if (!ref.mounted) {
          logger.w('Ref not mounted after deleteAccount API call');
          return;
        }
        await signOut();
      } else {
        throw Exception('Failed to delete account: ${response.error}');
      }
    } on Exception catch (e) {
      logger.e('Error deleting account: $e');
      rethrow;
    } finally {
      link.close();
    }
  }

  Future<void> _callLoginApi(User? user) async {
    final logger = Logger();
    if (user == null) {
      return;
    }

    try {
      final idToken = await user.getIdToken();
      if (idToken == null) {
        logger.w('ID token is null');
        return;
      }

      if (!ref.mounted) {
        return;
      }
      final apiClient = ref.read(apiClientProvider);

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

    // Sync cleared stages after login; failures are non-fatal.
    try {
      if (!ref.mounted) {
        return;
      }
      final stageRepository = await ref.read(stageRepositoryProvider.future);
      await stageRepository.syncStages();
      ref
        ..invalidate(clearedStageNumbersProvider)
        ..invalidate(clearedStageCountProvider);
    } on Exception catch (e) {
      logger.w('Sync after login failed (non-fatal): $e');
    }
  }
}
