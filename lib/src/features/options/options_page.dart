import 'package:flutter/material.dart';
import 'package:kyouen_flutter/src/features/privacy/privacy_policy_page.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  static const routeName = '/options';

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
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.licenses),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(context: context);
              },
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
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
