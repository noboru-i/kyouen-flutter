# GitHub Actions Build and Distribution Workflow

このワークフローは、Kyouen FlutterアプリのiOSとAndroidビルドを自動化し、Firebase App Distributionに配布します。

## ワークフローの概要

- **トリガー**: `workflow_dispatch`（手動実行のみ）
- **環境選択**: `dev`または`prod`環境を選択可能
- **並列ジョブ**: iOSとAndroidのビルドが並列実行
- **成果物**: Artifacts保存 + Firebase App Distribution配布

## GitHub Environmentsの設定

このワークフローはGitHub Environmentsを使用して環境別にSecretsを管理します。

### 1. Environmentsの作成
GitHubリポジトリで以下のEnvironmentsを作成してください：
- `dev` - 開発環境
- `prod` - 本番環境

Settings > Environments > New environment から作成できます。

## 必要なGitHub Secrets

以下のSecretsを各Environment（dev/prod）に設定する必要があります：

### iOS署名関連
- `BUILD_CERTIFICATE_BASE64`: Apple開発者証明書（.p12）をBase64エンコードしたもの
- `P12_PASSWORD`: .p12ファイルのパスワード
- `BUILD_PROVISION_PROFILE_BASE64`: プロビジョニングプロファイル（.mobileprovision）をBase64エンコードしたもの
  - **重要**: dev環境とprod環境でそれぞれ異なるBundle IDに対応したプロビジョニングプロファイルが必要
- `KEYCHAIN_PASSWORD`: 一時的なキーチェーンのパスワード（任意の強いパスワード）

#### iOS証明書の準備方法
1. Xcodeで開発者証明書をエクスポート（.p12形式）
2. Base64エンコード: `base64 -i certificate.p12 | pbcopy`
3. プロビジョニングプロファイルをBundle ID別に準備:
   - dev用: `hm.orz.chaos114.TumeKyouen.dev` 対応プロファイル
   - prod用: `hm.orz.chaos114.TumeKyouen` 対応プロファイル
4. プロビジョニングプロファイルをBase64エンコード: `base64 -i profile.mobileprovision | pbcopy`

### Android署名関連
- `ANDROID_KEYSTORE_BASE64`: Androidキーストア（.jks/.p12）をBase64エンコードしたもの
- `ANDROID_STORE_PASSWORD`: キーストアのパスワード
- `ANDROID_KEY_PASSWORD`: キーのパスワード
- `ANDROID_KEY_ALIAS`: キーのエイリアス名

#### Androidキーストアの準備方法
1. キーストアファイルをBase64エンコード: `base64 -i keystore.jks | pbcopy`
2. `android/key.properties`は自動生成されるため、事前準備不要

### Firebase関連
各環境のFirebaseプロジェクトに対応したSecretsを設定：

#### dev環境（`api-project-732262258565`）
- `FIREBASE_SERVICE_ACCOUNT_KEY`: dev Firebase Service AccountのJSONキー
- `FIREBASE_IOS_APP_ID`: dev Firebase iOSアプリID
- `FIREBASE_ANDROID_APP_ID`: dev Firebase AndroidアプリID

#### prod環境（`my-android-server`）
- `FIREBASE_SERVICE_ACCOUNT_KEY`: prod Firebase Service AccountのJSONキー  
- `FIREBASE_IOS_APP_ID`: prod Firebase iOSアプリID
- `FIREBASE_ANDROID_APP_ID`: prod Firebase AndroidアプリID

#### Firebase Service Accountの準備方法
**各環境のFirebaseプロジェクトで個別に実行：**

1. Firebase Console > プロジェクト設定 > サービスアカウント
2. 「新しい秘密鍵の生成」をクリック
3. ダウンロードしたJSONファイルの内容をそのまま対応するEnvironmentのSecretsに設定

## ワークフローの実行

1. GitHubリポジトリのActionsタブに移動
2. 「Build and Distribute」ワークフローを選択
3. 「Run workflow」をクリック
4. 環境（`dev`または`prod`）を選択
5. 「Run workflow」を実行

## 成果物

### Artifacts（GitHub Actions）
- `ios-app-{environment}`: iOS IPAファイル
- `android-apk-{environment}`: Android APKファイル
- `android-aab-{environment}`: Android AAB（App Bundle）ファイル

### Firebase App Distribution
- iOSアプリとAndroidアプリが自動的に`testers`グループに配布されます
- テスターはFirebase App Distributionの招待メールからアプリをダウンロード可能

## 環境別設定

### 開発環境（dev）
- Firebase Project: `api-project-732262258565`
- iOS Bundle ID: `hm.orz.chaos114.TumeKyouen.dev`
- Android Package: `hm.orz.chaos114.android.tumekyouen.dev`
- 設定ファイル: `.env.dev`

### 本番環境（prod）
- Firebase Project: `my-android-server`
- iOS Bundle ID: `hm.orz.chaos114.TumeKyouen`
- Android Package: `hm.orz.chaos114.android.tumekyouen`
- 設定ファイル: `.env.prod`

## トラブルシューティング

### iOS署名エラー
- Apple開発者証明書の有効期限を確認
- プロビジョニングプロファイルとBundle IDの一致を確認
- `security list-keychain`でキーチェーンの設定を確認

### Android署名エラー
- キーストアファイルのパスとパスワードを確認
- `android/key.properties`の設定を確認

### Firebase配布エラー
- Service Accountの権限（Firebase App Distribution Admin）を確認
- App IDが正しいFirebaseプロジェクトのものか確認
- `testers`グループが存在するか確認（Firebase Console > App Distribution > テスターとグループ）

## セキュリティ注意事項

- すべての証明書とキーはGitHub Secretsとして安全に保存
- 一時的なキーチェーンは実行後に削除
- キーストアファイルは実行時のみ作成され、実行後にクリーンアップ
- Firebase Service Accountキーは必要最小限の権限のみ付与推奨