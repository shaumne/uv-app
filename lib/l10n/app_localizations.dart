import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'UV Dosimeter'**
  String get appName;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In en, this message translates to:
  /// **'Know Your Skin'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions so we can personalise your UV protection.'**
  String get onboarding_welcome_subtitle;

  /// No description provided for @onboarding_fitzpatrick_question.
  ///
  /// In en, this message translates to:
  /// **'Which skin tone best describes you?'**
  String get onboarding_fitzpatrick_question;

  /// No description provided for @onboarding_fitzpatrickType1_label.
  ///
  /// In en, this message translates to:
  /// **'Type I — Very Fair'**
  String get onboarding_fitzpatrickType1_label;

  /// No description provided for @onboarding_fitzpatrickType1_desc.
  ///
  /// In en, this message translates to:
  /// **'Always burns, never tans'**
  String get onboarding_fitzpatrickType1_desc;

  /// No description provided for @onboarding_fitzpatrickType2_label.
  ///
  /// In en, this message translates to:
  /// **'Type II — Fair'**
  String get onboarding_fitzpatrickType2_label;

  /// No description provided for @onboarding_fitzpatrickType2_desc.
  ///
  /// In en, this message translates to:
  /// **'Usually burns, sometimes tans'**
  String get onboarding_fitzpatrickType2_desc;

  /// No description provided for @onboarding_fitzpatrickType3_label.
  ///
  /// In en, this message translates to:
  /// **'Type III — Medium'**
  String get onboarding_fitzpatrickType3_label;

  /// No description provided for @onboarding_fitzpatrickType3_desc.
  ///
  /// In en, this message translates to:
  /// **'Sometimes burns, always tans'**
  String get onboarding_fitzpatrickType3_desc;

  /// No description provided for @onboarding_fitzpatrickType4_label.
  ///
  /// In en, this message translates to:
  /// **'Type IV — Olive'**
  String get onboarding_fitzpatrickType4_label;

  /// No description provided for @onboarding_fitzpatrickType4_desc.
  ///
  /// In en, this message translates to:
  /// **'Rarely burns, always tans'**
  String get onboarding_fitzpatrickType4_desc;

  /// No description provided for @onboarding_fitzpatrickType5_label.
  ///
  /// In en, this message translates to:
  /// **'Type V — Brown'**
  String get onboarding_fitzpatrickType5_label;

  /// No description provided for @onboarding_fitzpatrickType5_desc.
  ///
  /// In en, this message translates to:
  /// **'Very rarely burns'**
  String get onboarding_fitzpatrickType5_desc;

  /// No description provided for @onboarding_fitzpatrickType6_label.
  ///
  /// In en, this message translates to:
  /// **'Type VI — Deep'**
  String get onboarding_fitzpatrickType6_label;

  /// No description provided for @onboarding_fitzpatrickType6_desc.
  ///
  /// In en, this message translates to:
  /// **'Never burns'**
  String get onboarding_fitzpatrickType6_desc;

  /// No description provided for @onboarding_spf_question.
  ///
  /// In en, this message translates to:
  /// **'What SPF sunscreen are you wearing?'**
  String get onboarding_spf_question;

  /// No description provided for @onboarding_spf_none.
  ///
  /// In en, this message translates to:
  /// **'None (SPF 1)'**
  String get onboarding_spf_none;

  /// No description provided for @onboarding_continue_button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboarding_continue_button;

  /// No description provided for @onboarding_start_button.
  ///
  /// In en, this message translates to:
  /// **'Start Protecting My Skin'**
  String get onboarding_start_button;

  /// No description provided for @home_uvIndex_label.
  ///
  /// In en, this message translates to:
  /// **'UV Index'**
  String get home_uvIndex_label;

  /// No description provided for @home_uvRisk_low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get home_uvRisk_low;

  /// No description provided for @home_uvRisk_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get home_uvRisk_moderate;

  /// No description provided for @home_uvRisk_high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get home_uvRisk_high;

  /// No description provided for @home_uvRisk_veryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get home_uvRisk_veryHigh;

  /// No description provided for @home_uvRisk_extreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get home_uvRisk_extreme;

  /// No description provided for @home_dailyDose_label.
  ///
  /// In en, this message translates to:
  /// **'Daily Dose Used'**
  String get home_dailyDose_label;

  /// No description provided for @home_safeTimeRemaining_label.
  ///
  /// In en, this message translates to:
  /// **'Safe time remaining'**
  String get home_safeTimeRemaining_label;

  /// Remaining safe sun exposure minutes shown under the arc gauge.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String home_safeTimeRemaining_value(int minutes);

  /// No description provided for @home_scan_button.
  ///
  /// In en, this message translates to:
  /// **'Scan My Sticker'**
  String get home_scan_button;

  /// No description provided for @home_noData_hint.
  ///
  /// In en, this message translates to:
  /// **'Scan your sticker to begin tracking.'**
  String get home_noData_hint;

  /// No description provided for @scan_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Scan Sticker'**
  String get scan_screen_title;

  /// No description provided for @scan_guideOverlay_hint.
  ///
  /// In en, this message translates to:
  /// **'Align the sticker inside the frame'**
  String get scan_guideOverlay_hint;

  /// No description provided for @scan_progress_label.
  ///
  /// In en, this message translates to:
  /// **'Analysing…'**
  String get scan_progress_label;

  /// No description provided for @result_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Your UV Report'**
  String get result_screen_title;

  /// No description provided for @result_safe_message.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re well protected today.'**
  String get result_safe_message;

  /// Shows cumulative UV exposure percentage on result screen.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ve used {percent}% of your daily limit.'**
  String result_warning_message(int percent);

  /// No description provided for @result_danger_message.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached. Seek shade now.'**
  String get result_danger_message;

  /// No description provided for @result_medUsed_label.
  ///
  /// In en, this message translates to:
  /// **'MED Used'**
  String get result_medUsed_label;

  /// No description provided for @result_spfStatus_label.
  ///
  /// In en, this message translates to:
  /// **'SPF Status'**
  String get result_spfStatus_label;

  /// No description provided for @result_recommendedAction_label.
  ///
  /// In en, this message translates to:
  /// **'Recommended Action'**
  String get result_recommendedAction_label;

  /// No description provided for @result_action_reapplySunscreen.
  ///
  /// In en, this message translates to:
  /// **'Reapply sunscreen (SPF {spf})'**
  String result_action_reapplySunscreen(int spf);

  /// No description provided for @result_action_seekShade.
  ///
  /// In en, this message translates to:
  /// **'Move to shade immediately'**
  String get result_action_seekShade;

  /// No description provided for @result_action_allGood.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the sun responsibly'**
  String get result_action_allGood;

  /// No description provided for @result_scanAgain_button.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get result_scanAgain_button;

  /// No description provided for @notification_uvPeak_body.
  ///
  /// In en, this message translates to:
  /// **'UV levels are peaking — great time to reapply sunscreen and keep your skin protected.'**
  String get notification_uvPeak_body;

  /// No description provided for @notification_spfExpired_body.
  ///
  /// In en, this message translates to:
  /// **'Your sunscreen\'\'s protection has likely faded. A quick reapplication keeps you covered.'**
  String get notification_spfExpired_body;

  /// No description provided for @notification_threshold80_body.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ve reached 80% of your safe UV limit for today. Consider moving to shade soon.'**
  String get notification_threshold80_body;

  /// No description provided for @notification_dailyDone_body.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ve hit your UV dose for today. Your skin will thank you for staying protected!'**
  String get notification_dailyDone_body;

  /// No description provided for @notification_morningReminder_body.
  ///
  /// In en, this message translates to:
  /// **'Starting your day? Don\'\'t forget sunscreen — UV can be present even on cloudy days.'**
  String get notification_morningReminder_body;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your settings.'**
  String get error_network;

  /// No description provided for @error_camera.
  ///
  /// In en, this message translates to:
  /// **'Camera access is required to scan the sticker.'**
  String get error_camera;

  /// No description provided for @error_location.
  ///
  /// In en, this message translates to:
  /// **'Location access helps us fetch local UV data.'**
  String get error_location;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Our server is temporarily unavailable. Please try again.'**
  String get error_server;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please restart the app.'**
  String get error_unknown;

  /// No description provided for @error_retry_button.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get error_retry_button;

  /// No description provided for @error_settings_button.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get error_settings_button;

  /// No description provided for @onboarding_splash_title.
  ///
  /// In en, this message translates to:
  /// **'Know Your\nSkin.'**
  String get onboarding_splash_title;

  /// No description provided for @onboarding_splash_body.
  ///
  /// In en, this message translates to:
  /// **'Your photochromic sticker measures UV in real time.\nWe turn colour into care.'**
  String get onboarding_splash_body;

  /// No description provided for @onboarding_spf_label.
  ///
  /// In en, this message translates to:
  /// **'Sunscreen SPF'**
  String get onboarding_spf_label;

  /// No description provided for @onboarding_spf_noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get onboarding_spf_noneLabel;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Today\'\'s UV'**
  String get home_title;

  /// No description provided for @home_noData_hint2.
  ///
  /// In en, this message translates to:
  /// **'Scan your sticker to begin tracking.'**
  String get home_noData_hint2;

  /// No description provided for @home_status_safe.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re well protected today.'**
  String get home_status_safe;

  /// No description provided for @home_status_caution.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ve used over half your daily dose.'**
  String get home_status_caution;

  /// No description provided for @home_status_warning.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re approaching your daily limit.'**
  String get home_status_warning;

  /// No description provided for @home_status_danger.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached. Seek shade now.'**
  String get home_status_danger;

  /// No description provided for @home_pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get home_pullToRefresh;

  /// No description provided for @scan_capturing.
  ///
  /// In en, this message translates to:
  /// **'Capturing…'**
  String get scan_capturing;

  /// No description provided for @scan_analysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing sticker…'**
  String get scan_analysing;

  /// No description provided for @scan_torch_on.
  ///
  /// In en, this message translates to:
  /// **'Torch on'**
  String get scan_torch_on;

  /// No description provided for @scan_torch_off.
  ///
  /// In en, this message translates to:
  /// **'Torch off'**
  String get scan_torch_off;

  /// No description provided for @scan_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get scan_back;

  /// No description provided for @result_safe_full.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re well protected today. ✨'**
  String get result_safe_full;

  /// No description provided for @result_caution_full.
  ///
  /// In en, this message translates to:
  /// **'Making good progress. {minutes} min of safe time left.'**
  String result_caution_full(int minutes);

  /// No description provided for @result_warning_full.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ve used {percent}% of your daily limit.'**
  String result_warning_full(String percent);

  /// No description provided for @result_danger_full.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached.\nTime to recharge in the shade.'**
  String get result_danger_full;

  /// No description provided for @result_exceeded_full.
  ///
  /// In en, this message translates to:
  /// **'Approaching your daily limit.\nStep into shade soon.'**
  String get result_exceeded_full;

  /// No description provided for @result_uvReading_label.
  ///
  /// In en, this message translates to:
  /// **'UV Reading'**
  String get result_uvReading_label;

  /// No description provided for @result_timeLeft_label.
  ///
  /// In en, this message translates to:
  /// **'min left'**
  String get result_timeLeft_label;

  /// No description provided for @result_action_shade.
  ///
  /// In en, this message translates to:
  /// **'Move to shade immediately.'**
  String get result_action_shade;

  /// No description provided for @result_action_partial.
  ///
  /// In en, this message translates to:
  /// **'Consider moving to partial shade.'**
  String get result_action_partial;

  /// No description provided for @result_action_reapply.
  ///
  /// In en, this message translates to:
  /// **'Reapply sunscreen to maintain protection.'**
  String get result_action_reapply;

  /// No description provided for @result_action_caution.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the sun — reapply sunscreen soon.'**
  String get result_action_caution;

  /// No description provided for @result_action_good.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the sun responsibly.'**
  String get result_action_good;

  /// No description provided for @result_spfFaded.
  ///
  /// In en, this message translates to:
  /// **'SPF protection has faded — reapply sunscreen'**
  String get result_spfFaded;

  /// No description provided for @result_spfCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current SPF effectiveness: '**
  String get result_spfCurrent;

  /// No description provided for @result_backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get result_backHome;

  /// No description provided for @premium_title.
  ///
  /// In en, this message translates to:
  /// **'UV Dosimeter Premium'**
  String get premium_title;

  /// No description provided for @premium_body.
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced skin analysis, exposure history, and personalised UV reports.'**
  String get premium_body;

  /// No description provided for @premium_upgrade_button.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get premium_upgrade_button;

  /// No description provided for @premium_later_button.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get premium_later_button;
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
      <String>['en', 'ja', 'tr'].contains(locale.languageCode);

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
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
