#!/bin/bash

# Production environment run script
echo "Running in production environment..."

# Configure Firebase for production environment
echo "Configuring Firebase for production environment..."
flutterfire configure \
  --project my-android-server \
  --android-package-name hm.orz.chaos114.android.tumekyouen \
  --ios-bundle-id hm.orz.chaos114.TumeKyouen \
  --platforms=android,ios,web \
  --yes

flutter run \
  --dart-define-from-file=.env.prod

echo "Production app is running!"
echo "App name will show as: '詰め共円'"
echo "API will connect to: https://kyouen.app/v2/"
echo "Firebase project: my-android-server"