#!/bin/bash

# Test script to run tests with development environment variables
echo "Running tests with development environment configuration..."

flutter test test/environment_test.dart \
  --dart-define=ENVIRONMENT=dev \
  --dart-define=API_BASE_URL=https://dev.kyouen.app/v2/ \
  --dart-define=FIREBASE_PROJECT_ID=api-project-732262258565-dev

echo "Development environment tests completed!"