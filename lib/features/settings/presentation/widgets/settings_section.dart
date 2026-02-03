import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/unified_section_header.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: ResponsiveConstants.lgSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UnifiedSectionHeader(
            title: title,
            icon: Icons.tune,
            color: Colors.black,
            margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.xsSpacing),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.xsSpacing),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
