// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '詰め共円';

  @override
  String get kyouenTitle => '共円';

  @override
  String get kyouenDescription =>
      '共円とは、４つの石を通る円のことです。\nこのページでは、盤上に置かれた石から共円を指摘する、「詰め共円」が多数登録されています。';

  @override
  String get start => 'スタート';

  @override
  String get createStage => 'ステージ作成';

  @override
  String get latestRegistrations => '最新の登録';

  @override
  String get activity => 'アクティビティ';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String stagesClearedCount(int count) {
    return '$countステージクリア';
  }

  @override
  String get loadingStageInfo => 'ステージ情報を読み込み中...';

  @override
  String get stageInfoError => 'ステージ情報取得エラー';

  @override
  String clearedStagesCount(int cleared, int total) {
    return 'クリアステージ数: $cleared / $total';
  }

  @override
  String get login => 'ログイン';

  @override
  String get logout => 'ログアウト';

  @override
  String get account => 'アカウント';

  @override
  String get guest => 'ゲスト';

  @override
  String get user => 'ユーザー';

  @override
  String get home => 'ホーム';

  @override
  String get settingsMenu => '設定';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get licenses => 'ライセンス';

  @override
  String get version => 'バージョン';

  @override
  String get options => 'オプション';

  @override
  String get puzzleDescription => '４つの石を通る円を見つけるパズル';

  @override
  String get loading => '読み込み中...';

  @override
  String stageClearedProgress(int cleared, int total) {
    return '$cleared / $total ステージクリア';
  }

  @override
  String get noMoreStages => 'これ以上ステージがありません';

  @override
  String get prevShort => '前';

  @override
  String get prevFull => '前へ';

  @override
  String get nextShort => '次';

  @override
  String get nextFull => '次へ';

  @override
  String get kyouenButton => '共円！！';

  @override
  String get tooBad => '残念！';

  @override
  String get notKyouenMessage => '共円ではありませんでした。';

  @override
  String get syncClearData => 'クリアデータを同期';

  @override
  String get syncing => '同期中...';

  @override
  String get syncSuccess => 'クリアデータを同期しました';

  @override
  String syncFailed(String error) {
    return '同期に失敗しました: $error';
  }

  @override
  String logoutFailed(String error) {
    return 'ログアウトに失敗しました: $error';
  }

  @override
  String get deleteAccount => 'アカウント削除';

  @override
  String get deleteAccountConfirmation =>
      'アカウントを削除してもよろしいですか？この操作は元に戻すことができず、すべてのデータが永久に削除されます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get deletingAccount => 'アカウントを削除中...';

  @override
  String get accountDeleted => 'アカウントが正常に削除されました';

  @override
  String accountDeleteFailed(String error) {
    return 'アカウント削除に失敗しました: $error';
  }

  @override
  String get kyouenSuccess => '共円！！';

  @override
  String get stageClear => 'ステージクリア';

  @override
  String get nextStage => '次のステージへ';

  @override
  String get kyouenFormed => '共円成立！';

  @override
  String get nameLabel => '名前';

  @override
  String get submitted => '送信済み';

  @override
  String get submit => '送信する';

  @override
  String get submitSuccess => 'ステージを送信しました！';

  @override
  String submitFailed(String error) {
    return '送信に失敗しました: $error';
  }

  @override
  String get undo => '1手戻す';

  @override
  String get reset => 'リセット';

  @override
  String errorWithMessage(String error) {
    return 'エラー: $error';
  }
}
