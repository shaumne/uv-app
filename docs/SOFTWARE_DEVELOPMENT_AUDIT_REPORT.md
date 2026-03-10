# UV Dosimeter — Yazılım Geliştirme Denetim Raporu (Technical Audit)

**Proje:** BlancMate / UV Dosimeter (uv-app)  
**Kapsam:** Flutter mobil uygulama + Python FastAPI backend  
**Tarih:** 2025-03-10  
**Hazırlayan:** Kıdemli Yazılım Mimarı / AI Ürün Stratejisti

---

## Özet

Bu rapor, UV sticker tarama, Fitzpatrick cilt tipi ve MED tabanlı UV doz ölçümü sunan sistemin **görüntü işleme**, **mimari**, **AI/dermatoloji genişletmesi**, **veri güvenliği** ve **offline/edge çalışma** başlıklarında teknik denetimini içerir. Tüm öneriler doğrudan uygulanabilir kod/kütüphane seçenekleriyle desteklenmiştir.

---

## 1. Görüntü İşleme ve Hassasiyet (OpenCV / Backend)

### 1.1 Mevcut Durum

- **Dosyalar:** `backend/app/services/colorimetry_service.py`, `/api/v1/endpoints/detect.py` (endpoint; algılama mantığı `colorimetry_service.detect_sticker_presence` içinde).
- **Beyaz dengesi:** LAB Grey-World (`_white_balance_lab`) + luminance-weighted A*/B* nötrleştirme; ardından `bilateralFilter(d=9, sigmaColor=75, sigmaSpace=75)`.
- **Sticker izolasyonu:** Mor HSV maskesi (H 100–178, S≥10/20), morfolojik kapatma/açma, merkez %36 ROI veya `pre_cropped` ile tüm görüntü.
- **Renk çıkarımı:** K-Means k=3, dominant cluster; UV% için ROI ortanca L* ile kalibrasyon eğrisi (`_roi_median_l_to_uv_percent`).

**Eksikler:**

- Işık tipine özel ayar yok: gölge, direkt güneş, yapay ışık aynı Grey-World ile işleniyor; renk sapması (özellikle tungsten/LED) kalabilir.
- Referans renk kalibrasyonu yok: sticker üzerindeki bilinen renkler (örn. beyaz referans patch) kullanılmıyor.
- `ambient_lux` sadece loglama için; WB algoritmasına girdi olarak bağlı değil.

### 1.2 Önerilen İleri Teknikler

#### A) White Balance — Işık Tipi Desteği (Grey-World + Geliştirmeler)

- **Öneri 1 — Shades of Grey (SoG):** Grey-World’de ortalama yerine p-norm (örn. p=6) kullanarak aşırı parlak/koyu bölgelerin etkisini azaltın.

```python
# colorimetry_service.py — _white_balance_lab alternatifi
def _white_balance_lab_sog(image: np.ndarray, p: float = 6.0) -> np.ndarray:
    lab = cv2.cvtColor(image, cv2.COLOR_BGR2LAB).astype(np.float64)
    # p-norm of A and B (avoid single bright region dominating)
    n = lab[:, :, 1].size
    avg_a = np.power(np.power(np.abs(lab[:, :, 1]), p).sum() / n, 1.0 / p)
    avg_b = np.power(np.power(np.abs(lab[:, :, 2]), p).sum() / n, 1.0 / p)
    lab[:, :, 1] -= (avg_a - 128) * (lab[:, :, 0] / 255.0) * 1.1
    lab[:, :, 2] -= (avg_b - 128) * (lab[:, :, 0] / 255.0) * 1.1
    lab = np.clip(lab, 0, 255).astype(np.uint8)
    balanced = cv2.cvtColor(lab, cv2.COLOR_LAB2BGR)
    return cv2.bilateralFilter(balanced, d=9, sigmaColor=75, sigmaSpace=75)
```

- **Öneri 2 — ambient_lux ile WB seçimi:** Düşük lux’ta (kapalı/yapay) daha agresif nötrleştirme; yüksek lux’ta (güneş) mevcut parametreler. İsteğe bağlı: `ambient_lux` ile SoG/Grey-World seçimi veya gain sınırı.

```python
# Örnek: lux < 200 → SoG; else mevcut _white_balance_lab
def _white_balance_adaptive(image: np.ndarray, ambient_lux: float) -> np.ndarray:
    if ambient_lux < 200:
        return _white_balance_lab_sog(image)
    return _white_balance_lab(image)
```

