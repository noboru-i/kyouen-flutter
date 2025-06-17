import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_Header(), _Body(), _Footer()],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              ref.read(currentStageNoProvider.notifier).prev();
            },
            child: const Text('前へ'),
          ),
          Expanded(
            child: Text(
              'STAGE: ${currentStage.hasValue ? currentStage.value!.stageNo : '?'}',
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(currentStageNoProvider.notifier).next();
            },
            child: const Text('前へ'),
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
            .where((element) => element == '2')
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
                    await _showKyouenDialog(context);
                    ref.read(currentStageNoProvider.notifier).next();
                  } else {
                    debugPrint('NOT KYOUEN!');
                    await _showNotKyouenDialog(context);
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
          title: const Text('共円！！'),
          content: const Text('おめでとうございます！'),
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
    return currentStage.when(
      data: (data) {
        return AspectRatio(
          aspectRatio: 1,
          child: ColoredBox(
            color: Colors.green,
            child: GridView.count(
              crossAxisCount: 6,
              children:
                  data.stage.split('').indexed.map((element) {
                    final (index, state) = element;
                    final stateEnum = switch (state) {
                      '0' => StoneState.none,
                      '1' => StoneState.black,
                      '2' => StoneState.white,
                      String() => StoneState.none,
                    };
                    return GestureDetector(
                      onTap: () => _onTapStone(ref, index),
                      child: _Stone(state: stateEnum, key: ValueKey(index)),
                    );
                  }).toList(),
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
        return AspectRatio(
          aspectRatio: 1,
          child: ColoredBox(
            color: Colors.green,
            child: Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
              child: const CircularProgressIndicator.adaptive(),
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
    return Stack(
      children: [
        Align(
          child: Container(
            height: 2,
            decoration: const BoxDecoration(color: Colors.brown),
          ),
        ),
        Align(
          child: Container(
            width: 2,
            decoration: const BoxDecoration(color: Colors.brown),
          ),
        ),
        _buildStone(),
      ],
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
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildWhiteStone() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

enum StoneState { none, black, white }
