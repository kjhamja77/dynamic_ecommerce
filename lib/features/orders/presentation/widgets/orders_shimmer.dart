import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class OrdersShimmer extends StatelessWidget {
  const OrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark 
        ? colorScheme.outline.withValues(alpha: 0.3)
        : Colors.grey.shade200;
    final highlightColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.5)
        : Colors.grey.shade100;
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        children: List.generate(5, (index) => _buildShimmerCard(context)),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Container(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveConstants.mdRadius),
                topRight: Radius.circular(ResponsiveConstants.mdRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                  ),
                ),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                  ),
                ),
              ],
            ),
          ),
          // Content shimmer
          Padding(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Image shimmer
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.mdSpacing),
                    // Text shimmer
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 14,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Container(
                            width: 100,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                            ),
                          ),
                          SizedBox(height: ResponsiveConstants.xsSpacing),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                // Summary shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                // Date shimmer
                Container(
                  width: 150,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
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

