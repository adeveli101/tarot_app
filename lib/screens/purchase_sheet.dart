// lib/services/purchase_service.dart
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:tarot_fal/data/tarot_bloc.dart';
import 'package:tarot_fal/data/tarot_event_state.dart';

import '../generated/l10n.dart';
import '../models/animations/tap_animations_scale.dart';

class PurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  late TarotBloc _tarotBloc;

  // Initialize the purchase service with TarotBloc
  void initialize(TarotBloc tarotBloc) {
    _tarotBloc = tarotBloc;
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        debugPrint('Purchase stream error: $error');
      },
      onDone: () {
        debugPrint('Purchase stream completed');
      },
    );
  }

  // Load products with error handling
  Future<List<ProductDetails>> loadProducts(List<String> productIds) async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
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

  // Initiate a product purchase
  Future<bool> buyProduct(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      if (product.id.contains('premium')) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
      return true; // Indicate purchase attempt started successfully
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false; // Indicate purchase attempt failed
    }
  }

  // Handle purchase updates from the stream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          double credits = _getCreditValue(purchase.productID);
          if (credits > 0) {
            final currentTokens = await _tarotBloc.userDataManager.getTokens();
            await _tarotBloc.userDataManager.saveTokens(currentTokens + credits);
            _tarotBloc.emit(TarotInitial(
              isPremium: _tarotBloc.state.isPremium,
              userTokens: currentTokens + credits,
              dailyFreeFalCount: _tarotBloc.state.dailyFreeFalCount,
            ));
          } else if (purchase.productID == 'premium_subscription') {
            await _tarotBloc.userDataManager.savePremiumStatus(true);
            _tarotBloc.emit(TarotInitial(
              isPremium: true,
              userTokens: _tarotBloc.state.userTokens,
              dailyFreeFalCount: _tarotBloc.state.dailyFreeFalCount,
            ));
          }
          await _inAppPurchase.completePurchase(purchase);
          debugPrint('Purchase completed: ${purchase.productID}');
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

  // Map product IDs to credit values
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

  // Clean up resources
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('PurchaseService disposed');
  }
}



class PurchaseSheet extends StatefulWidget {
  final double requiredTokens;

  const PurchaseSheet({super.key, required this.requiredTokens});

  @override
  PurchaseSheetState createState() => PurchaseSheetState();
}

class PurchaseSheetState extends State<PurchaseSheet> {
  late PurchaseService _purchaseService;
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _purchaseService = PurchaseService();
    _purchaseService.initialize(context.read<TarotBloc>());
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productIds = ['10_credits', '50_credits', '100_credits', 'premium_subscription'];
    final products = await _purchaseService.loadProducts(productIds);
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
        if (products.isEmpty) {
          _errorMessage = S.of(context)!.errorMessage('Failed to load purchase options');
          // Return to previous screen after a delay if products fail to load
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && _errorMessage != null) {
              Navigator.pop(context);
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.7,
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
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    loc!.purchaseCredits,
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
                  Text(
                    loc.insufficientCreditsMessage(widget.requiredTokens),
                    style: GoogleFonts.cinzel(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(color: Colors.purple[300]),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.cinzel(color: Colors.red[300], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ..._products.map((product) => _buildPurchaseOption(context, product)),
                  const SizedBox(height: 16),
                  Center(
                    child: TapAnimatedScale(
                      onTap: () => Navigator.pop(context),
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
                        ),
                        child: Text(
                          loc.cancel,
                          style: GoogleFonts.cinzel(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: TapAnimatedScale(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple[300]!.withOpacity(0.5)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: null, // Handled by TapAnimatedScale
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOption(BuildContext context, ProductDetails product) {
    final loc = S.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Should be bottom: 12
      child: TapAnimatedScale(
        onTap: () async {
          setState(() => _isLoading = true);
          final success = await _purchaseService.buyProduct(product);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc!.couponRedeemed('Purchase initiated'))),
            );
            // Wait briefly for purchase to process, then pop back
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.pop(context);
            }
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc!.errorMessage('Purchase failed'))),
            );
            setState(() => _isLoading = false);
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.title.split(' (')[0],
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                product.price,
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/screens/coupon_sheet.dart
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