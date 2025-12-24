# Firebase Cloud Messaging (FCM) Setup

This document describes the FCM implementation added to the Kyouen Flutter app.

## Overview

Firebase Cloud Messaging has been integrated to enable push notifications. The app automatically subscribes to the `stage_added` topic to receive notifications when new stages are available.

## Implementation Details

### Dependencies
- Added `firebase_messaging: ^15.1.8` to `pubspec.yaml`

### Main Setup (lib/main.dart)
- `_setupFirebaseMessaging()` function handles FCM initialization
- Requests notification permissions from the user
- Subscribes to the `stage_added` topic
- Sets up handlers for foreground and background messages
- Background message handler is defined as a top-level function with `@pragma('vm:entry-point')`

### Android Configuration
- Added required permissions to `AndroidManifest.xml`:
  - `INTERNET`, `WAKE_LOCK`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED`
- Added FCM service configuration for message handling

### iOS Configuration
- Added `remote-notification` background mode to `Info.plist`

## Usage

The FCM setup is automatic - when the app starts:
1. Firebase is initialized
2. Notification permissions are requested
3. App subscribes to `stage_added` topic
4. Message handlers are configured

## Testing

Basic tests are available in `test/fcm_test.dart` to verify the FCM setup.

## Topic Subscription

The app subscribes to the `stage_added` topic, which means it will receive push notifications whenever a message is sent to this topic from the Firebase Console or server.