import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kyouen_flutter/src/config/environment.dart';
import 'package:kyouen_flutter/src/features/account/account_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';
import 'package:kyouen_flutter/src/features/title/native_title_page.dart';
import 'package:kyouen_flutter/src/features/title/web_title_page.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';
import 'package:kyouen_flutter/src/widgets/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      restorationScopeId: 'app',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      onGenerateTitle: (BuildContext context) => Environment.appName,
      theme: AppTheme.lightTheme,
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
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
              default:
                if (routeSettings.name?.startsWith('/link') ?? false) {
                  // Firebase auth redirect (e.g. Twitter login callback).
                  // Replace the stack so that back button returns to TitlePage.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      AccountPage.routeName,
                      (route) => route.settings.name == TitlePage.routeName,
                    );
                  });
                  return const SizedBox.shrink();
                }
                if (kIsWeb) {
                  return const WebTitlePage();
                } else {
                  return const TitlePage();
                }
            }
          },
        );
      },
    );
  }
}
