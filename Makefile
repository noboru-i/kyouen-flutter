.PHONY: help run-dev run-prod build-dev build-prod test gen setup-web analyze screenshots screenshots-all screenshots-iphone screenshots-ipad screenshots-android clean-screenshots sim-lang-ja sim-lang-en sim-ipad-lang-ja sim-ipad-lang-en android-lang-ja android-lang-en

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
	@echo "  screenshots-all      英語/日本語 × Android/iOS/iPad の6パターンを撮影"
	@echo "  screenshots-iphone   iPhoneシミュレータでスクリーンショット撮影"
	@echo "  screenshots-ipad     iPad 13インチシミュレータでスクリーンショット撮影"
	@echo "  screenshots-android  Android エミュレータでスクリーンショット撮影"
	@echo "  clean-screenshots    撮影済み画像を削除"
	@echo ""
	@echo "Simulator:"
	@echo "  sim-lang-ja       iPhoneシミュレーターを日本語に切り替えて再起動"
	@echo "  sim-lang-en       iPhoneシミュレーターを英語に切り替えて再起動"
	@echo "  sim-ipad-lang-ja  iPadシミュレーターを日本語に切り替えて再起動"
	@echo "  sim-ipad-lang-en  iPadシミュレーターを英語に切り替えて再起動"
	@echo "  android-lang-ja  Androidエミュレーターのアプリ言語を日本語に切り替え"
	@echo "  android-lang-en  Androidエミュレーターのアプリ言語を英語に切り替え"
	@echo ""
	@echo "Code:"
	@echo "  gen         コード生成 (Riverpod, Freezed, JSON, Chopper, L10n)"
	@echo "  setup-web   Web向けSQLiteファイル生成"
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
	flutter gen-l10n

setup-web:
	dart run sqflite_common_ffi_web:setup

analyze:
	flutter analyze --fatal-infos

# ==============================================================
# Flutter スクリーンショット自動撮影
#
# 事前準備:
#   iOS:     $ open -a Simulator  でシミュレータを起動しておく
#   Android: $ emulator -avd <AVD名>  でエミュレータを起動しておく
#   Firebase: flutterfire configure (run-dev ターゲットが自動実行)
#
# 使い方:
#   $ make screenshots-iphone
#   $ make screenshots-ipad
#   $ make screenshots-android
#   $ make screenshots        # iOS + Android 両方
#   $ make screenshots-all    # 英語/日本語 × Android/iOS/iPad の6パターン
#
# 出力先: build/screenshots/
# デバイス名の確認: flutter devices
# ==============================================================

DRIVER         = test_driver/integration_test.dart
TARGET         = integration_test/screenshot_test.dart
SCREENSHOT_DIR = build/screenshots

# ストア申請で推奨されるデバイス名（flutter devices で確認して書き換えること）
IOS_DEVICE     = iPhone 17 Pro Max
IOS_IPAD_DEVICE = iPad Pro 13-inch (M5)
ANDROID_DEVICE = emulator-5554
ANDROID_PACKAGE = hm.orz.chaos114.android.tumekyouen.dev

screenshots:
	$(MAKE) screenshots-iphone SCREENSHOT_DIR=$(SCREENSHOT_DIR)/iphone
	$(MAKE) screenshots-ipad SCREENSHOT_DIR=$(SCREENSHOT_DIR)/ipad-13
	$(MAKE) screenshots-android SCREENSHOT_DIR=$(SCREENSHOT_DIR)/android

screenshots-all:
	@echo "英語 Android のスクリーンショットを撮影します"
	$(MAKE) android-lang-en
	$(MAKE) screenshots-android SCREENSHOT_DIR=build/screenshots/en/android
	@echo "英語 iOS のスクリーンショットを撮影します"
	$(MAKE) sim-lang-en
	$(MAKE) screenshots-iphone SCREENSHOT_DIR=build/screenshots/en/iphone
	@echo "英語 iPad 13インチ のスクリーンショットを撮影します"
	$(MAKE) sim-ipad-lang-en
	$(MAKE) screenshots-ipad SCREENSHOT_DIR=build/screenshots/en/ipad-13
	@echo "日本語 Android のスクリーンショットを撮影します"
	$(MAKE) android-lang-ja
	$(MAKE) screenshots-android SCREENSHOT_DIR=build/screenshots/ja/android
	@echo "日本語 iOS のスクリーンショットを撮影します"
	$(MAKE) sim-lang-ja
	$(MAKE) screenshots-iphone SCREENSHOT_DIR=build/screenshots/ja/iphone
	@echo "日本語 iPad 13インチ のスクリーンショットを撮影します"
	$(MAKE) sim-ipad-lang-ja
	$(MAKE) screenshots-ipad SCREENSHOT_DIR=build/screenshots/ja/ipad-13
	@echo "6パターンのスクリーンショット撮影が完了しました: build/screenshots/"

screenshots-iphone:
	@echo "📱 iPhone スクリーンショット撮影中... デバイス: $(IOS_DEVICE), 出力先: $(SCREENSHOT_DIR)"
	SCREENSHOT_DIR="$(SCREENSHOT_DIR)" flutter drive \
	  --driver=$(DRIVER) \
	  --target=$(TARGET) \
	  --dart-define-from-file=.env.dev \
	  -d "$(IOS_DEVICE)"
	@echo "✅ iPhone 完了"

