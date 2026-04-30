import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('スクリーンショット撮影', () {
    // Firebase は1プロセスで1回しか初期化できないため、全画面を1テスト内でまとめて撮影する
    testWidgets('全画面', (tester) async {
      await app.mainForScreenshot();

      // Firebase初期化・データロードを待機
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // タイトル画面のアニメーション完了を待機（500ms遅延 + 1800msアニメーション）
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();

      // Android はスクリーンショット前にサーフェス変換が必要（iOS では no-op）
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();

      // 01_title: タイトル画面
      await binding.takeScreenshot('01_title');

      // ステージ画面へ遷移
      await tester.tap(find.text('スタート'));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // 02_stage_1: ステージ1画面
      await binding.takeScreenshot('02_stage_1');

      // タイトル画面へ戻る
      await tester.pageBack();
      await tester.pumpAndSettle();

      // ステージ作成画面へ遷移
      await tester.tap(find.text('ステージ作成'));
      await tester.pumpAndSettle();

      // 03_create_stage: ステージ作成画面
      await binding.takeScreenshot('03_create_stage');
    });
  });
}
