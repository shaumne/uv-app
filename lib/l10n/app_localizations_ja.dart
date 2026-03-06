// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'UVドシメーター';

  @override
  String get onboarding_welcome_title => 'あなたの肌を知ろう';

  @override
  String get onboarding_welcome_subtitle =>
      'いくつかの質問にお答えいただき、パーソナライズされた美白ケアを始めましょう。';

  @override
  String get onboarding_fitzpatrick_question => 'あなたの肌色に近いのはどれですか？';

  @override
  String get onboarding_fitzpatrickType1_label => 'タイプⅠ — 非常に白い肌';

  @override
  String get onboarding_fitzpatrickType1_desc => '必ず日焼けする・絶対に褐色にならない';

  @override
  String get onboarding_fitzpatrickType2_label => 'タイプⅡ — 白い肌';

  @override
  String get onboarding_fitzpatrickType2_desc => 'よく日焼けする・ときどき褐色になる';

  @override
  String get onboarding_fitzpatrickType3_label => 'タイプⅢ — 普通の肌';

  @override
  String get onboarding_fitzpatrickType3_desc => 'ときどき日焼けする・必ず褐色になる';

  @override
  String get onboarding_fitzpatrickType4_label => 'タイプⅣ — オリーブ色の肌';

  @override
  String get onboarding_fitzpatrickType4_desc => 'ほとんど日焼けしない・必ず褐色になる';

  @override
  String get onboarding_fitzpatrickType5_label => 'タイプⅤ — 褐色の肌';

  @override
  String get onboarding_fitzpatrickType5_desc => 'めったに日焼けしない';

  @override
  String get onboarding_fitzpatrickType6_label => 'タイプⅥ — 非常に濃い褐色の肌';

  @override
  String get onboarding_fitzpatrickType6_desc => 'まったく日焼けしない';

  @override
  String get onboarding_spf_question => '現在お使いの日焼け止めのSPF値を教えてください。';

  @override
  String get onboarding_spf_none => 'なし（SPF 1）';

  @override
  String get onboarding_continue_button => '次へ';

  @override
  String get onboarding_start_button => '美白ケアをはじめる';

  @override
  String get home_uvIndex_label => 'UV指数';

  @override
  String get home_uvRisk_low => '低い';

  @override
  String get home_uvRisk_moderate => '普通';

  @override
  String get home_uvRisk_high => '高い';

  @override
  String get home_uvRisk_veryHigh => '非常に高い';

  @override
  String get home_uvRisk_extreme => '極めて高い';

  @override
  String home_remaining_minutes(int count) {
    return '残り$count分';
  }

  @override
  String get home_daily_limit_reached => '本日の上限に達しました';

  @override
  String get home_dailyDose_label => '本日の紫外線量';

  @override
  String get home_safeTimeRemaining_label => '美白を守れる残り時間';

  @override
  String home_safeTimeRemaining_value(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString分';
  }

  @override
  String get home_scan_button => 'ステッカーをスキャン';

  @override
  String get home_noData_hint => 'ステッカーをスキャンして美白ケアの記録を始めましょう。';

  @override
  String get scan_screen_title => 'スキャン';

  @override
  String get scan_guideOverlay_hint => 'ステッカーを枠内に合わせてください';

  @override
  String get scan_progress_label => '解析中…';

  @override
  String get result_screen_title => 'あなたの美白レポート';

  @override
  String get result_safe_message => '今日はしっかり美白を守れています✨';

  @override
  String result_warning_message(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return '本日の紫外線ケア目標の$percentString%に達しました。少し日陰で休んで、お肌を労わりましょう🌿';
  }

  @override
  String get result_danger_message => '本日の紫外線ケアが完了しました。日陰でうるおいを補給しましょう💕';

  @override
  String get result_medUsed_label => '使用済みMED';

  @override
  String get result_spfStatus_label => 'SPF状態';

  @override
  String get result_recommendedAction_label => 'おすすめのケア';

  @override
  String result_action_reapplySunscreen(int spf) {
    return '日焼け止め（SPF$spf）を塗り直して、キメを整えましょう';
  }

  @override
  String get result_action_seekShade => '日陰でハリとうるおいを補給しましょう';

  @override
  String get result_action_allGood => '美しい肌を保ちながら、日差しをお楽しみください';

  @override
  String get result_scanAgain_button => 'もう一度スキャン';

  @override
  String get notification_uvPeak_body =>
      '紫外線が強くなっています✨ 日焼け止めを塗り直して、美白をキープしましょう！';

  @override
  String get notification_spfExpired_body =>
      '日焼け止めの効果が薄れている可能性があります。塗り直してハリとうるおいを守りましょう💕';

  @override
  String get notification_threshold80_body =>
      '本日の紫外線ケア目標の80%に達しました。少し日陰で休んで、お肌を労わりましょう🌿';

  @override
  String get notification_dailyDone_body =>
      '本日の紫外線ケアが完了しました🎉 美しい肌を守れましたね。お疲れさまでした！';

  @override
  String get notification_morningReminder_body =>
      'おはようございます☀️ 今日も紫外線対策をしっかりして、キメ細やかな素肌を保ちましょう！';

  @override
  String get error_network => 'インターネット接続がありません。設定を確認してください。';

  @override
  String get error_camera => 'ステッカーをスキャンするにはカメラのアクセスが必要です。';

  @override
  String get error_location => '現地のUVデータを取得するために位置情報が必要です。';

  @override
  String get error_server => 'サーバーが一時的に利用できません。しばらくしてから再度お試しください。';

  @override
  String get error_unknown => '予期しないエラーが発生しました。アプリを再起動してください。';

  @override
  String get error_retry_button => '再試行';

  @override
  String get error_settings_button => '設定を開く';

  @override
  String get onboarding_splash_title => 'あなたの肌を\n知ろう。';

  @override
  String get onboarding_splash_body =>
      'ステッカーがリアルタイムで紫外線を測定します。\n色を美白ケアに変えましょう。';

  @override
  String get onboarding_spf_label => '日焼け止めSPF';

  @override
  String get onboarding_spf_noneLabel => 'なし';

  @override
  String onboarding_spf_value(int value) {
    return 'SPF $value';
  }

  @override
  String get home_title => '今日のUV';

  @override
  String get home_noData_hint2 => 'ステッカーをスキャンして記録を始めましょう。';

  @override
  String get home_status_safe => '今日はしっかり美白を守れています✨';

  @override
  String get home_status_caution => '1日の半分以上の紫外線量を受けました。';

  @override
  String get home_status_warning => '1日の上限に近づいています。';

  @override
  String get home_status_danger => '本日の上限に達しました。日陰でうるおいを補給しましょう💕';

  @override
  String get home_pullToRefresh => '引っ張って更新';

  @override
  String get scan_capturing => '撮影中…';

  @override
  String get scan_sticker_detecting => 'ステッカーを検出中…';

  @override
  String get scan_analysing => 'ステッカーを解析中…';

  @override
  String get scan_cameraStarting => 'カメラを起動中…';

  @override
  String get scan_torch_on => 'ライトオン';

  @override
  String get scan_torch_off => 'ライトオフ';

  @override
  String get scan_back => '戻る';

  @override
  String get result_safe_full => '今日はしっかり美白を守れています✨';

  @override
  String result_caution_full(int minutes) {
    return '順調です。あと$minutes分、安全に過ごせます。';
  }

  @override
  String result_warning_full(String percent) {
    return '本日の紫外線ケア目標の$percent%に達しました。少し日陰で休んで、お肌を労わりましょう🌿';
  }

  @override
  String get result_danger_full => '本日の上限に達しました。\n日陰でうるおいを補給しましょう💕';

  @override
  String get result_exceeded_full => '上限に近づいています。\n日陰でハリを守りましょう。';

  @override
  String get result_uvReading_label => '紫外線量';

  @override
  String get result_timeLeft_label => '分残り';

  @override
  String get result_action_shade => 'すぐに日陰に移動してください。';

  @override
  String get result_action_partial => '少し日陰に移動することをお勧めします。';

  @override
  String get result_action_reapply => '日焼け止めを塗り直して保護を維持しましょう。';

  @override
  String get result_action_caution => '日差しを楽しみながら、日焼け止めの塗り直しをそろそろ。';

  @override
  String get result_action_good => '美しい肌を保ちながら、日差しをお楽しみください。';

  @override
  String get result_spfFaded => '日焼け止めの効果が薄れています。塗り直してハリとうるおいを守りましょう💕';

  @override
  String get result_spfCurrent => '現在のSPF効果: ';

  @override
  String get result_backHome => 'ダッシュボードに戻る';

  @override
  String get home_uvUnavailable => 'UV情報なし';

  @override
  String get scan_sticker_detected => 'ステッカー検出済み';

  @override
  String get scan_sticker_notDetected => 'ステッカーが見つかりません';

  @override
  String get scan_sticker_checking => 'ステッカーをスキャン中…';

  @override
  String get scan_sticker_tooSmall => 'カメラをステッカーに近づけてください';

  @override
  String get scan_sticker_tooDark => 'より明るい場所に移動してください';

  @override
  String get scan_sticker_captureDisabledHint => '撮影するにはフレーム内にステッカーを合わせてください';

  @override
  String get settings_title => '設定';

  @override
  String get settings_section_language => '言語';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_language_tr => 'Türkçe';

  @override
  String get settings_language_ja => '日本語';

  @override
  String get settings_section_profile => '肌プロフィール';

  @override
  String get settings_section_app => 'アプリについて';

  @override
  String get settings_fitzpatrick_label => '肌タイプ';

  @override
  String get settings_spf_label => '日焼け止めSPF';

  @override
  String get settings_spf_none => 'なし';

  @override
  String get settings_save_button => '変更を保存';

  @override
  String get settings_saved_message => 'プロフィールが更新されました。';

  @override
  String get settings_version_label => 'バージョン';

  @override
  String get settings_support_label => 'サポート';

  @override
  String get settings_support_email => 'support@uvdosimetry.com';

  @override
  String get settings_reset_label => '初期設定にリセット';

  @override
  String get settings_reset_confirm => '肌プロフィールが削除されます。よろしいですか？';

  @override
  String get settings_reset_button => 'リセット';

  @override
  String get settings_cancel_button => 'キャンセル';

  @override
  String get premium_title => 'UVドシメーター プレミアム';

  @override
  String get premium_body => '高度な肌分析、日焼け履歴、パーソナライズされたUVレポートをご利用いただけます。';

  @override
  String get premium_upgrade_button => 'プレミアムにアップグレード';

  @override
  String get premium_later_button => 'あとで';

  @override
  String get settings_spfApplied_label => '日焼け止め塗布時刻';

  @override
  String get settings_spfApplied_notSet => '未記録';

  @override
  String get settings_spfApplied_setNow => '今塗りました';

  @override
  String get settings_spfApplied_clear => '記録を消去';

  @override
  String settings_spfApplied_ago(int hours, int minutes) {
    return '$hours時間$minutes分前';
  }

  @override
  String get settings_spfApplied_justNow => 'たった今塗りました';

  @override
  String get settings_spfApplied_hint => '日焼け止めの塗布時刻を記録して、SPFの効果低下を正確に計算しましょう。';

  @override
  String get history_screen_title => 'UV履歴';

  @override
  String get history_7days_label => '過去7日間';

  @override
  String get history_noData_hint => 'まだ記録がありません。ステッカーをスキャンして美白ケアの追跡を始めましょう。';

  @override
  String get history_day_label => '日';

  @override
  String get history_medUsed_label => '使用済みMED';

  @override
  String get history_safe_badge => '良好';

  @override
  String get history_caution_badge => '注意';

  @override
  String get history_warning_badge => '警告';

  @override
  String get history_danger_badge => '上限到達';

  @override
  String get history_premium_locked => 'プレミアムにアップグレードして、7日間の紫外線履歴をご確認ください。';
}
