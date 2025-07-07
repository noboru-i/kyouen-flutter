import 'package:flutter/material.dart';

class KyouenSuccessDialog extends StatefulWidget {
  const KyouenSuccessDialog({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<KyouenSuccessDialog> createState() => _KyouenSuccessDialogState();
}

class _KyouenSuccessDialogState extends State<KyouenSuccessDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 48),
                SizedBox(width: 8),
                Text(
                  '共円！！',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onClose,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                ),
                child: const Text('次のステージへ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showKyouenSuccessDialog({
  required BuildContext context,
  required VoidCallback onClose,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (context) => KyouenSuccessDialog(onClose: onClose),
  );
}
