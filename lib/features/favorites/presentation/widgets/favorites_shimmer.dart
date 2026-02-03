import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class FavoritesShimmer extends StatelessWidget {
  const FavoritesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: ResponsiveConstants.mdSpacing),
      itemBuilder: (_, __) => _shimmerRow(context),
    );
  }

  Widget _shimmerRow(BuildContext context) {
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
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        child: Row(
          children: [
            // Image
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: ResponsiveConstants.mdSpacing),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(context, width: 80, height: 14),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  _line(context, width: double.infinity, height: 16),
                  SizedBox(height: ResponsiveConstants.xsSpacing),
                  _line(context, width: double.infinity, height: 16),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  _line(context, width: 100, height: 18),
                ],
              ),
            ),

            SizedBox(width: ResponsiveConstants.mdSpacing),

            // Heart button placeholder
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _line(BuildContext context, {required double width, required double height}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}