#### B) Reference Color Calibration (Sticker Referans Patch)

- Sticker’da **bilinen renk patch’leri** (örn. beyaz #F8F9FA ve koyu mor #311B92) varsa, bu referanslara göre 2D/3D renk düzeltmesi yapılabilir.
- **Öneri — Referans tabanlı düzeltme:**
  1. ROI içinde referans patch’leri tespit (kontur veya sabit konum).
  2. Hedef LAB değerleri (kalibrasyon eğrisinden) ile ölçülen LAB’ı eşleştir; 3×3 veya 3×4 (affine) renk dönüşüm matrisi hesapla (least squares).
  3. Tüm ROI piksellerine bu matrisi uygula; sonra mevcut K-Means + L* → UV% pipeline’ı kullan.

**Kütüphane:** `cv2.getPerspectiveTransform` veya `numpy.linalg.lstsq` ile 3×3 renk matrisi; referans değerleri `reference.md` veya config’ten okunabilir.

#### C) Kütüphane Tavsiyeleri

| Amaç | Kütüphane | Not |
|------|-----------|-----|
| Gelişmiş WB | OpenCV (mevcut) + SoG/adaptive mantığı | Ek bağımlılık yok |
| Renk kalibrasyonu | `colour-science` (Python) | CIE CAM, delta-E; ileri renk bilimi |
| Referans patch tespiti | OpenCV contour + mor/beyaz mask | Mevcut HSV pipeline ile uyumlu |

**Sonuç:** Öncelik sırası: (1) `ambient_lux` ile adaptive WB, (2) SoG denemesi, (3) fiziksel sticker’da referans patch varsa referans tabanlı kalibrasyon. Referans kalibrasyonu, farklı cihaz ve ışıkta en yüksek renk doğruluğunu sağlar.

---

## 2. Mimari Analiz (Flutter / Riverpod)

### 2.1 Mevcut Yapı

- **Katmanlar:** Feature bazlı: `data` (datasources, models, repositories), `domain` (entities, repositories interface, use cases), `presentation` (screens, widgets, providers).
- **State:** Riverpod (StateNotifier/Provider); `homeNotifierProvider`, `scanNotifierProvider` autoDispose.
- **DI:** `app/di/providers.dart` (Dio, NetworkInfo, AmbientLight vb.); feature provider’ları ilgili feature klasöründe.

### 2.2 Tespit Edilen Noktalar

#### A) Separation of Concerns — Repository Örneği

- **Sorun:** `ScanNotifier.captureAndAnalyse` içinde `ScanRepositoryImpl` doğrudan oluşturuluyor; bağımlılık provider’dan enjekte edilmiyor.

```dart
// scan_provider.dart (mevcut)
final repository = ScanRepositoryImpl(
  remoteDatasource: _deps.remoteDatasource,
  networkInfo: _deps.networkInfo,
  cumulativeDoseJm2: currentDoseJm2,
  ...
);
final either = await AnalyzeSticker(repository)(request);
```

- **Öneri:** Repository’yi notifier constructor’a enjekte edin; `currentDoseJm2` / `uvIndex` gibi runtime değerleri use case veya repository’ye parametre olarak geçirin (ör. `AnalyzeSticker(repository).call(request, cumulativeDoseJm2: ..., uvIndex: ...)`). Böylece testte mock repository kullanılır ve SoC korunur.

#### B) Performans

- **HomeNotifier.loadAll:** `_loadUvIndex` ve `_loadDoseSummary` paralel (`Future.wait`); konum tek sefer; uygun.
- **ScanNotifier:** Her capture’da detect → analyze sıralı; crop cihazda, API çağrıları sırayla. Darboğaz ağ ve backend süresi; Flutter tarafında ek bekleme yok.
- **homeNotifierProvider:** `ref.watch(getUvIndexUseCaseProvider)` ve `ref.watch(getDailyDoseSummaryProvider)` her seferinde aynı instance’ları kullanır; gereksiz rebuild’ler yalnızca bu provider’lar değişirse olur. `loadAll()` provider oluşurken çağrılıyor; kabul edilebilir.
- **scanNotifierProvider:** `ref.watch(homeNotifierProvider)` ile home state’e bağlı; home yenilendiğinde scan notifier yeniden oluşur. Bu, `currentDoseJm2`/`uvIndex` güncellemesi için istenen davranış; ancak home sık güncellenirse scan ekranında da rebuild artar. Gerekirse sadece `doseSummary` ve `uvIndex` değerlerini okuyan ayrı bir `Provider` ile bağımlılığı minimize edebilirsiniz.

#### C) Clean Architecture Uyumu

- Domain, data ve presentation ayrımı net; use case’ler repository interface’ine bağımlı. Tek tutarsızlık ScanNotifier’ın repository’yi kendi içinde instantiate etmesi; yukarıdaki enjeksiyon önerisi ile giderilmeli.

**Özet:** Mimari genel olarak Clean Architecture ile uyumlu; en kritik iyileştirme Scan repository’nin DI ile verilmesi ve runtime parametrelerin (dose, uvIndex) use case/repository üzerinden geçirilmesidir.

---

## 3. AI ve Dermatoloji Entegrasyonu (Gelecek Özellikler)

### 3.1 Mevcut Durum

- Sadece **renk analizi** (sticker HEX → L* → UV%) ve **MED/SPF matematik motoru** (`med_calculator.py`); cilt görüntüsü sınıflandırması veya leke/yanık evresi yok.

### 3.2 “AI Dermatolog” Asistanı İçin Öneriler

#### A) Kullanım Senaryoları

- Cilt **lekeleri** (melasma, solar lentigo) takibi.
- **Güneş yanığı evresi** (hafif kızarıklık → eritem → soyulma) sınıflandırması.
- (İsteğe bağlı) Fitzpatrick tahmini: sadece rehberlik amaçlı, tıbbi tanı yerine geçmez.

#### B) Model Seçenekleri

| Model | Avantaj | Dezavantaj | Önerilen kullanım |
|-------|--------|------------|-------------------|
| **MobileNetV3** | Edge/telefonda hızlı, düşük bellek | Genel sınıflandırma; dermatoloji için fine-tune gerekir | Leke/yanık evresi sınıflandırma (TFLite) |
| **EfficientNet-B0/B1** | İyi accuracy/size dengesi | MobileNet’e göre daha ağır | Backend veya güçlü cihazlarda |
| **Vision Transformer (ViT)** | Patch-based; büyük veri setlerinde güçlü | Veri ve hesaplama ihtiyacı yüksek | Backend’de, yeterli veri varsa |
| **Dermatology-specific** (örn. DenseNet/ResNet tabanlı dermatoloji modelleri) | Literatür ve benchmark’larla uyum | Veri seti lisansı ve etik | Leke/lezyon sınıflandırma |

- **Edge (Flutter/cihaz):** TFLite ile **MobileNetV3** veya **EfficientNet-Lite**; güneş yanığı evresi veya basit “risk skoru” çıktısı.
- **Backend (Python):** PyTorch/TensorFlow ile **ViT** veya dermatoloji fine-tune’lu **EfficientNet**; daha ağır sınıflandırma ve ileride leke segmentasyonu.

#### C) Veri Setleri

- **ISIC Archive** (International Skin Imaging Collaboration): Ben ve dermatolojik lezyon görüntüleri; lisans ve kullanım koşullarına uygun şekilde.
- **HAM10000 / Fitzpatrick17k:** Cilt tonu ve lezyon çeşitliliği; Fitzpatrick veya lezyon sınıflandırması için.
- **Güneş yanığı evresi:** Hazır public veri seti kısıtlı; klinik işbirliği veya synthetically augmented veri (kızarıklık, eritem benzeri) ile eğitim gerekebilir.
- **Not:** Tüm veri setleri kişisel veri ve tıbbi etik açısından gözden geçirilmeli; HIPAA/GDPR/KVKK ile uyum için anonimleştirme ve veri saklama politikası şart.

#### D) Entegrasyon Mimarisi

- **Seçenek 1 — Backend’de AI:** Mevcut `/analyze` veya yeni `/skin/assess` endpoint’i; görüntü + sticker sonucu alır, model çıktısı (sınıf, risk skoru) JSON’da döner. Avantaj: model güncellemesi merkezi; dezavantaj: ağ ve gecikme.
- **Seçenek 2 — Edge (TFLite):** Flutter’da `tflite_flutter`; model asset olarak paketlenir; kamera/sticker akışından sonra yerel çıktı. Avantaj: offline, hızlı; dezavantaj: model boyutu ve güncelleme (OTA veya uygulama güncellemesi).

**Pratik sıra önerisi:** (1) Backend’de MobileNetV3/EfficientNet ile güneş yanığı evresi veya leke sınıfı proof-of-concept, (2) Veri seti ve etik onayı sonrası fine-tuning, (3) Gecikme/offline ihtiyacı belirginleşirse TFLite ile edge’e taşıma.

---

## 4. Veri Güvenliği ve HIPAA / GDPR / KVKK Uyumluluğu

### 4.1 Mevcut Durum

- **Backend:** FastAPI; CORS (`allowed_origins`), isteğe bağlı **X-API-Key** (env’de boşsa kapalı); rate limit (10/dk analyze, 60/dk detect). Görüntü ve form verisi geçici olarak işleniyor; kalıcı depolama yok.
- **Flutter:** API ile iletişim HTTP/HTTPS (baseUrl build-time); **X-API-Key** client’ta gönderilmiyor (production’da API_KEY set edilirse 403 riski). Skin profile ve dose history **SharedPreferences**’ta düz metin JSON.

### 4.2 Eksikler ve Öneriler

#### A) İletişim ve Kimlik Doğrulama

- **HTTPS:** Production’da baseUrl mutlaka `https://` olmalı; sertifika doğrulaması yapılmalı (Dio’da varsayılan).
- **X-API-Key:** Backend’de key kullanılıyorsa, Flutter’da güvenli şekilde (örn. build-time env veya runtime’da güvenli depodan) alınıp `BaseOptions.headers['X-API-Key']` veya interceptor ile eklenmeli. Key kaynak koda sabit yazılmamalı.

#### B) Veri Saklama (Cihaz)

- **Sorun:** Skin profile (Fitzpatrick, SPF tercihi vb.) ve dose history SharedPreferences’ta **şifresiz**.
- **Öneri:** Hassas veriler için **flutter_secure_storage** (platform keychain/Keystore) kullanın; SharedPreferences’ı yalnızca hassas olmayan ayarlar (ör. locale) için bırakın. Skin profile ve dose history’yi secure storage’da tutun veya en azından PII sayılan alanları şifreleyin.

#### C) Backend’de Kişisel/Sağlık Verisi

- Görüntü ve form verisi şu an kalıcı tutulmuyor; bu, HIPAA/GDPR/KVKK açısından “minimal veri” ile uyumludur. İleride log veya analitik için saklama yapılırsa:
  - **Anonimleştirme:** Kimlik çıkarılamayacak şekilde (ör. kullanıcı ID’si olmadan, sadece agregat/istatistik).
  - **Erişim ve şifreleme:** At-rest encryption (örn. disk/DB şifreleme), erişim logları, rol tabanlı erişim.
  - **Saklama süresi:** Belirli süre sonra silme veya anonimleştirme politikası.

#### D) End-to-End Encryption (E2E)

- Şu an yok. Sağlık verisini “tedavi amaçlı” sayıp HIPAA kapsamında tutmak isterseniz, “covered entity” tanımı ve BAA gereklilikleriyle birlikte değerlendirilmeli. E2E şifreleme (istemci şifreler → sunucu sadece şifreli saklar) eklemek:
  - İstemcide (Flutter) şifreleme, sunucuda sadece şifreli blob saklama.
  - Sunucu tarafında “görüntü analizi” yapılacaksa, bu veri sunucuda açık olacağı için E2E tam anlamıyla uygulanamaz; bu durumda “transit + at-rest encryption + erişim kontrolü + BAA” zinciri öne çıkar.

#### E) Özet Tablo

| Konu | Mevcut | Öneri |
|------|--------|--------|
| HTTPS | baseUrl config’e bağlı | Production’da zorunlu https |
| API Key | Backend’de var; client’ta yok | Client’ta güvenli kaynaktan header ekle |
| Cihazda hassas veri | SharedPreferences düz metin | flutter_secure_storage (skin + dose) |
| Backend kalıcı veri | Yok | Kalıcı veri gelirse: at-rest encryption, anonimleştirme, saklama süresi |
| E2E şifreleme | Yok | Sunucuda analiz gerekiyorsa kısıtlı; analiz yoksa E2E değerlendirilebilir |
| HIPAA/GDPR/KVKK | Tam uyum yok | Veri işleme politikası, yasal danışmanlık, gerekirse BAA |

---

## 5. Offline Çalışma Kapasitesi (Edge Computing)

### 5.1 Mevcut Durum

- Tüm analiz backend’de: görüntü → API → colorimetry + MED → sonuç. Ağ yoksa sadece detect/analyze başarısız olur; offline mod yok.

### 5.2 Edge’e Taşıma Seçenekleri

#### A) Görüntü İşleme Mantığının Cihaza Alınması

- **Seçenek 1 — Flutter + native plugin (OpenCV C++):** OpenCV’yi iOS/Android’de C++ ile derleyip Flutter’dan plugin ile çağırmak. Aynı pipeline (decode → WB → mask → K-Means → L* → UV%) cihazda çalışır.
  - **Maliyet:** Geliştirme süresi (plugin yazımı, platform testi), bakım, OpenCV ve bağımlılıklarının build’e eklenmesi (~10–30 MB).
  - **Performans:** Modern telefonda 1–3 saniye civarı beklenir; GPU kullanılmadığı sürece backend’den daha yavaş olabilir. Pil tüketimi artar.

- **Seçenek 2 — TFLite ile renk/UV modeli:** K-Means yerine küçük bir NN: görüntü (veya ROI özeti) → UV% veya HEX benzeri çıktı. Eğitim: backend’deki colorimetry çıktılarıyla sentetik veya gerçek veri.
  - **Maliyet:** Eğitim verisi ve model geliştirme; TFLite runtime (Flutter’da `tflite_flutter`) zaten mevcut.
  - **Performans:** Çok küçük modelde 100–300 ms; doğruluk kalibrasyon eğrisi ve veri kalitesine bağlı.

#### B) Hibrit Yaklaşım (Önerilen)

- **Varsayılan:** Backend analizi (mevcut).
- **Offline fallback:** Ağ yoksa veya timeout olursa:
  - Basit bir **TFLite modeli** (ROI → UV% veya risk sınıfı) veya
  - **Dart/Flutter tarafında sadece ROI crop + basit ortalama renk → sabit kalibrasyon tablosu** (OpenCV olmadan, düşük doğruluk ama “tahmini değer” gösterilebilir).
- Böylece “her zaman bir sonuç” sunulur; doğruluk offline’da düşük olsa bile kullanıcıya belirtilir (“Tahmini değer; internet bağlantısında daha doğru ölçüm yapılır”).

#### C) Maliyet / Performans Özeti

| Yaklaşım | Geliştirme | Çalışma süresi (tahmini) | Doğruluk | Offline |
|----------|------------|---------------------------|----------|---------|
| Mevcut (backend) | — | Ağ + backend ~1–3 s | Yüksek | Hayır |
| OpenCV C++ plugin | Yüksek | 1–3 s | Backend’e yakın | Evet |
| TFLite (UV% / risk) | Orta | 0.1–0.5 s | Veriye bağlı | Evet |
| Hibrit (backend + TFLite fallback) | Orta | Online: mevcut; offline: ~0.2–0.5 s | Online yüksek, offline orta | Evet |

**Sonuç:** Tam edge pipeline (OpenCV C++) mümkün ancak maliyeti yüksek; pratik çözüm olarak **TFLite fallback** veya **basit client-side tahmin** ile offline deneyimi sunup, doğruluk beklentisini kullanıcıya net iletmek önerilir.

---

## 6. Genel Öneri Listesi (Öncelik Sırasıyla)

1. **Güvenlik:** Skin profile ve dose history için `flutter_secure_storage`; production’da HTTPS ve X-API-Key’in client’ta güvenli eklenmesi.
2. **Mimari:** Scan repository ve `currentDoseJm2`/`uvIndex` parametrelerini DI ve use case/repository üzerinden geçirme.
3. **Renk doğruluğu:** `ambient_lux` ile adaptive white balance; isteğe bağlı SoG; sticker’da referans patch varsa referans tabanlı kalibrasyon.
4. **Offline:** Hibrit strateji — backend + TFLite (veya basit client) fallback; offline sonuçlar “tahmini” olarak işaretlensin.
5. **AI dermatolog:** Backend’de MobileNetV3/EfficientNet ile PoC; uygun veri seti ve etik onay sonrası genişletme; ihtiyaç halinde TFLite ile edge.

---

**Rapor sonu.**
