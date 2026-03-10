# BlancMate — Tasarım Brief & AI Görsel Prompt'ları

Bu dokümanda uygulamada kullanılacak tüm görsel içerikler, ölçüler ve yapay zeka (Midjourney, DALL·E, Ideogram vb.) ile üretebileceğiniz prompt'lar yer alıyor.

---

## 1. Tasarım Tokenları (Ölçüler ve Renkler)

### Renk paleti (HEX)

| Token | HEX | Kullanım |
|-------|-----|----------|
| clinicalWhite | `#F9F7F5` | Ana arka plan (ılık beyaz) |
| snowPearl | `#FFFFFF` | Kartlar, saf beyaz yüzeyler |
| deepInk | `#1A1A2E` | Metin rengi (koyu, mavi tonlu) |
| sakuraMist | `#F2E8F0` | Güvenli UV bölgesi tint |
| goldenCaution | `#FFF3CD` | Uyarı bölgesi tint |
| coralRisk | `#FFEAE6` | Tehlike bölgesi tint |
| uvSafeGreen | `#4CAF8D` | Güvenli doz göstergesi |
| uvWarnAmber | `#E8A838` | Uyarı göstergesi |
| uvDangerCoral | `#E05C4B` | Tehlike göstergesi |
| bihakuLavender | `#B8A9D9` | Premium aksan (buton, vurgu) |
| cardSurface | `#FFFFFF` | Kart arka planı |
| subtleDivider | `#EEECEA` | Çizgiler, border |
| scanVignette | `#CC000000` | Tarama ekranı karartma (alpha ~80%) |

### Tipografi

| Stil | Font | Boyut | Ağırlık | Kullanım |
|------|------|-------|---------|---------|
| displayLarge | DM Serif Display | 32 px | 400 | Onboarding / büyük başlık |
| headlineMed | DM Serif Display | 22 px | 400 | Ekran başlıkları, sonuç mesajı |
| bodyLarge | Inter | 16 px | 400 | Açıklama metni, line-height 1.6 |
| bodyMedium | Inter | 14 px | 400 | Kart içi metin |
| dataDisplay | Inter | 48 px | 300 | UV % / MED büyük sayı |
| labelSmall | Inter | 11 px | 500 | Etiketler, letter-spacing 1.2 |
| buttonLabel | Inter | 15 px | 600 | Buton metni |

### Spacing (dp)

- Ölçek: **4, 8, 16, 24, 32, 48** (sadece 4’ün katları)
- Kart border-radius: **20**
- Buton border-radius: **16**, yükseklik **56 dp**
- Chip / badge border-radius: **12–24**

### Bileşen ölçüleri (dp)

| Bileşen | Genişlik | Yükseklik | Not |
|---------|----------|-----------|-----|
| UV arc gauge (daire) | 200 | 200 | Yay yarıçapı ~84, stroke 10 |
| Scan kılavuz daire | 176 | 176 | Stroke 3 |
| UV index badge | — | ~40 | padding H:14 V:8, radius 20 |
| Remaining time chip | — | ~44 | padding H:20 V:10, radius 24 |
| Primary button | full width | 56 | radius 16 |
| Onboarding “UV dot” ikon alanı | 48 | 48 | radius 16, gradient |

---

## 2. Görsel Varlıklar ve AI Prompt'ları

Aşağıdaki her madde için: **çıktı formatı**, **önerilen boyut (px)** ve **kopyala-yapıştır AI prompt** verilmiştir. İstediğiniz araca (Midjourney, DALL·E, Ideogram, vb.) aynen yapıştırabilirsiniz.

---

### 2.1 Splash / Uygulama logosu (Native Splash)

