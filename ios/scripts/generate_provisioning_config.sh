#!/bin/bash

# This script generates ProvisioningProfile.xcconfig based on environment
# Usage: ./generate_provisioning_config.sh <environment>

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$SCRIPT_DIR/../Flutter/ProvisioningProfile.xcconfig"

if [ "$ENVIRONMENT" = "dev" ]; then
    PROFILE="TumeKyouenDevAdHoc"
else
    PROFILE="TumeKyouenDistribution"
fi

cat > "$CONFIG_FILE" << EOF
// Auto-generated provisioning profile configuration
// Generated for environment: $ENVIRONMENT

PROVISIONING_PROFILE_SPECIFIER = 
PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*] = $PROFILE
EOF

echo "Generated ProvisioningProfile.xcconfig for $ENVIRONMENT environment (Profile: $PROFILE)"
