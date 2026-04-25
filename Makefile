.PHONY: help run-dev run-prod build-dev build-prod build-ios-prod test gen analyze

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Run:"
	@echo "  run-dev     開発環境でアプリを起動"
	@echo "  run-prod    本番環境でアプリを起動"
	@echo ""
	@echo "Build:"
	@echo "  build-dev       開発環境向けビルド"
	@echo "  build-prod      本番環境向けビルド"
	@echo "  build-ios-prod  iOS本番ビルド & App Store Connectアップロード"
	@echo ""
	@echo "Test:"
	@echo "  test        開発環境でテスト実行"
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

build-ios-prod:
	ios/scripts/generate_provisioning_config.sh prod
	flutterfire configure \
	  --project my-android-server \
	  --android-package-name hm.orz.chaos114.android.tumekyouen \
	  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
	  --platforms=android,ios,web \
	  --yes
	flutter build ipa \
	  --dart-define-from-file=.env.prod \
	  --export-options-plist=ios/ExportOptions.prod.plist

test:
	flutter test --dart-define-from-file=.env.prod

gen:
	dart run build_runner build --delete-conflicting-outputs

analyze:
	flutter analyze
