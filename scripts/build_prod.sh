#!/bin/bash

# Production environment build script
echo "Building for production environment..."

# Generate provisioning profile configuration for prod
echo "Generating provisioning profile configuration..."
ios/scripts/generate_provisioning_config.sh prod

# Configure Firebase for production environment
echo "Configuring Firebase for production environment..."
flutterfire configure \
  --project my-android-server \
  --android-package-name hm.orz.chaos114.android.tumekyouen \
  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
  --platforms=android,ios,web \
  --yes

flutter build web \
  --dart-define-from-file=.env.prod

echo "Production build completed!"
echo "App name will show as: '詰め共円'"
echo "API will connect to: https://kyouen.app/v2/"
echo "Firebase project: my-android-server"