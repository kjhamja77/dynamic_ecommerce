import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';

class AboutProductSection extends StatefulWidget {
  final String description;

  const AboutProductSection({
    super.key,
    required this.description,
  });

  @override
  State<AboutProductSection> createState() => _AboutProductSectionState();
}

class _AboutProductSectionState extends State<AboutProductSection> with TickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Check if description is empty or null
    final bool hasDescription = widget.description.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.aboutThisProduct,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.mdFontSize,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveConstants.smSpacing),
        
        // Show content or empty state
        if (hasDescription) 
          _buildDescriptionContent(context)
        else
          _buildEmptyState(context),
      ],
    );
  }

  Widget _buildDescriptionContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = AppFonts.getTextStyle(
      fontSize: ResponsiveConstants.smFontSize,
      color: colorScheme.onSurface.withValues(alpha: 0.7),
      height: 1.5,
    );

    // Render HTML while preserving the previous expand/collapse UX
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: ResponsiveConstants.smDuration,
          curve: ResponsiveConstants.defaultCurve,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: _isExpanded
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: 120), // ~3 lines average height
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Html(
                data: widget.description,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(textStyle.fontSize ?? 14),
                    lineHeight: LineHeight(textStyle.height ?? 1.5),
                    color: textStyle.color,
                    fontWeight: textStyle.fontWeight,
                  ),
                },
              ),
            ),
          ),
        ),
        SizedBox(height: ResponsiveConstants.xsSpacing),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? AppLocalizations.of(context)!.readLess : AppLocalizations.of(context)!.readMore,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.smFontSize,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: ResponsiveConstants.xsSpacing),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                size: ResponsiveConstants.smIconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: ResponsiveConstants.lgIconSize,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            AppLocalizations.of(context)!.noProductDescription,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.xsSpacing),
          Text(
            AppLocalizations.of(context)!.productDescriptionComingSoon,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
