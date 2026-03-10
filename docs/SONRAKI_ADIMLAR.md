# BlancMate — Sonraki Adımlar ve Opsiyonel İyileştirmeler

Bu dokümanda **tamamlanmış** işler, **kalan küçük iyileştirmeler** ve **isteğe bağlı** geliştirmeler listelenir.

---

## Tamamlananlar (production-ready için yapıldı)

- Kamera izni tarama öncesi isteniyor (Ana ekran → Scan → izin → /scan).
- 404 ekranı tamamen l10n (error_pageNotFound_*, result_backHome).
- Kamera hatası snackbar’da l10n.error_camera.
- UV geçmişi: "Today" → history_today_label; Japonca gün etiketi RangeError düzeltildi.
- Kamera açıkken geri tuşu/hareketi: PopScope + releaseCamera() ile güvenli çıkış.

---

## ~~Kalan küçük iyileştirmeler~~ — Yapıldı

### ~~1. Bildirim metinleri (l10n)~~ ✅

- Home notifier artık bildirimi doğrudan göstermiyor; `pendingDoseNotification` (threshold80 / dailyDone) state’e yazıyor.
- Home ekranında `ref.listen` ile bu alan dinleniyor; l10n ile `NotificationService.showThreshold80` / `showDailyDone` çağrılıyor, sonra `clearPendingDoseNotification()`.
- SPF “Mark as applied” bildirimi: `markSpfAppliedNow(notificationTitle:, notificationBody:)` ile Settings ekranından l10n string’leri geçiriliyor.

### ~~2. Konum hata mesajları (l10n)~~ ✅

- ARB’ye eklendi: `error_location_services_off`, `error_location_denied_forever`, `error_location_denied`, `error_location_timeout`, `error_location_unavailable` (en/ja/tr).
- Notifier `_locationErrorCode()` ile hata kodu üretiyor; UI’da `_locationErrorMessage(code, l10n)` ile l10n string’i seçilip `_ErrorBadge`’de gösteriliyor.

---

## Opsiyonel — Yapıldı

| Konu | Durum |
|------|--------|
| **ARB parity** | en/ja/tr anahtar setleri eşleşiyor. |
| **Ortam ışığı (lux)** | ambient_light + AmbientLightService; tarama öncesi getCurrentLux() gönderiliyor. |
| **Splash görseli** | assets/images/ ve README eklendi. |
| **Unit / widget testleri** | Kritik provider’lar ve ekranlar için test sayısı artırılabilir. |
| **README** | Proje, kurulum, API_BASE_URL, backend güncellendi. |
| **Erişilebilirlik** | Semantics (button/label) ana ekran, tarama, sonuç, ayarlar. |

---

## Özet

- **Zorunlu** sayılabilecek production-ready adımlar tamamlandı.  
- **Önerilen:** Bildirim ve konum hata metinlerini l10n’e taşımak (kullanıcı dilinde görünmesi için).  
- **Opsiyonel:** ARB parity, lux sensörü, splash, test, README, erişilebilirlik.

Reklam/premium açılmayacaksa bu alanlarda ek işlem gerekmez.
