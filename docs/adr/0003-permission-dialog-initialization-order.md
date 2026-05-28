# ADR-0003: 権限ダイアログの初期化タイミングと表示順序

- ステータス: 採用
- 日付: 2026-05-28

## 背景

App Store レビューにて、ATT（App Tracking Transparency）の許可ダイアログが iPadOS 26.5 で表示されないと指摘された（Submission ID: 8dde7830-4f13-4606-b598-4e435260fdd3）。

## 問題の詳細

### ATT ダイアログが表示されない原因

`main()` で `runApp()` を呼ぶ**前**に `AppTrackingTransparency.requestTrackingAuthorization()` を呼んでいた。iOS/iPadOS 17 以降（iPadOS 26 含む）では、ATT ダイアログの表示に `UIWindowScene` が必要であり、Flutter のウィンドウが生成される `runApp()` より前に呼ぶと動作しない。

```dart
// 変更前（問題のあったコード）
void main() async {
  await _setupFirebase();
  await _requestATT();      // ← runApp() 前のため失敗
  await _setupConsent();
  await MobileAds.instance.initialize();
  runApp(...);
}
```

### 追加で判明した問題

1. **PUSH 通知許可も同様に `runApp()` 前だった**: `_setupMessaging()` が `_setupFirebase()` 内で呼ばれており、通知許可ダイアログもアプリ UI が一切表示されていない状態で出ていた。

2. **`ProviderContainer` の分離**: `_setupConsent()` が `ProviderScope` とは無関係な別の `ProviderContainer` を作成・破棄していた。`_MyAppState` が `ConsumerState` であるため `ref` を使えるにもかかわらず、無駄な分離が生じていた。

3. **表示順序が非最適**: PUSH 通知 → ATT → UMP 同意の順だったが、ATT を最初に表示すべき理由がある（後述）。

## 決定

### 1. 初期化の場所を `_MyAppState.initState()` に移動

UI に依存する権限ダイアログの初期化を `main()` から `app.dart` の `_MyAppState.initState()` 内の `addPostFrameCallback` に移動する。これにより、最初のフレーム描画後（アプリウィンドウが確実に表示された後）にダイアログが出るようになる。

```dart
// main()
void main() async {
  await _setupFirebase(); // Firebase・Crashlytics・FCMバックグラウンドハンドラーのみ
  runApp(...);
}

// _MyAppState.initState()
WidgetsBinding.instance.addPostFrameCallback((_) {
  unawaited(_initTracking());
});
```

### 2. `ProviderContainer` を廃止して `ref` を使用

`_MyAppState` は `ConsumerState` なので、`ref.read(consentServiceProvider)` で直接アクセスできる。別 `ProviderContainer` は不要。

### 3. 表示順序を ATT → UMP → PUSH に変更

| 順序 | ダイアログ | 理由 |
|---|---|---|
| 1 | ATT | Apple 要件。トラッキング前に最初に取得する。UMP 同意フォームは ATT の結果を参照できる |
| 2 | UMP 同意 | GDPR 要件（EEA 地域のみ）。ATT の後に広告・Analytics 同意を取得する |
| 3 | PUSH 通知 | 広告同意と独立しており、最後に確認する |

### 4. FCM バックグラウンドハンドラーは `main()` に残す

`FirebaseMessaging.onBackgroundMessage()` はトップレベル関数の登録が必要であり、アプリ起動直後に設定する必要がある。ダイアログは表示しないため、`main()` に残すことが適切。

## 実装

### `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setupFirebase(); // ← ATT/同意/広告/PUSH許可を含まない
  runApp(...);
}

void _setupMessaging() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // 通知許可ダイアログは app.dart の _initTracking() で表示する
}
```

### `app.dart`

```dart
void initState() {
  super.initState();
  if (!kIsWeb) {
    _initDeepLinkStream();
    _initNotificationTapHandling();
    _initForegroundNotificationHandling();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initTracking());
    });
  }
}

Future<void> _initTracking() async {
  // 1. ATT
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
  // 2. UMP同意
  await ref.read(consentServiceProvider).requestConsent();
  // 3. PUSH通知
  await _requestPushPermission();
  await MobileAds.instance.initialize();
}
```

## 検討した代替案

### 案1: `runApp()` の直後に `Completer` で待機する（最初の修正）

```dart
runApp(...);
final completer = Completer<void>();
WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
await completer.future;
await _requestATT();
```

**却下理由**: `main()` は「アプリ起動前の準備」の場所であり、`runApp()` 後に UI 依存の処理を書くのはアーキテクチャとして不自然。`_MyAppState` のウィジェットライフサイクルを使う方が適切。また `ProviderContainer` の問題も解消されない。

### 案2: PUSH 通知許可のタイミングをさらに遅らせる

初回起動時ではなく、ユーザーがアプリの価値を体験した後（例: ステージクリア後）に通知許可を求める UX パターン。

**保留理由**: 変更範囲が大きく、現時点での優先度が低い。今後の UX 改善として検討する。

## 影響

- ATT ダイアログが正しく表示されるようになり、App Store レビューの指摘が解消される
- すべての権限ダイアログがアプリ UI 表示後に出るようになり、UX が統一される
- `ProviderContainer` の無駄な生成・破棄がなくなる
- ATT → UMP → PUSH の順序が保証され、各 SDK が前のステップの結果を参照できる
