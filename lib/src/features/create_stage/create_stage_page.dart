import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/features/create_stage/create_stage_service.dart';
import 'package:kyouen_flutter/src/features/create_stage/widgets/create_stage_board.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/widgets/common/background_widget.dart';
import 'package:kyouen_flutter/src/widgets/theme/app_theme.dart';

class CreateStagePage extends ConsumerStatefulWidget {
  const CreateStagePage({super.key});

  static const routeName = '/create-stage';

  @override
  ConsumerState<CreateStagePage> createState() => _CreateStagePageState();
}

class _CreateStagePageState extends ConsumerState<CreateStagePage> {
  final _creatorController = TextEditingController();
  bool _controllerInitialized = false;

  @override
  void dispose() {
    _creatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(createStageProvider);

    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('ステージ作成'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
          data: (state) {
            if (!_controllerInitialized) {
              _creatorController.text = state.creator;
              _controllerInitialized = true;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SizeSelector(
                      selectedSize: state.size,
                      hasStones: state.stage.contains(StoneState.white.value),
                    ),
                    const SizedBox(height: 16),
                    CreateStageBoard(
                      stage: state.stage,
                      size: state.size,
                      kyouen: state.kyouen,
                      onTap: state.kyouen == null
                          ? (index) => ref
                                .read(createStageProvider.notifier)
                                .tapCell(index)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    if (state.kyouen != null) ...[
                      _KyouenForm(
                        controller: _creatorController,
                        isSubmitting: state.isSubmitting,
                        hasSubmitted: state.hasSubmitted,
                        onCreatorChanged: (name) => ref
                            .read(createStageProvider.notifier)
                            .setCreator(name),
                        onSubmit: () => _submit(context),
                      ),
                      const SizedBox(height: 12),
                    ],
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(createStageProvider.notifier).reset(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('リセット'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    try {
      await ref.read(createStageProvider.notifier).submit();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ステージを送信しました！')),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('送信に失敗しました: $e')),
        );
      }
    }
  }
}

class _SizeSelector extends ConsumerWidget {
  const _SizeSelector({required this.selectedSize, required this.hasStones});

  final int selectedSize;
  final bool hasStones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SegmentedButton<int>(
        selected: {selectedSize},
        segments: const [
          ButtonSegment(value: 6, label: Text('6×6')),
          ButtonSegment(value: 9, label: Text('9×9')),
        ],
        onSelectionChanged: hasStones
            ? null
            : (selection) {
                ref.read(createStageProvider.notifier).setSize(selection.first);
              },
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white54;
          }),
        ),
      ),
    );
  }
}

class _KyouenForm extends StatelessWidget {
  const _KyouenForm({
    required this.controller,
    required this.isSubmitting,
    required this.hasSubmitted,
    required this.onCreatorChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final bool hasSubmitted;
  final void Function(String) onCreatorChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '共円成立！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '名前',
              labelStyle: const TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white38),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppTheme.accentColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onCreatorChanged,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: (isSubmitting || hasSubmitted) ? null : onSubmit,
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(hasSubmitted ? '送信済み' : '送信する'),
          ),
        ],
      ),
    );
  }
}
