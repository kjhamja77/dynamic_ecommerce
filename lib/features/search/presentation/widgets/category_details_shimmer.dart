import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class CategoryDetailsShimmer extends StatelessWidget {
  const CategoryDetailsShimmer({super.key});

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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveConstants.mdPadding,
              ResponsiveConstants.mdPadding,
              ResponsiveConstants.mdPadding,
              ResponsiveConstants.smPadding,
            ),
            child: _buildShimmerBox(
              context,
              height: 20,
              width: 100,
              radius: 8,
            ),
          ),
          
          // List items
          ...List.generate(8, (index) => _buildCategoryItemShimmer(context)),
        ],
      ),
    );
  }

  Widget _buildCategoryItemShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.mdPadding,
          vertical: ResponsiveConstants.mdPadding,
        ),
        child: Row(
          children: [
            // Icon placeholder
            _buildShimmerBox(
              context,
              height: 32,
              width: 32,
              radius: 6,
            ),
            
            SizedBox(width: ResponsiveConstants.mdSpacing),
            
            // Title placeholder
            Expanded(
              child: _buildShimmerBox(
                context,
                height: 18,
                width: double.infinity,
                radius: 8,
              ),
            ),
            
            SizedBox(width: ResponsiveConstants.mdSpacing),
            
            // Chevron placeholder
            _buildShimmerBox(
              context,
              height: 20,
              width: 20,
              radius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(
    BuildContext context, {
    required double height,
    required double width,
    required double radius,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

