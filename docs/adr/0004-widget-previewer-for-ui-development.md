# ADR-0004: Flutter Widget Previewer による UI 開発

- ステータス: 採用
- 日付: 2026-06-05

## 背景

Flutter ウィジェットの見た目を確認するには、従来はアプリ全体をビルド・起動してから目的の画面に遷移する必要があった。これはUIの試行錯誤において時間コストが大きい。

Flutter 3.35 以降で提供される Widget Previewer は、フルアプリを起動せずに Chrome 上でウィジェットをリアルタイムにプレビューできる機能である。

## 決定

`@Preview` アノテーション（`package:flutter/widget_previews.dart`）を使い、ウィジェット単体のプレビューファイルを各ウィジェットと同一ディレクトリに配置する。

### ファイル命名規則

```
lib/src/features/stage/widgets/stage_board.dart         # 本体
lib/src/features/stage/widgets/stage_board_preview.dart # プレビュー
```

プレビューファイル名は `{widget_name}_preview.dart` とする。

### `@Preview` アノテーションの記述ルール

- `wrapper` パラメーターに渡す関数は **パブリックなトップレベル関数** にする（`@Preview` は const のため、private 関数 `_xxx` は不可）
- `ConsumerWidget` サブクラスのプレビューには `ProviderScope` を注入する wrapper が必要

```dart
// OK: パブリックトップレベル関数
Widget providerScopeWrapper(Widget child) => ProviderScope(child: child);

@Preview(name: 'example', wrapper: providerScopeWrapper)
Widget myPreview() => const MyWidget();
```

### プレビューの起動方法

```shell
flutter widget-preview start
```

IDE（VS Code / Android Studio）では Flutter 3.38 以降で自動起動する。

## 根拠

- フルビルド不要でホットリロード的にUIを確認できるため、ウィジェット開発の反復速度が向上する
- プレビューファイルはテストコードと同様に「仕様の文書化」としても機能する
- 実装コードへの変更が不要（アノテーション付きの別ファイルに分離）

## 制約事項

Widget Previewer は Flutter Web ベースで動作するため、以下は使用不可：

- `dart:io` / `dart:ffi`
- ネイティブプラグイン（Firebase、SQLite 等）

プレビューで `ProviderScope` を用意しても、実際のデータベースや Firebase への接続は行えない。プレビューには `const` で構築できるダミーデータを渡す。

## 検討した代替案

### 案1: `widgetbook` パッケージの使用

UI カタログを専用アプリとして構築する OSS。ストーリーベースでコンポーネントを管理できる。

**却下理由**: 専用パッケージの追加・維持コストが発生する。Flutter 標準の Widget Previewer で要件を満たせるため採用しない。

### 案2: Widget テストで `pump` してスクリーンショット確認

`flutter test --update-goldens` でゴールデンイメージを生成する。

**保留理由**: CI での回帰検知には有効だが、開発中のリアルタイム確認には向かない。将来的にゴールデンテストと併用する可能性はある。

## 影響

- プレビューファイルはビルド成果物に含まれるが、`@Preview` アノテーション自体はリリースビルドに影響しない
- `build.yaml` の `generate_for` 設定がある場合、プレビューファイルが不要なコード生成対象にならないよう注意する
