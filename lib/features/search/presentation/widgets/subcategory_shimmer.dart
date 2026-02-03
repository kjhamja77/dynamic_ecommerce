import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class SubcategoryShimmer extends StatelessWidget {
  const SubcategoryShimmer({super.key});

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
    
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      itemCount: 5, // Show 5 shimmer items
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: ResponsiveConstants.mdBorderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.lgPadding,
                vertical: ResponsiveConstants.smPadding,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              trailing: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
