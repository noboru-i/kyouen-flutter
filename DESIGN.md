# Kyouen Flutter — Design System

> 「詰め共円」の世界観を体現する、幾何学的エレガンスと静謐さをテーマにしたデザインシステム。
> Google Stitch の "vibe design" コンセプトに基づき、一貫した高品質な UI を素早く展開できることを目指す。

---

## 1. デザイン原則

| 原則 | 説明 |
|------|------|
| **幾何学的美学** | 円・石・格子というゲームの構成要素をUIモチーフとして継承する |
| **ダーク&ミニマル** | 暗いキャンバスにゲームを浮かび上がらせ、集中を促す |
| **意味あるモーション** | アニメーションは装飾ではなく、ゲームルールの可視化に使う |
| **標準フォントのみ** | アプリ容量抑制のためカスタムフォントは使用しない |

---

## 2. カラーシステム

### 基本パレット

```dart
// lib/src/widgets/theme/app_theme.dart に定義する
const kColorBgTop    = Color(0xFF1C2334);  // ダークネイビー (背景グラデーション上端)
const kColorBgBottom = Color(0xFF0D1117);  // 深夜ブラック   (背景グラデーション下端)
const kColorAccent   = Color(0xFFFF6B35);  // ウォームオレンジ (共円・CTA)
const kColorSuccess  = Color(0xFF4CAF50);  // グリーン        (クリア済み)
const kColorDanger   = Color(0xFFE53935);  // レッド          (破壊的アクション)
```

### テキスト用アルファ値

| トークン | 値 | 用途 |
|---------|-----|------|
| `onBg.primary`   | `Colors.white` (不透明) | 見出し・ボタンラベル |
| `onBg.secondary` | `Colors.white54` (54%) | 説明文・サブテキスト |
| `onBg.tertiary`  | `Colors.white38` (38%) | プレースホルダー |
| `onBg.disabled`  | `Colors.white24` (24%) | 無効状態 |

### サーフェス (カード・入力欄など)

| トークン | 値 | 用途 |
|---------|-----|------|
| `surface.low`    | `Colors.white.withValues(alpha: 0.06)` | 控えめな区切り |
| `surface.medium` | `Colors.white.withValues(alpha: 0.10)` | カード背景 |
| `surface.high`   | `Colors.white.withValues(alpha: 0.15)` | 強調カード・入力欄 |

---

## 3. タイポグラフィ

標準フォント (iOS: SF Pro / Android: Roboto) を使用する。

| ロール | fontSize | fontWeight | letterSpacing | 使用箇所 |
|--------|----------|------------|---------------|---------|
| `display`      | 40 | Bold (700)    | 6.0 | タイトル画面のアプリ名 |
| `titleLarge`   | 24 | Bold (700)    | 0.5 | ページ見出し |
| `titleMedium`  | 18 | SemiBold (600)| 0   | セクション見出し |
| `bodyLarge`    | 16 | Regular (400) | 0   | ボタンラベル・主要テキスト |
| `bodyMedium`   | 14 | Regular (400) | 0   | 一般テキスト |
| `bodySmall`    | 13 | Regular (400) | 0.5 | サブテキスト・キャプション |
| `caption`      | 12 | Regular (400) | 0   | フッター・補足 |

---

## 4. スペーシング

4px グリッドを基本単位とする。

```
4  / 8  / 12 / 16 / 24 / 32 / 48 / 64
xs / sm / md / lg / xl / 2x / 3x / 4x
```

ページの左右パディングは `horizontal: 32` を標準とする。

---

## 5. 背景 (`BackgroundWidget`)

全ページ共通の暗いグラデーション背景。

```
Gradient: kColorBgTop → kColorBgBottom (topCenter → bottomCenter)
装飾円:   白 4% 透明度の大円3つ (幾何学モチーフ)
```

タイトル画面の `_TitleBackground` が参照実装。`BackgroundWidget` をこれと同等に更新することで全ページに適用する。

---

## 6. コンポーネント

### 6.1 AppBar

```dart
AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  foregroundColor: Colors.white,          // アイコン・タイトルを白に
  title: Text(title, style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  )),
)
```

### 6.2 ボタン

**Primary (スタート・確定など主要アクション)**
```dart
FilledButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: kColorBgTop,
  minimumSize: const Size.fromHeight(56),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
)
```

