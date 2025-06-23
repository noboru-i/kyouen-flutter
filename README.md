# Kyouen Flutter

「詰め共円」パズルゲームのFlutterアプリケーションです。

## プロジェクト概要

このアプリは、石を配置して特定の幾何学的配置（共円）を達成するパズルゲームです。

## 開発環境のセットアップ

詳細な開発コマンドやアーキテクチャについては、[CLAUDE.md](./CLAUDE.md)を参照してください。

### クイックスタート

```bash
# 開発環境での実行
./scripts/run_dev.sh

# 本番環境での実行
./scripts/run_prod.sh

# Web用ビルド
flutter build web --dart-define-from-file=.env.prod
```

### Web対応

このアプリはFlutter webでも動作します。Web用のビルドには以下の追加設定が必要です：

```bash
# sqflite web用セットアップ（初回のみ）
dart run sqflite_common_ffi_web:setup

# Web用ビルド
flutter build web --no-tree-shake-icons
```

## 技術スタック

- **フレームワーク**: Flutter (Mobile & Web対応)
- **状態管理**: Riverpod
- **API通信**: Chopper + HTTP
- **ローカルDB**: sqflite (Mobile), sqflite_common_ffi_web (Web)
- **バックエンド**: Firebase (Auth, Analytics, Crashlytics)
- **アーキテクチャ**: Feature-based architecture with Clean Architecture
- **CI/CD**: GitHub Actions

## コントリビューション

開発に関する詳細な情報は [CLAUDE.md](./CLAUDE.md) を参照してください。
