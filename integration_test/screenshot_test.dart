import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_main.dart' as app;

Future<void> _settleAfterRouteChange(WidgetTester tester) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

Future<void> _takeStableScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
  await tester.pump(const Duration(milliseconds: 500));
  await binding.takeScreenshot(name);
}

Future<void> _tapLocalizedText(
  WidgetTester tester,
  List<String> labels,
) async {
  for (final label in labels) {
    final finder = find.text(label);
    if (finder.evaluate().isNotEmpty) {
      await tester.tap(finder);
      return;
    }
  }

  fail('Could not find any of the texts: ${labels.join(', ')}');
}

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
      await _takeStableScreenshot(binding, tester, '01_title');

      // ステージ画面へ遷移
      await _tapLocalizedText(tester, ['スタート', 'Start']);
      await _settleAfterRouteChange(tester);

      // 02_stage_1: ステージ1画面
      await _takeStableScreenshot(binding, tester, '02_stage_1');

      // タイトル画面へ戻る
      await tester.pageBack();
      await _settleAfterRouteChange(tester);

      // ステージ作成画面へ遷移
      await _tapLocalizedText(tester, ['ステージ作成', 'Create Stage']);
      await _settleAfterRouteChange(tester);

      // 03_create_stage: ステージ作成画面
      await _takeStableScreenshot(binding, tester, '03_create_stage');
    });
  });
}
