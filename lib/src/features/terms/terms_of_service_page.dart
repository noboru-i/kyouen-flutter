import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/markdown_text.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static const routeName = '/terms';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(l10n.termsOfService),
        ),
        body: FutureBuilder<String>(
          future: rootBundle.loadString('assets/terms_of_service.md'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(l10n.loadTermsOfServiceFailed),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MarkdownText(snapshot.data!),
            );
          },
        ),
      ),
    );
  }
}
