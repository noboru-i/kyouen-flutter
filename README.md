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
```

## 技術スタック

- **フレームワーク**: Flutter
- **状態管理**: Riverpod
- **API通信**: Chopper + HTTP
- **バックエンド**: Firebase (Auth, Analytics, Crashlytics)
- **アーキテクチャ**: Feature-based architecture with Clean Architecture

## コントリビューション

開発に関する詳細な情報は [CLAUDE.md](./CLAUDE.md) を参照してください。
