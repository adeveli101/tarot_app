// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';
import 'package:tarot_fal/generated/l10n.dart';
import 'package:tarot_fal/models/animations/tap_animations_scale.dart';

class PaymentManager {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final VoidCallback? onPurchaseSuccess;

  PaymentManager({this.onPurchaseSuccess});

  void initialize() {
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

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    final tarotBloc = _findTarotBloc();
    for (var purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          double credits = _getCreditValue(purchase.productID);
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

  double _getCreditValue(String productId) {
    switch (productId) {
      case '10_credits':
        return 10.0;
      case '50_credits':
        return 50.0;
      case '100_credits':
        return 100.0;
      default:
        return 0.0;
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
    return showDialog<void>(  // Explicitly return the Future<void>
      context: context,
      builder: (_) => PaymentDialog(manager: paymentManager, requiredTokens: requiredTokens),
      barrierDismissible: false,
    ).then((_) => paymentManager.dispose()); // Dispose after dialog closes
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
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[900]!, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc!.purchaseCredits,
              style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
              Text(_errorMessage!, style: GoogleFonts.cinzel(color: Colors.red, fontSize: 16), textAlign: TextAlign.center)
            else
              ..._products.map((product) => _buildPurchaseOption(product)),
            const SizedBox(height: 16),
            TapAnimatedScale(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[700]!.withOpacity(0.8), Colors.deepPurple[900]!.withOpacity(0.6)],
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

// Global navigator key for context access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();




class CouponSheet extends StatefulWidget {
  const CouponSheet({super.key});

  @override
  CouponSheetState createState() => CouponSheetState();
}

class CouponSheetState extends State<CouponSheet> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple[900]!, Colors.black87],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              loc!.redeem,
              style: GoogleFonts.cinzel(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.purple[300]!.withOpacity(0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _couponController,
              style: GoogleFonts.cinzel(color: Colors.white),
              decoration: InputDecoration(
                hintText: loc.couponHint,
                hintStyle: GoogleFonts.cinzel(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.purple[300]!.withOpacity(0.5)),
                ),
                filled: true,
                fillColor: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TapAnimatedScale(
              onTap: () {
                if (_couponController.text.trim().isNotEmpty) {
                  context.read<TarotBloc>().add(RedeemCoupon(_couponController.text));
                  _couponController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.errorMessage('Coupon code cannot be empty'))),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple[700]!.withOpacity(0.8),
                      Colors.deepPurple[900]!.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  loc.redeem,
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    color: Colors.white,
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
}