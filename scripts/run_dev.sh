#!/bin/bash

# Development environment run script
echo "Running in development environment..."

# Copy firebase options template if needed
if [ ! -f "lib/firebase_options.dart" ]; then
  echo "Copying firebase_options template..."
  cp lib/firebase_options_template.dart lib/firebase_options.dart
fi

flutter run \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=API_BASE_URL=https://dev.kyouen.app/v2/ \
  --dart-define=FIREBASE_PROJECT_ID=api-project-732262258565-dev

echo "Development app is running!"
echo "App name will show as: 'DEV 詰め共円'"
echo "API will connect to: https://dev.kyouen.app/v2/"
echo "Firebase project: api-project-732262258565-dev"