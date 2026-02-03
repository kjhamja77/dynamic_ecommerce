import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class SearchResultsShimmer extends StatelessWidget {
  const SearchResultsShimmer({super.key});

  Widget _bar(BuildContext context, {double height = 14, double width = double.infinity, double radius = 8}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

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
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.mdPadding,
          vertical: ResponsiveConstants.smPadding,
        ),
        children: [
          // Recent title bar
          _bar(context, width: 100, height: 16),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          // Recent chips row
          Wrap(
            spacing: ResponsiveConstants.xsSpacing,
            runSpacing: ResponsiveConstants.xsSpacing,
            children: List.generate(6, (i) => _bar(context, width: 80, height: 28, radius: 20)),
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          // Suggestions title
          _bar(context, width: 140, height: 16),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          // Suggestion rows
          ...List.generate(8, (i) => Padding(
                padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.xsSpacing),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: ResponsiveConstants.smSpacing),
                    Expanded(child: _bar(context, height: 14)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
