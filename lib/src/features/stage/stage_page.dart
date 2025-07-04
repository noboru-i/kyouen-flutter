import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/features/stage/widgets/stage_board.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';

class StagePage extends ConsumerWidget {
  const StagePage({super.key});

  static const routeName = '/stage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // initialize and keep instance
    // TODO: デフォルト値の設定
    ref.watch(currentStageNoProvider);

    return Scaffold(
      appBar: AppBar(),
      body: const BackgroundWidget(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_Header(), Expanded(child: _Body()), _Footer()],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStage = ref.watch(currentStageProvider);
    final currentStageNo = ref.watch(currentStageNoProvider);
    final clearedStages = ref.watch(clearedStageNumbersProvider);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
              onPressed: () {
                ref.read(currentStageNoProvider.notifier).prev();
              },
              child: Text(isSmallScreen ? '前' : '前へ'),
            ),
          ),
          Expanded(
            flex: isSmallScreen ? 3 : 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'STAGE: ${currentStage.hasValue ? currentStage.value!.stageNo : '?'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isCleared
                            ? const Color(0xFF2E7D32)
                            : null, // Dark green for cleared
                  ),
                ),
                if (isCleared) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF4CAF50), // Material green
                    size: isSmallScreen ? 16 : 20,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: isSmallScreen ? 1 : 2,
            child: FilledButton(
              onPressed: () {
                ref.read(currentStageNoProvider.notifier).next();
              },
              child: Text(isSmallScreen ? '次' : '次へ'),
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
        onPressed:
            hasFourWhiteStones
                ? () async {
                  final isKyouen =
                      ref.read(currentStageProvider.notifier).isKyouen();
                  if (isKyouen) {
                    debugPrint('KYOUEN!');
                    // Mark stage as cleared
                    await ref
                        .read(currentStageProvider.notifier)
                        .markCurrentStageCleared();
                    if (context.mounted) {
                      await _showKyouenDialog(context);
                    }
                    ref.read(currentStageNoProvider.notifier).next();
                  } else {
                    debugPrint('NOT KYOUEN!');
                    if (context.mounted) {
                      await _showNotKyouenDialog(context);
                    }
                    ref.read(currentStageProvider.notifier).reset();
                  }
                }
                : null,
        child: const Text('共円！！'),
      ),
    );
  }

  Future<void> _showKyouenDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('共円！！')),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 48),
              SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('次のステージへ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNotKyouenDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('残念！')),
          content: const Text('共円ではありませんでした。'),
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
    final currentStage = ref.watch(currentStageProvider);

    return currentStage.when(
      data: (data) {
        return StageBoard(
          stageData: data,
          onTapStone: (index) => _onTapStone(ref, index),
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
