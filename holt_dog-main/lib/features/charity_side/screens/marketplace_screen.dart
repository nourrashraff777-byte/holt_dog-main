import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../models/marketplace_product.dart';

class MarketplaceScreen extends StatefulWidget {
  /// Notifies parent when total cart item count changes (for nav badge).
  final ValueChanged<int>? onCartItemCountChanged;

  const MarketplaceScreen({super.key, this.onCartItemCountChanged});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  static const List<MarketplaceProduct> _catalog = [
    MarketplaceProduct(
      id: '1',
      title: 'Alpha Dry Food',
      priceEgp: 1500,
      imageUrl:
          'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=400&q=80',
      category: MarketplaceCategory.food,
    ),
    MarketplaceProduct(
      id: '2',
      title: 'Wet Food',
      priceEgp: 70,
      imageUrl:
          'https://images.unsplash.com/photo-1620464403445-187ae6be0ed1?w=400&q=80',
      category: MarketplaceCategory.food,
    ),
    MarketplaceProduct(
      id: '3',
      title: 'Rubber Toys',
      priceEgp: 95,
      imageUrl:
          'https://images.unsplash.com/photo-1535294435444-d323c2f6ddeb?w=400&q=80',
      category: MarketplaceCategory.toys,
    ),
    MarketplaceProduct(
      id: '4',
      title: 'Dog Enrichment Set',
      priceEgp: 115,
      imageUrl:
          'https://images.unsplash.com/photo-1587300003381-2922fccb74a4?w=400&q=80',
      category: MarketplaceCategory.accessories,
    ),
  ];

  static const List<_CategoryTab> _tabs = [
    _CategoryTab(label: 'All', category: MarketplaceCategory.all),
    _CategoryTab(label: 'Food', category: MarketplaceCategory.food),
    _CategoryTab(label: 'Toys', category: MarketplaceCategory.toys),
    _CategoryTab(
        label: 'Accessories', category: MarketplaceCategory.accessories),
  ];

  /// Preserves catalog order for cart lines.
  final Map<String, int> _cartQtyByProductId = {};

  MarketplaceCategory _selected = MarketplaceCategory.all;

  int get _totalCartItems =>
      _cartQtyByProductId.values.fold(0, (sum, q) => sum + q);

  int get _cartTotalEgp {
    var total = 0;
    for (final p in _catalog) {
      final q = _cartQtyByProductId[p.id] ?? 0;
      total += p.priceEgp * q;
    }
    return total;
  }

  List<({MarketplaceProduct product, int quantity})> get _cartLines {
    final out = <({MarketplaceProduct product, int quantity})>[];
    for (final p in _catalog) {
      final q = _cartQtyByProductId[p.id] ?? 0;
      if (q > 0) out.add((product: p, quantity: q));
    }
    return out;
  }

  void _notifyCartCount() {
    widget.onCartItemCountChanged?.call(_totalCartItems);
  }

  List<MarketplaceProduct> get _visibleProducts {
    if (_selected == MarketplaceCategory.all) return _catalog;
    return _catalog.where((p) => p.category == _selected).toList();
  }