**Secondary (ログイン・サブアクション)**
```dart
FilledButton.styleFrom(
  backgroundColor: Colors.white.withValues(alpha: 0.12),
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(52),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
)
```

**Danger (アカウント削除など破壊的操作)**
```dart
FilledButton.styleFrom(
  backgroundColor: kColorDanger,
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(56),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
)
```

### 6.3 カード

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white.withValues(alpha: 0.10),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  ),
  padding: const EdgeInsets.all(20),
)
```

Material `Card` は使用せず、上記の半透明コンテナで統一する。

### 6.4 ListTile (設定・オプション画面)

```dart
ListTile(
  tileColor: Colors.white.withValues(alpha: 0.06),
  iconColor: Colors.white70,
  textColor: Colors.white,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
)
```

### 6.5 SnackBar

```dart
SnackBar(
  backgroundColor: Colors.white.withValues(alpha: 0.15),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  content: Text(message, style: const TextStyle(color: Colors.white)),
)
```

### 6.6 AlertDialog

```dart
AlertDialog(
  backgroundColor: const Color(0xFF1E2A3A),   // サーフェス色
  titleTextStyle: const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  contentTextStyle: const TextStyle(
    color: Colors.white70,
    fontSize: 14,
  ),
)
```

### 6.7 プログレスバー

```dart
LinearProgressIndicator(
  value: progress,          // null で indeterminate
  minHeight: 5,
  backgroundColor: Colors.white.withValues(alpha: 0.15),
  valueColor: const AlwaysStoppedAnimation<Color>(kColorAccent),
)
```

---

## 7. アニメーション

| パターン | duration | curve | 用途 |
|---------|----------|-------|------|
| 共円描画 | 1800ms | `easeInOut` | タイトル画面の図、正解時の円弧 |
| フェードイン | 400ms | `easeOut` | ページ遷移・ダイアログ出現 |
| スケール弾性 | 600ms | `elasticOut` | 成功フィードバック |

---

## 8. ゲームボード (`StageBoard`)

盤面は現状の緑グラデーション (`#4CAF50` → `#2E7D32`) を維持する。
暗い背景との対比で視認性が確保されており、囲碁盤の伝統色として意味がある。

```
石(黒): RadialGradient #4A4A4A → #1C1C1C → #000000
石(白): RadialGradient #FFFFFF → #E8E8E8 → #D0D0D0
正解円: kColorAccent (#FF6B35), strokeWidth 4, strokeCap round
```

---

## 9. 各画面への適用方針

### 優先順位

| 優先度 | 画面 | 主な変更 |
|--------|------|---------|
| ✅ 完了 | `TitlePage` (native) | ダーク背景・共円アニメーション・プログレスバー |
| 🔶 高 | `BackgroundWidget` | ダークグラデーションに更新 (全画面に波及) |
| 🔶 高 | `AppTheme` | ダークカラースキーム・AppBar スタイル定義 |
| 🔷 中 | `AccountPage` | カードをガラス風サーフェスに。ボタンスタイル統一 |
| 🔷 中 | `StagePage` | ヘッダー・フッターのボタンスタイル統一 |
| 🔷 中 | `OptionsPage` | ListTile をダークスタイルに。セクション分け |
| ⬜ 低 | `PrivacyPolicyPage` | テキスト色を白系に調整 |

### 変更不要なもの

- `StageBoard` のゲームロジック・盤面描画
- `KyouenAnswerOverlayWidget` の円アニメーション
- `KyouenSuccessDialog` のコア構造

---

## 10. `AppTheme` 更新仕様

```dart
// lib/src/widgets/theme/app_theme.dart
static ThemeData get darkTheme {
  const colorScheme = ColorScheme.dark(
    primary: Color(0xFFFF6B35),           // kColorAccent
    onPrimary: Colors.white,
    surface: Color(0xFF1E2A3A),
    onSurface: Colors.white,
    error: Color(0xFFE53935),             // kColorDanger
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1C2334),
        minimumSize: Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      iconColor: Colors.white70,
      textColor: Colors.white,
    ),
  );
}
```

---

## 11. `BackgroundWidget` 更新仕様

```dart
// lib/src/widgets/common/background_widget.dart
class BackgroundWidget extends StatelessWidget {
  // 装飾円なし版 (子画面用: サブページ等)
  // タイトル画面は native_title_page.dart 内で装飾円付きバージョンを使用
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C2334), Color(0xFF0D1117)],
        ),
      ),
      child: child,
    );
  }
}
```
