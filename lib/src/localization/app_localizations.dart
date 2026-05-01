import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Kyouen'**
  String get appTitle;

  /// The game title displayed on the web title page
  ///
  /// In en, this message translates to:
  /// **'Kyouen'**
  String get kyouenTitle;

  /// Description of the game on the web title page
  ///
  /// In en, this message translates to:
  /// **'Kyouen is a circle passing through 4 stones.\nThis page hosts many \'Tsume Kyouen\' puzzles, where you find the kyouen from stones placed on the board.'**
  String get kyouenDescription;

  /// Start button label
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Create stage button label
  ///
  /// In en, this message translates to:
  /// **'Create Stage'**
  String get createStage;

  /// Section title for latest registrations
  ///
  /// In en, this message translates to:
  /// **'Latest Registrations'**
  String get latestRegistrations;

  /// Section title for activity
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// Number of stages cleared by a user in activity
  ///
  /// In en, this message translates to:
  /// **'{count} stages cleared'**
  String stagesClearedCount(int count);

  /// Loading indicator for stage information
  ///
  /// In en, this message translates to:
  /// **'Loading stage information...'**
  String get loadingStageInfo;

  /// Error message for stage information fetch failure
  ///
  /// In en, this message translates to:
  /// **'Error fetching stage information'**
  String get stageInfoError;

  /// Cleared stage count display
  ///
  /// In en, this message translates to:
  /// **'Cleared: {cleared} / {total}'**
  String clearedStagesCount(int cleared, int total);

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Account button/page label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Default name for a guest user
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// Default name for a logged-in user without a display name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Home menu item label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Settings menu item label in drawer
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsMenu;

  /// Privacy policy menu item label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Licenses menu item label
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Options page title
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// Short description of the game on the native title page
  ///
  /// In en, this message translates to:
  /// **'A puzzle to find a circle passing through 4 stones'**
  String get puzzleDescription;

  /// Generic loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Stage clear progress text on native title page
  ///
  /// In en, this message translates to:
  /// **'{cleared} / {total} stages cleared'**
  String stageClearedProgress(int cleared, int total);

  /// Message when there are no more stages to navigate to
  ///
  /// In en, this message translates to:
  /// **'No more stages'**
  String get noMoreStages;

  /// Short label for previous button on small screens
  ///
  /// In en, this message translates to:
  /// **'Prev'**
  String get prevShort;

  /// Full label for previous button on large screens
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get prevFull;

  /// Short label for next button on small screens
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextShort;

  /// Full label for next button on large screens
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextFull;

  /// Label for the kyouen check button
  ///
  /// In en, this message translates to:
  /// **'Kyouen!!'**
  String get kyouenButton;

  /// Dialog title when the answer is not kyouen
  ///
  /// In en, this message translates to:
  /// **'Too bad!'**
  String get tooBad;

  /// Dialog message when the answer is not kyouen
  ///
  /// In en, this message translates to:
  /// **'That was not kyouen.'**
  String get notKyouenMessage;

  /// Button label to sync clear data
  ///
  /// In en, this message translates to:
  /// **'Sync Clear Data'**
  String get syncClearData;

  /// Loading text while syncing
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// Success message after syncing clear data
  ///
  /// In en, this message translates to:
  /// **'Clear data synced'**
  String get syncSuccess;

  /// Error message when sync fails
  ///
  /// In en, this message translates to:
  /// **'Failed to sync: {error}'**
  String syncFailed(String error);

  /// Error message when logout fails
  ///
  /// In en, this message translates to:
  /// **'Failed to logout: {error}'**
  String logoutFailed(String error);

  /// Delete account button label and dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Confirmation message for account deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all data will be permanently deleted.'**
  String get deleteAccountConfirmation;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Loading text while deleting account
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deletingAccount;

  /// Success message after account deletion
  ///
  /// In en, this message translates to:
  /// **'Account successfully deleted'**
  String get accountDeleted;

  /// Error message when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String accountDeleteFailed(String error);

  /// Success title in the kyouen success dialog
  ///
  /// In en, this message translates to:
  /// **'Kyouen!!'**
  String get kyouenSuccess;

  /// Subtitle in the kyouen success dialog
  ///
  /// In en, this message translates to:
  /// **'Stage Clear'**
  String get stageClear;

  /// Button label to go to the next stage
  ///
  /// In en, this message translates to:
  /// **'Next Stage'**
  String get nextStage;

  /// Title shown in the create stage form when kyouen is achieved
  ///
  /// In en, this message translates to:
  /// **'Kyouen formed!'**
  String get kyouenFormed;

  /// Label for the name input field in create stage form
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Button label after a stage has been submitted
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// Button label to submit a stage
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Snackbar message after successfully submitting a stage
  ///
  /// In en, this message translates to:
  /// **'Stage submitted!'**
  String get submitSuccess;

  /// Snackbar message when stage submission fails
  ///
  /// In en, this message translates to:
  /// **'Failed to submit: {error}'**
  String submitFailed(String error);

  /// Button label to undo the last move in create stage
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Button label to reset the board in create stage
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Error message with details
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