  void _addToCart(MarketplaceProduct product) {
    setState(() {
      _cartQtyByProductId[product.id] =
          (_cartQtyByProductId[product.id] ?? 0) + 1;
    });
    _notifyCartCount();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _setQuantity(MarketplaceProduct product, int nextQty) {
    if (nextQty <= 0) {
      _cartQtyByProductId.remove(product.id);
    } else {
      _cartQtyByProductId[product.id] = nextQty;
    }
  }

  void _openCartSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void applyAndSync(VoidCallback fn) {
              fn();
              setState(() {});
              setModalState(() {});
              _notifyCartCount();
            }

            final lines = _cartLines;
            final total = _cartTotalEgp;

            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.38,
              maxChildSize: 0.92,
              expand: false,
              builder: (_, scrollController) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.r)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10.h),
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                        child: Row(
                          children: [
                            Text(
                              'Your cart',
                              style: AppTypography.h3.copyWith(fontSize: 20.sp),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              icon: Icon(Icons.close,
                                  color: AppColors.textSecondary, size: 24.w),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: lines.isEmpty
                            ? ListView(
                                controller: scrollController,
                                padding: EdgeInsets.all(32.w),
                                children: [
                                  SizedBox(height: 48.h),
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shopping_cart_outlined,
                                            size: 56.w,
                                            color: AppColors.textHint),
                                        SizedBox(height: 16.h),
                                        Text(
                                          'Your cart is empty',
                                          style:
                                              AppTypography.bodyLarge.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Add items from the shop',
                                          style: AppTypography.bodySmall,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                                itemCount: lines.length,
                                separatorBuilder: (_, __) => Divider(
                                    height: 24.h, color: AppColors.borderLight),
                                itemBuilder: (context, index) {
                                  final line = lines[index];
                                  return _CartLineTile(
                                    product: line.product,
                                    quantity: line.quantity,
                                    onIncrement: () => applyAndSync(() {
                                      _setQuantity(
                                        line.product,
                                        line.quantity + 1,
                                      );
                                    }),
                                    onDecrement: () => applyAndSync(() {
                                      _setQuantity(
                                        line.product,
                                        line.quantity - 1,
                                      );
                                    }),
                                    onRemove: () => applyAndSync(() {
                                      _cartQtyByProductId
                                          .remove(line.product.id);
                                    }),
                                  );
                                },
                              ),
                      ),
                      if (lines.isNotEmpty)
                        _CartSheetFooter(
                          totalEgp: total,
                          onCheckout: () {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checkout coming soon'),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundGray,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MarketplaceAppBar(
              cartItemCount: _totalCartItems,
              onCartTap: _openCartSheet,
            ),
            _CategoryStrip(
              tabs: _tabs,
              selected: _selected,
              onSelected: (c) => setState(() => _selected = c),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
                itemCount: _visibleProducts.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final product = _visibleProducts[index];
                  return _ProductCard(
                    product: product,
                    onAddToCart: () => _addToCart(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTab {
  final String label;
  final MarketplaceCategory category;

  const _CategoryTab({required this.label, required this.category});
}

class _MarketplaceAppBar extends StatelessWidget {
  final int cartItemCount;
  final VoidCallback onCartTap;

  const _MarketplaceAppBar({
    required this.cartItemCount,
    required this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryPurple,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(
                'Marketplace',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textOnPurple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Search coming soon')),
          //     );
          //   },
          //   icon: Icon(Icons.search, color: AppColors.textOnPurple, size: 26.w),
          //   visualDensity: VisualDensity.compact,
          // ),
          IconButton(
            onPressed: onCartTap,
            icon: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    color: AppColors.textOnPurple, size: 26.w),
                if (cartItemCount > 0)
                  Positioned(
                    right: -2.w,
                    top: -4.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: cartItemCount > 9 ? 4.w : 5.w,
                        vertical: 2.h,
                      ),
                      constraints: BoxConstraints(minWidth: 18.w),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cartItemCount > 99 ? '99+' : '$cartItemCount',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold?.hasDrawer == true) {
                scaffold!.openDrawer();
              }
            },
            icon: Icon(Icons.person_outline,
                color: AppColors.textOnPurple, size: 26.w),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  final MarketplaceProduct product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartLineTile({
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = product.priceEgp * quantity;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            width: 72.w,
            height: 72.w,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: AppColors.backgroundGray,
                child: Icon(Icons.pets, size: 32.w, color: AppColors.textHint),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${product.priceEgp} EGP each',
                style: AppTypography.caption.copyWith(fontSize: 12.sp),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  _QtyChip(icon: Icons.remove, onTap: onDecrement),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      '$quantity',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  _QtyChip(icon: Icons.add, onTap: onIncrement),
                  const Spacer(),
                  Text(
                    '$lineTotal EGP',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onRemove,
          icon:
              Icon(Icons.delete_outline, color: AppColors.textHint, size: 22.w),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _QtyChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyChip({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundGray,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Icon(icon, size: 18.w, color: AppColors.primaryPurple),
        ),
      ),
    );
  }
}

class _CartSheetFooter extends StatelessWidget {
  final int totalEgp;
  final VoidCallback onCheckout;

  const _CartSheetFooter({
    required this.totalEgp,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Total',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$totalEgp EGP',
                  style: AppTypography.h3.copyWith(fontSize: 20.sp),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: AppColors.textOnPurple,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Checkout',
                style: AppTypography.buttonLabel.copyWith(fontSize: 16.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  final List<_CategoryTab> tabs;
  final MarketplaceCategory selected;
  final ValueChanged<MarketplaceCategory> onSelected;

  const _CategoryStrip({
    required this.tabs,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundWhite,
      child: SizedBox(
        height: 48.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: tabs.length,
          separatorBuilder: (_, __) => SizedBox(width: 20.w),
          itemBuilder: (context, index) {
            final tab = tabs[index];
            final isActive = tab.category == selected;
            return GestureDetector(
              onTap: () => onSelected(tab.category),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tab.label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 15.sp,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isActive ? AppColors.textPrimary : AppColors.textHint,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3.h,
                    width: isActive ? 32.w : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundWhite,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: SizedBox(
                  width: 96.w,
                  height: 96.w,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: AppColors.backgroundGray,
                      child: Icon(Icons.pets,
                          size: 40.w, color: AppColors.textHint),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: SizedBox(
                  height: 96.w,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onAddToCart,
                            borderRadius: BorderRadius.circular(12.r),
                            child: Padding(
                              padding: EdgeInsets.all(6.w),
                              child: Icon(
                                Icons.add_shopping_cart_outlined,
                                color: AppColors.statusRescued,
                                size: 26.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '${product.priceEgp} EGP',
                          style: AppTypography.bodyLarge.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
