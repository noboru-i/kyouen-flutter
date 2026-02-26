.PHONY: help run-dev run-prod build-dev build-prod test gen analyze

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

build-prod:
	ios/scripts/generate_provisioning_config.sh prod
	flutterfire configure \
	  --project my-android-server \
	  --android-package-name hm.orz.chaos114.android.tumekyouen \
	  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
	  --platforms=android,ios,web \
	  --yes
	flutter build web --dart-define-from-file=.env.prod

test:
	flutter test test/environment_test.dart --dart-define-from-file=.env.prod

gen:
	dart run build_runner build --delete-conflicting-outputs

analyze:
	flutter analyze
