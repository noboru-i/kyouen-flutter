# ADR-0002: firebase.json の git 管理方針

- ステータス: 採用
- 日付: 2026-04-15

## 背景

`firebase.json` は以下の2種類の設定を含む：

1. **`flutter` セクション**: `flutterfire configure` が自動生成・更新するFirebaseプロジェクトの設定（`projectId`、`appId` など）
2. **`hosting` セクション**: Firebase Hosting のビルドパスやリライトルールなど、手動で管理する設定

当初 `firebase.json` はまるごと `.gitignore` に追加されていたため、`hosting` セクションに設定を追加しても git 管理されず、リポジトリ共有や CI/CD 環境で失われる問題が生じた。

## 決定

`firebase.json` を `.gitignore` から外し、git で管理する。

### 根拠

- `firebase.json` の `flutter` セクションに含まれる `projectId`・`appId` は秘密情報ではない（API キー等の機密情報は gitignore 済みの `lib/firebase_options.dart` に分離されている）
- `flutterfire configure` は `firebase.json` の `flutter` セクションのみを更新し、`hosting` などの他のセクションは保持する
- Makefile の各ターゲット（`run-dev`、`run-prod`、`build-dev`、`build-prod`）が実行前に必ず `flutterfire configure --project=XXX` を実行するため、常に正しい環境の設定に上書きされる
- `hosting` セクションの設定をリポジトリで管理することで、チーム共有・CI/CD 環境での再現性が保たれる

## 影響

- `make run-dev` / `make run-prod` 実行後、`git status` で `firebase.json` の `flutter` セクションが変更済みとして表示される場合がある（環境を切り替えた場合）
- これは正常な動作であり、次回のビルド・実行時に Makefile が正しい設定に書き換えるため、コミットする必要はない

## 検討した代替案

### 案1: firebase.json を引き続き gitignore し、hosting設定をテンプレートファイルで管理する

`firebase.hosting.json` のようなテンプレートファイルを git 管理し、Makefile で `jq` 等を使って `firebase.json` にマージする。

**却下理由**: ツール依存（`jq`）が増え、Makefile が複雑になる割に得られるメリットが少ない。

### 案2: firebase.json を gitignore から外し、flutter セクションを空にしておく

`firebase.json` に `hosting` セクションのみ記載し、`flutter` セクションは `flutterfire configure` が追記する形にする。

**却下理由**: `flutterfire configure` が既存の `flutter` セクションを前提に動作するケースがあり、挙動が不安定になるリスクがある。現状のままコミットするほうがシンプル。
