# 詰め共円アプリ紹介動画 — HyperFrames 制作指示書

## 前提・セットアップ

以下の手順で HyperFrames プロジェクトを初期化し、この指示書の内容をもとにコンポジション HTML を作成してレンダリングしてください。

```bash
# 1. HyperFrames スキルのインストール（未インストールの場合）
npx skills add heygen-com/hyperframes

# 2. プロジェクト初期化
npx hyperframes init kyouen-app-intro
cd kyouen-app-intro

# 3. プレビュー（作業中に随時確認）
npx hyperframes preview

# 4. 最終レンダリング
npx hyperframes render
```

---

## 動画仕様

| 項目 | 値 |
|---|---|
| 総尺 | 約60秒（60,000ms） |
| 解像度 | 1280×720（16:9） |
| フォーマット | MP4 |
| フレームレート | 30fps |
| 出力ファイル名 | `kyouen-app-intro.mp4` |

---

## デザイン基本方針

- **トーン**: 落ち着いた、静的、ミニマル
- **配色**:
  - 背景: `#0f0f0f`（ほぼ黒）
  - メインテキスト: `#e8e8e8`（オフホワイト）
  - アクセント: `#7eb8c9`（くすんだ水色）
  - サブテキスト: `#888888`（グレー）
- **フォント**:
  - 日本語: `"Noto Sans JP", sans-serif`
  - 数字・英字: `"Inter", sans-serif`
  - Google Fonts から読み込む
- **アニメーション原則**:
  - フェードイン/アウトは緩やかに（1.0〜1.5秒）
  - 動きは最小限。スライドやズームは使わない
  - GSAP の `fade` と `opacity` のみ使用
- **BGM**: 無音（別途音声トラックを乗せることを前提とする）

---

## シーン構成

コンポジション HTML は `compositions/kyouen-intro.html` として作成してください。
各シーンは `data-scene` 属性を持つ `<div>` として定義し、タイミングは `data-start`（ms）と `data-duration`（ms）で指定します。

---

### Scene 1 — 導入（0ms 〜 8000ms）

**目的**: タイトルを静かに提示する

**レイアウト**:
- 画面中央に大きめのタイトルテキストのみ
- それ以外の要素なし

**テキスト**:
```
詰め共円
```
（サブテキストとして小さく下に）
```
― 共円パズル ―
```

**アニメーション**:
- `0ms`: タイトル `opacity: 0`
- `500ms〜2000ms`: タイトル フェードイン（`opacity: 0 → 1`）、easing: `"power1.inOut"`
- `6500ms〜8000ms`: 全体 フェードアウト（`opacity: 1 → 0`）

**スタイル**:
- タイトルテキスト: font-size `72px`、font-weight `300`、letter-spacing `0.15em`
- サブテキスト: font-size `16px`、color `#888888`、letter-spacing `0.4em`、margin-top `16px`

---

### Scene 2 — ルール説明（8000ms 〜 28000ms）

**目的**: 詰め共円のルールを端的に説明する

**構成**: 3つのステップを順番にフェードイン表示する

#### Step 2-A（8000ms〜14000ms）

**テキスト**:
```
盤面に、石が並んでいます。
```
（サブテキスト）
```
オセロに似た碁盤目の上に、黒と白の石が置かれた状態からゲームは始まります。
```

**アニメーション**:
- `8500ms`: メインテキスト フェードイン（1200ms）
- `10000ms`: サブテキスト フェードイン（1000ms）
- `13500ms〜14000ms`: フェードアウト（500ms）

#### Step 2-B（14000ms〜21000ms）

**テキスト**:
```
「共円」とは ―
```
（説明テキスト）
```
同一円周上に存在する 4つの点のことです。
```
（補足テキスト、小さく）
```
3点は必ず1つの円を決める。
4点目がその円の上にあるとき、4点は共円の関係になります。
```

**右側にアニメーション図**:
- 4点（黒丸）が静かに現れる（`opacity: 0 → 1`）
- 少し遅れて円が描かれる（SVG `stroke-dashoffset` アニメーション）
- 円の色: `#7eb8c9`、線幅: `1.5px`

**アニメーション**:
- `14500ms`: 見出しテキスト フェードイン（1000ms）
- `15500ms`: 説明テキスト フェードイン（1000ms）
- `16500ms`: 補足テキスト フェードイン（1000ms）
- `17000ms`: 4点の黒丸 フェードイン（800ms）
- `18500ms`: 円の描画開始（`stroke-dashoffset` 1500ms）
- `20500ms〜21000ms`: フェードアウト（500ms）

#### Step 2-C（21000ms〜28000ms）

