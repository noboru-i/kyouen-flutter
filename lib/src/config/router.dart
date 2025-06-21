import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kyouen_flutter/src/features/sign_in/sign_in_page.dart';
import 'package:kyouen_flutter/src/features/stage/stage_page.dart';
import 'package:kyouen_flutter/src/features/title/title_page.dart';
import 'package:kyouen_flutter/src/settings/settings_controller.dart';
import 'package:kyouen_flutter/src/settings/settings_view.dart';

GoRouter createRouter(SettingsController settingsController) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'title',
        builder: (context, state) => const TitlePage(),
      ),
      GoRoute(
        path: '/stage',
        name: 'stage',
        builder: (context, state) => const StagePage(),
      ),
      GoRoute(
        path: '/sign_in',
        name: 'signIn',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => SettingsView(controller: settingsController),
      ),
    ],
  );
}