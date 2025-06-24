#!/bin/sh

# Define output file path
OUTPUT_FILE="${SRCROOT}/Flutter/Dart-Defines.xcconfig"
# Clear previous contents
: > $OUTPUT_FILE

# Function to decode Dart defines
function decode_url() { echo "${*}" | base64 --decode; }

IFS=',' read -r -a define_items <<<"$DART_DEFINES"

for index in "${!define_items[@]}"
do
    item=$(decode_url "${define_items[$index]}")
    # Convert to lowercase to check
    lowercase_item=$(echo "$item" | tr '[:upper:]' '[:lower:]')
    # Exclude Flutter-related defines
    if [[ $lowercase_item != flutter* ]]; then
        echo "$item" >> "$OUTPUT_FILE"
    fi
done