**テキスト**:
```
ゲームの目標
```
（説明テキスト）
```
盤面の中から、共円になる 4つの石を見つけてください。
```
（補足テキスト）
```
正方形・長方形・等脚台形など、
幾何学的なパターンが手がかりになります。
```

**アニメーション**:
- `21500ms`: 見出し フェードイン（1000ms）
- `22500ms`: 説明テキスト フェードイン（1000ms）
- `24000ms`: 補足テキスト フェードイン（1000ms）
- `27000ms〜28000ms`: フェードアウト（1000ms）

---

### Scene 3 — アプリ操作説明（28000ms 〜 52000ms）

**目的**: アプリの基本操作を3ステップで説明する

**全体レイアウト**:
- 左半分: 説明テキスト
- 右半分: アプリ画面のモックアップ（SVG で描画する碁盤と石）

#### Step 3-A「問題を開く」（28000ms〜36000ms）

**左テキスト**:
```
Step 1
```
（メインテキスト）
```
問題を選んで
盤面を開きます。
```
（サブテキスト）
```
難易度は初級から上級まであります。
```

**右モックアップ**:
- 碁盤目（8×8 グリッド）を SVG で描画
- グリッド色: `#2a2a2a`（暗いグレー線）
- 石をランダムに15〜20個配置（黒: `#222`、白: `#ddd`、いずれも丸）
- 盤面全体を `opacity: 0 → 1` でフェードイン

**アニメーション**:
- `28500ms`: Step番号 フェードイン（800ms）
- `29300ms`: メインテキスト フェードイン（1000ms）
- `30300ms`: サブテキスト フェードイン（800ms）
- `30800ms`: 盤面モックアップ フェードイン（1200ms）
- `35000ms〜36000ms`: フェードアウト（1000ms）

#### Step 3-B「石を選択する」（36000ms〜44000ms）

**左テキスト**:
```
Step 2
```
（メインテキスト）
```
4つの石をタップして
選択します。
```
（サブテキスト）
```
選んだ石はハイライト表示されます。
```

**右モックアップ**:
- 同じ盤面を表示
- 4つの石が順番に `border` でハイライトされる（`#7eb8c9` の外枠）
- 1個ずつ 500ms 間隔でハイライトが追加される演出

**アニメーション**:
- `36500ms`: Step番号・テキスト フェードイン（1000ms）
- `37500ms`: 盤面 フェードイン（800ms）
- `38500ms`: 石1つ目 ハイライト（`opacity: 0 → 1`、300ms）
- `39000ms`: 石2つ目 ハイライト
- `39500ms`: 石3つ目 ハイライト
- `40000ms`: 石4つ目 ハイライト
- `43000ms〜44000ms`: フェードアウト（1000ms）

#### Step 3-C「正解判定」（44000ms〜52000ms）

**左テキスト**:
```
Step 3
```
（メインテキスト）
```
4点が共円であれば、
円が描かれて正解となります。
```
（サブテキスト）
```
間違えた場合は選択がリセットされます。
```

**右モックアップ**:
- ハイライトされた4石の状態から
- `#7eb8c9` の円が静かに描画される（SVG `stroke-dashoffset` アニメーション、2000ms）

**アニメーション**:
- `44500ms`: Step番号・テキスト フェードイン（1000ms）
- `45500ms`: 盤面（4点ハイライト状態）フェードイン（800ms）
- `46500ms`: 円の描画開始（`stroke-dashoffset`、2000ms、easing: `"power1.inOut"`）
- `51000ms〜52000ms`: フェードアウト（1000ms）

---

### Scene 4 — 締め・CTA（52000ms 〜 60000ms）

**目的**: 静かにまとめ、アプリへの導線を示す

**レイアウト**:
- 画面中央に縦並び

**テキスト構成**:
```
詰め共円は、幾何学的な直感を静かに問いかけるパズルです。
```
（間を置いて）
```
詰め共円
```
（アプリアイコン画像 or プレースホルダー枠 ※画像は別途差し替え）
```
App Store / Google Play にて配信中
```

**アニメーション**:
- `52500ms`: キャッチコピー フェードイン（1200ms）
- `54500ms`: アプリ名 フェードイン（1000ms）
- `55500ms`: アイコンプレースホルダー フェードイン（800ms）
- `56500ms`: 配信情報テキスト フェードイン（800ms）
- `59500ms〜60000ms`: 全体 フェードアウト（500ms）

**アイコンプレースホルダーのスタイル**:
- `width: 80px`、`height: 80px`
- `border-radius: 18px`
- `background: #1e3a45`（暗い水色）
- 中央に `○` を `#7eb8c9` で表示（共円のイメージ）

---

## HTMLコンポジション実装メモ

