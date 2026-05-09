import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/product_model.dart';
import '../../data/models/marketplace_category.dart';
import '../manager/marketplace_cubit.dart';
import '../manager/marketplace_state.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';
import 'marketplace_cart_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  final bool isRetailer;
  final ValueChanged<int>? onCartItemCountChanged;

  const MarketplaceScreen(
      {super.key, this.onCartItemCountChanged, this.isRetailer = false});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final Map<String, int> _cartQtyByProductId = {};
  MarketplaceCategory _selectedCategory = MarketplaceCategory.all;

  int get _totalCartItems =>
      _cartQtyByProductId.values.fold(0, (sum, q) => sum + q);

  void _notifyCartCount() {
    widget.onCartItemCountChanged?.call(_totalCartItems);
  }

  void _executeAddToCart(ProductModel product) {
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

  void _executeOpenAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
  }

  Future<void> _executeOpenCart() async {
    final cubitState = context.read<MarketplaceCubit>().state;
    if (cubitState is! MarketplaceSuccess) return;

    final updated = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(
        builder: (_) => MarketplaceCartScreen(
          initialQuantities: Map<String, int>.from(_cartQtyByProductId),
          catalog: cubitState.products,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _cartQtyByProductId
          ..clear()
          ..addAll(updated);
      });
      _notifyCartCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: AppColors.backgroundGray,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MarketplaceAppBar(
                  isRetailer: widget.isRetailer,
                  cartItemCount: _totalCartItems,
                  onCartTap: widget.isRetailer ? () {} : _executeOpenCart,
                ),
                _CategoryStrip(
                  selected: _selectedCategory,
                  onSelected: (c) => setState(() => _selectedCategory = c),
                ),
                Expanded(
                  child: BlocBuilder<MarketplaceCubit, MarketplaceState>(
                    builder: (context, state) {
                      if (state is MarketplaceLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is MarketplaceSuccess) {
                        final products = _selectedCategory ==
                                MarketplaceCategory.all
                            ? state.products
                            : state.products
                                .where((p) => p.category == _selectedCategory)
                                .toList();

                        if (products.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: () =>
                              context.read<MarketplaceCubit>().fetchProducts(),
                          child: ListView.separated(
                            padding:
                                EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
                            itemCount: products.length,
                            separatorBuilder: (_, __) => SizedBox(height: 14.h),
                            itemBuilder: (context, index) {
                              return ProductCard(
                                isRetailer: widget.isRetailer,
                                product: products[index],
                                onAddToCart: () =>
                                    _executeAddToCart(products[index]),
                                // onOpenCart: _executeOpenCart,
                              );
                            },
                          ),
                        );
                      } else if (state is MarketplaceError) {
                        log('Error: ${state.message}');
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (widget.isRetailer)
            Positioned(
              right: 16.w,
              bottom: bottomInset,
              child: FloatingActionButton(
                onPressed: _executeOpenAddProduct,
                backgroundColor: AppColors.primaryPurple,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 64.w, color: AppColors.textHint),
          SizedBox(height: 16.h),
          Text(
            'No products found',
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MarketplaceAppBar extends StatelessWidget {
  final int cartItemCount;
  final VoidCallback onCartTap;
  final bool isRetailer;

  const _MarketplaceAppBar({
    this.isRetailer = false,
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
          IconButton(
            onPressed: () {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold?.hasDrawer == true) {
                scaffold!.openDrawer();
              }
            },
            icon: Icon(
              Icons.person_outline,
              color: AppColors.textOnPurple,
              size: 26.w,
            ),
          ),
          Expanded(
            child: Text(
              'Marketplace',
              style: AppTypography.h3.copyWith(
                color: AppColors.textOnPurple,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onCartTap,
            icon: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (!isRetailer)
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
          ),
        ],
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  final MarketplaceCategory selected;
  final ValueChanged<MarketplaceCategory> onSelected;

  const _CategoryStrip({
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
          itemCount: MarketplaceCategory.values.length,
          separatorBuilder: (_, __) => SizedBox(width: 20.w),
          itemBuilder: (context, index) {
            final category = MarketplaceCategory.values[index];
            final isActive = category == selected;
            final label =
                category.name[0].toUpperCase() + category.name.substring(1);

            return GestureDetector(
              onTap: () => onSelected(category),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
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
