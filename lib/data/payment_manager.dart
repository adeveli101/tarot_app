// payment_manager.dart

// ignore_for_file: invalid_use_of_visible_for_testing_member, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
// shared_preferences artık doğrudan burada kullanılmıyor
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/generated/l10n.dart'; // Yerelleştirme için
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';
import 'package:tarot_fal/data/user_data_manager.dart'; // UserDataManager import edildi

// ---- PaymentManager Sınıfı ----
class PaymentManager {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final VoidCallback? onPurchaseSuccess; // Satın alma başarılı olduğunda çağrılacak callback
  final UserDataManager _userDataManager = UserDataManager(); // UserDataManager örneği

  // Satın alınabilir ürünlerin ID'leri ve karşılık gelen kredi miktarları
  final Map<String, double> _creditValues = {
    '25_tokens': 25.0,
    '50_tokens': 50.0,
    '150_tokens': 150.0,
    '300_tokens': 300.0,
    '500_tokens': 500.0,
    '1000_tokens': 1000.0,
    // 'premium_subscription': 0.0,
  };

  // --- Yerel Kupon Listesi ---
  // validCoupons map'i BURADAN SİLİNDİ. Tüm kupon mantığı TarotBloc'ta.

  PaymentManager({this.onPurchaseSuccess});

