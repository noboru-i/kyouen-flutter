import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyouen_flutter/src/features/stage/stage_service.dart';
import 'package:kyouen_flutter/src/features/title/total_stage_count_provider.dart';
import 'package:kyouen_flutter/src/localization/app_localizations.dart';

Future<int?> showStageSelectDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (context) => const _StageSelectDialog(),
  );
}

class _StageSelectDialog extends ConsumerStatefulWidget {
  const _StageSelectDialog();

  @override
  ConsumerState<_StageSelectDialog> createState() => _StageSelectDialogState();
}

class _StageSelectDialogState extends ConsumerState<_StageSelectDialog> {
  late final TextEditingController _controller;
  int _stageNo = 1;
  int? _initializedForStageNo;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncText(int value) {
    final text = value.toString();
    if (_controller.text == text) {
      return;
    }
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  int _clampStageNo(int value, int maxStageNo) {
    return value.clamp(1, maxStageNo);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalStageCount = ref.watch(totalStageCountProvider).asData?.value;
    final currentStageNo = ref.watch(currentStageNoProvider).asData?.value ?? 1;
    final maxStageNo = totalStageCount ?? 0;
    final isReady = maxStageNo > 0;

    if (_initializedForStageNo != currentStageNo) {
      _initializedForStageNo = currentStageNo;
      _stageNo = isReady
          ? _clampStageNo(currentStageNo, maxStageNo)
          : currentStageNo;
      _syncText(_stageNo);
    }

    return AlertDialog(
      title: Text(l10n.selectStage),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              enabled: isReady,
              decoration: InputDecoration(
                labelText: l10n.stageNumber,
                suffixText: isReady ? '/ $maxStageNo' : null,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed == null || !isReady) {
                  return;
                }
                final nextStageNo = _clampStageNo(parsed, maxStageNo);
                setState(() => _stageNo = nextStageNo);
                if (parsed != nextStageNo) {
                  _syncText(nextStageNo);
                }
              },
            ),
            const SizedBox(height: 24),
            Slider(
              min: 1,
              max: isReady ? maxStageNo.toDouble() : 1,
              divisions: isReady && maxStageNo > 1 ? maxStageNo - 1 : null,
              value: isReady
                  ? _clampStageNo(_stageNo, maxStageNo).toDouble()
                  : 1,
              label: isReady ? _stageNo.toString() : null,
              onChanged: isReady
                  ? (value) {
                      final nextStageNo = value.round();
                      setState(() => _stageNo = nextStageNo);
                      _syncText(nextStageNo);
                    }
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: isReady
                    ? () {
                        final parsed = int.tryParse(_controller.text);
                        final selectedStageNo = _clampStageNo(
                          parsed ?? _stageNo,
                          maxStageNo,
                        );
                        Navigator.of(context).pop(selectedStageNo);
                      }
                    : null,
                child: Text(l10n.go),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
