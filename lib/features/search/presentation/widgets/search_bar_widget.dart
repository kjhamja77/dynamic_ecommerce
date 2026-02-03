import 'package:flutter/material.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../filters_v2/presentation/pages/filters_loading_page.dart';
import '../../../filters/domain/entities/filter_criteria.dart';
import '../../../catalog/domain/models/catalog_args.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;
  final VoidCallback? onTapNavigate;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    this.onTapNavigate,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: ResponsiveConstants.mdIconSize,
          ),
          SizedBox(width: ResponsiveConstants.smSpacing),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              readOnly: onTapNavigate != null,
              onTap: onTapNavigate,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.whatAreYouLookingFor,
                hintStyle: AppFonts.getTextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: ResponsiveConstants.mdFontSize,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await HapticService.buttonClick();
              if (onFilterTap != null) {
                onFilterTap!();
              } else {
                // Default behavior: navigate to filter screen without search query
                final criteria = await Navigator.of(context).push<FilterCriteria>(
                  MaterialPageRoute(
                    builder: (_) => FiltersLoadingPage(
                      initial: const FilterCriteria(),
                      category: null,
                      brand: null,
                      query: null, // No search query - allows filtering without typing
                    ),
                  ),
                );
                
                // If filters were applied, navigate to catalog page with the filters
                if (criteria != null && context.mounted) {
                  // Navigate to catalog page with filter criteria
                  final catalogArgs = CatalogArgs(
                    title: AppLocalizations.of(context)!.filters,
                    category: criteria.category,
                    brand: criteria.brand,
                    query: null,
                    initialFilters: criteria, // Pass filter criteria to be applied on load
                  );
                  
                  Navigator.of(context).pushNamed(
                    '/catalog',
                    arguments: catalogArgs,
                  );
                }
              }
            },
            child: Container(
              padding: EdgeInsets.all(ResponsiveConstants.xsPadding),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(ResponsiveConstants.smRadius),
              ),
              child: Icon(
                Icons.tune,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: ResponsiveConstants.smIconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
