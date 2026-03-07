# UV Dosimeter — Geliştirme Eksikleri ve İyileştirme Raporu

Bu rapor, verdiğiniz prompt ve Agent Skill’lere (ComputerVision, Dermatology Math, Cultural Localization, Premium UI) göre projenin incelenmesi sonucunda tespit edilen **eksik** ve **iyileştirilmesi gereken** alanları özetler. Reklam ve premium özellikler gelir amacı olmadığı için “yapılması gerekli” listesine alınmamıştır.

---

## 1. Öncelikli Eksikler (Production-Ready için giderilmeli)

### 1.1 Kamera izni — taranmadan önce istenmiyor

**Durum:** `PermissionService.requestCamera()` ve `isCameraGranted` tanımlı ancak **hiçbir yerde kullanılmıyor**. Ana ekrandaki “Scan My Sticker” butonu doğrudan `/scan` sayfasına gidiyor; tarama ekranı açılınca kamera `initCamera()` ile başlatılıyor. İlk kullanımda sistem izin diyaloğu çıkabilir; daha önce reddedildiyse kullanıcı doğrudan teknik bir hata mesajı görür.

**Öneri:** Tarama ekranına gitmeden önce kamera iznini isteyin:

- **Konum:** Ana ekran → “Scan My Sticker” tıklanınca, `context.go(RouteNames.scan)` çağrılmadan önce.
- **Akış:**  
  1. `PermissionService.requestCamera()` çağrılsın.  
  2. Reddedilirse: `error_camera` (l10n) ile bilgilendirme ve “Open Settings” / “Retry” seçenekleri sunulsun; `/scan`’e gidilmesin.  
  3. Verilirse veya zaten verilmişse: `context.go(RouteNames.scan)` ile tarama ekranına gidilsin.

Böylece izin reddi durumunda kullanıcı anlamlı bir mesaj ve aksiyon görür; production-ready hata yönetimi sağlanır.

**İlgili dosyalar:**  
- `lib/core/services/permission_service.dart` (mevcut API)  
- `lib/features/home/presentation/screens/home_screen.dart` (Scan butonu)  
- `lib/l10n/app_*.arb` — `error_camera`, `error_settings_button` zaten var.

---

### 1.2 404 ekranı — sabit metinler (l10n dışı)

**Durum:** `app_router.dart` içindeki 404 ekranında metinler doğrudan kodda:

- `'Page Not Found'`
- `'The page you are looking for does not exist.'`
- `'Back to Dashboard'`

**Öneri:**  
- Bu üç metin için `lib/l10n/app_en.arb`, `app_ja.arb`, `app_tr.arb` içinde yeni anahtarlar ekleyin (örn. `error_pageNotFound_title`, `error_pageNotFound_message`, buton için mevcut `result_backHome` kullanılabilir).  
- 404 ekranında bu l10n anahtarlarını kullanın.  
Böylece tüm metinler ARB’de toplanır ve Japonca/Türkçe tutarlı olur (Cultural Localization skill ile uyumlu).

**İlgili dosya:** `lib/app/router/app_router.dart` (satır ~165–185).

---

### 1.3 Kamera hata mesajı — kullanıcı dostu l10n kullanımı

**Durum:** Tarama ekranında hata gösterilirken `CameraFailure` için `failure.message` (ham mesaj) kullanılıyor; `error_camera` l10n metni kullanılmıyor.

**Öneri:**  
- `CameraFailure` için varsayılan olarak `l10n.error_camera` gösterilsin.  
- İsterseniz: izin reddi / “no cameras” gibi bilinen durumlar için `failure.message`’a göre kısa bir eşleme yapıp yine l10n metinlerine düşün.  
Böylece kullanıcı her zaman anlaşılır, lokalize bir mesaj görür.

**İlgili dosya:** `lib/features/scan/presentation/screens/scan_screen.dart` — `_showFailureSnackbar` içinde `CameraFailure()` dalı.

---

## 2. Opsiyonel / İyileştirme Önerileri

### 2.1 Ortam ışığı (ambient lux)

**Durum:** Uygulama analiz isteğine `ambientLux = 500` sabit değer gönderiyor; gerçek ortam ışığı sensörü kullanılmıyor.