  /// In-App Purchase servisini başlatır ve satın alma akışını dinler.
  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('Ödeme Yöneticisi: In-App Purchase servisi kullanılamıyor.');
      return;
    }
    // Mevcut aboneliği iptal et (varsa)
    await _subscription?.cancel();
    // Satın alma akışını dinle
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates, // Gelen güncellemeleri işle
      onDone: () {
        debugPrint('Ödeme Yöneticisi: Satın alma akışı tamamlandı.');
        _subscription?.cancel(); // Akış bitince aboneliği iptal et
      },
      onError: (error) {
        debugPrint('Ödeme Yöneticisi: Satın alma akışı hatası: $error');
        // Hata durumunda da aboneliği iptal etmek iyi olabilir
        _subscription?.cancel();
      },
      cancelOnError: true, // Hata durumunda otomatik iptal et
    );
    debugPrint('Ödeme Yöneticisi: Başlatıldı ve satın alma akışı dinleniyor.');
  }

  /// Mağazadan satın alınabilir ürün detaylarını yükler.
  Future<List<ProductDetails>> loadProducts() async {
    // Tanımlı ürün ID'lerini al
    final Set<String> productIds = _creditValues.keys.toSet();
    // TODO: Varsa premium ürün ID'sini de ekleyin
    // productIds.add('premium_subscription');

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('Ödeme Yöneticisi: Ürünler yüklenemedi - servis kullanılamıyor.');
        return [];
      }
      // Ürün detaylarını sorgula
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

      // Hataları logla
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Ödeme Yöneticisi: Bulunamayan ürün ID\'leri: ${response.notFoundIDs}');
      }
      if (response.error != null) {
        debugPrint('Ödeme Yöneticisi: Ürün sorgulama hatası: ${response.error!.message}');
        return []; // Hata durumunda boş liste dön
      }

      // Ürünleri fiyata göre sırala (isteğe bağlı)
      response.productDetails.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

      debugPrint('Ödeme Yöneticisi: ${response.productDetails.length} ürün yüklendi.');
      return response.productDetails;
    } catch (e) {
      debugPrint('Ödeme Yöneticisi: Ürün yükleme sırasında istisna oluştu: $e');
      return [];
    }
  }

  /// Seçilen ürünü satın alma işlemini başlatır.
  Future<bool> buyProduct(ProductDetails product, BuildContext context) async {
    try {
      final loc = S.of(context); // Yerelleştirme için
      // Kullanıcıya satın alma onayı göster
      final bool confirmed = await _showConfirmationDialog(context, product);
      if (!confirmed) {
        debugPrint('Ödeme Yöneticisi: Kullanıcı satın almayı iptal etti.');
        return false; // Kullanıcı iptal etti
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      bool purchaseInitiated;

      // Ürün tipine göre doğru satın alma metodu çağır
      // TODO: 'premium_subscription' ID'sini doğru şekilde kontrol edin
      if (product.id == 'premium_subscription') { // Örnek premium ID
        purchaseInitiated = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Diğer tüm ürünler tüketilebilir (kredi paketleri)
        purchaseInitiated = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
      debugPrint('Ödeme Yöneticisi: Satın alma başlatıldı (${product.id}): $purchaseInitiated');
      return purchaseInitiated;

    } catch (e) {
      debugPrint('Ödeme Yöneticisi: Satın alma başlatma hatası (${product.id}): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.errorMessage('Satın alma başlatılamadı: $e'))),
      );
      return false;
    }
  }

  /// Satın alma öncesi kullanıcıya onay dialogu gösterir.
  Future<bool> _showConfirmationDialog(BuildContext context, ProductDetails product) async {
    final loc = S.of(context); // Yerelleştirme için
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Dışarı tıklayarak kapatmayı engelle
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple[900]?.withOpacity(0.95), // Arka plan rengi
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Kenar yuvarlatma
        title: Row(
          children: [
            const Icon(Icons.shopping_cart_checkout, color: Colors.purpleAccent), // İkon
            const SizedBox(width: 10),
            Text(
              loc!.confirmPurchase, // Yerelleştirilmiş başlık
              style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        content: Text(
          // Yerelleştirilmiş içerik (ürün adı ve fiyatı ile)
          loc.purchaseConfirmation(product.title, product.price),
          style: GoogleFonts.cabin(color: Colors.white70, fontSize: 12), // İçerik fontu
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly, // Butonları hizala
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70, // Buton rengi
            ),
            onPressed: () => Navigator.pop(context, false), // İptal
            child: Text(loc.cancel, style: GoogleFonts.cinzel(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton( // Onay butonu daha belirgin olsun
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent, // Buton rengi
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true), // Onay
            child: Text(loc.confirm, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false; // Dialog kapatılırsa (örneğin geri tuşu ile) false dön
  }

  /// Girilen kupon kodunun daha önce kullanılıp kullanılmadığını kontrol eder.
  ///
  /// Returns: `true` eğer kupon DAHA ÖNCE kullanılmışsa, aksi takdirde `false`.
  /// Kuponun geçerliliğini veya token eklemeyi KONTROL ETMEZ. Bu iş TarotBloc'tadır.
  Future<bool> redeemCoupon(String code) async {
    // UserDataManager üzerinden kontrol yap
    final bool alreadyUsed = await _userDataManager.isCouponUsed(code);
    debugPrint("Ödeme Yöneticisi: Kupon '$code' kontrol edildi. Zaten kullanılmış mı? $alreadyUsed");
    return alreadyUsed;
  }

  /// Satın alma akışından gelen güncellemeleri işler.
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    // NavigatorKey üzerinden global context'i al
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint("Ödeme Yöneticisi: _handlePurchaseUpdates - Global context bulunamadı.");
      return;
    }
    // Context üzerinden TarotBloc'u bul
    final tarotBloc = BlocProvider.of<TarotBloc>(context);

    for (var purchase in purchases) {
      bool purchaseProcessed = false; // Satın almanın işlenip işlenmediğini takip et

      // --- Başarılı Satın Alma veya Geri Yükleme Durumu ---
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        debugPrint('Ödeme Yöneticisi: İşleniyor ${purchase.status == PurchaseStatus.restored ? "geri yüklenen" : "yeni"} satın alma: ${purchase.productID}');

        bool creditsOrPremiumUpdated = false;

        // 1. Kredi Ekleme (Tüketilebilir Ürünler)
        if (_creditValues.containsKey(purchase.productID)) {
          final creditsToAdd = _creditValues[purchase.productID] ?? 0.0;
          if (creditsToAdd > 0) {
            final currentTokens = await _userDataManager.getTokens();
            await _userDataManager.saveTokens(currentTokens + creditsToAdd);
            creditsOrPremiumUpdated = true;
            debugPrint('Ödeme Yöneticisi: ${purchase.productID} için $creditsToAdd kredi eklendi. Yeni bakiye: ${currentTokens + creditsToAdd}');
            // Başarı mesajı göster
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context)!.creditsAdded(creditsToAdd.toStringAsFixed(0)))),
            );
          }
        }
        // 2. Premium Abonelik (Tüketilemez Ürün)
        else if (purchase.productID == 'premium_subscription') { // Örnek ID
          await _userDataManager.savePremiumStatus(true);
          creditsOrPremiumUpdated = true;
          debugPrint('Ödeme Yöneticisi: Premium abonelik aktif edildi.');
          // Başarı mesajı göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context)!.premiumActivated)),
          );
        }

        // 3. Satın Almayı Tamamla (Mağazaya bildir)
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
          debugPrint('Ödeme Yöneticisi: Satın alma mağaza tarafında tamamlandı: ${purchase.productID}');
        } else {
          debugPrint('Ödeme Yöneticisi: Satın alma zaten tamamlanmış olarak işaretlenmişti: ${purchase.productID}');
        }

        // 4. Gerekirse UI'ı Güncellemek İçin BLoC'a Event Gönder
        if (creditsOrPremiumUpdated) {
          // Bloc'un kullanıcı verilerini yeniden yüklemesini tetikle
          // tarotBloc.add(LoadUserDataEvent()); // Kendi event isminizi kullanın
          // VEYA basitçe mevcut state'i kopyalayarak emit et (ama bu en iyi pratik değil)
          // Şimdilik sadece loglama ve SnackBar ile devam edelim.
          onPurchaseSuccess?.call(); // Callback'i çağır
        }

        purchaseProcessed = true; // Bu satın alma işlendi
      }
      // --- Hata Durumu ---
      else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Ödeme Yöneticisi: Satın alma hatası (${purchase.productID}): ${purchase.error?.code} - ${purchase.error?.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.purchaseFailed(purchase.error?.message ?? 'Bilinmeyen Hata'))), // Yerelleştirme
        );
        // Hatalı da olsa satın almayı tamamla (mağazanın takılı kalmaması için)
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
        purchaseProcessed = true; // Hata durumu da işlendi
      }
      // --- Beklemede Durumu ---
      else if (purchase.status == PurchaseStatus.pending) {
        debugPrint('Ödeme Yöneticisi: Satın alma beklemede: ${purchase.productID}');
        // Kullanıcıya bilgi verilebilir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.purchasePending)), // Yerelleştirme
        );
        // Beklemede durumu işlenmiş sayılmaz, akış devam eder.
      }
      // --- İptal Durumu ---
      else if (purchase.status == PurchaseStatus.canceled) {
        debugPrint('Ödeme Yöneticisi: Satın alma iptal edildi: ${purchase.productID}');
        // İptal edilen satın almayı tamamla
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
        purchaseProcessed = true; // İptal durumu da işlendi
      }
      // --- Diğer Durumlar ---
      else {
        debugPrint('Ödeme Yöneticisi: Bilinmeyen satın alma durumu (${purchase.productID}): ${purchase.status}');
        // Bilinmeyen durumdaki satın almayı da tamamlamak iyi olabilir
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
        purchaseProcessed = true; // Bilinmeyen durum da işlendi
      }

      // Eğer satın alma işlendiyse (başarılı, hatalı, iptal) logla
      if (purchaseProcessed) {
        debugPrint('Ödeme Yöneticisi: Satın alma detayı işlendi: ID=${purchase.productID}, Status=${purchase.status}');
      }
    }
  }

  /// PaymentManager'ı temizler ve stream aboneliğini iptal eder.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('Ödeme Yöneticisi: Dispose edildi.');
  }

  /// Satın alma seçeneklerini içeren bir dialog gösterir.
  static Future<void> showPaymentDialog(
      BuildContext context, {
        double requiredTokens = 0.0, // Gerekli token (bilgi amaçlı)
        VoidCallback? onSuccess, // Başarılı satın alma sonrası callback
      }) {
    // Yeni bir PaymentManager örneği oluştur
    final paymentManager = PaymentManager(onPurchaseSuccess: onSuccess);
    // Başlat ve stream'i dinle
    paymentManager.initialize();

    return showDialog<void>(
      context: context,
      builder: (_) =>
      // BlocProvider.value kullanarak mevcut TarotBloc'u dialoga aktar
      BlocProvider.value(
          value: BlocProvider.of<TarotBloc>(context),
          child: PaymentDialog(
              manager: paymentManager, requiredTokens: requiredTokens)),
      barrierDismissible: false, // Dışarı tıklayarak kapatmayı engelle
    ).then((_) {
      // Dialog kapatıldığında PaymentManager'ı dispose et
      paymentManager.dispose();
    });
  }
}

