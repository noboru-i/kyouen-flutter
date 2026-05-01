import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/features/stage/widgets/stage_board.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';
import 'package:kyouen_flutter/src/utils/web_url_updater.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/kyouen_answer_overlay_widget.dart';
import 'package:kyouen_flutter/src/widgets/common/kyouen_success_dialog.dart';

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
              onLongPress: !isBusy && currentStageNo > 1
                  ? () => _navigate(
                      _NavDirection.prev,
                      () => ref
                          .read(currentStageNoProvider.notifier)
                          .prevUncleared(),
                    )
                  : null,
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
              onLongPress: isBusy
                  ? null
                  : () => _navigate(
                      _NavDirection.next,
                      () => ref
                          .read(currentStageNoProvider.notifier)
                          .nextUncleared(),
                    ),
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

class _Footer extends ConsumerWidget {
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStage = ref.watch(currentStageProvider);
    final hasFourWhiteStones =
        currentStage.asData?.value.stage
            .split('')
            .where(
              (element) => StoneState.fromString(element) == StoneState.white,
            )
            .length ==
        4;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FilledButton(
        onPressed: hasFourWhiteStones
            ? () async {
                final isKyouen = ref
                    .read(currentStageProvider.notifier)
                    .isKyouen();
                if (isKyouen) {
                  debugPrint('KYOUEN!');

                  // Show kyouen overlay
                  ref.read(showKyouenOverlayProvider.notifier).show();

                  // オーバーレイアニメーション(500ms)完了を待ちつつ、DB書き込みを並列実行
                  await Future.wait([
                    Future<void>.delayed(const Duration(milliseconds: 600)),
                    ref
                        .read(currentStageProvider.notifier)
                        .markCurrentStageCleared(),
                  ]);

                  if (context.mounted) {
                    await showKyouenSuccessDialog(
                      context: context,
                      onClose: () {
                        Navigator.of(context).pop();
                      },
                    );
                    final moved = await ref
                        .read(currentStageNoProvider.notifier)
                        .next();
                    if (!moved && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.noMoreStages,
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  debugPrint('NOT KYOUEN!');
                  if (context.mounted) {
                    await _showNotKyouenDialog(context);
                  }
                  ref.read(currentStageProvider.notifier).reset();
                }
              }
            : null,
        child: Text(AppLocalizations.of(context)!.kyouenButton),
      ),
    );
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
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNavigating = ref.watch(_isNavigatingProvider);
    final currentStage = ref.watch(currentStageProvider);
    final showOverlay = ref.watch(showKyouenOverlayProvider);

    if (isNavigating) {
      return const StageBoard();
    }

    return currentStage.when(
      data: (data) {
        final boardSize = data.size;
        return StageBoard(
          stageData: data,
          onTapStone: (index) => _onTapStone(ref, index),
          overlay: showOverlay
              ? Consumer(
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
                )
              : null,
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
