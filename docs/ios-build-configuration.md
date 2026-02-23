# iOS環境別ビルド設定

## 概要

`--dart-define-from-file`を使用してdev/prod環境を切り分けており、Bundle IDも環境ごとに異なります。
Provisioning ProfileはExportOptions.plistのみで指定し、Xcodeプロジェクトでは自動選択としています。

## 環境別のBundle ID

- **開発環境**: `hm.orz.chaos114.TumeKyouen.dev`
- **本番環境**: `hm.orz.chaos114.TumeKyouen`

## ビルド構成と環境の関係

### ビルド構成（Build Configuration）
- **Debug**: 開発中のデバッグビルド（シミュレータやローカルデバイスで実行）
- **Profile**: パフォーマンス測定用ビルド
- **Release**: リリース用のビルド（最適化あり）

### 環境（Environment）
- **Dev**: 開発環境（開発用API、開発用Firebase、開発用Bundle ID）
- **Prod**: 本番環境（本番API、本番Firebase、本番Bundle ID）

これらは直交する概念なので、例えば：
- **Release + Dev**: 開発環境向けAdHocビルド（TestFlightやFirebase App Distribution用）
- **Release + Prod**: 本番環境向けApp Storeビルド

## 設定ファイル

### ExportOptions.plist

#### ios/ExportOptions.dev.plist
開発環境用:
- Bundle ID: `hm.orz.chaos114.TumeKyouen.dev`
- Provisioning Profile: `TumeKyouenDev`
- Signing Style: `manual`

#### ios/ExportOptions.prod.plist
本番環境用:
- Bundle ID: `hm.orz.chaos114.TumeKyouen`
- Provisioning Profile: `TumeKyouenDistribution`
- Signing Style: `manual`

### Xcodeプロジェクト設定

- `PRODUCT_BUNDLE_IDENTIFIER`: `$(IOS_BUNDLE_ID)` で動的に設定（Dart-Definesから読み込み）
- `PROVISIONING_PROFILE_SPECIFIER`: 空文字列（ExportOptions.plistで指定）
- `CODE_SIGN_STYLE`: Manual

## GitHub Actions Secrets

以下のSecretsを設定する必要があります:

### リポジトリレベルのSecrets
- `BUILD_CERTIFICATE_BASE64`: Apple Distribution証明書（P12形式、Base64エンコード）
- `P12_PASSWORD`: 証明書のパスワード
- `KEYCHAIN_PASSWORD`: 一時キーチェーンのパスワード

### 環境別のSecrets（Environment Secrets）

GitHub ActionsのEnvironment機能を使用して、同じ名前のSecretsを環境ごとに異なる値で設定します。

#### `dev` 環境
- `BUILD_PROVISION_PROFILE_BASE64`: 開発環境用Provisioning Profile（Base64エンコード）
  - Bundle ID: `hm.orz.chaos114.TumeKyouen.dev`
  - Profile名: `TumeKyouenDev`

#### `prod` 環境
- `BUILD_PROVISION_PROFILE_BASE64`: 本番環境用Provisioning Profile（Base64エンコード）
  - Bundle ID: `hm.orz.chaos114.TumeKyouen`
  - Profile名: `TumeKyouenDistribution`

## Provisioning Profileの作成手順

1. Apple Developer Consoleで各環境用のApp IDを作成
   - Dev: `hm.orz.chaos114.TumeKyouen.dev`
   - Prod: `hm.orz.chaos114.TumeKyouen`

2. 各App ID用のProvisioning Profileを作成
   - Type: App Store Connect
   - Profile名をメモ（ExportOptions.plistで使用）

3. Provisioning ProfileをダウンロードしてBase64エンコード:
   ```bash
   # 開発環境用
   base64 -i TumeKyouenDev.mobileprovision | pbcopy
   
   # 本番環境用
   base64 -i TumeKyouenDistribution.mobileprovision | pbcopy
   ```

4. GitHub Secretsに登録

## ビルド方法

### ローカルビルド

開発環境（AdHoc/TestFlight用）:
```bash
flutter build ipa --dart-define-from-file=.env.dev \
    --release \
    --export-options-plist=ios/ExportOptions.dev.plist
```

本番環境（App Store用）:
```bash
flutter build ipa --dart-define-from-file=.env.prod \
    --release \
    --export-options-plist=ios/ExportOptions.prod.plist
```

### GitHub Actions

ワークフローは環境に応じて自動的に適切なProvisioning ProfileとExportOptionsを選択します。

- Dev環境: `BUILD_PROVISION_PROFILE_DEV_BASE64` + `ExportOptions.dev.plist`
- Prod環境: `BUILD_PROVISION_PROFILE_PROD_BASE64` + `ExportOptions.prod.plist`

## トラブルシューティング

### Provisioning Profile not foundエラー

- Provisioning Profileの名前がExportOptions.plistで指定したものと一致しているか確認
- Apple Developer ConsoleでProvisioning Profileが有効か確認
- GitHub Secretsが正しく設定されているか確認

### Bundle ID mismatch

- Provisioning ProfileがBundle IDと一致しているか確認
- .env.dev/.env.prodのIOS_BUNDLE_IDが正しいか確認

### Code signing error

- Xcodeプロジェクトで `PROVISIONING_PROFILE_SPECIFIER = ""` になっているか確認
- ExportOptions.plistで `signingStyle = manual` になっているか確認
