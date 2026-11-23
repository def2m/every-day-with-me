# 🌌 365 Gün - Gökyüzü Günlüğü (Constellation Journal)

Her güne bir şekil ve anı bıraktığınız, yılınızı ışıltılı bir takımyıldızına dönüştüren kişisel Android günlüğünüz.

![365 Gün Uygulaması](https://img.shields.io/badge/Flutter-Android_APK-blue?logo=flutter)
![GitHub Actions CI/CD](https://img.shields.io/badge/GitHub_Actions-Otomatik_APK-success?logo=github-actions)

---

## ✨ Özellikler

1. **🌌 365 Noktalı Gökyüzü Haritası (1. Sekme):**
   - Yılın 365 gününü temsil eden estetik, derin uzay laciverti arka planda organik yıldız noktaları.
   - Herhangi bir güne not yazdığınızda, o gün için seçtiğiniz **özel şekil** (Yıldız ⭐, Hilal 🌙, Güneş ☀️, Kalp 💖, Çiçek 🌸, Elmas 💎, Ateş 🔥, Kelebek 🦋 vb.) o noktada parıldayarak belirir.
   - Seçtiğiniz ışıltı rengiyle (Altın, Kozmik Mor, Gök Mavisi, Gül Pembesi, Zümrüt vb.) canlanır.
   - Bugünün yıldızı üzerinde altın renkli nabız halkası (pulsing halo) bulunur.
   - Yakınlaştırma (zoom) ve kaydırma desteklidir.

2. **📖 Günlük & Anılar Akışı (2. Sekme):**
   - Günlere yazdığınız tüm notların kronolojik listesi.
   - Her kartta günün şekli, tarihi, gün numarası (örn: `#327 Gün`), başlığı ve hissi yer alır.
   - Notlar ve tarihler arasında anında arama çubuğu ve şekle göre filtreleme.

3. **⭐ Bugün Sekmesi (3. Sekme):**
   - Her gün girdiğinizde doğrudan bugününüzü aydınlatabileceğiniz hızlı kayıt ekranı.
   - Yazma serisi (Streak) sayacı (örn: *5 Günlük Seri*).
   - Kalan gün sayacı.

4. **⚙️ Güvenlik, Ayarlar ve Yedekleme:**
   - Tamamen **çevrimdışı (offline)** çalışır, verileriniz asla cihazınızın dışına çıkmaz.
   - Tek dokunuşla tüm anılarınızı JSON olarak yedekleyebilir veya başka telefona aktarabilirsiniz.

---

## 📱 Telefonunuza APK'yı İndirme (GitHub Actions ile)

Bu projede `.github/workflows/build-apk.yml` dosyası hazır olarak tanımlanmıştır. Kodları GitHub'a gönderdiğiniz anda GitHub'ın sunucuları telefonunuz için **APK** dosyasını otomatik olarak oluşturur!

### Adım 1: GitHub Deposu Açın
1. [github.com](https://github.com) adresine gidin ve oturum açın.
2. Sağ üstten **"+"** simgesine tıklayıp **"New repository"** seçin.
3. Depo adı olarak `gun365` yazın, **Public** seçin ve **Create repository** butonuna basın.

### Adım 2: Kodları Gönderin
Masaüstündeki `uygulama` klasöründe yer alan **`push_to_github.bat`** dosyasına çift tıklayın ve GitHub deponuzun linkini yapıştırın.

*(Veya terminalden şu komutları çalıştırabilirsiniz):*
```bash
git init
git branch -M main
git add .
git commit -m "365 Gün Uygulaması"
git remote add origin https://github.com/KULLANICI_ADINIZ/gun365.git
git push -u origin main
```

### Adım 3: APK Dosyasını Telefonunuza İndirin
1. Kodları GitHub'a yükledikten sonra, GitHub sayfanızdaki **"Actions"** sekmesine gidin.
2. Yaklaşık 2-3 dakika içinde **"Android APK Oluştur ve Yayınla"** işlemi yeşil tik ✅ olacaktır.
3. Deponuzun ana sayfasında sağ tarafta bulunan **"Releases"** bölümüne tıklayın (veya Actions sayfasındaki Artifacts kısmına bakın).
4. **`gun365-release.apk`** dosyasına telefonunuzun tarayıcısından tıklayarak indirin ve telefonunuza kurun!

---

## 💻 Bilgisayarda Hemen Denemek İçin (Web Önizleme)

Uygulamanın masaüstü tarayıcınızda birebir çalışan interaktif bir önizlemesi hazırlanmıştır:
- Klasörün içindeki **`uygulama_onizleme.html`** dosyasına çift tıklayın.
- Açılan pencerede noktaları tıklayabilir, not yazabilir, şekil ve renk seçebilir, sekmeler arasında gezinebilirsiniz!
