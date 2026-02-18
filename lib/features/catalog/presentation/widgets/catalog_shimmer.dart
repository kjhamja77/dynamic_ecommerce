import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class CatalogShimmer extends StatelessWidget {
  const CatalogShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: colorScheme.background,
          elevation: 0,
          floating: true,
          snap: true,
          title: _line(context, width: 160, height: 20, radius: 6),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: ResponsiveConstants.smPadding),
              child: _circle(context, size: 28),
            )
          ],
        ),

        // Suggested Filters bar placeholder
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveConstants.mdPadding,
              ResponsiveConstants.smPadding,
              ResponsiveConstants.mdPadding,
              ResponsiveConstants.smPadding,
            ),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  _chip(context),
                  SizedBox(width: ResponsiveConstants.xsSpacing),
                  _chip(context, width: 100),
                  SizedBox(width: ResponsiveConstants.xsSpacing),
                  _chip(context, width: 80),
                ],
              ),
            ),
          ),
        ),

        // Grid placeholders
        SliverPadding(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveConstants.gridCrossAxisCount,
              crossAxisSpacing: ResponsiveConstants.gridSpacing,
              mainAxisSpacing: ResponsiveConstants.gridSpacing,
              childAspectRatio: ResponsiveConstants.catalogGridChildAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _card(context),
              childCount: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context) {
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
      period: const Duration(milliseconds: 1100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image placeholder (match product card aspect)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          // Brand line
          _line(context, width: double.infinity, height: 12, radius: 6),
          SizedBox(height: ResponsiveConstants.xsSpacing / 2),
          // Title line
          _line(context, width: double.infinity, height: 12, radius: 6),
          SizedBox(height: ResponsiveConstants.xsSpacing / 2),
          // Price row
          Row(
            children: [
              Expanded(child: _line(context, width: double.infinity, height: 12, radius: 6)),
              SizedBox(width: ResponsiveConstants.xsSpacing),
              _line(context, width: 32, height: 12, radius: 6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(BuildContext context, {required double width, required double height, required double radius}) {
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
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _circle(BuildContext context, {required double size}) {
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
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, {double width = 80}) {
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
        height: 32,
        width: width,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class CatalogShimmerTile extends StatelessWidget {
  const CatalogShimmerTile({super.key});

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
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}


