import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/responsive_constants.dart';

class FashionShimmer extends StatelessWidget {
  const FashionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = ResponsiveConstants.mdPadding;
    final double spacing = ResponsiveConstants.gridSpacing;
    return CustomScrollView(
      slivers: [
        // Hero banner placeholder with consistent horizontal padding like Home
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            ResponsiveConstants.smPadding,
            horizontalPadding,
            ResponsiveConstants.smPadding,
          ),
          sliver: SliverToBoxAdapter(
            child: Builder(
              builder: (context) => _box(context, height: 180, width: double.infinity, radius: 12.r),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverToBoxAdapter(
            child: Builder(
              builder: (context) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _box(context, height: 24, width: 160, radius: 8.r),
                  _box(context, height: 20, width: 80, radius: 8.r),
                ],
              ),
            ),
          ),
        ),
        // Horizontal product cards placeholder aligned with Home spacing
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: ResponsiveConstants.mdPadding),
            child: SizedBox(
              height: 0.6.sw + 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                itemCount: 6,
                separatorBuilder: (_, __) => SizedBox(width: spacing),
                itemBuilder: (context, index) => SizedBox(
                  width: 0.6.sw,
                  child: _card(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _card() {
    return Builder(
      builder: (context) {
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
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(context, height: 160, width: double.infinity, radius: 12.r),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                _box(context, height: 14, width: 120, radius: 6.r),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                _box(context, height: 14, width: double.infinity, radius: 6.r),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                _box(context, height: 14, width: 180, radius: 6.r),
                SizedBox(height: ResponsiveConstants.smSpacing),
                Row(
                  children: [
                    _box(context, height: 16, width: 80, radius: 6.r),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    _box(context, height: 14, width: 60, radius: 6.r),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _box(BuildContext context, {required double height, required double width, required double radius}) {
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