**Öneri:** Skill’de “optional, from light sensor” deniyor. İleride doğruluk önemli olursa platform ışık sensörü (sensor_plus veya benzeri) ile gerçek lux değeri gönderilebilir. Şu an için **zorunlu değil**.

---

### 2.2 ARB anahtar sayısı (en: 149, ja/tr: 148)

**Durum:** Keşif raporunda İngilizce 149, Japonca ve Türkçe 148 anahtar olduğu belirtildi. `result_backHome` ve `history_premium_locked` üç dilde de mevcut.

**Öneri:** Projede bir kere `app_en.arb` ile `app_ja.arb` / `app_tr.arb` karşılaştırması yapıp eksik veya fazla anahtar varsa (ör. sadece @ açıklama farkı da olabilir) giderin. Tam eşleşme, çeviri eksiklerini önler.

---

### 2.3 Splash ekranı görseli

**Durum:** `pubspec.yaml` içinde splash görseli yorum satırında; aktif bir splash asset’i yok.

**Öneri:** Tasarım tamamlandığında `flutter_native_splash` için gerçek görsel eklenebilir. **Öncelikli değil.**

---

## 3. Reklam ve Premium ile ilgili (şu an değişiklik gerekmez)

- **Feature Toggles:** `isPremiumModeActive` ve `areAdsEnabled` false; reklam ve premium akışları kapalı.  
- **Placeholder ID’ler:** `ad_service.dart` ve `revenue_cat_service.dart` içinde placeholder reklam birim ID’leri ve RevenueCat API anahtarları var. Gelir amacı olmadığı sürece bunları değiştirmeniz veya kaldırmanız gerekmez; kod feature toggle ile kapalı.  
- **History “Premium” metni:** Geçmiş ekranında “Upgrade to Premium…” metni gösteriliyor; toggle kapalı olduğu için sadece bilgilendirme. İsterseniz ileride bu metni tamamen kaldırıp geçmişi herkese açabilirsiniz; bu ürün kararı.

Özet: Reklam ve premium için **ek geliştirme zorunluluğu yok**; mevcut yapı “reklam/premium yok” senaryosuna uygun.

---

## 4. Skill uyumluluğu özeti

| Skill | Durum |
|-------|--------|
| **ComputerVision_Colorimetry** | Backend: LAB white balance, mor sticker HSV maskesi, K-Means, L*→UV% kalibrasyon eğrisi, hata kodları (sticker_not_detected, too_small, insufficient_lighting) uygulanmış. |
| **Dermatology_Math_Engine** | Backend: MED tablosu (200–1000 J/m²), SPF bi-exponential decay, remaining_safe_minutes, risk seviyeleri (safe/caution/warning/danger/exceeded) mevcut. |
| **Cultural_Localization_Expert** | En/ja/tr ARB dosyaları ve bildirim şablonları var; 404 ve kamera mesajları l10n’e alınarak tam uyum sağlanabilir. |
| **Premium_Cosmeceutical_UI_Designer** | Tema (AppColors, AppTypography), arc gauge, pulse overlay, shimmer, kart düzeni kullanılıyor. |
| **Monetization_Stealth_Controller** | Toggle’lar kapalı; reklam/premium kodları yerinde, kullanılmıyor. |

---

## 5. Yapılacaklar özet listesi

1. ~~**Kamera izni:** Ana ekranda “Scan”e basıldığında tarama sayfasına gitmeden önce `PermissionService.requestCamera()` çağrısı ekleyin; reddedilirse l10n ile bilgilendirme ve “Settings”/“Retry” sunun.~~ **Yapıldı.**  
2. ~~**404 ekranı:** 404 başlık ve mesajını ARB’ye taşıyın; buton metni için `result_backHome` kullanın.~~ **Yapıldı.**  
3. ~~**Kamera hatası:** `CameraFailure` durumunda snackbar’da `l10n.error_camera` kullanın.~~ **Yapıldı.**  
4. (İsteğe bağlı) ARB en/ja/tr anahtar sayısını kontrol edip eksik çeviriyi tamamlayın.  
5. (İsteğe bağlı) İleride ambient lux sensörü eklenebilir; splash görseli tasarım sonrası eklenebilir.

Reklam ve premium özellikleri açmayacaksanız bu alanlarda ek işlem yapmanız gerekmez.