**Kullanım:** Uygulama açılış ekranında ortada görünecek logo.  
**Teknik:** PNG, şeffaf arka plan. Açık tema: logo açık renk (#F9F7F5 veya beyaz ile uyumlu). Koyu tema: logo açık renk (#1A1A2E koyu arka plan üzerinde).  
**Önerilen boyut:** **288×288 px** veya daha büyük (1x, 2x, 3x için 288, 576, 864).

**Prompt (İngilizce — DALL·E / Midjourney):**

```
Minimal app icon for BlancMate — a Japanese luxury skincare UV dosimeter app. 
Single elegant symbol: a small circle or droplet representing a photochromic UV sticker, 
combined with a subtle sun or light ray motif. 
Style: premium cosmeceutical, Shiseido or POLA-like. 
Colors: soft lavender (#B8A9D9) and warm white, on transparent background. 
No text. Clean vector-style, flat design. 
Square canvas, centered, plenty of negative space.
```

**Alternatif (daha soyut):**

```
Minimal logo mark for "BlancMate" app. 
Abstract shape: a circle that suggests both a sticker and a sun shield. 
Premium Japanese skincare aesthetic, Bihaku (beautiful white skin) concept. 
Palette: lavender #B8A9D9, soft green #4CAF8D, warm white. 
Transparent background, centered, vector flat design, square format.
```

---

### 2.2 Onboarding ekranı — hero görseli (opsiyonel)

**Kullanım:** Onboarding ilk ekranda, başlık üstünde veya yanında kullanılabilecek tek görsel. Şu an kodda yok; ileride eklenebilir.  
**Önerilen boyut:** **600×400 px** (yatay) veya **400×500 px** (dikey).

**Prompt:**

```
Illustration for a mobile app onboarding screen. 
Theme: gentle UV protection and skin care. 
A soft, abstract representation of skin being protected by an invisible shield or soft light, 
with a tiny circular sticker symbol. 
Style: premium Japanese skincare brand, calm and trustworthy. 
Colors: warm white #F9F7F5, lavender #B8A9D9, soft green #4CAF8D, deep navy text #1A1A2E. 
No faces, no realistic body. Minimal, editorial, lots of whitespace. 
Horizontal layout, suitable for above-the-fold mobile screen.
```

---

### 2.3 Ana ekran — “Henüz veri yok” (empty state) illüstrasyonu (opsiyonel)

**Kullanım:** İlk açılışta veya veri yokken “Scan your sticker to begin tracking.” metninin yanında veya üstünde.  
**Önerilen boyut:** **240×240 px** (veya 480×480 @2x).

**Prompt:**

```
Empty state illustration for a UV and skin protection app. 
A smartphone screen showing a soft circular frame (like a camera viewfinder) 
with a small, friendly illustration of a circular UV sticker inside. 
Mood: inviting, “tap to start”, not sad or empty. 
Style: minimal, premium Japanese skincare app, pastel palette. 
Colors: #F9F7F5 background, #B8A9D9 lavender accent, #4CAF8D soft green. 
No text in the image. Centered composition, square format.
```

---

### 2.4 Geçmiş ekranı — “Henüz kayıt yok” (empty state) (opsiyonel)

**Kullanım:** UV History’de kayıt yokken: “No UV exposure recorded yet. Scan your sticker to start tracking.”  
**Önerilen boyut:** **240×200 px**.

**Prompt:**

```
Empty state illustration for a “history” or “tracking” screen in a skincare app. 
Simple visual: a minimal calendar or timeline with a single soft glowing dot, 
suggesting “your first scan will appear here”. 
Style: clean, premium, Japanese cosmetic app. 
Colors: warm white #F9F7F5, lavender #B8A9D9, subtle grey #EEECEA. 
No text. Calm and encouraging mood. Portrait orientation, space for text below.
```

---

### 2.5 Sonuç ekranı — durum ikonları (güvenli / uyarı / tehlike) (opsiyonel)

**Kullanım:** Result ekranında UV durumuna göre (safe / caution / danger) kullanılabilecek küçük ikonlar.  
**Önerilen boyut:** **64×64 px** veya **128×128** @2x.

**Prompt (güvenli — safe):**

```
Tiny icon for “you are safe” or “well protected” in a UV/skincare app. 
Symbol: soft checkmark, or a small shield, or a leaf. 
Style: minimal line icon, single color #4CAF8D (soft green). 
Transparent background. No text. 64x64 pixels style, simple vector.
```

**Prompt (uyarı — caution):**

```
Tiny icon for “caution” or “moderate UV exposure” in a skincare app. 
Symbol: soft sun with a gentle warning, or a half-filled gauge. 
Style: minimal line icon, single color #E8A838 (amber). 
Transparent background. No text. 64x64 pixels style.
```

**Prompt (tehlike — danger):**

```
Tiny icon for “daily limit reached” or “seek shade” in a UV app. 
Symbol: small sun with minus or stop, or a hand shielding. 
Style: minimal line icon, single color #E05C4B (coral red). 
Transparent background. No text. 64x64 pixels style.
```

---

### 2.6 Tarama (scan) ekranı — kılavuz çerçeve stil referansı

**Kullanım:** Görsel üretmek gerekmez; kamera overlay’i kodla çiziliyor. Referans için: kullanıcı sticker’ı **176×176 dp** daire içine hizalıyor. Çerçeve: ince beyaz daire, pulse animasyonu.

**Not:** Bu ekran için ayrı bir AI görseli önerilmez; UI tamamen Flutter ile çiziliyor.

---

### 2.7 Premium / yükseltme ekranı (opsiyonel görsel)

**Kullanım:** Premium paywall’da kullanılabilecek “unlock” veya “premium” hissi veren görsel.  
**Önerilen boyut:** **360×200 px**.

**Prompt:**

```
Illustration for an in-app “Upgrade to Premium” screen. 
Theme: unlock, premium features, skin analysis, personal care. 
Abstract: soft lock opening, or a path leading to a brighter, more detailed dashboard. 
Style: premium Japanese app, not gaming. Colors: #B8A9D9 lavender, #F9F7F5 white, #1A1A2E dark. 
No text. Horizontal card shape, minimal and elegant.
```

---

## 3. Metin İçerikleri (Görsele Gömülmemesi Gerekenler)

Aşağıdaki metinler uygulama içinde dinamik; görsellere **yazı olarak koymayın**. Sadece başlık/kısa tagline için kullanılacaksa belirttim.

- **onboarding_splash_title:** “Know Your Skin.” (EN) / “Cildinizi Tanıyın.” (TR) / “あなたの肌を知ろう。” (JA)
- **onboarding_splash_body:** “Your photochromic sticker measures UV in real time. We turn colour into care.”
- **home_noData_hint:** “Scan your sticker to begin tracking.”
- **history_noData_hint:** “No UV exposure recorded yet. Scan your sticker to start tracking.”
- **scan_guideOverlay_hint:** “Align the sticker inside the frame”

Görsel üretirken bu cümleleri **genelde kullanmayın**; uygulama kendi metnini gösteriyor. İstisna: splash logo yanında çok kısa bir “Know Your Skin” yazısı istersen, ayrı bir “splash with tagline” prompt’u yazılabilir.

---

## 4. Dosya Yolları ve Nereye Ekleneceği

Tüm görseller **proje kökü** `uv_dosimeter/` kabul edilerek verilmiştir.

### 4.1 Asset klasör yapısı

```
uv_dosimeter/
  assets/
    images/          ← Tüm görseller buraya
      splash_logo.png
      onboarding_hero.png
      empty_home.png
      empty_history.png
      icon_safe.png
      icon_caution.png
      icon_danger.png
      premium_card.png
```

### 4.2 Tek tek dosya yolları ve adımlar

| Görsel | Tam dosya yolu | Nereye ekleyeceksin | Pubspec / entegrasyon |
|--------|----------------|---------------------|------------------------|
| **Splash logo** | `uv_dosimeter/assets/images/splash_logo.png` | Dosyayı `assets/images/` içine koy. | 1) `pubspec.yaml` → `flutter:` altına `assets: [ assets/images/ ]` ekle. 2) `flutter_native_splash:` altında `image: assets/images/splash_logo.png` satırının yorumunu kaldır. 3) Terminal: `dart run flutter_native_splash:create` çalıştır. |
| **Onboarding hero** | `uv_dosimeter/assets/images/onboarding_hero.png` | Dosyayı `assets/images/` içine koy. | `pubspec.yaml` → `assets: [ assets/images/ ]` (zaten images klasörü tanımlıysa ek dosya gerekmez). Kodda henüz kullanılmıyor; `lib/features/onboarding/.../onboarding_screen.dart` içinde `Image.asset('assets/images/onboarding_hero.png')` ile eklenebilir. |
| **Home empty state** | `uv_dosimeter/assets/images/empty_home.png` | Dosyayı `assets/images/` içine koy. | Aynı şekilde `assets/images/` tanımlıysa yeterli. Kodda henüz yok; `lib/features/home/.../home_screen.dart` içinde “Scan your sticker…” metninin üstüne/yanına `Image.asset('assets/images/empty_home.png')` eklenebilir. |
| **History empty state** | `uv_dosimeter/assets/images/empty_history.png` | Dosyayı `assets/images/` içine koy. | Aynı. Kullanım: `lib/features/history/.../history_screen.dart` → “No UV exposure recorded…” bölümüne `Image.asset('assets/images/empty_history.png')`. |
| **Result: safe icon** | `uv_dosimeter/assets/images/icon_safe.png` | Dosyayı `assets/images/` içine koy. | Opsiyonel; şu an Phosphor Icons kullanılıyor. Kullanırsan: `lib/features/result/.../result_screen.dart` içinde duruma göre `Image.asset('assets/images/icon_safe.png', width: 64, height: 64)`. |
| **Result: caution icon** | `uv_dosimeter/assets/images/icon_caution.png` | Dosyayı `assets/images/` içine koy. | Aynı şekilde result ekranında durum ikonu olarak. |
| **Result: danger icon** | `uv_dosimeter/assets/images/icon_danger.png` | Dosyayı `assets/images/` içine koy. | Aynı şekilde result ekranında durum ikonu olarak. |
| **Premium card** | `uv_dosimeter/assets/images/premium_card.png` | Dosyayı `assets/images/` içine koy. | Opsiyonel. Premium paywall ekranı eklendiğinde `Image.asset('assets/images/premium_card.png')` ile kullanılır. |

