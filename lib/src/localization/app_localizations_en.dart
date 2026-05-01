// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kyouen';

  @override
  String get kyouenTitle => 'Kyouen';

  @override
  String get kyouenDescription =>
      'Kyouen is a circle passing through 4 stones.\nThis page hosts many \'Tsume Kyouen\' puzzles, where you find the kyouen from stones placed on the board.';

  @override
  String get start => 'Start';

  @override
  String get createStage => 'Create Stage';

  @override
  String get latestRegistrations => 'Latest Registrations';

  @override
  String get activity => 'Activity';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String stagesClearedCount(int count) {
    return '$count stages cleared';
  }

  @override
  String get loadingStageInfo => 'Loading stage information...';

  @override
  String get stageInfoError => 'Error fetching stage information';

  @override
  String clearedStagesCount(int cleared, int total) {
    return 'Cleared: $cleared / $total';
  }

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get account => 'Account';

  @override
  String get guest => 'Guest';

  @override
  String get user => 'User';

  @override
  String get home => 'Home';

  @override
  String get settingsMenu => 'Settings';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get licenses => 'Licenses';

  @override
  String get version => 'Version';

  @override
  String get options => 'Options';

  @override
  String get puzzleDescription =>
      'A puzzle to find a circle passing through 4 stones';

  @override
  String get loading => 'Loading...';

  @override
  String stageClearedProgress(int cleared, int total) {
    return '$cleared / $total stages cleared';
  }

  @override
  String get noMoreStages => 'No more stages';

  @override
  String get prevShort => 'Prev';

  @override
  String get prevFull => 'Previous';

  @override
  String get nextShort => 'Next';

  @override
  String get nextFull => 'Next';

  @override
  String get kyouenButton => 'Kyouen!!';

  @override
  String get tooBad => 'Too bad!';

  @override
  String get notKyouenMessage => 'That was not kyouen.';

  @override
  String get syncClearData => 'Sync Clear Data';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncSuccess => 'Clear data synced';

  @override
  String syncFailed(String error) {
    return 'Failed to sync: $error';
  }

  @override
  String logoutFailed(String error) {
    return 'Failed to logout: $error';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone and all data will be permanently deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String get accountDeleted => 'Account successfully deleted';

  @override
  String accountDeleteFailed(String error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get kyouenSuccess => 'Kyouen!!';

  @override
  String get stageClear => 'Stage Clear';

  @override
  String get nextStage => 'Next Stage';

  @override
  String get kyouenFormed => 'Kyouen formed!';

  @override
  String get nameLabel => 'Name';

  @override
  String get submitted => 'Submitted';

  @override
  String get submit => 'Submit';

  @override
  String get submitSuccess => 'Stage submitted!';

  @override
  String submitFailed(String error) {
    return 'Failed to submit: $error';
  }

  @override
  String get undo => 'Undo';

  @override
  String get reset => 'Reset';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }
}
