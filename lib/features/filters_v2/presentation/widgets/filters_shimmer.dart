import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/responsive_constants.dart';

class FiltersShimmer extends StatelessWidget {
  const FiltersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      children: [
        _sectionTitle(),
        _line(height: 20, width: 180),
        SizedBox(height: ResponsiveConstants.smSpacing),
        _line(height: 16, width: 220),
        SizedBox(height: ResponsiveConstants.mdSpacing),

        _sectionTitle(),
        Wrap(
          spacing: ResponsiveConstants.xsSpacing,
          runSpacing: ResponsiveConstants.xsSpacing,
          children: List.generate(10, (i) => _chip(width: 88 + (i % 3) * 24.0)),
        ),
        SizedBox(height: ResponsiveConstants.mdSpacing),

        _sectionTitle(),
        Wrap(
          spacing: ResponsiveConstants.xsSpacing,
          runSpacing: ResponsiveConstants.xsSpacing,
          children: List.generate(10, (i) => _chip(width: 78 + (i % 4) * 20.0)),
        ),
        SizedBox(height: ResponsiveConstants.mdSpacing),

        _sectionTitle(),
        Wrap(
          spacing: ResponsiveConstants.xsSpacing,
          runSpacing: ResponsiveConstants.xsSpacing,
          children: List.generate(12, (i) => _chip(width: 70 + (i % 5) * 18.0)),
        ),
        SizedBox(height: ResponsiveConstants.lgSpacing),

        Row(
          children: [
            Expanded(child: _button(height: 48)),
            SizedBox(width: ResponsiveConstants.smSpacing),
            Expanded(child: _button(height: 48)),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle() {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.smSpacing),
      child: _line(height: 16, width: 140),
    );
  }

  Widget _line({required double height, required double width}) {
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
          period: const Duration(milliseconds: 1100),
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  Widget _chip({required double width}) {
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
          period: const Duration(milliseconds: 1100),
          child: Container(
            height: 32,
            width: width,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _button({required double height}) {
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
          period: const Duration(milliseconds: 1100),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
        );
      },
    );
  }
}



