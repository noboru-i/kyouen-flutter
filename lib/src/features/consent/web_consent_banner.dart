import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/analytics/analytics_service.dart';
import 'package:kyouen_flutter/src/features/consent/web_storage.dart'
    if (dart.library.js_interop) 'package:kyouen_flutter/src/features/consent/web_storage_web.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';

const _storageKey = 'consent_choice_v1';

/// Webのみに表示するCookie同意バナー。
///
/// ネイティブはUMP SDKが同等の役割を担う。
/// localStorageに同意済み/拒否済みが保存されていれば何も表示しない。
class WebConsentBanner extends ConsumerStatefulWidget {
  const WebConsentBanner({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<WebConsentBanner> createState() => _WebConsentBannerState();
}

class _WebConsentBannerState extends ConsumerState<WebConsentBanner> {
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      try {
        final saved = getConsentStorage(_storageKey);
        if (saved == null) {
          setState(() => _showBanner = true);
        }
      } on Exception catch (_) {
        setState(() => _showBanner = true);
      }
    }
  }

  Future<void> _accept() async {
    try {
      setConsentStorage(_storageKey, 'granted');
    } on Exception catch (_) {}
    await ref
        .read(analyticsServiceProvider)
        .setConsent(
          analyticsStorage: true,
          adStorage: true,
        );
    setState(() => _showBanner = false);
  }

  Future<void> _reject() async {
    try {
      setConsentStorage(_storageKey, 'denied');
    } on Exception catch (_) {}
    await ref
        .read(analyticsServiceProvider)
        .setConsent(
          analyticsStorage: false,
          adStorage: false,
        );
    setState(() => _showBanner = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBanner) {
      return widget.child;
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          width: screenWidth,
          bottom: 0,
          child: _ConsentBannerBar(onAccept: _accept, onReject: _reject),
        ),
      ],
    );
  }
}

class _ConsentBannerBar extends StatelessWidget {
  const _ConsentBannerBar({required this.onAccept, required this.onReject});

  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.consentBannerMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onReject,
                  child: Text(
                    l10n.consentReject,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(80, 40),
                  ),
                  child: Text(l10n.consentAcceptAll),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
