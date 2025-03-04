// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';

class PaymentManager {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final VoidCallback? onPurchaseSuccess;
  final Map<String, double> _creditValues = {
    '10_credits': 10.0,
    '50_credits': 50.0,
    '100_credits': 100.0,
  };

  PaymentManager({this.onPurchaseSuccess});

  Future<void> initialize() async {
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) => debugPrint('Payment stream error: $error'),
      onDone: () => debugPrint('Payment stream completed'),
    );
  }

  Future<List<ProductDetails>> loadProducts() async {
    const productIds = ['10_credits', '50_credits', '100_credits', 'premium_subscription'];
    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('In-app purchase service unavailable');
        return [];
      }
      final response = await _inAppPurchase.queryProductDetails(productIds.toSet());
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }
      if (response.error != null) {
        debugPrint('Product query error: ${response.error!.message}');
        return [];
      }
      return response.productDetails;
    } catch (e) {
      debugPrint('Failed to load products: $e');
      return [];
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      if (product.id.contains('premium')) {
        return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        return await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  Future<bool> redeemCoupon(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final redeemedCoupons = prefs.getStringList('redeemed_coupons') ?? [];
    if (redeemedCoupons.contains(code)) return false;

    const validCoupons = ['WELCOME10', 'TAROT50'];
    if (!validCoupons.contains(code)) return false;

    final tarotBloc = _findTarotBloc();
    if (tarotBloc == null) return false;

    double credits = code == 'WELCOME10' ? 10.0 : 50.0;
    final currentTokens = await tarotBloc.userDataManager.getTokens();
    await tarotBloc.userDataManager.saveTokens(currentTokens + credits);
    tarotBloc.emit(TarotInitial(
      isPremium: tarotBloc.state.isPremium,
      userTokens: currentTokens + credits,
      dailyFreeFalCount: tarotBloc.state.dailyFreeFalCount,
    ));

    redeemedCoupons.add(code);
    await prefs.setStringList('redeemed_coupons', redeemedCoupons);
    return true;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    final tarotBloc = _findTarotBloc();
    for (var purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          double credits = _creditValues[purchase.productID] ?? 0.0;
          if (credits > 0 && tarotBloc != null) {
            final currentTokens = await tarotBloc.userDataManager.getTokens();
            await tarotBloc.userDataManager.saveTokens(currentTokens + credits);
            tarotBloc.emit(TarotInitial(
              isPremium: tarotBloc.state.isPremium,
              userTokens: currentTokens + credits,
              dailyFreeFalCount: tarotBloc.state.dailyFreeFalCount,
            ));
          } else if (purchase.productID == 'premium_subscription' && tarotBloc != null) {
            await tarotBloc.userDataManager.savePremiumStatus(true);
            tarotBloc.emit(TarotInitial(
              isPremium: true,
              userTokens: tarotBloc.state.userTokens,
              dailyFreeFalCount: tarotBloc.state.dailyFreeFalCount,
            ));
          }
          await _inAppPurchase.completePurchase(purchase);
          debugPrint('Purchase completed: ${purchase.productID}');
          onPurchaseSuccess?.call();
          break;
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchase.error?.message}');
          break;
        case PurchaseStatus.pending:
          debugPrint('Purchase pending: ${purchase.productID}');
          break;
        default:
          debugPrint('Unhandled purchase status: ${purchase.status}');
          break;
      }
    }
  }

  TarotBloc? _findTarotBloc() {
    try {
      return BlocProvider.of<TarotBloc>(navigatorKey.currentContext!);
    } catch (e) {
      debugPrint('TarotBloc not found in context: $e');
      return null;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('PaymentManager disposed');
  }

  static Future<void> showPaymentDialog(BuildContext context, {double requiredTokens = 0.0, VoidCallback? onSuccess}) {
    final paymentManager = PaymentManager(onPurchaseSuccess: onSuccess);
    paymentManager.initialize();
    return showDialog<void>(
      context: context,
      builder: (_) => PaymentDialog(manager: paymentManager, requiredTokens: requiredTokens),
      barrierDismissible: false,
    ).then((_) => paymentManager.dispose());
  }
}

class PaymentDialog extends StatefulWidget {
  final PaymentManager manager;
  final double requiredTokens;

  const PaymentDialog({super.key, required this.manager, required this.requiredTokens});

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

