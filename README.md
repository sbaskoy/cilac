# cilac_java

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


- Uygulama login view den başlar. Login olduktan sonra **home_view.dart** gider

- HOME
    - giriş yapanın yetkisine göre ekran değişir.
    - sol menü buradır
    - acıldıgınıda **uygulama_istatislik_view.dart** widget gösterir. bu widget istetisliğin baş ve bitiş tarihini alıp ona göre gösterir
    - eger tipi adminse uygulamaları grublar. **istatislik_state.dart** içerinde
    - herhangi bir uygulama tıklanınca **uygulama_detay_view.dart** sayfasına gider
- EKİP ATA
    - girilen şikayete ekip atanır. Sadece **admin** yetkisine sahip olanlar yaar
- EKİP KONUM BİLDİ
    - Üyenin ekibiinin konumu kayıt eder. 
- EKİP KONUM LİSTE
    - tüm ekiplerin konumunu haritada gösterir
- KAYNAK KAYIT
    - kaynak kayıt etme
    - kaynagın konumu almak için **GetLocation.dart** calışır ve geriye şeçile konumu döndürü
- SAVE LOCAL FİLE
    - tüm uygulamaları local veritabanına kayıt eder. İnternet yokken kullanabilmek için
    - veritabı oluşturma ve diger işlermler **localdb** klasörü içerindedir
- UYGULAMA YAP
    - bu sayfaya gelmeden önce **uygulama_sec.dart** çalışır. ve burada bir uygulama şeçilir
    - şeçilen uygulama modelinin property degerine göre alanlar oluşturur.
    - örnegin 
    ```dart
        class UygulamaTanim {
        int id;
        String uygulamaTanimi;
        String kaynakTurleri;
        String ilaclar;
        String ekipmanlar;
        String yontemler;
        String alanlar;
        String uygulamaAlanlari;
        String hedefZararli;
        int kayitSayisi;
        // burada modelde ilaclar kısmı null veya '' boş işe ilaclar alanı gösterirmez
        // eger dolu ise 1;5;6 gibi bir deger olur
        // bunlar bu uygulamada kullanılabilir olan ilaçların id sidir
        // bu ilaçlardan birkaçı uygulama yapılırken şeçilir
        // diger tüm propertyler için aynıdır
        }
    ``` 
- GEZİCİ UYGULAMA
    - Burada java kodu kullanılmıştır.
    - konum şeçildikten sonra **java** ile yazılan arkaplan servisi calışır. her konum değiştiginde konumu local veritabına kayıt eder
    - **dart** kısmında ise aynı localdb den bu tablo her saniyede okunup harita güncellenir
    - eger uygulama kapatılırsa arkaplan servisi çalışmaya devam edeceginden konum alınmaya devam eder
    - uygulama tekrar acılınca ilgidi tablo okunur ve uygulama kapalı iken alınmış konumlar alınıp kayıt edilir
    - **java servisi**  `Android/app/src/main/java/com/oryaz/cilac` yolu altındaki **MyService.java** dır. Grekli modeller oradadır
    

