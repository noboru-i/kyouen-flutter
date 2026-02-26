# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

**Kyouen Flutter** は「詰め共円」という日本のパズルゲームのFlutterアプリケーションです。ユーザーが石を配置して特定の幾何学的配置を達成するパズルステージを提供します。

### 基本情報
- **プロジェクトタイプ**: Flutter mobile/webアプリケーション
- **メイン言語**: Dart with Flutter framework
- **アーキテクチャパターン**: Feature-based architecture with Riverpod state management

## 依存関係とTechnology Stack

### Core Dependencies (pubspec.yaml)
- **State Management**: flutter_riverpod, riverpod_annotation
- **API Client**: chopper, http
- **Serialization**: json_annotation, freezed_annotation
- **Firebase**: firebase_core, firebase_auth, firebase_analytics, firebase_crashlytics, firebase_performance
- **Local Storage**: sqflite, sqflite_common_ffi_web, shared_preferences
- **Game Logic**: kyouen (パズルロジック用カスタムパッケージ)
- **Localization**: flutter_localizations
- **Logging**: logger

### Dev Dependencies
- **Code Generation**: build_runner, chopper_generator, freezed, json_serializable, riverpod_generator
- **Linting**: flutter_lints, custom_lint, pedantic_mono, riverpod_lint
- **Icons**: flutter_launcher_icons

## プロジェクトアーキテクチャ

### ディレクトリ構成
```
lib/
├── main.dart                    # Firebase setupを含むアプリエントリーポイント
├── firebase_options.dart        # 生成されたFirebase設定 (gitignore対象)
└── src/
    ├── app.dart                 # ルーティングを含むメインアプリwidget
    ├── config/
    │   └── environment.dart     # 環境設定
    ├── data/
    │   ├── api/
    │   │   ├── api_client.dart              # Chopper API client
    │   │   ├── firebase_auth_interceptor.dart # Firebase認証インターセプター
    │   │   ├── json_serializable_converter.dart # カスタムJSON converter
    │   │   └── entity/                      # API data models (Freezed使用)
    │   ├── local/                           # SQLite関連
    │   │   ├── database.dart                # SQLiteデータベース設定
    │   │   ├── last_stage_service.dart      # 最後のステージ管理
    │   │   ├── dao/                         # Data Access Object層
    │   │   │   └── tume_kyouen_dao.dart
    │   │   └── entity/                      # ローカルデータモデル
    │   │       └── tume_kyouen.dart
    │   └── repository/                      # リポジトリ層
    │       ├── stage_repository.dart        # ステージデータ管理
    │       └── web_title_repository.dart    # Webタイトルデータ管理
    ├── features/               # Feature-based構成
    │   ├── account/           # アカウント管理
    │   │   ├── account_page.dart
    │   │   └── account_service.dart
    │   ├── stage/             # ゲームステージロジック
    │   │   ├── stage_page.dart
    │   │   ├── stage_service.dart
    │   │   └── widgets/
    │   │       └── stage_board.dart
    │   └── title/             # タイトル画面
    │       ├── native_title_page.dart       # ネイティブ向けタイトル画面
    │       ├── web_title_page.dart          # Web向けタイトル画面
    │       └── views/
    │           ├── account_button.dart
    │           ├── my_app_bar.dart
    │           └── my_drawer.dart
    ├── localization/          # i18n対応 (英語)
    └── widgets/               # 共通Widgetコンポーネント
        ├── common/            # アプリ全体で使用される共通Widget
        │   ├── background_widget.dart           # モノトーングラデーション背景Widget
        │   ├── circle_overlay_widget.dart       # 円オーバーレイWidget
        │   ├── kyouen_answer_overlay_widget.dart # 共円解答オーバーレイWidget
        │   └── kyouen_success_dialog.dart       # 共円成功ダイアログ
        └── theme/
            └── app_theme.dart                   # アプリテーマ定義
```

### アーキテクチャパターン
- **Feature-based architecture**: 機能別にコードを整理 (account, stage, title)
- **Riverpod for state management**: dependency injectionと状態管理にproviderを使用
- **Repository pattern**: ChopperによるAPI clientの抽象化
- **Clean architecture**: data, domain, presentation layerの分離
- **SQLite-first data architecture**: APIデータをSQLiteに自動保存し、以降のアクセスはローカルDBから実行

## 環境設定

`--dart-define-from-file`を使用した複数環境対応:

### 環境ファイル
- `.env.dev` - 開発環境
- `.env.prod` - 本番環境

### 環境変数
- `ENVIRONMENT`: 'dev' or 'prod' (デフォルト: 'prod')
- `API_BASE_URL`: API endpoint URL (デフォルト: 'https://kyouen.app/v2/')
- `FIREBASE_PROJECT_ID`: Firebase project ID (デフォルト: 'my-android-server')