// ---- PaymentDialog Widget ----
class PaymentDialog extends StatefulWidget {
  final PaymentManager manager;
  final double requiredTokens;

  const PaymentDialog({
    super.key,
    required this.manager,
    required this.requiredTokens,
  });

  @override
  PaymentDialogState createState() => PaymentDialogState();
}

class PaymentDialogState extends State<PaymentDialog> {
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Ürünleri yükler ve state'i günceller.
  Future<void> _loadProducts() async {
    // Başlangıçta state'i yükleniyor olarak ayarla
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    final products = await widget.manager.loadProducts();
    // Widget hala bağlıysa state'i güncelle
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
        // Ürün yüklenemezse hata mesajı ayarla
        if (products.isEmpty) {
          _errorMessage = S.of(context)!.failedToLoadProducts; // Yerelleştirme
          debugPrint("PaymentDialog: Ürünler yüklenemedi veya boş liste döndü.");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context); // Yerelleştirme için
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: Colors.transparent, // Şeffaf arka plan
      contentPadding: EdgeInsets.zero, // İçeriğin kendi padding'i olacak
      // Dialog içeriğini oluşturan Container
      content: Container(
        width: screenSize.width * 0.9, // Ekran genişliğinin %90'ı
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.8), // Maksimum yükseklik
        decoration: BoxDecoration(
          gradient: LinearGradient( // Arka plan gradient'i
            colors: [Colors.deepPurple[900]!, Colors.black.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20), // Yuvarlak kenarlar
          border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)), // İnce çerçeve
          boxShadow: [ // Gölge efekti
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column( // Ana düzen dikey olacak
          mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
          children: [
            // Başlık Bölümü
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
              child: Text(
                loc!.purchaseCredits, // Yerelleştirilmiş başlık
                style: GoogleFonts.cinzelDecorative( // Özel font
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Gerekli Kredi Bilgisi (varsa)
            if (widget.requiredTokens > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 20, right: 20),
                child: Text(
                  loc.insufficientCreditsMessage(widget.requiredTokens.toStringAsFixed(0)), // Yerelleştirme
                  style: GoogleFonts.cabin(color: Colors.orangeAccent[100], fontSize: 14), // Font ve renk
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 10), // Boşluk
            Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 20), // Ayırıcı çizgi

            // Ürün Listesi veya Yükleme/Hata Göstergesi
            Expanded( // Listenin scroll edilebilir olması için
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                  : _errorMessage != null
                  ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.cabin(color: Colors.redAccent, fontSize: 15), // Hata fontu
                      textAlign: TextAlign.center,
                    ),
                  ))
                  : _products.isEmpty // Ürünler yüklendi ama boşsa
                  ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      loc.noProductsAvailable, // Yerelleştirme
                      style: GoogleFonts.cabin(color: Colors.white70, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ))
                  : ListView.builder( // Ürün listesi
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildPurchaseOption(_products[index]); // Her ürün için seçenek oluştur
                },
              ),
            ),

