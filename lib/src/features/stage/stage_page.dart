import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/stage/ads/banner_ad_widget.dart';
import 'package:kyouen_flutter/src/features/stage/ads/hint_rewarded_ad_service.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/features/stage/widgets/stage_board.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';
import 'package:kyouen_flutter/src/utils/web_url_updater.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/hint_highlight_overlay.dart';
import 'package:kyouen_flutter/src/widgets/common/kyouen_answer_overlay_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/kyouen_success_dialog.dart';
import 'package:kyouen_flutter/src/widgets/common/stage_select_dialog.dart';

class _IsNavigatingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;
  void stop() => state = false;
}

final _isNavigatingProvider = NotifierProvider<_IsNavigatingNotifier, bool>(
  _IsNavigatingNotifier.new,
);

// Notifier for controlling kyouen overlay visibility
// Automatically resets when currentStageNoProvider changes
class ShowKyouenOverlayNotifier extends Notifier<bool> {
  @override
  bool build() {
    // Watch currentStageNoProvider to trigger reset when stage changes
    ref.watch(currentStageNoProvider);
    return false;
  }

  void show() => state = true;
  void hide() => state = false;
}

final showKyouenOverlayProvider =
    NotifierProvider<ShowKyouenOverlayNotifier, bool>(
      ShowKyouenOverlayNotifier.new,
    );

class _HintHighlightNotifier extends Notifier<int?> {
  @override
  int? build() {
    ref.watch(currentStageNoProvider);
    return null;
  }

  // ignore: use_setters_to_change_properties
  void show(int index) => state = index;
  void clear() => state = null;
}

final _hintHighlightIndexProvider =
    NotifierProvider<_HintHighlightNotifier, int?>(
      _HintHighlightNotifier.new,
    );

class StagePage extends ConsumerWidget {
  const StagePage({super.key});

