#!/bin/bash

# Test script to run tests with development environment variables
echo "Running tests with development environment configuration..."

flutter test test/environment_test.dart \
  --dart-define-from-file=.env.dev

echo "Development environment tests completed!"