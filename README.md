# kyouen_flutter

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application that follows the
[simple app state management
tutorial](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple).

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/docs/development/ui/assets-and-images#resolution-aware).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter
apps](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)

## Environment Configuration

This app supports environment switching using `dart-define` to configure:
- API connection domain
- Firebase project
- App name (with "DEV" prefix for development)

### Environment Variables

- `ENVIRONMENT`: Set to `dev` or `prod` (default: `prod`)
- `API_BASE_URL`: API endpoint URL (default: `https://kyouen.app/v2/`)
- `FIREBASE_PROJECT_ID`: Firebase project ID (default: `api-project-732262258565`)

### Firebase Configuration

The `lib/firebase_options.dart` file is automatically generated from `lib/firebase_options_template.dart` when running the build or run scripts. This file is gitignored and uses environment variables to configure Firebase for different environments.

### Running in Different Environments

#### Development Environment
```bash
# Using scripts
./scripts/run_dev.sh

# Or manually
flutter run \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=API_BASE_URL=https://dev.kyouen.app/v2/ \
  --dart-define=FIREBASE_PROJECT_ID=api-project-732262258565-dev
```

#### Production Environment
```bash
# Using scripts  
./scripts/run_prod.sh

# Or manually
flutter run \
  --dart-define=ENVIRONMENT=prod \
  --dart-define=API_BASE_URL=https://kyouen.app/v2/ \
  --dart-define=FIREBASE_PROJECT_ID=api-project-732262258565
```

### Building for Different Environments

#### Development Build
```bash
./scripts/build_dev.sh
```

#### Production Build
```bash
./scripts/build_prod.sh
```

## Scripts

### Setup Firebase
dev

```
flutterfire configure --project api-project-732262258565 --android-package-name hm.orz.chaos114.android.tumekyouen.dev --ios-bundle-id hm.orz.chaos114.TumeKyouen.dev --platforms=android,ios,web
```