### Firebaseプロジェクト
- **開発環境**: api-project-732262258565
- **本番環境**: my-android-server

## 開発用コマンド

Makefileにまとめられています。`make help` で一覧を確認できます。

コード生成のwatch modeのみMakefileに含まれていません:
```bash
dart run build_runner watch
```

## Firebase設定

`make run-dev` / `make build-dev` などのMakefileターゲットがFirebaseの設定を自動で行います:
- 開発環境: プロジェクト api-project-732262258565 を使用
- 本番環境: プロジェクト my-android-server を使用

## コード生成設定

`make gen` でコード生成を実行します（対象: `lib/src/data/**/*.dart`）。

- **JSON命名規則**: `build.yaml` で `field_rename: snake` が設定済みのため、通常 `@JsonKey` は不要。Dartのcamelケース（`stageNo`）は自動的にsnake_case（`stage_no`）に変換される。APIスペックと異なる場合のみ `@JsonKey(name: 'custom_name')` を使用。
- **生成ファイル** (gitignore対象): `*.g.dart`, `*.freezed.dart`, `*.chopper.dart`, `firebase_options.dart`

## Linting設定 (analysis_options.yaml)

- **Base**: pedantic_mono package rulesを使用
- **除外対象**: 生成ファイル (`*.g.dart`, `*.freezed.dart`, `firebase_options.dart`)
- **カスタムルール**: 80文字行制限を無効化
- **Plugins**: custom_lint有効

## テスト

### テストファイル
- `test/environment_test.dart` - 環境設定テスト
- `test/unit_test.dart` - Unit test
- `test/widget_test.dart` - Widget test

## ゲームロジック

パズルゲームロジック用にカスタム`kyouen`パッケージを使用:
- **Kyouen**: パズル解答チェック用のコアゲームロジック
- **Stage Format**: ゲームボードの文字列表現 (0=空, 1=配置可能, 2=石配置済み)
- **Goal**: 「共円」(特定の幾何学的配置)を達成するように石を配置

## 主要なProviders (Riverpod)

### API & ネットワーク
- `apiClientProvider` - Chopper API clientインスタンス

### データベース
- `appDatabaseProvider` - SQLiteデータベースインスタンス
- `tumeKyouenDaoProvider` - ステージデータ操作用DAO

### ステージ管理 (SQLite-first)
- `fetchStagesProvider` - APIからステージデータを取得してSQLiteに保存
- `fetchStageProvider` - 個別ステージをSQLite優先で取得 (なければAPI経由)
- `currentStageNoProvider` - 現在のステージ番号状態
- `currentStageProvider` - 現在のステージデータと操作

### クリア状況管理
- `clearedStagesProvider` - SQLiteからクリア済みステージリストを取得

## UI・Widget構成

### 共通Widgetコンポーネント
- **BackgroundWidget** (`lib/src/widgets/common/background_widget.dart`)
  - アプリ全体で統一されたモノトーングラデーション背景を提供
  - 全ページで使用される

## 今後の開発における重要な注意点

1. **生成コード**: API entitiesまたはprovidersを変更した後は必ず`make gen`を実行
2. **環境**: 適切なFirebase設定を確保するため、実行/ビルドにはスクリプトを使用
3. **API Client**: カスタムJsonSerializableConverterがURLパターンに基づいて型変換を処理
4. **Firebase**: 設定ファイルは自動生成されgitignore対象
5. **テスト**: 開発環境でのテストには `make test` を使用
6. **State Management**: 新機能にはRiverpodパターンに従う
7. **Localization**: 現在は英語のみ対応だが、i18n基盤は整備済み
8. **データアーキテクチャ**: 新しいデータ操作はSQLite-firstパターンに従う（API → SQLite → UI）
9. **クリア状況**: ステージクリア処理は `markCurrentStageCleared()` メソッドを使用
10. **データベース変更**: SQLiteスキーマ変更時は `database.dart` の `_databaseVersion` を更新し、マイグレーション処理を追加
11. **共通Widget**: 複数画面で使用するWidgetは `lib/src/widgets/common/` に配置し、一貫性のあるデザインを保つ
12. **WidgetRef受け渡し禁止**: WidgetRefをコンストラクタ引数として他のWidgetに渡すことを禁止。代わりにConsumerWidgetまたはConsumerを使用してWidget内部でWidgetRefを取得する
13. **要素間マージンはSizedBox使用**: Widget間のマージンにはContainerのmarginプロパティではなく、SizedBoxを使用する。外側の余白にはPaddingを使用する

## カスタムスラッシュコマンド

プロジェクト用のカスタムスラッシュコマンドが `.claude/commands/` ディレクトリで定義されています：

### /create-pr
新しいブランチを作成し、変更をコミット・プッシュしてPRを作成するワークフローを実行します。
