import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../models/retailer_order.dart';

/// Retailer-facing orders list with summary metrics and order activity table.
class RetailerOrdersScreen extends StatelessWidget {
  const RetailerOrdersScreen({super.key});

  static const List<RetailerOrder> _mockOrders = [
    RetailerOrder(
      orderId: '#10234',
      customerName: 'Ahmed Hassan',
      orderDateLabel: '12 Mar 2026',
      status: RetailerOrderStatus.delivered,
      priceEgp: 450,
    ),
    RetailerOrder(
      orderId: '#10235',
      customerName: 'Sara Ali',
      orderDateLabel: '12 Mar 2026',
      status: RetailerOrderStatus.processing,
      priceEgp: 320,
      highlightRow: true,
    ),
    RetailerOrder(
      orderId: '#10236',
      customerName: 'Omar Khaled',
      orderDateLabel: '11 Mar 2026',
      status: RetailerOrderStatus.delivered,
      priceEgp: 890,
    ),
    RetailerOrder(
      orderId: '#10237',
      customerName: 'Layla Mahmoud',
      orderDateLabel: '11 Mar 2026',
      status: RetailerOrderStatus.returned,
      priceEgp: 120,
    ),
    RetailerOrder(
      orderId: '#10238',
      customerName: 'Youssef Nabil',
      orderDateLabel: '10 Mar 2026',
      status: RetailerOrderStatus.processing,
      priceEgp: 560,
    ),
    RetailerOrder(
      orderId: '#10239',
      customerName: 'Nour El-Din',
      orderDateLabel: '10 Mar 2026',
      status: RetailerOrderStatus.delivered,
      priceEgp: 275,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundGray,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _OrdersAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 120.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SummaryGrid(),
                    SizedBox(height: 24.h),
                    const _OrderActivityCard(orders: _mockOrders),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersAppBar extends StatelessWidget {
  const _OrdersAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryPurple,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text(
                'Orders',
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
          //       const SnackBar(content: Text('Filters coming soon')),
          //     );
          //   },
          //   icon: Icon(Icons.filter_list_outlined,
          //       color: AppColors.textOnPurple, size: 26.w),
          //   visualDensity: VisualDensity.compact,
          // ),
          IconButton(
            onPressed: () {
              final scaffold = Scaffold.maybeOf(context);
              if (scaffold?.hasDrawer == true) scaffold!.openDrawer();
            },
            icon: Icon(Icons.menu, color: AppColors.textOnPurple, size: 26.w),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final spacing = 12.w;
        final cardWidth = (c.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: 12.h,
          children: [
            SizedBox(
              width: cardWidth,
              child: const _StatCard(
                icon: Icons.show_chart_outlined,
                iconColor: AppColors.statusRescued,
                title: 'Total orders',
                value: '2,000',
                caption: '+12% from last month',
                captionColor: AppColors.statusRescued,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _StatCard(
                icon: Icons.swap_horiz_rounded,
                iconColor: AppColors.statusUndercare,
                title: 'Active orders',
                value: '25',
                caption: 'Processing',
                captionColor: AppColors.statusUndercare,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _StatCard(
                icon: Icons.local_shipping_outlined,
                iconColor: AppColors.statusRescued,
                title: 'Delivered',
                value: '500',
                caption: 'Last 30 days',
                captionColor: AppColors.statusRescued,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: const _StatCard(
                icon: Icons.assignment_return_outlined,
                iconColor: AppColors.statusNeedsHelp,
                title: 'Returned',
                value: '10',
                caption: 'Needs review',
                captionColor: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String caption;
  final Color captionColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.caption,
    required this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundWhite,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(18.r),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 26.w),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.caption.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              value,
              style: AppTypography.h2.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              caption,
              style: AppTypography.caption.copyWith(
                fontSize: 11.sp,
                color: captionColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderActivityCard extends StatelessWidget {
  final List<RetailerOrder> orders;

  const _OrderActivityCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundWhite,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(18.r),
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 16.h, 0, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Order activity',
                style: AppTypography.h3.copyWith(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _tableHeader('Order ID')),
                        Expanded(flex: 3, child: _tableHeader('Customer')),
                        Expanded(flex: 2, child: _tableHeader('Date')),
                        Expanded(flex: 3, child: _tableHeader('Status')),
                        Expanded(
                          flex: 2,
                          child: _tableHeader('Price', align: TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final o = orders[index];
                      return ColoredBox(
                        color: o.highlightRow
                            ? const Color(0xFFE8F4FC)
                            : Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.h, horizontal: 8.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _tableCell(o.orderId, bold: true),
                              ),
                              Expanded(
                                flex: 3,
                                child: _tableCell(o.customerName),
                              ),
                              Expanded(
                                flex: 2,
                                child: _tableCell(o.orderDateLabel),
                              ),
                              Expanded(
                                flex: 3,
                                child: _StatusPill(status: o.status),
                              ),
                              Expanded(
                                flex: 2,
                                child: _tableCell(
                                  '${o.priceEgp}',
                                  align: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      style: AppTypography.caption.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 11.sp,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _tableCell(String text,
      {bool bold = false, TextAlign align = TextAlign.left}) {
    return Text(
      text,
      textAlign: align,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.bodySmall.copyWith(
        fontSize: 12.sp,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final RetailerOrderStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      RetailerOrderStatus.delivered => (
          'Delivered',
          AppColors.statusRescued,
          AppColors.statusRescuedBg,
        ),
      RetailerOrderStatus.processing => (
          'Processing',
          const Color(0xFFB8832E),
          const Color(0xFFFFF6E5),
        ),
      RetailerOrderStatus.returned => (
          'Returned',
          AppColors.statusNeedsHelp,
          AppColors.statusNeedsHelpBg,
        ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}
