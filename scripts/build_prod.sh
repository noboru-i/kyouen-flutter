#!/bin/bash

# Production environment build script
echo "Building for production environment..."

# Copy firebase options template if needed
if [ ! -f "lib/firebase_options.dart" ]; then
  echo "Copying firebase_options template..."
  cp lib/firebase_options_template.dart lib/firebase_options.dart
fi

flutter build web \
  --dart-define=ENVIRONMENT=prod \
  --dart-define=API_BASE_URL=https://kyouen.app/v2/ \
  --dart-define=FIREBASE_PROJECT_ID=api-project-732262258565

echo "Production build completed!"
echo "App name will show as: '詰め共円'"
echo "API will connect to: https://kyouen.app/v2/"
echo "Firebase project: api-project-732262258565"