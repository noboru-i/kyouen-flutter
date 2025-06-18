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
- `FIREBASE_PROJECT_ID`: Firebase project ID (default: `my-android-server`)

### Firebase Configuration

The `lib/firebase_options.dart` file is automatically generated using the `flutterfire configure` command when running the build or run scripts. This file is gitignored and will be configured for the appropriate Firebase project based on the environment:

- **Development environment**: Uses project `api-project-732262258565`
- **Production environment**: Uses project `my-android-server`

Each script automatically runs the appropriate `flutterfire configure` command to set up Firebase for the target environment.

### Running in Different Environments

#### Development Environment
```bash
# Using scripts
./scripts/run_dev.sh

# Or manually
flutter run \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=API_BASE_URL=https://dev.kyouen.app/v2/ \
  --dart-define=FIREBASE_PROJECT_ID=api-project-732262258565
```

#### Production Environment
```bash
# Using scripts  
./scripts/run_prod.sh

# Or manually
flutter run \
  --dart-define=ENVIRONMENT=prod \
  --dart-define=API_BASE_URL=https://kyouen.app/v2/ \
  --dart-define=FIREBASE_PROJECT_ID=my-android-server
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

### Manual Firebase Setup

If you need to manually configure Firebase for different environments, you can use these commands:

#### Development Environment
```bash
flutterfire configure \
  --project api-project-732262258565 \
  --android-package-name hm.orz.chaos114.android.tumekyouen.dev \
  --ios-bundle-id hm.orz.chaos114.TumeKyouen.dev \
  --platforms=android,ios,web
```

#### Production Environment
```bash
flutterfire configure \
  --project my-android-server \
  --android-package-name hm.orz.chaos114.android.tumekyouen \
  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
  --platforms=android,ios,web
```

**Note**: The build and run scripts automatically handle Firebase configuration, so manual setup is typically not required.
