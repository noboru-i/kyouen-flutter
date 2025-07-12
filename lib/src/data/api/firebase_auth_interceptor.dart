import 'package:chopper/chopper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Firebase認証トークンを自動的にAPIリクエストに含めるInterceptor
class FirebaseAuthInterceptor implements Interceptor {
  static final _logger = Logger();

  @override
  Future<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    final request = chain.request;

    try {
      // Firebase認証の現在のユーザーを取得
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Firebase IDトークンを取得
        final token = await user.getIdToken();

        // AuthorizationヘッダーにBearerトークンを追加
        final newRequest = request.copyWith(
          headers: {...request.headers, 'Authorization': 'Bearer $token'},
        );

        if (kDebugMode) {
          _logger.d('Firebase Auth Interceptor: Token added to request');
        }

        return chain.proceed(newRequest);
      } else {
        if (kDebugMode) {
          _logger.d(
            'Firebase Auth Interceptor: No authenticated user, proceeding without token',
          );
        }
        return chain.proceed(request);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        _logger.e('Firebase Auth Interceptor: Error getting token: $e');
      }
      // エラーが発生した場合はトークンなしで続行
      return chain.proceed(request);
    }
  }
}
