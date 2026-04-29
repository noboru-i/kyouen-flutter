import 'package:flutter/material.dart';

const _kBoardGreenLight = Color(0xFF4CAF50);
const _kBoardGreenDark = Color(0xFF2E7D32);

class BoardCardWidget extends StatelessWidget {
  const BoardCardWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          elevation: 8,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kBoardGreenLight, _kBoardGreenDark],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
