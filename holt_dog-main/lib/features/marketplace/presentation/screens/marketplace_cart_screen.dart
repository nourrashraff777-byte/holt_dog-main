import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holt_dog/features/auth/cubit/auth_cubit.dart';
import 'package:holt_dog/features/auth/cubit/auth_state.dart';
import 'package:holt_dog/features/donation/screens/payment_webview_page.dart';
import 'package:holt_dog/paymob_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/product_model.dart';

/// Full-screen cart for marketplace; pops with updated quantity map when the
/// user leaves via the back button (or swipe back).
class MarketplaceCartScreen extends StatefulWidget {
  final Map<String, int> initialQuantities;
  final List<ProductModel> catalog;

  const MarketplaceCartScreen({
    super.key,
    required this.initialQuantities,
    required this.catalog,
  });

  @override
  State<MarketplaceCartScreen> createState() => _MarketplaceCartScreenState();
}

class _MarketplaceCartScreenState extends State<MarketplaceCartScreen> {
  late Map<String, int> _qtyById;
  bool _checkoutLoading = false;

  @override
  void initState() {
    super.initState();
    _qtyById = Map<String, int>.from(widget.initialQuantities);
  }

  ProductModel? _productFor(String id) {
    for (final p in widget.catalog) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<MapEntry<String, int>> get _lines =>
      _qtyById.entries.where((e) => e.value > 0).toList();

  int get _grandTotal {
    var sum = 0;
    for (final e in _lines) {
      final p = _productFor(e.key);
      if (p != null) sum += p.price * e.value;
    }
    return sum;
  }

  void _setQty(String productId, int qty) {
    setState(() {
      if (qty <= 0) {
        _qtyById.remove(productId);
      } else {
        _qtyById[productId] = qty;
      }
    });
  }

  void _popWithResult() {
    Navigator.pop<Map<String, int>>(context, Map<String, int>.from(_qtyById));
  }

  ({String email, String firstName, String lastName, String phone}) _billingDetails() {
    var email = 'customer@holtdog.com';
    var firstName = 'Customer';
    var lastName = 'User';
    var phone = '+201000000000';

    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final u = authState.user;
      if (u.email.isNotEmpty) email = u.email;
      final name = u.name.trim();
      if (name.isNotEmpty) {
        final parts = name.split(RegExp(r'\s+'));
        firstName = parts.first;
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'User';
      }
      if (u.phone.trim().isNotEmpty) {
        final p = u.phone.trim();
        phone = p.startsWith('+') ? p : '+20$p';
      }
    } else {
      final fb = FirebaseAuth.instance.currentUser;
      if (fb?.email != null && fb!.email!.isNotEmpty) email = fb.email!;
      final display = fb?.displayName?.trim();
      if (display != null && display.isNotEmpty) {
        final parts = display.split(RegExp(r'\s+'));
        firstName = parts.first;
        lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'User';
      }
    }

    return (email: email, firstName: firstName, lastName: lastName, phone: phone);
  }

  Future<void> _checkout() async {
    final total = _grandTotal;
    if (total <= 0 || _checkoutLoading) return;

    setState(() => _checkoutLoading = true);
    final billing = _billingDetails();

    final paymentUrl = await PaymobService().getPaymentGatewayUri(
      amount: total.toDouble(),
      email: billing.email,
      firstName: billing.firstName,
      lastName: billing.lastName,
      phoneNumber: billing.phone,
    );

    if (!mounted) return;
    setState(() => _checkoutLoading = false);

    if (paymentUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not start payment. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebViewPage(paymentUrl: paymentUrl),
      ),
    );

    if (!mounted) return;

    if (success == true) {
      setState(() => _qtyById.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful! Order total: $total EGP'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop<Map<String, int>>(context, {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = _lines;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popWithResult();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundGray,
        appBar: AppBar(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: AppColors.textOnPurple,
          elevation: 0,
          title: Text(
            'Cart',
            style: AppTypography.h3.copyWith(
              color: AppColors.textOnPurple,
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithResult,
          ),
        ),
        body: lines.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 64.w, color: AppColors.textHint),
                    SizedBox(height: 16.h),
                    Text(
                      'Your cart is empty',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                      itemCount: lines.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final entry = lines[index];
                        final product = _productFor(entry.key);
                        if (product == null) return const SizedBox.shrink();
                        final qty = entry.value;
                        final lineTotal = product.price * qty;

                        return Material(
                          color: AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(14.r),
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: SizedBox(
                                    width: 72.w,
                                    height: 72.w,
                                    child: Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => ColoredBox(
                                        color: AppColors.backgroundGray,
                                        child: Icon(Icons.pets,
                                            size: 28.w,
                                            color: AppColors.textHint),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          _qtyButton(
                                            icon: Icons.remove,
                                            onTap: () =>
                                                _setQty(product.id, qty - 1),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12.w),
                                            child: Text(
                                              '$qty',
                                              style: AppTypography.bodyLarge
                                                  .copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                          _qtyButton(
                                            icon: Icons.add,
                                            onTap: () =>
                                                _setQty(product.id, qty + 1),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '$lineTotal EGP',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w,
                        12.h + MediaQuery.paddingOf(context).bottom),
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: AppTypography.h3.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '$_grandTotal EGP',
                              style: AppTypography.h3.copyWith(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        ElevatedButton(
                          onPressed:
                              _checkoutLoading || _grandTotal <= 0 ? null : _checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            foregroundColor: AppColors.textOnPurple,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _checkoutLoading
                              ? SizedBox(
                                  height: 22.h,
                                  width: 22.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnPurple,
                                  ),
                                )
                              : Text(
                                  'Checkout with Paymob',
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textOnPurple,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.backgroundGray,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Icon(icon, size: 20.w, color: AppColors.primaryPurple),
        ),
      ),
    );
  }
}