  Future<void> _loadProducts() async {
    final products = await widget.manager.loadProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
        _errorMessage = products.isEmpty ? S.of(context)!.errorMessage('Failed to load products') : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: screenSize.width * 0.85,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.7,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[900]!, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  loc!.purchaseCredits,
                  style: GoogleFonts.cinzel(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.insufficientCreditsMessage(widget.requiredTokens),
                  style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.purple))
                else if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.cinzel(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ..._products.map((product) => _buildPurchaseOption(product)),
                      const SizedBox(height: 16),
                      TapAnimatedScale(
                        onTap: () => _showCouponSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple[700]!.withOpacity(0.8),
                                Colors.deepPurple[900]!.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            loc.redeem,
                            style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                TapAnimatedScale(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple[700]!.withOpacity(0.8),
                          Colors.deepPurple[900]!.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      loc.cancel,
                      style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCouponSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TarotBloc>(context),
        child: CouponSheet(manager: widget.manager),
      ),
    );
  }

  Widget _buildPurchaseOption(ProductDetails product) {
    final loc = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TapAnimatedScale(
        onTap: () async {
          setState(() => _isLoading = true);
          final success = await widget.manager.buyProduct(product);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc!.couponRedeemed('Processing...'))));
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) Navigator.pop(context);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc!.errorMessage('Purchase failed'))));
            setState(() => _isLoading = false);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[700]!.withOpacity(0.8), Colors.deepPurple[900]!.withOpacity(0.6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.title.split(' (')[0], style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
              Text(product.price, style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class CouponSheet extends StatefulWidget {
  final PaymentManager manager;

  const CouponSheet({super.key, required this.manager});

  @override
  CouponSheetState createState() => CouponSheetState();
}

class CouponSheetState extends State<CouponSheet> with SingleTickerProviderStateMixin {
  final TextEditingController _couponController = TextEditingController();
  late AnimationController _sheetController;
  bool _isProcessing = false;
  String? _resultMessage;
  bool? _couponSuccess;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _couponController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return BlocListener<TarotBloc, TarotState>(
      listener: (context, state) {
        if (state is CouponRedeemed) {
          setState(() {
            _isProcessing = false;
            _couponSuccess = true;
            _resultMessage = loc.couponRedeemed(state.message);
          });
          // Başarılı durumda 2 saniye sonra kapat
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        } else if (state is CouponInvalid) {
          setState(() {
            _isProcessing = false;
            _couponSuccess = false;
            _resultMessage = loc.couponInvalid(state.message);
          });
        } else if (state is TarotError) {
          setState(() {
            _isProcessing = false;
            _couponSuccess = false;
            _resultMessage = loc.errorMessage(state.message);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[900]!.withOpacity(0.9),
              Colors.black87.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Üst Süsleme: Yıldızlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.purpleAccent),
                    const SizedBox(width: 20),
                    Text(
                      loc!.redeem,
                      style: GoogleFonts.cinzel(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.purple[300]!.withOpacity(0.6),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.star, size: 12, color: Colors.purpleAccent),
                  ],
                ),
                const SizedBox(height: 20),
                // Kupon Giriş Alanı
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[900]!.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.black87.withOpacity(0.8),
                      width: 1.3,
                    ),
                  ),
                  child: TextField(
                    controller: _couponController,
                    style: GoogleFonts.cinzel(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    maxLength: 20,
                    decoration: InputDecoration(
                      hintText: loc.couponHint,
                      hintStyle: GoogleFonts.cinzel(color: Colors.grey[400], fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      counterText: "",
                    ),
                    enabled: !_isProcessing,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _redeemCoupon(context),
                  ),
                ),
                const SizedBox(height: 20),
                // Redeem Butonu
                TapAnimatedScale(
                  onTap: () => _redeemCoupon(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple[700]!.withOpacity(_isProcessing ? 0.5 : 0.9),
                          Colors.deepPurple[900]!.withOpacity(_isProcessing ? 0.4 : 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        loc.redeem,
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // Sonuç mesajı
                if (_resultMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _couponSuccess == true
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _couponSuccess == true
                            ? Colors.green.withOpacity(0.4)
                            : Colors.red.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _couponSuccess == true ? Icons.check_circle : Icons.error,
                          color: _couponSuccess == true ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _resultMessage!,
                            style: GoogleFonts.cinzel(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            // Close button positioned at the top right
            Positioned(
              top: 0,
              right: 0,
              child: _buildCloseButton(context),
            ),
          ],
        ),
      ),
    );
  }

  void _redeemCoupon(BuildContext context) {
    if (_isProcessing) return;
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _couponSuccess = false;
        _resultMessage = S.of(context)!.errorMessage('Coupon code cannot be empty');
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _couponSuccess = null;
      _resultMessage = null;
    });

    // BlocProvider üzerinden event gönder
    context.read<TarotBloc>().add(RedeemCoupon(code));
  }

  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.6),
          boxShadow: [
            BoxShadow(
              color: Colors.purple[300]!.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 24),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();