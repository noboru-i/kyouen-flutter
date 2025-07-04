# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

**Kyouen Flutter** は「詰め共円」という日本のパズルゲームのFlutterアプリケーションです。ユーザーが石を配置して特定の幾何学的配置を達成するパズルステージを提供します。

### 基本情報
- **プロジェクトタイプ**: Flutter mobile/webアプリケーション
- **メイン言語**: Dart with Flutter framework
- **アーキテクチャパターン**: Feature-based architecture with Riverpod state management
- **現在のステータス**: 最近dio+retrofitからhttp+Chopperに移行完了

## 依存関係とTechnology Stack

### Core Dependencies (pubspec.yaml)
- **Flutter**: ^3.32.4 (SDK >=3.7.0 <4.0.0)
- **State Management**: flutter_riverpod ^2.6.1, riverpod_annotation ^2.3.5
- **API Client**: chopper ^8.1.0, http ^1.4.0 (最近dio+retrofitから移行)
- **Serialization**: json_annotation ^4.9.0, freezed_annotation ^3.0.0
- **Firebase**: firebase_core ^3.14.0, firebase_auth ^5.6.0, firebase_analytics ^11.5.0, firebase_crashlytics ^4.3.7, firebase_performance ^0.10.1
- **Game Logic**: kyouen ^0.0.1 (パズルロジック用カスタムパッケージ)
- **Logging**: logger

### Dev Dependencies
- **Code Generation**: build_runner ^2.4.13, chopper_generator ^8.1.0, freezed ^3.0.6, json_serializable ^6.8.0, riverpod_generator ^2.6.5
- **Linting**: flutter_lints ^5.0.0, custom_lint ^0.7.5, pedantic_mono ^1.28.0, riverpod_lint ^2.6.5

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
    │   │   ├── api_client.dart         # Chopper API client
    │   │   ├── api_client.chopper.dart # 生成されたChopperコード
    │   │   ├── json_serializable_converter.dart # カスタムJSON converter
    │   │   └── entity/          # API data models (Freezed使用)
    │   └── local/              # SQLite関連
    │       ├── database.dart           # SQLiteデータベース設定
    │       ├── cleared_stages_service.dart # クリア状況管理
    │       ├── dao/                    # Data Access Object層
    │       │   └── tume_kyouen_dao.dart
    │       └── entity/                 # ローカルデータモデル
    │           └── tume_kyouen.dart
    ├── features/               # Feature-based構成
    │   ├── sign_in/           # ユーザー認証
    │   ├── stage/             # ゲームステージロジック
    │   └── title/             # タイトル画面
    ├── localization/          # i18n対応 (英語)
    ├── settings/              # アプリ設定
    └── widgets/               # 共通Widgetコンポーネント
        └── common/            # アプリ全体で使用される共通Widget
            └── background_widget.dart # モノトーングラデーション背景Widget
```

### アーキテクチャパターン
- **Feature-based architecture**: 機能別にコードを整理 (sign_in, stage, title)
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

### アプリの実行
```bash
# 開発環境
./scripts/run_dev.sh
# または手動で:
flutter run --dart-define-from-file=.env.dev

# 本番環境
./scripts/run_prod.sh
# または手動で:
flutter run --dart-define-from-file=.env.prod
```

### アプリのビルド
```bash
# 開発用ビルド
./scripts/build_dev.sh

# 本番用ビルド
./scripts/build_prod.sh
```

### テスト
```bash
# 開発環境でのテスト実行
./scripts/test_dev.sh

# 標準Flutter test
flutter test
```

### コード生成
```bash
# 全コード生成 (Riverpod, Freezed, JSON, Chopper)
dart run build_runner build

# 開発用watch mode
dart run build_runner watch

# クリーンして再ビルド
dart run build_runner build --delete-conflicting-outputs
```

### Linting
```bash
# Linter実行
flutter analyze

# Custom lint
dart run custom_lint
```

## Firebase設定

### 自動設定
スクリプトが適切な環境用にFirebaseを自動設定:
- 開発環境: プロジェクト api-project-732262258565 を使用
- 本番環境: プロジェクト my-android-server を使用

### 手動Firebase設定 (必要な場合)
```bash
# 開発環境
flutterfire configure \
  --project api-project-732262258565 \
  --android-package-name hm.orz.chaos114.android.tumekyouen.dev \
  --ios-bundle-id hm.orz.chaos114.TumeKyouen.dev \
  --platforms=android,ios,web

# 本番環境
flutterfire configure \
  --project my-android-server \
  --android-package-name hm.orz.chaos114.android.tumekyouen \
  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
  --platforms=android,ios,web
```

## コード生成設定

### build.yaml
- **json_serializable**: API entities用にsnake_case field namingで設定
- **freezed**: API entities用のimmutable data classを生成
- **対象ディレクトリ**: `lib/src/data/**/*.dart`

### 生成ファイル (gitignore対象)
- `*.g.dart` - JSON serialization
- `*.freezed.dart` - Freezed immutable classes
- `*.chopper.dart` - Chopper API client
- `firebase_options.dart` - Firebase設定

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

1. **生成コード**: API entitiesまたはprovidersを変更した後は必ず`dart run build_runner build`を実行
2. **環境**: 適切なFirebase設定を確保するため、実行/ビルドにはスクリプトを使用
3. **API Client**: カスタムJsonSerializableConverterがURLパターンに基づいて型変換を処理
4. **Firebase**: 設定ファイルは自動生成されgitignore対象
5. **テスト**: 開発環境でのテストには `./scripts/test_dev.sh` を使用
6. **State Management**: 新機能にはRiverpodパターンに従う
7. **Localization**: 現在は英語のみ対応だが、i18n基盤は整備済み
8. **データアーキテクチャ**: 新しいデータ操作はSQLite-firstパターンに従う（API → SQLite → UI）
9. **クリア状況**: ステージクリア処理は `markCurrentStageCleared()` メソッドを使用
10. **データベース変更**: SQLiteスキーマ変更時は `database.dart` の `_databaseVersion` を更新し、マイグレーション処理を追加
11. **共通Widget**: 複数画面で使用するWidgetは `lib/src/widgets/common/` に配置し、一貫性のあるデザインを保つ

## カスタムスラッシュコマンド

プロジェクト用のカスタムスラッシュコマンドが `.claude/commands/` ディレクトリで定義されています：

### /ship
新しいブランチを作成し、変更をコミット・プッシュしてPRを作成するワークフローを実行します。

```
/ship <branch-name> <commit-message>
```

例：
```
/ship feature/new-stage-ui "新しいステージUI画面の追加"
```

実行内容：
1. 新しいブランチを作成してチェックアウト
2. 変更をステージングしてコミット
3. リモートブランチにプッシュ
4. PRを作成（mainブランチに対して）

## ブランチ情報
- **現在のブランチ**: migrate-to-chopper
- **最近の作業**: dio+retrofitからhttp+ChopperへのAPI client移行
- **ステータス**: 移行完了、統合準備完了