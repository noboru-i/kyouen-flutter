#!/bin/bash

# Production environment build script
echo "Building for production environment..."

# Configure Firebase for production environment
echo "Configuring Firebase for production environment..."
flutterfire configure \
  --project api-project-732262258565 \
  --android-package-name hm.orz.chaos114.android.tumekyouen \
  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
  --platforms=android,ios,web \
  --yes

flutter build web \
  --dart-define=ENVIRONMENT=prod \
  --dart-define=API_BASE_URL=https://kyouen.app/v2/ \
  --dart-define=FIREBASE_PROJECT_ID=api-project-732262258565

echo "Production build completed!"
echo "App name will show as: '詰め共円'"
echo "API will connect to: https://kyouen.app/v2/"
echo "Firebase project: api-project-732262258565"