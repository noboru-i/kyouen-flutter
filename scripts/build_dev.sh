#!/bin/bash

# Development environment build script
echo "Building for development environment..."

# Generate provisioning profile configuration for dev
echo "Generating provisioning profile configuration..."
ios/scripts/generate_provisioning_config.sh dev

# Configure Firebase for development environment
echo "Configuring Firebase for development environment..."
flutterfire configure \
  --project api-project-732262258565 \
  --android-package-name hm.orz.chaos114.android.tumekyouen.dev \
  --ios-bundle-id hm.orz.chaos114.TumeKyouen.dev \
  --platforms=android,ios,web \
  --yes

flutter build web \
  --dart-define-from-file=.env.dev

echo "Development build completed!"
echo "App name will show as: 'DEV 詰め共円'"
echo "API will connect to: https://kyouen-server-dev-732262258565.asia-northeast1.run.app/v2/"
echo "Firebase project: api-project-732262258565"