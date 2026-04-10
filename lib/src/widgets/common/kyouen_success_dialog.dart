import 'package:flutter/material.dart';

const _kAccent = Color(0xFFFF6B35);
const _kSurface = Color(0xFF1E2A3A);

class KyouenSuccessDialog extends StatefulWidget {
  const KyouenSuccessDialog({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<KyouenSuccessDialog> createState() => _KyouenSuccessDialogState();
}

class _KyouenSuccessDialogState extends State<KyouenSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.75, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fade.value,
            child: Transform.scale(scale: _scale.value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // アクセントカラーの共円アイコン
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kAccent.withValues(alpha: 0.12),
                  border: Border.all(color: _kAccent, width: 2),
                ),
                child: const Icon(Icons.check, color: _kAccent, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                '共円！！',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ステージクリア',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.54),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: widget.onClose,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1C2334),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('次のステージへ'),
                ),
              ),
            ],
          ),
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
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => KyouenSuccessDialog(onClose: onClose),
  );
}
