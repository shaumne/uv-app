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
  String home_remaining_minutes(int count) {
    return '$count min remaining';
  }

  @override
  String get home_daily_limit_reached => 'Daily limit reached';

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
  String get error_location_services_off => 'Location services are off.';

  @override
  String get error_location_denied_forever =>
      'Location permission denied. Enable in device Settings.';

  @override
  String get error_location_denied =>
      'Location permission required for UV index.';

  @override
  String get error_location_timeout =>
      'Location timed out. UV index unavailable.';

  @override
  String get error_location_unavailable => 'Location unavailable.';

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
  String onboarding_spf_value(int value) {
    return 'SPF $value';
  }

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
  String get scan_sticker_detecting => 'Detecting sticker…';

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
  String get home_uvUnavailable => 'UV unavailable';

  @override
  String get scan_sticker_detected => 'Sticker detected';

  @override
  String get scan_sticker_notDetected => 'No sticker detected';

  @override
  String get scan_sticker_checking => 'Scanning for sticker…';

  @override
  String get scan_sticker_tooSmall => 'Move closer to the sticker';

  @override
  String get scan_sticker_tooDark => 'Move to better lighting';

  @override
  String get scan_sticker_captureDisabledHint =>
      'Align the sticker in the frame to capture';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_section_language => 'Language';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_language_tr => 'Türkçe';

  @override
  String get settings_language_ja => '日本語';

  @override
  String get settings_section_profile => 'Skin Profile';

  @override
  String get settings_section_app => 'About';

  @override
  String get settings_fitzpatrick_label => 'Skin Type';

  @override
  String get settings_spf_label => 'Sunscreen SPF';

  @override
  String get settings_spf_none => 'None';

  @override
  String get settings_save_button => 'Save Changes';

  @override
  String get settings_saved_message => 'Profile updated successfully.';

  @override
  String get settings_version_label => 'Version';

  @override
  String get settings_support_label => 'Support';

  @override
  String get settings_support_email => 'support@uvdosimetry.com';

  @override
  String get settings_reset_label => 'Reset Onboarding';

  @override
  String get settings_reset_confirm =>
      'This will clear your skin profile. Continue?';

  @override
  String get settings_reset_button => 'Reset';

  @override
  String get settings_cancel_button => 'Cancel';

  @override
  String get premium_title => 'UV Dosimeter Premium';

  @override
  String get premium_body =>
      'Unlock advanced skin analysis, exposure history, and personalised UV reports.';

  @override
  String get premium_upgrade_button => 'Upgrade to Premium';

  @override
  String get premium_later_button => 'Maybe later';

  @override
  String get settings_spfApplied_label => 'Sunscreen Applied';

  @override
  String get settings_spfApplied_notSet => 'Not recorded';

  @override
  String get settings_spfApplied_setNow => 'Mark as applied now';

  @override
  String get settings_spfApplied_clear => 'Clear time';

  @override
  String settings_spfApplied_ago(int hours, int minutes) {
    return '${hours}h ${minutes}m ago';
  }

  @override
  String get settings_spfApplied_justNow => 'Just applied';

  @override
  String get settings_spfApplied_hint =>
      'Track when you last applied sunscreen to calculate protection decay.';

  @override
  String get history_screen_title => 'UV History';

  @override
  String get history_today_label => 'Today';

  @override
  String get history_7days_label => 'Past 7 Days';

  @override
  String get history_noData_hint =>
      'No UV exposure recorded yet. Scan your sticker to start tracking.';

  @override
  String get history_day_label => 'Day';

  @override
  String get history_medUsed_label => 'MED Used';

  @override
  String get history_safe_badge => 'Safe';

  @override
  String get history_caution_badge => 'Caution';

  @override
  String get history_warning_badge => 'Warning';

  @override
  String get history_danger_badge => 'Limit Reached';

  @override
  String get history_premium_locked =>
      'Upgrade to Premium to unlock your full 7-day UV exposure history.';

  @override
  String get error_pageNotFound_title => 'Page Not Found';

  @override
  String get error_pageNotFound_message =>
      'The page you are looking for does not exist.';
}