screenshots-ipad:
	@echo "📱 iPad 13インチ スクリーンショット撮影中... デバイス: $(IOS_IPAD_DEVICE), 出力先: $(SCREENSHOT_DIR)"
	SCREENSHOT_DIR="$(SCREENSHOT_DIR)" flutter drive \
	  --driver=$(DRIVER) \
	  --target=$(TARGET) \
	  --dart-define-from-file=.env.dev \
	  -d "$(IOS_IPAD_DEVICE)"
	@echo "✅ iPad 13インチ 完了"

screenshots-android:
	@echo "🤖 Android スクリーンショット撮影中... デバイス: $(ANDROID_DEVICE), 出力先: $(SCREENSHOT_DIR)"
	cd android && ./gradlew --stop
	SCREENSHOT_DIR="$(SCREENSHOT_DIR)" flutter drive \
	  --driver=$(DRIVER) \
	  --target=$(TARGET) \
	  --dart-define-from-file=.env.dev \
	  -d "$(ANDROID_DEVICE)"
	@echo "✅ Android 完了"

clean-screenshots:
	@echo "🗑️  スクリーンショットを削除します"
	rm -rf build/screenshots/

sim-lang-ja:
	@echo "iOSシミュレーターを日本語に切り替えます... デバイス: $(IOS_DEVICE)"
	-xcrun simctl boot "$(IOS_DEVICE)"
	xcrun simctl spawn "$(IOS_DEVICE)" defaults write -g AppleLanguages -array "ja"
	xcrun simctl spawn "$(IOS_DEVICE)" defaults write -g AppleLocale -string "ja_JP"
	xcrun simctl shutdown "$(IOS_DEVICE)"
	xcrun simctl boot "$(IOS_DEVICE)"
	@echo "日本語に切り替えました（シミュレーターが再起動されました）"

sim-lang-en:
	@echo "iOSシミュレーターを英語に切り替えます... デバイス: $(IOS_DEVICE)"
	-xcrun simctl boot "$(IOS_DEVICE)"
	xcrun simctl spawn "$(IOS_DEVICE)" defaults write -g AppleLanguages -array "en"
	xcrun simctl spawn "$(IOS_DEVICE)" defaults write -g AppleLocale -string "en_US"
	xcrun simctl shutdown "$(IOS_DEVICE)"
	xcrun simctl boot "$(IOS_DEVICE)"
	@echo "英語に切り替えました（シミュレーターが再起動されました）"

sim-ipad-lang-ja:
	@echo "iPadシミュレーターを日本語に切り替えます... デバイス: $(IOS_IPAD_DEVICE)"
	-xcrun simctl boot "$(IOS_IPAD_DEVICE)"
	xcrun simctl spawn "$(IOS_IPAD_DEVICE)" defaults write -g AppleLanguages -array "ja"
	xcrun simctl spawn "$(IOS_IPAD_DEVICE)" defaults write -g AppleLocale -string "ja_JP"
	xcrun simctl shutdown "$(IOS_IPAD_DEVICE)"
	xcrun simctl boot "$(IOS_IPAD_DEVICE)"
	@echo "日本語に切り替えました（iPadシミュレーターが再起動されました）"

sim-ipad-lang-en:
	@echo "iPadシミュレーターを英語に切り替えます... デバイス: $(IOS_IPAD_DEVICE)"
	-xcrun simctl boot "$(IOS_IPAD_DEVICE)"
	xcrun simctl spawn "$(IOS_IPAD_DEVICE)" defaults write -g AppleLanguages -array "en"
	xcrun simctl spawn "$(IOS_IPAD_DEVICE)" defaults write -g AppleLocale -string "en_US"
	xcrun simctl shutdown "$(IOS_IPAD_DEVICE)"
	xcrun simctl boot "$(IOS_IPAD_DEVICE)"
	@echo "英語に切り替えました（iPadシミュレーターが再起動されました）"

android-lang-ja:
	@echo "Androidエミュレーターのアプリ言語を日本語に切り替えます... デバイス: $(ANDROID_DEVICE), パッケージ: $(ANDROID_PACKAGE)"
	adb -s "$(ANDROID_DEVICE)" shell cmd locale set-app-locales "$(ANDROID_PACKAGE)" ja-JP
	adb -s "$(ANDROID_DEVICE)" shell am force-stop "$(ANDROID_PACKAGE)"
	@echo "日本語に切り替えました（アプリを再起動してください）"

android-lang-en:
	@echo "Androidエミュレーターのアプリ言語を英語に切り替えます... デバイス: $(ANDROID_DEVICE), パッケージ: $(ANDROID_PACKAGE)"
	adb -s "$(ANDROID_DEVICE)" shell cmd locale set-app-locales "$(ANDROID_PACKAGE)" en-US
	adb -s "$(ANDROID_DEVICE)" shell am force-stop "$(ANDROID_PACKAGE)"
	@echo "英語に切り替えました（アプリを再起動してください）"
