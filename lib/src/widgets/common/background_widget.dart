import 'package:flutter/material.dart';

/// アプリ全体で共通のダークグラデーション背景。
/// サブページ (アカウント・オプション・ステージ等) で使用する装飾円なし版。
/// タイトル画面は native_title_page.dart の _TitleBackground (装飾円付き) を使用。
class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1C2334), // ダークネイビー
            Color(0xFF0D1117), // 深夜ブラック
          ],
        ),
      ),
      child: child,
    );
  }
}
