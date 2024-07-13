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
          children: [
            _Header(),
            _Body(),
          ],
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
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            ref.read(currentStageNoProvider.notifier).prev();
          },
          child: const Text('前へ'),
        ),
        Expanded(
          child: Text(
              // ignore: lines_longer_than_80_chars
              'STAGE: ${currentStage.hasValue ? currentStage.value!.stageNo : '?'}'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(currentStageNoProvider.notifier).next();
          },
          child: const Text('前へ'),
        ),
      ],
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
          // ignore: use_colored_box
          child: Container(
            color: Colors.green,
            child: Text('stage raw data: ${data.stage}'),
          ),
        );
      },
      error: (error, stackTrace) {
        print(error);
        print(stackTrace);
        return const Text('error');
      },
      loading: () {
        return const CircularProgressIndicator.adaptive();
      },
    );
  }
}