  static const routeName = '/stage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<int>>(currentStageNoProvider, (_, next) {
      next.whenData(updateStageUrl);
    });

    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              Expanded(child: _Body()),
              _Footer(),
              SizedBox(height: 8),
              _BannerAdSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerStatefulWidget {
  const _Header();

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

enum _NavDirection { next, prev }

class _HeaderState extends ConsumerState<_Header> {
  _NavDirection? _activeNavigation;
  Timer? _loadingTimer;

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  Future<void> _navigate(
    _NavDirection direction,
    Future<bool> Function() action,
  ) async {
    if (_activeNavigation != null) {
      return;
    }
    setState(() => _activeNavigation = direction);

    _loadingTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        ref.read(_isNavigatingProvider.notifier).start();
      }
    });

    try {
      final moved = await action();
      if (!moved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noMoreStages)),
        );
      }
    } finally {
      _loadingTimer?.cancel();
      _loadingTimer = null;
      ref.read(_isNavigatingProvider.notifier).stop();
      if (mounted) {
        setState(() => _activeNavigation = null);
      }
    }
  }

  Future<void> _selectStage() async {
    if (_activeNavigation != null) {
      return;
    }
    final stageNo = await showStageSelectDialog(context);
    if (stageNo == null || !mounted) {
      return;
    }
    await ref.read(currentStageNoProvider.notifier).setStageNo(stageNo);
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = ref.watch(currentStageProvider);
    final currentStageNoAsync = ref.watch(currentStageNoProvider);
    final clearedStages = ref.watch(clearedStageNumbersProvider);
    final isLoadingShown = ref.watch(_isNavigatingProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isBusy = _activeNavigation != null;

    // Extract current stage number from AsyncValue
    final currentStageNo = currentStageNoAsync.when(
      data: (stageNo) => stageNo,
      loading: () => null,
      error: (_, _) => null,
    );
    if (currentStageNo == null) {
      return const SizedBox.shrink(); // or some loading indicator
    }

    // Check if current stage is cleared
    final isCleared = clearedStages.when(
      data: (cleared) => cleared.contains(currentStageNo),
      loading: () => false,
      error: (_, _) => false,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: isSmallScreen ? 1 : 2,
            child: FilledButton(
              onPressed: !isBusy && currentStageNo > 1
                  ? () => _navigate(
                      _NavDirection.prev,
                      () => ref.read(currentStageNoProvider.notifier).prev(),
                    )
                  : null,
              onLongPress: isBusy ? null : _selectStage,
              child: isLoadingShown && _activeNavigation == _NavDirection.prev
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.prevShort),
            ),
          ),
          Expanded(
            flex: isSmallScreen ? 2 : 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'STAGE: ${currentStage.hasValue ? currentStage.value!.stageNo : ''}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: isCleared ? const Color(0xFF2E7D32) : null,
                      ),
                    ),
                    if (isCleared) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: const Color(0xFF4CAF50),
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ],
                  ],
                ),
                if (currentStage.hasValue) ...[
                  const SizedBox(height: 2),
                  Text(
                    'created by ${currentStage.value!.creator}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: isSmallScreen ? 1 : 2,
            child: FilledButton(
              onPressed: isBusy
                  ? null
                  : () => _navigate(
                      _NavDirection.next,
                      () => ref.read(currentStageNoProvider.notifier).next(),
                    ),
              onLongPress: isBusy ? null : _selectStage,
              child: isLoadingShown && _activeNavigation == _NavDirection.next
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.nextShort),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends ConsumerStatefulWidget {
  const _Footer();

  @override
  ConsumerState<_Footer> createState() => _FooterState();
}

class _FooterState extends ConsumerState<_Footer> {
  bool _isHintLoading = false;

  Future<void> _onKyouenPressed() async {
    final isKyouen = ref.read(currentStageProvider.notifier).isKyouen();
    if (isKyouen) {
      debugPrint('KYOUEN!');
      ref.read(showKyouenOverlayProvider.notifier).show();

      await Future.wait([
        Future<void>.delayed(const Duration(milliseconds: 600)),
        ref.read(currentStageProvider.notifier).markCurrentStageCleared(),
      ]);

      if (!mounted) {
        return;
      }
      await showKyouenSuccessDialog(
        context: context,
        onClose: () {
          Navigator.of(context).pop();
        },
      );
      final moved = await ref.read(currentStageNoProvider.notifier).next();
      if (!moved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noMoreStages),
          ),
        );
      }
    } else {
      debugPrint('NOT KYOUEN!');
      if (mounted) {
        await _showNotKyouenDialog(context);
      }
      ref.read(currentStageProvider.notifier).reset();
    }
  }

  Future<void> _onHintPressed() async {
    if (_isHintLoading) {
      return;
    }
    setState(() => _isHintLoading = true);
    try {
      await ref
          .read(hintRewardedAdProvider.notifier)
          .show(
            onEarnedReward: _applyHint,
            onFailed: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to load ad')),
                );
              }
            },
          );
    } finally {
      if (mounted) {
        setState(() => _isHintLoading = false);
      }
    }
  }

  void _applyHint() {
    final index = ref
        .read(currentStageProvider.notifier)
        .pickRandomUnselectedSolutionIndex();
    if (index == null) {
      return;
    }
    ref.read(currentStageProvider.notifier).toggleSelect(index);
    ref.read(_hintHighlightIndexProvider.notifier).show(index);
  }

  Future<void> _showNotKyouenDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text(l10n.tooBad)),
          content: Text(l10n.notKyouenMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = ref.watch(currentStageProvider);
    final stoneStates =
        currentStage.asData?.value.stage.split('').map(StoneState.fromString) ??
        [];
    final whiteCount = stoneStates.where((s) => s == StoneState.white).length;
    final hasFourWhiteStones = whiteCount == 4;
    final hasAnyWhiteStone = whiteCount > 0;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: hasFourWhiteStones ? _onKyouenPressed : null,
              child: Text(AppLocalizations.of(context)!.kyouenButton),
            ),
          ),
          if (!kIsWeb) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: (!hasAnyWhiteStone && !_isHintLoading)
                  ? _onHintPressed
                  : null,
              tooltip: 'Hint (Ad)',
              icon: _isHintLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.lightbulb_outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNavigating = ref.watch(_isNavigatingProvider);
    final currentStage = ref.watch(currentStageProvider);
    final showOverlay = ref.watch(showKyouenOverlayProvider);
    final hintIndex = ref.watch(_hintHighlightIndexProvider);

    if (isNavigating) {
      return const StageBoard();
    }

    return currentStage.when(
      data: (data) {
        final boardSize = data.size;

        Widget? overlay;
        if (showOverlay) {
          overlay = Consumer(
            builder: (context, ref, child) {
              final kyouenData = ref
                  .read(currentStageProvider.notifier)
                  .getKyouenData();
              if (kyouenData != null) {
                return KyouenAnswerOverlayWidget(
                  kyouenData: kyouenData,
                  boardSize: boardSize,
                );
              }
              return const SizedBox.shrink();
            },
          );
        } else if (hintIndex != null) {
          overlay = HintHighlightOverlayWidget(
            targetIndex: hintIndex,
            boardSize: boardSize,
            onComplete: () =>
                ref.read(_hintHighlightIndexProvider.notifier).clear(),
          );
        }

        return StageBoard(
          stageData: data,
          onTapStone: (index) => _onTapStone(ref, index),
          overlay: overlay,
        );
      },
      error: (error, stackTrace) {
        debugPrint(error.toString());
        debugPrint(stackTrace.toString());
        return const Text('error');
      },
      loading: () {
        return const StageBoard();
      },
    );
  }

  void _onTapStone(WidgetRef ref, int index) {
    ref.watch(currentStageProvider.notifier).toggleSelect(index);
  }
}

class _BannerAdSection extends StatelessWidget {
  const _BannerAdSection();

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const SizedBox.shrink();
    }
    return const BannerAdWidget();
  }
}
