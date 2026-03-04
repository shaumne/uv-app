// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'UV Dozimetre';

  @override
  String get onboarding_welcome_title => 'Cildinizi Tanıyın';

  @override
  String get onboarding_welcome_subtitle =>
      'Kişiselleştirilmiş UV korumanız için birkaç soruyu yanıtlayın.';

  @override
  String get onboarding_fitzpatrick_question =>
      'Cilt tonunuzu en iyi hangisi tanımlar?';

  @override
  String get onboarding_fitzpatrickType1_label => 'Tip I — Çok Açık Ten';

  @override
  String get onboarding_fitzpatrickType1_desc =>
      'Her zaman yanar, hiç bronzlaşmaz';

  @override
  String get onboarding_fitzpatrickType2_label => 'Tip II — Açık Ten';

  @override
  String get onboarding_fitzpatrickType2_desc =>
      'Genellikle yanar, bazen bronzlaşır';

  @override
  String get onboarding_fitzpatrickType3_label => 'Tip III — Orta Ten';

  @override
  String get onboarding_fitzpatrickType3_desc =>
      'Bazen yanar, her zaman bronzlaşır';

  @override
  String get onboarding_fitzpatrickType4_label => 'Tip IV — Zeytin Teni';

  @override
  String get onboarding_fitzpatrickType4_desc =>
      'Nadiren yanar, her zaman bronzlaşır';

  @override
  String get onboarding_fitzpatrickType5_label => 'Tip V — Esmer Ten';

  @override
  String get onboarding_fitzpatrickType5_desc => 'Çok nadiren yanar';

  @override
  String get onboarding_fitzpatrickType6_label => 'Tip VI — Koyu Esmer Ten';

  @override
  String get onboarding_fitzpatrickType6_desc => 'Hiç yanmaz';

  @override
  String get onboarding_spf_question =>
      'Kullandığınız güneş kremi SPF değeri nedir?';

  @override
  String get onboarding_spf_none => 'Yok (SPF 1)';

  @override
  String get onboarding_continue_button => 'Devam';

  @override
  String get onboarding_start_button => 'Cildimi Korumaya Başla';

  @override
  String get home_uvIndex_label => 'UV İndeksi';

  @override
  String get home_uvRisk_low => 'Düşük';

  @override
  String get home_uvRisk_moderate => 'Orta';

  @override
  String get home_uvRisk_high => 'Yüksek';

  @override
  String get home_uvRisk_veryHigh => 'Çok Yüksek';

  @override
  String get home_uvRisk_extreme => 'Aşırı';

  @override
  String home_remaining_minutes(int count) {
    return '$count dk kaldı';
  }

  @override
  String get home_daily_limit_reached => 'Günlük limit doldu';

  @override
  String get home_dailyDose_label => 'Günlük Kullanılan Doz';

  @override
  String get home_safeTimeRemaining_label => 'Kalan güvenli süre';

  @override
  String home_safeTimeRemaining_value(int minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$minutesString dk';
  }

  @override
  String get home_scan_button => 'Sticker\'\'ı Tara';

  @override
  String get home_noData_hint => 'Takibi başlatmak için sticker\'\'ı tarayın.';

  @override
  String get scan_screen_title => 'Sticker Tara';

  @override
  String get scan_guideOverlay_hint => 'Sticker\'\'ı çerçeve içine hizalayın';

  @override
  String get scan_progress_label => 'Analiz ediliyor…';

  @override
  String get result_screen_title => 'UV Raporunuz';

  @override
  String get result_safe_message => 'Bugün güzel korunuyorsunuz.';

  @override
  String result_warning_message(int percent) {
    final intl.NumberFormat percentNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String percentString = percentNumberFormat.format(percent);

    return 'Günlük limitinizin %$percentString\'\'ini kullandınız.';
  }

  @override
  String get result_danger_message =>
      'Günlük limit doldu. Hemen gölgeye geçin.';

  @override
  String get result_medUsed_label => 'Kullanılan MED';

  @override
  String get result_spfStatus_label => 'SPF Durumu';

  @override
  String get result_recommendedAction_label => 'Önerilen Eylem';

  @override
  String result_action_reapplySunscreen(int spf) {
    return 'Güneş kremini yenileyin (SPF $spf)';
  }

  @override
  String get result_action_seekShade => 'Hemen gölgeye geçin';

  @override
  String get result_action_allGood => 'Güneşin tadını sorumlu şekilde çıkarın';

  @override
  String get result_scanAgain_button => 'Tekrar Tara';

  @override
  String get notification_uvPeak_body =>
      'UV seviyeleri yükseliyor! Güneş kremini yenileme zamanı — cildin sana teşekkür edecek.';

  @override
  String get notification_spfExpired_body =>
      'Güneş kreminin koruyucu etkisi azalmış olabilir. Yeniden sürerek korunmaya devam et!';

  @override
  String get notification_threshold80_body =>
      'Bugünkü güvenli UV limitinin %80\'\'ine ulaştın. Gölgeye geçmeyi düşünebilirsin.';

  @override
  String get notification_dailyDone_body =>
      'Bugünkü UV dozunu tamamladın! Cildin korunmuş olduğu için harika hissedecek.';

  @override
  String get notification_morningReminder_body =>
      'Güne başlıyorsun! Bulutlu havalarda bile UV varsa, güneş kremini atlamayı unutma.';

  @override
  String get error_network =>
      'İnternet bağlantısı yok. Ayarlarınızı kontrol edin.';

  @override
  String get error_camera =>
      'Sticker\'\'ı taramak için kamera izni gereklidir.';

  @override
  String get error_location => 'Yerel UV verisi için konum izni gereklidir.';

  @override
  String get error_server =>
      'Sunucumuz geçici olarak kullanılamıyor. Lütfen tekrar deneyin.';

  @override
  String get error_unknown =>
      'Beklenmedik bir hata oluştu. Uygulamayı yeniden başlatın.';

  @override
  String get error_retry_button => 'Tekrar Dene';

  @override
  String get error_settings_button => 'Ayarları Aç';

  @override
  String get onboarding_splash_title => 'Cildinizi\nTanıyın.';

  @override
  String get onboarding_splash_body =>
      'Sticker\'\'ınız UV\'\'yi gerçek zamanlı ölçer.\nRengi cilt bakımına dönüştürüyoruz.';

  @override
  String get onboarding_spf_label => 'Güneş Kremi SPF';

  @override
  String get onboarding_spf_noneLabel => 'Yok';

  @override
  String get home_title => 'Bugünkü UV';

  @override
  String get home_noData_hint2 => 'Takibi başlatmak için sticker\'\'ı tarayın.';

  @override
  String get home_status_safe => 'Bugün güzel korunuyorsunuz.';

  @override
  String get home_status_caution =>
      'Günlük dozunuzun yarısından fazlasını kullandınız.';

  @override
  String get home_status_warning => 'Günlük limitinize yaklaşıyorsunuz.';

  @override
  String get home_status_danger => 'Günlük limit doldu. Hemen gölgeye geçin.';

  @override
  String get home_pullToRefresh => 'Yenilemek için çekin';

  @override
  String get scan_capturing => 'Çekiliyor…';

  @override
  String get scan_analysing => 'Sticker analiz ediliyor…';

  @override
  String get scan_cameraStarting => 'Kamera başlatılıyor…';

  @override
  String get scan_torch_on => 'Flaş açık';

  @override
  String get scan_torch_off => 'Flaş kapalı';

  @override
  String get scan_back => 'Geri';

  @override
  String get result_safe_full => 'Bugün güzel korunuyorsunuz. ✨';

  @override
  String result_caution_full(int minutes) {
    return 'İyi gidiyorsunuz. $minutes dakika güvenli süreniz kaldı.';
  }

  @override
  String result_warning_full(String percent) {
    return 'Günlük limitinizin %$percent\'\'ini kullandınız.';
  }

  @override
  String get result_danger_full =>
      'Günlük limit doldu.\nGölgede dinlenme zamanı.';

  @override
  String get result_exceeded_full =>
      'Günlük limitinize yaklaşıyorsunuz.\nGölgeye geçin.';

  @override
  String get result_uvReading_label => 'UV Okuması';

  @override
  String get result_timeLeft_label => 'dk kaldı';

  @override
  String get result_action_shade => 'Hemen gölgeye geçin.';

  @override
  String get result_action_partial => 'Yarı gölgeye geçmeyi düşünün.';

  @override
  String get result_action_reapply =>
      'Korumayı sürdürmek için güneş kremini yenileyin.';

  @override
  String get result_action_caution =>
      'Güneşin tadını çıkarın — güneş kremini yakında yenileyin.';

  @override
  String get result_action_good => 'Güneşin tadını sorumlu şekilde çıkarın.';

  @override
  String get result_spfFaded =>
      'SPF koruması azalmış — güneş kremini yenileyin';

  @override
  String get result_spfCurrent => 'Mevcut SPF etkinliği: ';

  @override
  String get result_backHome => 'Panele Dön';

  @override
  String get home_uvUnavailable => 'UV verisi yok';

  @override
  String get scan_sticker_detected => 'Sticker algılandı';

  @override
  String get scan_sticker_notDetected => 'Sticker bulunamadı';

  @override
  String get scan_sticker_checking => 'Sticker taranıyor…';

  @override
  String get scan_sticker_tooSmall => 'Kamerayı sticker\'a yaklaştırın';

  @override
  String get scan_sticker_tooDark => 'Daha iyi aydınlatmaya gidin';

  @override
  String get scan_sticker_captureDisabledHint =>
      'Çekim için sticker\'ı çerçeveye hizalayın';

  @override
  String get settings_title => 'Ayarlar';

  @override
  String get settings_section_language => 'Dil';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_language_tr => 'Türkçe';

  @override
  String get settings_language_ja => '日本語';

  @override
  String get settings_section_profile => 'Cilt Profili';

  @override
  String get settings_section_app => 'Uygulama Hakkında';

  @override
  String get settings_fitzpatrick_label => 'Cilt Tipi';

  @override
  String get settings_spf_label => 'Güneş Kremi SPF';

  @override
  String get settings_spf_none => 'Yok';

  @override
  String get settings_save_button => 'Değişiklikleri Kaydet';

  @override
  String get settings_saved_message => 'Profil başarıyla güncellendi.';

  @override
  String get settings_version_label => 'Sürüm';

  @override
  String get settings_support_label => 'Destek';

  @override
  String get settings_support_email => 'support@uvdosimetry.com';

  @override
  String get settings_reset_label => 'Başlangıcı Sıfırla';

  @override
  String get settings_reset_confirm =>
      'Bu işlem cilt profilinizi siler. Devam edilsin mi?';

  @override
  String get settings_reset_button => 'Sıfırla';

  @override
  String get settings_cancel_button => 'İptal';

  @override
  String get premium_title => 'UV Dozimetre Premium';

  @override
  String get premium_body =>
      'Gelişmiş cilt analizi, maruziyet geçmişi ve kişisel UV raporlarının kilidini açın.';

  @override
  String get premium_upgrade_button => 'Premium\'\'a Geç';

  @override
  String get premium_later_button => 'Belki daha sonra';
}
