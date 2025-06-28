# Stage Count Display Implementation

## Overview
This implementation adds a stage count display to the title page showing "クリアステージ数: X / Y" where X is the number of cleared stages and Y is the total number of stages.

## Changes Made

### 1. Title Page Conversion
- **File**: `lib/src/features/title/title_page.dart`
- **Change**: Converted from `StatelessWidget` to `ConsumerWidget` to access Riverpod providers
- **Added**: Import for `flutter_riverpod` and `cleared_stages_service`

### 2. Stage Count Display Widget
- **Added**: `_StageCountDisplay` widget as a private ConsumerWidget
- **Functionality**: Uses FutureBuilder to asynchronously load stage count data
- **Data Source**: Uses existing `clearedStagesService.getStageCount()` method
- **States Handled**:
  - Loading: Shows "ステージ情報を読み込み中..." message
  - Error: Shows "ステージ情報取得エラー" message with red styling
  - Success: Shows "クリアステージ数: X / Y" with blue accent styling

### 3. UI Integration
- **Location**: Added to the title card section below the app subtitle
- **Styling**: Consistent with the app's design language using:
  - Light blue accent color (0xFF3498DB)
  - Rounded corners (12px border radius)
  - Subtle border and background
  - Proper padding and typography

### 4. Testing
- **File**: `test/features/title/title_page_test.dart`
- **Coverage**: Tests for correct display, loading state, and error handling
- **Mock**: Uses MockClearedStagesService for isolated testing

## Data Flow
```
SQLite Database -> TumeKyouenDao -> ClearedStagesService -> TitlePage -> _StageCountDisplay
```

## Visual Layout
```
┌─────────────────────────────────────┐
│           App Title Card            │
│  ┌─────────────────────────────┐   │
│  │      アプリ名表示            │   │
│  │   詰め共円パズルゲーム        │   │
│  │                             │   │
│  │ ┌─────────────────────────┐ │   │
│  │ │ クリアステージ数: 3 / 10 │ │   │ <- NEW
│  │ └─────────────────────────┘ │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## Implementation Benefits
1. **Minimal Changes**: Used existing service without creating new providers
2. **Consistent Design**: Matches the app's existing visual style
3. **Robust Error Handling**: Gracefully handles loading and error states
4. **Testable**: Comprehensive unit tests ensure reliability
5. **Performance**: Uses FutureBuilder for efficient async data loading