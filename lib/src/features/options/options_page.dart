import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/consent/consent_service.dart';
import 'package:kyouen_flutter/src/features/privacy/privacy_policy_page.dart';
import 'package:kyouen_flutter/src/features/terms/terms_of_service_page.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OptionsPage extends ConsumerStatefulWidget {
  const OptionsPage({super.key});

  static const routeName = '/options';

  @override
  ConsumerState<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends ConsumerState<OptionsPage> {
  late final Future<bool> _privacyOptionsRequiredFuture;
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _privacyOptionsRequiredFuture = ref
        .read(consentServiceProvider)
        .isPrivacyOptionsRequired;
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.options),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.restorablePushNamed(
                  context,
                  PrivacyPolicyPage.routeName,
                );
              },
            ),
            if (!kIsWeb)
              FutureBuilder<bool>(
                future: _privacyOptionsRequiredFuture,
                builder: (context, snapshot) {
                  if (snapshot.data != true) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    leading: const Icon(Icons.manage_accounts_outlined),
                    title: Text(l10n.adConsentSettings),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ref.read(consentServiceProvider).showPrivacyOptions();
                    },
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l10n.termsOfService),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.restorablePushNamed(
                  context,
                  TermsOfServicePage.routeName,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.licenses),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(context: context);
              },
            ),
            FutureBuilder<PackageInfo>(
              future: _packageInfoFuture,
              builder: (context, snapshot) {
                final version = snapshot.hasData
                    ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                    : '';
                return ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.version),
                  trailing: Text(version),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
