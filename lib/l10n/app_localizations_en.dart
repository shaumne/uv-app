// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'UV Dosimeter';

  @override
  String get onboarding_welcome_title => 'Know Your Skin';

  @override
  String get onboarding_welcome_subtitle =>
      'Answer a few questions so we can personalise your UV protection.';

  @override
  String get onboarding_fitzpatrick_question =>
      'Which skin tone best describes you?';

  @override
  String get onboarding_fitzpatrickType1_label => 'Type I — Very Fair';

  @override
  String get onboarding_fitzpatrickType1_desc => 'Always burns, never tans';

  @override
  String get onboarding_fitzpatrickType2_label => 'Type II — Fair';

  @override
  String get onboarding_fitzpatrickType2_desc =>
      'Usually burns, sometimes tans';

  @override
  String get onboarding_fitzpatrickType3_label => 'Type III — Medium';

  @override
  String get onboarding_fitzpatrickType3_desc => 'Sometimes burns, always tans';

  @override
  String get onboarding_fitzpatrickType4_label => 'Type IV — Olive';

  @override
  String get onboarding_fitzpatrickType4_desc => 'Rarely burns, always tans';

  @override
  String get onboarding_fitzpatrickType5_label => 'Type V — Brown';

  @override
  String get onboarding_fitzpatrickType5_desc => 'Very rarely burns';

  @override
  String get onboarding_fitzpatrickType6_label => 'Type VI — Deep';

  @override
  String get onboarding_fitzpatrickType6_desc => 'Never burns';

  @override
  String get onboarding_spf_question => 'What SPF sunscreen are you wearing?';

  @override
  String get onboarding_spf_none => 'None (SPF 1)';

  @override
  String get onboarding_continue_button => 'Continue';

  @override
  String get onboarding_start_button => 'Start Protecting My Skin';

  @override
  String get home_uvIndex_label => 'UV Index';

  @override
  String get home_uvRisk_low => 'Low';

  @override
  String get home_uvRisk_moderate => 'Moderate';

  @override
  String get home_uvRisk_high => 'High';

  @override
  String get home_uvRisk_veryHigh => 'Very High';

  @override
  String get home_uvRisk_extreme => 'Extreme';

  @override
  String get home_dailyDose_label => 'Daily Dose Used';

  @override
  String get home_safeTimeRemaining_label => 'Safe time remaining';

  @override
  String home_safeTimeRemaining_value(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString min';
  }

  @override
  String get home_scan_button => 'Scan My Sticker';

  @override
  String get home_noData_hint => 'Scan your sticker to begin tracking.';

  @override
  String get scan_screen_title => 'Scan Sticker';

  @override
  String get scan_guideOverlay_hint => 'Align the sticker inside the frame';

  @override
  String get scan_progress_label => 'Analysing…';

  @override
  String get result_screen_title => 'Your UV Report';

  @override
  String get result_safe_message => 'You\'\'re well protected today.';

  @override
  String result_warning_message(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'You\'\'ve used $percentString% of your daily limit.';
  }

  @override
  String get result_danger_message => 'Daily limit reached. Seek shade now.';

  @override
  String get result_medUsed_label => 'MED Used';

  @override
  String get result_spfStatus_label => 'SPF Status';

  @override
  String get result_recommendedAction_label => 'Recommended Action';

  @override
  String result_action_reapplySunscreen(int spf) {
    return 'Reapply sunscreen (SPF $spf)';
  }

  @override
  String get result_action_seekShade => 'Move to shade immediately';

  @override
  String get result_action_allGood => 'Enjoy the sun responsibly';

  @override
  String get result_scanAgain_button => 'Scan Again';

  @override
  String get notification_uvPeak_body =>
      'UV levels are peaking — great time to reapply sunscreen and keep your skin protected.';

  @override
  String get notification_spfExpired_body =>
      'Your sunscreen\'\'s protection has likely faded. A quick reapplication keeps you covered.';

  @override
  String get notification_threshold80_body =>
      'You\'\'ve reached 80% of your safe UV limit for today. Consider moving to shade soon.';

  @override
  String get notification_dailyDone_body =>
      'You\'\'ve hit your UV dose for today. Your skin will thank you for staying protected!';

  @override
  String get notification_morningReminder_body =>
      'Starting your day? Don\'\'t forget sunscreen — UV can be present even on cloudy days.';

  @override
  String get error_network =>
      'No internet connection. Please check your settings.';

  @override
  String get error_camera => 'Camera access is required to scan the sticker.';

  @override
  String get error_location => 'Location access helps us fetch local UV data.';

  @override
  String get error_server =>
      'Our server is temporarily unavailable. Please try again.';

  @override
  String get error_unknown => 'Something went wrong. Please restart the app.';

  @override
  String get error_retry_button => 'Retry';

  @override
  String get error_settings_button => 'Open Settings';

  @override
  String get onboarding_splash_title => 'Know Your\nSkin.';

  @override
  String get onboarding_splash_body =>
      'Your photochromic sticker measures UV in real time.\nWe turn colour into care.';

  @override
  String get onboarding_spf_label => 'Sunscreen SPF';

  @override
  String get onboarding_spf_noneLabel => 'None';

  @override
  String get home_title => 'Today\'\'s UV';

  @override
  String get home_noData_hint2 => 'Scan your sticker to begin tracking.';

  @override
  String get home_status_safe => 'You\'\'re well protected today.';

  @override
  String get home_status_caution => 'You\'\'ve used over half your daily dose.';

  @override
  String get home_status_warning => 'You\'\'re approaching your daily limit.';

  @override
  String get home_status_danger => 'Daily limit reached. Seek shade now.';

  @override
  String get home_pullToRefresh => 'Pull to refresh';

  @override
  String get scan_capturing => 'Capturing…';

  @override
  String get scan_analysing => 'Analysing sticker…';

  @override
  String get scan_cameraStarting => 'Starting camera…';

  @override
  String get scan_torch_on => 'Torch on';

  @override
  String get scan_torch_off => 'Torch off';

  @override
  String get scan_back => 'Back';

  @override
  String get result_safe_full => 'You\'\'re well protected today. ✨';

  @override
  String result_caution_full(int minutes) {
    return 'Making good progress. $minutes min of safe time left.';
  }

  @override
  String result_warning_full(String percent) {
    return 'You\'\'ve used $percent% of your daily limit.';
  }

  @override
  String get result_danger_full =>
      'Daily limit reached.\nTime to recharge in the shade.';

  @override
  String get result_exceeded_full =>
      'Approaching your daily limit.\nStep into shade soon.';

  @override
  String get result_uvReading_label => 'UV Reading';

  @override
  String get result_timeLeft_label => 'min left';

  @override
  String get result_action_shade => 'Move to shade immediately.';

  @override
  String get result_action_partial => 'Consider moving to partial shade.';

  @override
  String get result_action_reapply =>
      'Reapply sunscreen to maintain protection.';

  @override
  String get result_action_caution => 'Enjoy the sun — reapply sunscreen soon.';

  @override
  String get result_action_good => 'Enjoy the sun responsibly.';

  @override
  String get result_spfFaded => 'SPF protection has faded — reapply sunscreen';

  @override
  String get result_spfCurrent => 'Current SPF effectiveness: ';

  @override
  String get result_backHome => 'Back to Dashboard';

  @override
  String get premium_title => 'UV Dosimeter Premium';

  @override
  String get premium_body =>
      'Unlock advanced skin analysis, exposure history, and personalised UV reports.';

  @override
  String get premium_upgrade_button => 'Upgrade to Premium';

  @override
  String get premium_later_button => 'Maybe later';
}