```html
<!DOCTYPE html>
<html data-duration="60000" data-fps="30" data-width="1280" data-height="720">
<head>
  <meta charset="UTF-8">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+JP:wght@300;400&family=Inter:wght@300;400&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: #0f0f0f;
      color: #e8e8e8;
      font-family: "Noto Sans JP", "Inter", sans-serif;
      font-weight: 300;
      overflow: hidden;
      width: 1280px;
      height: 720px;
    }
    .scene {
      position: absolute;
      inset: 0;
      display: flex;
      align-items: center;
      justify-content: center;
      opacity: 0;
    }
    /* 各シーンのレイアウトは scene-id ごとに定義 */
  </style>
</head>
<body>
  <!-- Scene 1: タイトル -->
  <div class="scene" id="scene-1" data-scene data-start="0" data-duration="8000">
    <!-- テキスト要素をここに配置 -->
  </div>

  <!-- Scene 2: ルール説明（3ステップ） -->
  <div class="scene" id="scene-2a" data-scene data-start="8000" data-duration="6000">
    <!-- Step 2-A -->
  </div>
  <div class="scene" id="scene-2b" data-scene data-start="14000" data-duration="7000">
    <!-- Step 2-B（SVG円アニメーション含む） -->
  </div>
  <div class="scene" id="scene-2c" data-scene data-start="21000" data-duration="7000">
    <!-- Step 2-C -->
  </div>

  <!-- Scene 3: アプリ操作説明（3ステップ） -->
  <div class="scene" id="scene-3a" data-scene data-start="28000" data-duration="8000">
    <!-- Step 3-A（盤面モックアップ） -->
  </div>
  <div class="scene" id="scene-3b" data-scene data-start="36000" data-duration="8000">
    <!-- Step 3-B（石のハイライト） -->
  </div>
  <div class="scene" id="scene-3c" data-scene data-start="44000" data-duration="8000">
    <!-- Step 3-C（円の描画） -->
  </div>

  <!-- Scene 4: 締め -->
  <div class="scene" id="scene-4" data-scene data-start="52000" data-duration="8000">
    <!-- CTA -->
  </div>

  <!-- GSAP (CDN) -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>
  <script>
    // 各シーンのアニメーションを上記タイミング指定に従って実装する
    // gsap.to() で opacity アニメーションを記述する
    // data-start の値をミリ秒→秒に変換して delay に使用する
  </script>
</body>
</html>
```

---

## 差し替え・カスタマイズ対象

以下は制作後に実際の素材に差し替えてください。

| 項目 | 現在の状態 | 差し替え内容 |
|---|---|---|
| アプリアイコン | プレースホルダー枠 | 実際のアプリアイコン画像（PNG推奨） |
| 盤面モックアップ | SVGで生成した仮盤面 | 実際のアプリのスクリーンショット |
| 配信情報テキスト | `App Store / Google Play にて配信中` | 実際の配信先・URL・QRコード |
| BGM | 無音 | 別途音声ファイルを FFmpeg でミックス |

---

## レンダリング後の音声合成（任意）

ナレーションをつける場合、以下のスクリプトを参考に TTS ツール（VOICEVOX 等）で音声を生成し、FFmpeg でミックスしてください。

### ナレーション台本

| シーン | タイムコード | テキスト |
|---|---|---|
| Scene 1 | 0:01〜0:07 | 「これは、詰め共円というパズルです。」 |
| Scene 2-A | 0:09〜0:13 | 「盤面に、石が並んでいます。」 |
| Scene 2-B | 0:15〜0:20 | 「同一円周上に存在する4つの点のことを、共円といいます。3点は必ず1つの円を決めます。4点目がその円の上にあるとき、その4点は共円の関係にあります。」 |
| Scene 2-C | 0:22〜0:27 | 「盤面の中から、共円になる4つの石を見つけてください。」 |
| Scene 3-A | 0:29〜0:35 | 「問題を選んで、盤面を開きます。」 |
| Scene 3-B | 0:37〜0:43 | 「4つの石をタップして選択します。」 |
| Scene 3-C | 0:45〜0:51 | 「4点が共円であれば、円が描かれて正解となります。間違えた場合は、選択がリセットされます。」 |
| Scene 4 | 0:53〜0:59 | 「詰め共円は、幾何学的な直感を静かに問いかけるパズルです。」 |

```bash
# 音声ミックスの例（FFmpeg）
ffmpeg -i kyouen-app-intro.mp4 -i narration.mp3 \
  -filter_complex "[1:a]volume=1.0[a]" \
  -map 0:v -map "[a]" \
  -c:v copy -c:a aac \
  kyouen-app-intro-with-audio.mp4
```