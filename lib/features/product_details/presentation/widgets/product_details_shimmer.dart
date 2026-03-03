import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../cart/presentation/widgets/cart_button_with_badge.dart';

class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.3)
        : Colors.grey.shade300;
    final highlightColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.5)
        : Colors.grey.shade100;

    return CustomScrollView(
      slivers: [
        // App bar matching the real product details page (back, title, share, cart, heart)
        SliverAppBar(
          expandedHeight: ResponsiveConstants.productDetailsAppBarHeight,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: colorScheme.background,
          leading: Padding(
            padding: EdgeInsets.only(left: ResponsiveConstants.mdPadding),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: colorScheme.onBackground,
                size: ResponsiveConstants.mdIconSize,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  height: 12,
                  width: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(ResponsiveConstants.smRadius),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(ResponsiveConstants.smRadius),
                  ),
                ),
              ),
            ],
          ),
          iconTheme: IconThemeData(color: colorScheme.onBackground),
          actions: [
            IconButton(
              icon: Icon(Icons.share,
                  color: colorScheme.onBackground,
                  size: ResponsiveConstants.mdIconSize),
              onPressed: () {},
            ),
            const CartButtonWithBadge(),
            Padding(
              padding: EdgeInsetsDirectional.only(
                  end: ResponsiveConstants.mdPadding),
              child: IconButton(
                icon: Icon(Icons.favorite_border,
                    color: colorScheme.onBackground,
                    size: ResponsiveConstants.mdIconSize),
                onPressed: () {},
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                color: colorScheme.surface,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),

        // Variant / thumbnail selectors: label + 3 rounded squares
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveConstants.horizontalMdEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveConstants.lgSpacing),
                _ShimmerLine(
                    height: 14, width: 80, radius: 6.r),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      if (i > 0) SizedBox(width: ResponsiveConstants.smSpacing),
                      _ShimmerLine(
                          height: 56,
                          width: 56,
                          radius: ResponsiveConstants.smRadius),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        // Product info card: brand, name, price placeholder, small placeholder
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.smPadding,
              vertical: ResponsiveConstants.lgSpacing,
            ),
            child: Container(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(ResponsiveConstants.mdRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerLine(
                                height: 14, width: 72, radius: 6.r),
                            SizedBox(height: ResponsiveConstants.xsSpacing),
                            _ShimmerLine(
                                height: 18,
                                width: double.infinity,
                                radius: 8.r),
                          ],
                        ),
                      ),
                      SizedBox(width: ResponsiveConstants.smSpacing),
                      _ShimmerLine(
                          height: 24, width: 72, radius: 12.r),
                    ],
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  _ShimmerLine(
                      height: 22, width: 80, radius: 8.r),
                ],
              ),
            ),
          ),
        ),

        // Variant attributes (e.g. size): label + 5 chips
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.smPadding),
            child: Container(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(ResponsiveConstants.mdRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                        alpha: isDark ? 0.35 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerLine(
                      height: 18, width: 80, radius: 8.r),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Row(
                    children: [
                      for (int i = 0; i < 5; i++) ...[
                        if (i > 0)
                          SizedBox(width: ResponsiveConstants.smSpacing),
                        _ShimmerLine(
                            height: 40, width: 64, radius: 8.r),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // About product placeholder
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mdPadding,
              vertical: ResponsiveConstants.lgPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerLine(height: 18, width: 160, radius: 8.r),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                _ShimmerLine(height: 14, width: double.infinity, radius: 6.r),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                _ShimmerLine(height: 14, width: double.infinity, radius: 6.r),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                _ShimmerLine(height: 14, width: 220, radius: 6.r),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: ResponsiveConstants.lgSpacing),
        ),
      ],
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const _ShimmerLine({
    required this.height,
    required this.width,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.3)
        : Colors.grey.shade300;
    final highlightColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.5)
        : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