### 4.3 pubspec.yaml — tek seferlik ayar

Görselleri projeye tanıtmak için `pubspec.yaml` içinde `flutter:` bloğunda `assets` tanımlı olmalı:

```yaml
flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/images/
```

Bu satırlar **zaten varsa** sadece dosyaları `assets/images/` içine koyman yeterli; yeni satır ekleme.

### 4.4 Splash için ek adımlar (sadece splash_logo için)

1. **Dosyayı koy:** `uv_dosimeter/assets/images/splash_logo.png`
2. **pubspec.yaml** içinde:
   - `flutter:` altında `assets: [ assets/images/ ]` olduğundan emin ol.
   - `flutter_native_splash:` bölümünde şu satırı **yorumdan çıkar:**  
     `image: assets/images/splash_logo.png`
3. **Terminal (proje kökünde):**  
   `dart run flutter_native_splash:create`  
   Bu komut Android/iOS splash kaynaklarını günceller.

### 4.5 Opsiyonel görselleri kodda kullanmak

- **Onboarding hero:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart` → başlıktan önce veya `Spacer` yerine bir `Image.asset('assets/images/onboarding_hero.png', fit: BoxFit.contain)` eklenebilir.
- **Empty state’ler:** `home_screen.dart` ve `history_screen.dart` içinde ilgili “no data” bölümüne `Image.asset('assets/images/empty_home.png')` / `empty_history.png` eklenir.
- **İkonlar ve premium:** İstersen result ve premium ekranlarında `Image.asset('assets/images/...')` ile yukarıdaki dosya yollarını kullanırsın.

---

## 5. Özet Tablo — Hangi Görsel, Hangi Boyut, Hangi Dosya

| Görsel | Önerilen boyut (px) | Dosya adı | Tam yol | Zorunlu? |
|--------|----------------------|-----------|---------|----------|
| Splash / app logo | 288×288 (veya 288/576/864) | `splash_logo.png` | `uv_dosimeter/assets/images/splash_logo.png` | Evet (splash) |
| Onboarding hero | 600×400 veya 400×500 | `onboarding_hero.png` | `uv_dosimeter/assets/images/onboarding_hero.png` | Hayır |
| Home empty state | 240×240 veya 480×480 | `empty_home.png` | `uv_dosimeter/assets/images/empty_home.png` | Hayır |
| History empty state | 240×200 | `empty_history.png` | `uv_dosimeter/assets/images/empty_history.png` | Hayır |
| Result: safe icon | 64×64 veya 128×128 | `icon_safe.png` | `uv_dosimeter/assets/images/icon_safe.png` | Hayır |
| Result: caution icon | 64×64 veya 128×128 | `icon_caution.png` | `uv_dosimeter/assets/images/icon_caution.png` | Hayır |
| Result: danger icon | 64×64 veya 128×128 | `icon_danger.png` | `uv_dosimeter/assets/images/icon_danger.png` | Hayır |
| Premium unlock | 360×200 | `premium_card.png` | `uv_dosimeter/assets/images/premium_card.png` | Hayır |

---

## 6. Kısa Kullanım Notları

- **Renk tutarlılığı:** Prompt’larda HEX’leri belirttim; AI bire bir uymayabilir. Üretilen görseli Figma/Photoshop’ta renkleri token’lara yaklaştırarak ince ayar yapabilirsiniz.
- **Yazı kullanmama:** Mümkünse görsellerde metin olmasın; uygulama tüm metinleri l10n ile veriyor.
- **Splash:** `assets/images/splash_logo.png` ekledikten sonra `pubspec.yaml` içinde `flutter_native_splash` altında `image: assets/images/splash_logo.png` satırını açıp `dart run flutter_native_splash:create` çalıştırmanız yeterli.
- **2x/3x:** Mobil için 2x (576 px), 3x (864 px) versiyonları üretirseniz, Flutter’da `AssetImage` ile kullanırken otomatik seçim yapılır.

Bu dokümandaki prompt’ları olduğu gibi veya marka tonuna göre hafifçe değiştirerek kullanabilirsiniz. Ölçüler ve renk kodları projedeki `AppColors` ve `AppTypography` ile uyumludur.
