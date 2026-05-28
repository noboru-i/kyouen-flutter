import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kyouen_flutter/src/config/environment.dart';
import 'package:kyouen_flutter/src/data/analytics/analytics_service.dart';
import 'package:kyouen_flutter/src/data/consent/consent_service.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/account/account_page.dart';
import 'package:kyouen_flutter/src/features/consent/web_consent_banner.dart';
import 'package:kyouen_flutter/src/features/create_stage/create_stage_page.dart';
import 'package:kyouen_flutter/src/features/notification/push_notification_service.dart';
import 'package:kyouen_flutter/src/features/options/options_page.dart';
import 'package:kyouen_flutter/src/features/privacy/privacy_policy_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/features/terms/terms_of_service_page.dart';
import 'package:kyouen_flutter/src/features/title/native_title_page.dart';
import 'package:kyouen_flutter/src/features/title/web_title_page.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';
import 'package:kyouen_flutter/src/widgets/theme/app_theme.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final FirebaseAnalyticsObserver _analyticsObserver =
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(analyticsServiceProvider).initPlatformProperty(),
    );
    if (!kIsWeb) {
      _initDeepLinkStream();
      _initNotificationTapHandling();
      _initForegroundNotificationHandling();
      // ATTダイアログはウィンドウが表示済みである必要があるため、
      // 最初のフレーム描画後に実行する
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_initTracking());
      });
    }
  }

  Future<void> _initTracking() async {
    // 1. ATT: Apple要件。トラッキング前に最初に取得する
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
    // 2. UMP同意: ATTの結果を参照して広告・Analytics同意を取得する
    await ref.read(consentServiceProvider).requestConsent();
    // 3. PUSH通知: 広告同意とは独立しており、最後に確認する
    await _requestPushPermission();
    await MobileAds.instance.initialize();
  }

  Future<void> _requestPushPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await messaging.subscribeToTopic('stage_added');
    }
  }

  void _initDeepLinkStream() {
    final appLinks = AppLinks();
    _linkSubscription = appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  Future<void> _handleDeepLink(Uri uri) async {
    final stageNo = _extractStageNo(uri);
    if (stageNo == null) {
      return;
    }
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logDeepLinkOpen(stageNo: stageNo, source: 'app_links'),
    );
    await _navigateToStage(stageNo);
  }

  int? _extractStageNo(Uri uri) {
    final stageParam = uri.queryParameters['stage'];
    if (stageParam == null) {
      return null;
    }
    final stageNo = int.tryParse(stageParam);
    if (stageNo == null || stageNo <= 0) {
      return null;
    }
    return stageNo;
  }

  void _initNotificationTapHandling() {
    FirebaseMessaging.instance.getInitialMessage().then(
      _handleNotificationNavigation,
    );

    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationNavigation,
    );
  }

  Future<void> _handleNotificationNavigation(RemoteMessage? message) async {
    if (message == null) {
      return;
    }

    final stageNo = extractTargetStageNo(message.data);
    if (stageNo == null) {
      return;
    }

    unawaited(
      ref.read(analyticsServiceProvider).logNotificationOpen(stageNo: stageNo),
    );
    await _openStageFromNotification(stageNo);
  }

  Future<void> _openStageFromNotification(int stageNo) async {
    final repository = await ref.read(stageRepositoryProvider.future);
    final exists = await repository.stageExists(stageNo);
    if (!exists || !mounted) {
      return;
    }

    ref
      ..invalidate(clearedStageNumbersProvider)
      ..invalidate(clearedStageCountProvider);

    await _navigateToStage(stageNo);
  }

  Future<void> _navigateToStage(int stageNo) async {
    await ref.read(currentStageNoProvider.notifier).setStageNo(stageNo);
    unawaited(
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        StagePage.routeName,
        (route) => route.isFirst,
      ),
    );
  }

  void _initForegroundNotificationHandling() {
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
      (message) {
        final stageNo = extractTargetStageNo(message.data);
        if (stageNo == null) {
          return;
        }

        final context = _navigatorKey.currentContext;
        if (context == null || !context.mounted) {
          return;
        }

        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.newStageAdded ?? 'New stage added',
            ),
            action: SnackBarAction(
              label: l10n?.openAction ?? 'Open',
              onPressed: () {
                unawaited(_openStageFromNotification(stageNo));
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Web: ハッシュベースURLで自動ルーティングされるため initialRoute 設定不要。
    // ネイティブ: ディープリンクでコールドスタートした場合のみ初期ルートをステージに設定。
    final initialStageNo = ref.read(initialDeepLinkStageNoProvider);
    final initialRoute = (!kIsWeb && initialStageNo != null)
        ? StagePage.routeName
        : TitlePage.routeName;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [_analyticsObserver],
      restorationScopeId: 'app',
      builder: kIsWeb
          ? (context, child) => WebConsentBanner(child: child!)
          : null,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (BuildContext context) => Environment.appName,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            // クエリパラメーターを除いたパス部分だけでルーティングする
            final path = Uri.parse(routeSettings.name ?? '/').path;
            switch (path) {
              case TitlePage.routeName:
                if (kIsWeb) {
                  return const WebTitlePage();
                } else {
                  return const TitlePage();
                }
              case StagePage.routeName:
                return const StagePage();
              case AccountPage.routeName:
                return const AccountPage();
              case OptionsPage.routeName:
                return const OptionsPage();
              case PrivacyPolicyPage.routeName:
                return const PrivacyPolicyPage();
              case TermsOfServicePage.routeName:
                return const TermsOfServicePage();
              case CreateStagePage.routeName:
                return const CreateStagePage();
              default:
                // 未知パス（旧URLの /html/list.html 等）はWebのみ対応
                if (kIsWeb) {
                  if (initialStageNo != null) {
                    return const StagePage();
                  }
                  return const WebTitlePage();
                }
                throw Exception();
            }
          },
        );
      },
    );
  }
}
