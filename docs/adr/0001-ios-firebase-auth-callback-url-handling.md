# ADR-0001: iOS Firebase Auth コールバックURLのハンドリング

- ステータス: 採用
- 日付: 2026-02-27

## 背景

iOSでTwitterログイン（`signInWithProvider(TwitterAuthProvider())`）を使用すると、認証後にアプリへ戻る際に Firebase のコールバックURLが Flutter の Navigator に届き、`onGenerateRoute` でルート解決に失敗してエラーが発生していた。

## 問題の詳細

### URLのフォーマット

Firebase Auth の Twitter ログインコールバックは以下の形式のURLでアプリを開く：

```
app-1-{PROJECT_ID}-ios-{HASH}:///link?deep_link_id=https://PROJECT.firebaseapp.com/__/auth/callback?authType=signInWithRedirect&...
```

### 原因の連鎖

1. **Scene-based lifecycle が有効**
   `Info.plist` に `UISceneDelegateClassName: FlutterSceneDelegate` が設定されており、URLコールバックは `application(_:open:options:)` ではなく `scene(_:openURLContexts:)` で届く。

2. **`firebase_auth` iOS プラグインが Scene-based lifecycle に未対応**
   `FLTFirebaseAuthPlugin.m` は `application:openURL:options:` のみを実装しており、`scene:openURLContexts:` パスには対応していない。そのため、Flutter のプラグインチェックをスルーしてしまう。

3. **Firebase Auth の `canHandleURL:` がこのURLに対して `false` を返す**
   このURLは Firebase Dynamic Links 形式（`/link?deep_link_id=...`）であり、Firebase Auth SDK の `canHandleURL:` が直接処理する形式ではない。

4. **Flutter のディープリンク処理がURLを Flutter Navigator に転送**
   `FlutterSceneLifeCycle.mm` の処理順：
   - プラグインチェック → スルー（firebase_auth が未対応）
   - `handleDeeplink` → `sendDeepLinkToFramework`
   - `navigationChannel.invokeMethod("pushRouteInformation")` → Dart Navigator へ転送
   - `onGenerateRoute` が呼ばれ、不明なルートとして処理される

## 決定

`FlutterSceneDelegate` を継承したカスタム `SceneDelegate` を作成し、`scene(_:openURLContexts:)` をオーバーライドする。Firebase Auth のカスタムURLスキーム（`Info.plist` の `CFBundleURLSchemes` に登録済み）のURLは Flutter Navigator に転送しない。

### 根拠

- `signInWithProvider` の認証処理自体は `ASWebAuthenticationSession` の内部で完了している
- このURLコールバックは Firebase Dynamic Links 経由の中間リダイレクトであり、Flutter Navigator への転送は不要
- `Info.plist` の `CFBundleURLSchemes` を動的に参照することでハードコードを避けられる

## 実装

### `ios/Runner/SceneDelegate.swift`（新規作成）

```swift
class SceneDelegate: FlutterSceneDelegate {
  private lazy var registeredURLSchemes: Set<String> = {
    // Info.plist の CFBundleURLSchemes を動的に取得
    ...
  }()

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for urlContext in URLContexts {
      let url = urlContext.url
      if Auth.auth().canHandle(url) { return }
      // Firebase カスタムスキームのURLは Flutter に転送しない
      if let scheme = url.scheme, registeredURLSchemes.contains(scheme) { return }
    }
    super.scene(scene, openURLContexts: URLContexts)
  }
}
```

### `ios/Runner/Info.plist`

`UISceneDelegateClassName` を `FlutterSceneDelegate` → `Runner.SceneDelegate` に変更。

## 検討した代替案

### 案1: `app.dart` の `onGenerateRoute` で `/link` ルートを処理する（当初の対処）

`/link` で始まるルート名を検出し、`navigatorKey` + `postFrameCallback` + `pushNamedAndRemoveUntil` でAccountPageに遷移させる実装。

**却下理由**: `onGenerateRoute` はルートを生成する場所であり、ナビゲーションの副作用を起こすべきではない。根本原因への対処になっていない。

### 案2: `go_router` への移行

宣言的ルーティングライブラリでディープリンク処理を適切に管理する。

**保留理由**: 変更範囲が大きく、現時点での優先度が低い。将来的なリファクタリングの候補として検討する。

## 影響

- Firebase カスタムURLスキームを使う認証プロバイダー（Twitter、Google 等）のコールバックURLは Flutter Navigator に届かなくなる
- 認証処理は `signInWithProvider` 内部で完了するため、機能上の影響はない
- 将来的に他のカスタムURLスキームをアプリで使用する場合は、`SceneDelegate` の処理を見直す必要がある
