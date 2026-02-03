import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/responsive_constants.dart';

class ProductDetailsShimmer extends StatelessWidget {
  const ProductDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Collapsing image placeholder
        SliverToBoxAdapter(
          child: Builder(
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
              
              return SizedBox(
                height: 0.6.sh,
                child: Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(color: colorScheme.surface),
                ),
              );
            },
          ),
        ),

        // Title, brand, rating
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveConstants.horizontalMdEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveConstants.lgSpacing),
                _line(height: 18, width: 120, radius: 8.r),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                _line(height: 22, width: double.infinity, radius: 8.r),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Row(
                  children: [
                    _circle(dimension: ResponsiveConstants.mdIconSize),
                    SizedBox(width: ResponsiveConstants.xsSpacing),
                    _line(height: 16, width: 40, radius: 6.r),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    _line(height: 14, width: 100, radius: 6.r),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Price block
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveConstants.horizontalMdEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveConstants.lgSpacing),
                Row(
                  children: [
                    _line(height: 26, width: 120, radius: 8.r),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    _line(height: 16, width: 80, radius: 6.r),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    _line(height: 16, width: 40, radius: 6.r),
                  ],
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                _line(height: 12, width: 80, radius: 6.r),
              ],
            ),
          ),
        ),

        // Size recommendation card
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveConstants.horizontalMdEdgeInsets,
            child: Container(
              padding: ResponsiveConstants.mdEdgeInsets,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              ),
              child: Row(
                children: [
                  _circle(dimension: ResponsiveConstants.mdIconSize),
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  Expanded(child: _line(height: 16, width: double.infinity, radius: 6.r)),
                  SizedBox(width: ResponsiveConstants.smSpacing),
                  _line(height: 16, width: 40, radius: 6.r),
                ],
              ),
            ),
          ),
        ),

        // Size chips skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveConstants.horizontalMdEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: ResponsiveConstants.lgSpacing),
                _line(height: 18, width: 100, radius: 6.r),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Wrap(
                  spacing: ResponsiveConstants.smSpacing,
                  runSpacing: ResponsiveConstants.smSpacing,
                  children: List.generate(6, (index) => _chip(width: 64, height: 36, radius: 8.r)),
                ),
              ],
            ),
          ),
        ),

        // Action buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: ResponsiveConstants.horizontalMdEdgeInsets,
            child: Row(
              children: [
                Expanded(child: _button(height: 48, radius: ResponsiveConstants.smRadius)),
                SizedBox(width: ResponsiveConstants.mdSpacing),
                _square(dimension: ResponsiveConstants.xlDimension, radius: ResponsiveConstants.smRadius),
              ],
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
                _line(height: 18, width: 160, radius: 8.r),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                _line(height: 14, width: double.infinity, radius: 6.r),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                _line(height: 14, width: double.infinity, radius: 6.r),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                _line(height: 14, width: 220, radius: 6.r),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _line({required double height, required double width, required double radius}) {
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
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
    );
  }

  Widget _circle({required double dimension}) {
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
            height: dimension,
            width: dimension,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _chip({required double width, required double height, required double radius}) {
    return _line(height: height, width: width, radius: radius);
  }

  Widget _button({required double height, required double radius}) {
    return _line(height: height, width: double.infinity, radius: radius);
  }

  Widget _square({required double dimension, required double radius}) {
    return _line(height: dimension, width: dimension, radius: radius);
  }
}


