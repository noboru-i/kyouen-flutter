import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kyouen_flutter/src/config/environment.dart';
import 'package:kyouen_flutter/src/features/sign_in/sign_in_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';
import 'package:kyouen_flutter/src/features/title/title_page.dart';
import 'package:kyouen_flutter/src/features/web_title/web_title_page.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';
import 'package:kyouen_flutter/src/settings/settings_controller.dart';
import 'package:kyouen_flutter/src/settings/settings_view.dart';
import 'package:kyouen_flutter/src/widgets/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
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
          themeMode: settingsController.themeMode,
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
                  case SignInPage.routeName:
                    return const SignInPage();
                  // TODO: remove the followings.
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  default:
                    throw Exception();
                }
              },
            );
          },
        );
      },
    );
  }
}
