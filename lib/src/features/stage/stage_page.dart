import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/data/repository/stage_repository.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';

class StagePage extends ConsumerWidget {
  const StagePage({super.key});

  static const routeName = '/stage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // initialize and keep instance
    // TODO: デフォルト値の設定
    ref.watch(currentStageNoProvider);

    return const Scaffold(
      body: BackgroundWidget(
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
            child: ElevatedButton(
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
            child: ElevatedButton(
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
    final isEnabled =
        currentStage.asData?.value.stage
            .split('')
            .where(
              (element) => StoneState.fromString(element) == StoneState.white,
            )
            .length ==
        4;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed:
            isEnabled
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
          title: const Row(
            children: [
              Icon(Icons.celebration, color: Color(0xFFFFD700)), // Gold color
              SizedBox(width: 8),
              Text('共円！！'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 48),
              SizedBox(height: 16),
              Text(
                'おめでとうございます！\nステージクリア！',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
              ),
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
          title: const Text('残念！'),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBoardSize = screenWidth * 0.9;

    return currentStage.when(
      data: (data) {
        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxBoardSize,
              maxHeight: maxBoardSize,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD4AF37), // Gold
                      Color(0xFFB8860B), // Dark Golden Rod
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.count(
                    crossAxisCount: 6,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    children:
                        data.stage.split('').indexed.map((element) {
                          final (index, state) = element;
                          final stateEnum = StoneState.fromString(state);
                          return GestureDetector(
                            onTap: () => _onTapStone(ref, index),
                            child: _Stone(
                              state: stateEnum,
                              key: ValueKey(index),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        debugPrint(error.toString());
        debugPrint(stackTrace.toString());
        return const Text('error');
      },
      loading: () {
        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxBoardSize,
              maxHeight: maxBoardSize,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFD4AF37), // Gold
                      Color(0xFFB8860B), // Dark Golden Rod
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator.adaptive(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTapStone(WidgetRef ref, int index) {
    ref.watch(currentStageProvider.notifier).toggleSelect(index);
  }
}

class _Stone extends StatelessWidget {
  const _Stone({required this.state, super.key});

  final StoneState state;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4E4BC), // Light wood color
        border: Border.all(
          color: const Color(0xFF8B4513), // Saddle brown
          width: 0.5,
        ),
      ),
      child: Stack(
        children: [
          // Grid lines
          Align(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                color: Color(0xFF8B4513), // Saddle brown
              ),
            ),
          ),
          Align(
            child: Container(
              width: 1,
              decoration: const BoxDecoration(
                color: Color(0xFF8B4513), // Saddle brown
              ),
            ),
          ),
          // Stone
          Padding(padding: const EdgeInsets.all(4), child: _buildStone()),
        ],
      ),
    );
  }

  Widget _buildStone() {
    switch (state) {
      case StoneState.none:
        return const SizedBox();
      case StoneState.black:
        return _buildBlackStone();
      case StoneState.white:
        return _buildWhiteStone();
    }
  }

  Widget _buildBlackStone() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFF4A4A4A), // Light gray
            Color(0xFF1C1C1C), // Dark gray
            Color(0xFF000000), // Black
          ],
          stops: [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteStone() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFFFFF), // White
            Color(0xFFF0F0F0), // Light gray
            Color(0xFFE0E0E0), // Darker gray
          ],
          stops: [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );
  }
}
