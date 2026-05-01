.PHONY: help run-dev run-prod build-dev build-prod test gen analyze screenshots screenshots-ios screenshots-android clean-screenshots sim-lang-ja sim-lang-en

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Run:"
	@echo "  run-dev     開発環境でアプリを起動"
	@echo "  run-prod    本番環境でアプリを起動"
	@echo ""
	@echo "Build:"
	@echo "  build-dev   開発環境向けビルド"
	@echo "  build-prod  本番環境向けビルド"
	@echo ""
	@echo "Test:"
	@echo "  test        開発環境でテスト実行"
	@echo ""
	@echo "Screenshots:"
	@echo "  screenshots          iOS + Android 両方撮影"
	@echo "  screenshots-ios      iOS シミュレータでスクリーンショット撮影"
	@echo "  screenshots-android  Android エミュレータでスクリーンショット撮影"
	@echo "  clean-screenshots    撮影済み画像を削除"
	@echo ""
	@echo "Simulator:"
	@echo "  sim-lang-ja  iOSシミュレーターを日本語に切り替えて再起動"
	@echo "  sim-lang-en  iOSシミュレーターを英語に切り替えて再起動"
	@echo ""
	@echo "Code:"
	@echo "  gen         コード生成 (Riverpod, Freezed, JSON, Chopper)"
	@echo "  analyze     flutter analyze 実行"

run-dev:
	flutterfire configure \
	  --project api-project-732262258565 \
	  --android-package-name hm.orz.chaos114.android.tumekyouen.dev \
	  --ios-bundle-id hm.orz.chaos114.TumeKyouen.dev \
	  --platforms=android,ios,web \
	  --yes
	flutter run --dart-define-from-file=.env.dev

run-prod:
	flutterfire configure \
	  --project my-android-server \
	  --android-package-name hm.orz.chaos114.android.tumekyouen \
	  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
	  --platforms=android,ios,web \
	  --yes
	flutter run --dart-define-from-file=.env.prod

build-dev:
	ios/scripts/generate_provisioning_config.sh dev
	flutterfire configure \
	  --project api-project-732262258565 \
	  --android-package-name hm.orz.chaos114.android.tumekyouen.dev \
	  --ios-bundle-id hm.orz.chaos114.TumeKyouen.dev \
	  --platforms=android,ios,web \
	  --yes
	flutter build web --dart-define-from-file=.env.dev
	mkdir -p build/web/.well-known
	cp web/.well-known/dev/assetlinks.json build/web/.well-known/assetlinks.json
	cp web/.well-known/dev/apple-app-site-association build/web/.well-known/apple-app-site-association

build-prod:
	ios/scripts/generate_provisioning_config.sh prod
	flutterfire configure \
	  --project my-android-server \
	  --android-package-name hm.orz.chaos114.android.tumekyouen \
	  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
	  --platforms=android,ios,web \
	  --yes
	flutter build web --dart-define-from-file=.env.prod
	mkdir -p build/web/.well-known
	cp web/.well-known/prod/assetlinks.json build/web/.well-known/assetlinks.json
	cp web/.well-known/prod/apple-app-site-association build/web/.well-known/apple-app-site-association

test:
	flutter test --dart-define-from-file=.env.prod

gen:
	dart run build_runner build --delete-conflicting-outputs

analyze:
	flutter analyze

# ==============================================================
# Flutter スクリーンショット自動撮影
#
# 事前準備:
#   iOS:     $ open -a Simulator  でシミュレータを起動しておく
#   Android: $ emulator -avd <AVD名>  でエミュレータを起動しておく
#   Firebase: flutterfire configure (run-dev ターゲットが自動実行)
#
# 使い方:
#   $ make screenshots-ios
#   $ make screenshots-android
#   $ make screenshots        # iOS + Android 両方
#
# 出力先: build/screenshots/
# デバイス名の確認: flutter devices
# ==============================================================

DRIVER   = test_driver/integration_test.dart
TARGET   = integration_test/screenshot_test.dart

# ストア申請で推奨されるデバイス名（flutter devices で確認して書き換えること）
IOS_DEVICE     = iPhone 17 Pro Max
ANDROID_DEVICE = emulator-5554

screenshots: screenshots-ios screenshots-android

screenshots-ios:
	@echo "📱 iOS スクリーンショット撮影中... デバイス: $(IOS_DEVICE)"
	flutter drive \
	  --driver=$(DRIVER) \
	  --target=$(TARGET) \
	  --dart-define-from-file=.env.dev \
	  -d "$(IOS_DEVICE)"
	@echo "✅ iOS 完了"

screenshots-android:
	@echo "🤖 Android スクリーンショット撮影中... デバイス: $(ANDROID_DEVICE)"
	flutter drive \
	  --driver=$(DRIVER) \
	  --target=$(TARGET) \
	  --dart-define-from-file=.env.dev \
	  -d "$(ANDROID_DEVICE)"
	@echo "✅ Android 完了"

clean-screenshots:
	@echo "🗑️  スクリーンショットを削除します"
	rm -rf build/screenshots/

sim-lang-ja:
	@echo "iOSシミュレーターを日本語に切り替えます..."
	xcrun simctl spawn booted defaults write -g AppleLanguages -array "ja"
	xcrun simctl spawn booted defaults write -g AppleLocale -string "ja_JP"
	xcrun simctl shutdown booted
	xcrun simctl boot "$(IOS_DEVICE)"
	@echo "日本語に切り替えました（シミュレーターが再起動されました）"

sim-lang-en:
	@echo "iOSシミュレーターを英語に切り替えます..."
	xcrun simctl spawn booted defaults write -g AppleLanguages -array "en"
	xcrun simctl spawn booted defaults write -g AppleLocale -string "en_US"
	xcrun simctl shutdown booted
	xcrun simctl boot "$(IOS_DEVICE)"
	@echo "英語に切り替えました（シミュレーターが再起動されました）"