            Divider(color: Colors.purpleAccent.withOpacity(0.2), height: 20), // Ayırıcı çizgi

            // Kupon Kullan Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: TapAnimatedScale(
                onTap: () => _showCouponSheet(context), // Kupon sheet'ini aç
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade600, Colors.cyan.shade800], // Farklı renk
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row( // İkon ve Metin
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard, color: Colors.white.withOpacity(0.9), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        loc.redeem, // Yerelleştirilmiş metin
                        style: GoogleFonts.cinzel( // Font
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // İptal Butonu
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0, top: 5.0),
              child: TextButton( // Basit TextButton
                onPressed: () => Navigator.pop(context), // Dialogu kapat
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  loc.cancel, // Yerelleştirilmiş metin
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    color: Colors.white70, // Daha soluk renk
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Kupon giriş ekranını (Modal Bottom Sheet) gösterir.
  void _showCouponSheet(BuildContext context) {
    // Dialog içindeki context yerine ana Scaffold context'ini kullanmak daha iyi olabilir.
    // Ancak bu yapı çalışıyorsa şimdilik kalabilir.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavye için önemli
      backgroundColor: Colors.transparent, // Arka planı şeffaf yap
      builder: (sheetContext) =>
      // BlocProvider.value ile mevcut Bloc'u aktar
      BlocProvider.value(
          value: BlocProvider.of<TarotBloc>(context), // Dialog context'inden Bloc'u al
          child: CouponSheet(manager: widget.manager) // PaymentManager'ı da aktar
      ),
    );
  }

  /// Tek bir satın alma seçeneği widget'ını oluşturur.
  /// Hem para birimi sembolünü hem de kodunu gösterir.
  Widget _buildPurchaseOption(ProductDetails product) {
    final loc = S.of(context); // Yerelleştirme için
    final credits = widget.manager._creditValues[product.id] ?? 0.0;

    // --- YENİ: Fiyatı MANUEL OLARAK formatla (Sayı + Sembol + Kod) ---
    String formattedPrice;
    try {
      // 1. Adım: Sadece sayıyı Türkçe locale'e göre formatla (örn: 23,99)
      final numberFormatter = NumberFormat.decimalPattern('tr_TR');
      final double priceValue = product.rawPrice;
      final String numberPart = numberFormatter.format(priceValue);

      // 2. Adım: Para birimi sembolünü al (örn: "₺")
      // ProductDetails'dan gelen sembolü kullan, yoksa boş bırak
      final String symbolPart = product.currencySymbol.isNotEmpty
          ? product.currencySymbol
          : ''; // Sembol yoksa boş string

      // 3. Adım: Para birimi kodunu al (örn: "TRY")
      final String currencyCodePart = product.currencyCode;

      // 4. Adım: Sayı, boşluk, sembol, boşluk, parantez içinde kodu birleştir
      // Örnek format: "23,99 ₺ (TRY)"
      // Eğer sembol yoksa sadece sayı ve kod gösterilir: "10.50 USD"
      formattedPrice = '$numberPart ${symbolPart.isNotEmpty ? '$symbolPart ' : ''}($currencyCodePart)';
      // formattedPrice = '$numberPart $symbolPart ($currencyCodePart)'; // Sembolün varlığını garanti ediyorsanız bu daha basit

    } catch (e) {
      // Hata durumunda orijinal fiyatı göster
      if (kDebugMode) {
        print("Fiyat MANUEL formatlama hatası (symbol+code): $e");
      }
      // Hata durumunda bile en azından orijinal fiyat string'ini göster
      formattedPrice = product.price;
    }
    // --- MANUEL FORMATLAMA SONU ---

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TapAnimatedScale(
        onTap: () async {
          if (!mounted) return;
          final success = await widget.manager.buyProduct(product, context);
          if (success && mounted) {
            if (kDebugMode) { print("Satın alma işlemi başlatıldı: ${product.id}");}
          } else if (!success && mounted) {
            if (kDebugMode) { print("Satın alma işlemi başlatılamadı veya iptal edildi: ${product.id}"); }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade700.withOpacity(0.8),
                Colors.deepPurple.shade800.withOpacity(0.9),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  // Loc nesnesinin null olmadığından emin olalım
                  '${credits.toStringAsFixed(0)} ${loc?.mysticalTokens ?? 'Mystical Tokens'}',
                  style: GoogleFonts.cabin(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              // Fiyat Gösterimi (Sayı + Sembol + Kod)
              Text(
                formattedPrice, // Örn: "23,99 ₺ (TRY)"
                style: GoogleFonts.cabin( // Veya daha okunabilir bir font? cabin deneyebilirsiniz.
                  fontSize: 14, // Boyutu biraz ayarlayabiliriz
                  color: Colors.yellowAccent.shade100,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right, // Sağa yasla
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- CouponSheet Widget ----
class CouponSheet extends StatefulWidget {
  final PaymentManager manager; // PaymentManager gerekli

  const CouponSheet({super.key, required this.manager});

  @override
  CouponSheetState createState() => CouponSheetState();
}

class CouponSheetState extends State<CouponSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _couponController = TextEditingController();
  late AnimationController _sheetController; // Animasyon için (isteğe bağlı)
  bool _isProcessing = false; // İşlem yapılıyor mu?
  String? _resultMessage; // Sonuç mesajı (başarı/hata)
  bool? _couponSuccess; // Sonuç durumu (true: başarı, false: hata)

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward(); // Sheet açılırken animasyon
  }

  @override
  void dispose() {
    _couponController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context); // Yerelleştirme

    // Bloc'tan gelen state değişikliklerini dinle
    return BlocListener<TarotBloc, TarotState>(
      listener: (context, state) {
        // Sadece kupon işlemi (_isProcessing == true) sırasındaki state'leri dinle
        if (_isProcessing) {
          if (state is CouponRedeemed) {
            // Başarılı: İşlemi bitir, başarı durumunu ayarla, mesajı göster
            setState(() {
              _isProcessing = false;
              _couponSuccess = true;
              _resultMessage = loc.couponRedeemed(state.message); // BLoC mesajı
            });
            // Başarıdan sonra sheet'i kapat
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.pop(context);
            });
          } else if (state is CouponInvalid) {
            // Geçersiz/Hata: İşlemi bitir, hata durumunu ayarla, mesajı göster
            setState(() {
              _isProcessing = false;
              _couponSuccess = false;
              _resultMessage = loc.couponInvalid(state.message); // BLoC mesajı
            });
          } else if (state is TarotError) {
            // Genel Hata: İşlemi bitir, hata durumunu ayarla, mesajı göster
            setState(() {
              _isProcessing = false;
              _couponSuccess = false;
              _resultMessage = loc.errorMessage(state.message); // BLoC mesajı
            });
          }
          // Not: TarotLoading state'i zaten _isProcessing ile yönetiliyor.
        }
      },
      // İçeriği oluşturan Container
      child: Container(
        // Padding: Klavye göründüğünde içeriğin yukarı kayması için
        padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20 // Klavye yüksekliği + ekstra boşluk
        ),
        // Stil
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple[900]!.withOpacity(0.95), // Biraz daha opak
                Colors.black.withOpacity(0.98), // Biraz daha opak
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), // Sadece üst kenarlar yuvarlak
            boxShadow: [ // Gölge
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, -5), // Yukarı doğru gölge
              ),
            ],
            border: Border(top: BorderSide(color: Colors.purpleAccent.withOpacity(0.3), width: 1.5)) // Üst çerçeve
        ),
        // Ana İçerik
        child: Stack( // Kapatma butonu için Stack
          children: [
            Column( // Dikey düzen
              mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
              crossAxisAlignment: CrossAxisAlignment.stretch, // Yatayda genişle
              children: [
                // Başlık
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 24, color: Colors.purpleAccent[100]),
                    const SizedBox(width: 12),
                    Text(
                      loc!.redeem, // Yerelleştirme
                      style: GoogleFonts.cinzelDecorative(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.confirmation_number_outlined, size: 24, color: Colors.purpleAccent[100]),
                  ],
                ),
                const SizedBox(height: 25),

                // Kupon Kodu Giriş Alanı
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[800]?.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _couponController,
                    style: GoogleFonts.cabin(color: Colors.white, fontSize: 15), // Giriş metni stili
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: loc.couponHint, // İpucu metni
                      hintStyle: GoogleFonts.cabin(color: Colors.white54, fontSize: 15),
                      border: InputBorder.none, // Çerçeveyi kaldır
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      counterText: "", // Karakter sayacını gizle
                      prefixIcon: Icon(Icons.vpn_key_outlined, color: Colors.purpleAccent[100], size: 20), // Başlangıç ikonu
                    ),
                    enabled: !_isProcessing, // İşlem sırasında devre dışı bırak
                    textCapitalization: TextCapitalization.characters, // Otomatik büyük harf
                    maxLength: 30, // Maksimum uzunluk
                    textInputAction: TextInputAction.done, // Klavye action butonu
                    onSubmitted: (_) => _redeemCoupon(context), // Enter'a basınca gönder
                  ),
                ),
                const SizedBox(height: 25),

                // Kupon Kullan Butonu
                TapAnimatedScale(

                  onTap: _isProcessing ? () {} : () => _redeemCoupon(context), // Hata: null yerine () {} kullanıldı
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isProcessing
                            ? [Colors.grey[700]!, Colors.grey[800]!] // Pasifken gri
                            : [Colors.purpleAccent.shade100, Colors.purpleAccent.shade400], // Aktifken canlı renkler
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: !_isProcessing // Sadece aktifken gölge
                          ? [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : null,
                    ),
                    child: Center(
                      child: _isProcessing // İşlem varsa progress indicator
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                          : Text( // İşlem yoksa metin
                        loc.redeem,
                        style: GoogleFonts.cinzel(
                          fontSize: 17,
                          color: Colors.black87, // Koyu renk metin
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),

                // Sonuç Mesajı Alanı
                // AnimatedOpacity ile yumuşak geçiş
                AnimatedOpacity(
                  opacity: _resultMessage != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _resultMessage == null ? const SizedBox(height: 16) : Padding( // Mesaj yoksa sadece boşluk
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: (_couponSuccess == true ? Colors.green : Colors.red).withOpacity(0.15), // Arka plan rengi
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (_couponSuccess == true ? Colors.green : Colors.red).withOpacity(0.4), // Çerçeve rengi
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon( // Duruma göre ikon
                            _couponSuccess == true ? Icons.check_circle_outline : Icons.highlight_off,
                            color: _couponSuccess == true ? Colors.greenAccent.shade100 : Colors.redAccent.shade100, // İkon rengi
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded( // Mesajın taşmasını engelle
                            child: Text(
                              _resultMessage ?? '', // Boş değilse mesajı göster
                              style: GoogleFonts.cabin( // Mesaj fontu
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Klavye göründüğünde en alta ekstra boşluk
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 0),
              ],
            ),
            // Kapatma Butonu
            Positioned(
              top: -8, // Konumunu ayarla
              right: -8,
              child: _buildCloseButton(context),
            ),
          ],
        ),
      ),
    );
  }

  void _redeemCoupon(BuildContext context) async {
    if (_isProcessing) return;
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    final code = _couponController.text.trim();
    final S? loc = S.of(context);

    if (code.isEmpty) {
      setState(() {
        _isProcessing = false;
        _couponSuccess = false;
        // Yerelleştirme: 'couponCannotBeEmpty' getter'ı S sınıfında tanımlı olmalı.
        _resultMessage = loc!.couponCannotBeEmpty;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _couponSuccess = null;
      _resultMessage = null;
    });

    try {
      // Önce kuponun daha önce kullanılıp kullanılmadığını kontrol et
      final bool alreadyUsed = await widget.manager.redeemCoupon(code);

      if (!mounted) return; // Widget dispose edilmiş olabilir

      if (alreadyUsed) {
        // Zaten kullanılmışsa hata göster
        setState(() {
          _isProcessing = false;
          _couponSuccess = false;
          _resultMessage = loc!.couponAlreadyUsed;
        });
      } else {
        // Kullanılmamışsa, BLoC'a gönder
        context.read<TarotBloc>().add(RedeemCoupon(code));
        // Sonuç BlocListener tarafından işlenecek, _isProcessing true kalacak
      }
    } catch (e) {
      debugPrint("Kupon ön kontrol hatası: $e");
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _couponSuccess = false;
          _resultMessage = loc!.errorMessage("Bir hata oluştu."); // Genel hata
        });
      }
    }
  }

  /// Kapatma butonu widget'ını oluşturur.
  Widget _buildCloseButton(BuildContext context) {
    return Material( // Tıklama efekti için Material
      color: Colors.transparent,
      child: InkWell( // Tıklanabilir alan
        borderRadius: BorderRadius.circular(15), // Yuvarlak tıklama alanı
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.4),
          ),
          child: const Icon(Icons.close, color: Colors.white70, size: 18), // İkon boyutu
        ),
      ),
    );
  }
}

// ---- Global Navigator Key ----
// Uygulamanızın ana MaterialApp widget'ına atanmalıdır.
// Arka plandaki işlemlerden (örn: _handlePurchaseUpdates) context erişimi sağlar.
// main.dart dosyanızda tanımlayabilirsiniz:
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// MaterialApp( navigatorKey: navigatorKey, ... );
// Başka bir dosyada tanımlıysa oradan import edin.
// Şimdilik burada tanımlı bırakalım:
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();