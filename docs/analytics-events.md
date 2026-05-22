# Analytics イベント定義書

Firebase Analytics に送信するイベント・ユーザープロパティの定義一覧。

実装ファイル: `lib/src/data/analytics/analytics_service.dart`

---

## ユーザープロパティ

| プロパティ名 | 型 | 値の例 | 設定タイミング |
|---|---|---|---|
| `platform_kind` | string | `web` / `ios` / `android` | アプリ起動時 (`initPlatformProperty`) |
| `auth_method` | string | `twitter` / `apple` | ログイン成功後 (`setUserContext`) |
| `cleared_stage_count` | string (数値) | `"42"` | ステージクリア時 / ログイン後の同期成功時 / 手動同期成功時 |

ユーザーIDは `setUserId` で設定（未ログイン時は `null`）。

---

## 同意設定

アプリ起動時にデフォルトで全同意を「拒否」に設定し、ユーザーの同意取得後に反映する。

| Firebase 設定項目 | 対応同意項目 |
|---|---|
| `analyticsStorageConsentGranted` | アクセス解析の同意 |
| `adStorageConsentGranted` | 広告配信の同意 |
| `adUserDataConsentGranted` | 広告向けユーザーデータの同意 |
| `adPersonalizationSignalsConsentGranted` | 広告パーソナライズの同意 |

---

## カスタムイベント一覧

### ステージ関連

#### `stage_start`

`currentStageNoProvider` の値が変化したとき（`ref.listen`）に送信。ステージページ表示時の初期ロード（loading → data 遷移）とステージ切り替え時の両方で発火する。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |
| `source` | string | 遷移元（現在は常に `unknown`） |

---

#### `stage_clear`

ステージクリア時に送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |
| `board_size` | int | ボードサイズ（一辺のマス数、例: 6 → 6×6ボード） |
| `duration_ms` | int | ステージ開始からクリアまでの経過時間（ミリ秒） |
| `used_hint` | int | ヒントを使用したか（`1`: 使用, `0`: 未使用） |
| `taps_count` | int | タップ総数 |

---

#### `stage_fail`

「共円」の判定失敗時（石を選択したが共円でなかった）に送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |
| `stage` | string | 失敗時の盤面状態（`0`=空, `1`=黒石, `2`=白石(選択中)） |

---

#### `stage_reset`

ステージをリセットしたときに送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |

---

### ヒント広告関連

#### `hint_requested`

ユーザーがヒントボタンを押した時点で送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |
| `ad_ready` | int | 広告の準備ができているか（`1`: 準備済み, `0`: 未準備） |

---

#### `hint_ad_shown`

リワード広告が表示されたときに送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |

---

#### `hint_reward_earned`

ユーザーが広告を最後まで視聴して報酬（ヒント）を獲得したときに送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |

---

#### `hint_ad_failed`

広告の読み込みまたは表示に失敗したときに送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |
| `reason` | string | `no_fill`（広告在庫なし）/ `show_failed`（表示失敗） |

---

### アカウント関連

#### `login`

Firebase 標準イベント (`logLogin`) を使用。ログイン成功時に送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `method` | string | `twitter` / `apple` |

---

#### `logout`

ログアウト時に送信。パラメータなし。

---

#### `account_delete`

アカウント削除成功時に送信。パラメータなし。

---

### データ同期関連

#### `sync_stages`

ログイン後のクリア状況同期完了時に送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `result` | string | `success` / `fail` |
| `synced_count` | int | 同期されたステージ数（成功時のみ） |
| `error_type` | string | エラー種別（失敗時のみ） |

---

### ナビゲーション関連

#### `deep_link_open`

アプリリンク（App Links / Universal Links）経由でステージを開いたときに送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |
| `source` | string | `app_links` |

---

#### `notification_open`

プッシュ通知からステージを開いたときに送信。

| パラメータ | 型 | 値 |
|---|---|---|
| `stage_no` | int | ステージ番号 |
