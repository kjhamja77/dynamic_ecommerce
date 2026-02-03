import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class SearchShimmer extends StatelessWidget {
  const SearchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar placeholder
        Padding(
          padding: EdgeInsets.fromLTRB(
            ResponsiveConstants.mdPadding,
            ResponsiveConstants.mdPadding,
            ResponsiveConstants.mdPadding,
            ResponsiveConstants.smPadding,
          ),
          child: Builder(
            builder: (context) => _roundedBox(context, height: 44, width: double.infinity, radius: 12),
          ),
        ),

        // Tabs placeholder
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) => _roundedBox(context, height: 28, width: 70, radius: 20),
                ),
                Builder(
                  builder: (context) => _roundedBox(context, height: 28, width: 60, radius: 20),
                ),
                Builder(
                  builder: (context) => _roundedBox(context, height: 28, width: 60, radius: 20),
                ),
              ],
          ),
        ),

        SizedBox(height: ResponsiveConstants.lgSpacing),

        // Category cards list placeholder
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
            itemCount: 8,
            separatorBuilder: (_, __) => SizedBox(height: ResponsiveConstants.mdSpacing),
            itemBuilder: (context, index) {
              return _categoryCard(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(BuildContext context) {
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
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _roundedBox(context, height: 18, width: 160, radius: 8),
            SizedBox(height: ResponsiveConstants.smSpacing),
            _roundedBox(context, height: 14, width: double.infinity, radius: 8),
            SizedBox(height: ResponsiveConstants.xsSpacing),
            _roundedBox(context, height: 14, width: double.infinity, radius: 8),
            SizedBox(height: ResponsiveConstants.xsSpacing),
            _roundedBox(context, height: 14, width: 140, radius: 8),
            SizedBox(height: ResponsiveConstants.mdSpacing),
            Row(
              children: [
                _roundedBox(context, height: 100, width: 100, radius: 10),
                SizedBox(width: ResponsiveConstants.smSpacing),
                _roundedBox(context, height: 100, width: 100, radius: 10),
                SizedBox(width: ResponsiveConstants.smSpacing),
                _roundedBox(context, height: 100, width: 100, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundedBox(BuildContext context, {required double height, required double width, required double radius}) {
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


