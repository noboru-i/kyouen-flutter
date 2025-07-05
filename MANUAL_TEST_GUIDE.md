# Manual Testing Guide for Last Stage Number Persistence

## Feature Description
This feature saves the last opened stage number to SharedPreferences and restores it when the app is restarted, matching the Android implementation behavior.

## Test Steps

### 1. Initial State Test
1. Fresh install the app (or clear app data)
2. Navigate to the stage page
3. **Expected**: Should show "STAGE: 1" (default value)

### 2. Navigation Test
1. From stage 1, tap "次へ" (Next) button several times
2. Navigate to stage 5
3. **Expected**: Should show "STAGE: 5"

### 3. Persistence Test
1. While on stage 5, close the app completely
2. Restart the app
3. Navigate to the stage page
4. **Expected**: Should show "STAGE: 5" (restored from preferences)

### 4. Previous Navigation Test
1. From stage 5, tap "前へ" (Previous) button
2. **Expected**: Should show "STAGE: 4"
3. Close and restart the app
4. Navigate to the stage page
5. **Expected**: Should show "STAGE: 4"

### 5. Boundary Test
1. Navigate to stage 1
2. Tap "前へ" (Previous) button
3. **Expected**: Should stay at "STAGE: 1" (cannot go below 1)

### 6. Large Number Test
1. Navigate to a high stage number (e.g., stage 50)
2. Close and restart the app
3. Navigate to the stage page
4. **Expected**: Should show "STAGE: 50"

## Code Changes Made

### 1. Added SharedPreferences Dependency
- Added `shared_preferences: ^2.5.0` to pubspec.yaml

### 2. Created PreferenceService
- `lib/src/data/local/preference_service.dart`
- Handles saving/loading stage numbers
- Uses key `last_stage_no` matching Android implementation

### 3. Updated CurrentStageNo Provider
- Now saves stage number on navigation (next/prev/setStageNo)
- Loads saved stage number when StagePage is opened
- Handles errors gracefully

### 4. Updated StagePage
- Listens to `initialStageNoProvider` to load saved stage number
- Updates current stage number if different from saved value

## Technical Implementation Details

### SharedPreferences Key
- Uses `last_stage_no` key (matching Android `KEY_LAST_STAGE_NO`)
- Default value is 1 if no saved value exists

### Persistence Points
- Stage number is saved when:
  - User navigates next/previous
  - Stage number is set directly via `setStageNo()`
  - Stage is accessed (CurrentStage provider build)

### Error Handling
- App continues to work even if SharedPreferences fails
- Graceful fallback to default values
- No crashes due to persistence errors

## Test Coverage
- Unit tests for PreferenceService
- Integration tests for CurrentStageNo provider
- Tests for boundary conditions and error scenarios