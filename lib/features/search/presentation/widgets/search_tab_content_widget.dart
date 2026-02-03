import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../constants/category_card_theme.dart';
import 'search_shimmer.dart';
import 'subcategory_shimmer.dart';
import 'expandable_category_list_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class SearchTabContentWidget extends StatefulWidget {
  final String tabId;
  final String tabTitle;
  final int tabIndex;

  const SearchTabContentWidget({
    super.key,
    required this.tabId,
    required this.tabTitle,
    required this.tabIndex,
  });

  @override
  State<SearchTabContentWidget> createState() => _SearchTabContentWidgetState();
}

class _SearchTabContentWidgetState extends State<SearchTabContentWidget> {
  @override
  void initState() {
    super.initState();
    // Load subcategories for this specific tab only if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final bloc = context.read<SearchBloc>();
        if (bloc.isClosed) return;
        
        final currentState = bloc.state;
        if (currentState is SearchLoaded) {
          final subcategories = currentState.subcategories[widget.tabId];
          final isLoading = currentState.loadingSubcategories.contains(widget.tabId);
          
          // Only load if not already loaded and not currently loading
          if (subcategories == null && !isLoading) {
            if (!mounted || bloc.isClosed) return;
            bloc.add(LoadSubcategories(widget.tabId));
          }
        }
      } catch (e) {
        debugPrint('⚠️ SearchTabContentWidget: Error in initState callback: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchInitial || state is SearchLoading) {
          return const SearchShimmer();
        }

        if (state is SearchError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.lgPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: ResponsiveConstants.xlIconSize,
                    color: colorScheme.error,
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Text(
                    AppLocalizations.of(context)!.somethingWentWrong,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveConstants.smSpacing),
                  Text(
                    state.message,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      color: colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.7 : 0.6,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveConstants.lgSpacing),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (!mounted) return;
                      // Fire-and-forget to avoid any perceived lag on tap
                      HapticService.buttonClick();
                      try {
                        final bloc = context.read<SearchBloc>();
                        if (!bloc.isClosed) {
                          // When we're in an error state the safest recovery is to
                          // reload the whole search data (categories + tabs).
                          bloc.add(const LoadSearchData());
                        }
                      } catch (e) {
                        debugPrint('⚠️ SearchTabContentWidget: Error reloading subcategories: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveConstants.lgPadding,
                        vertical: ResponsiveConstants.smPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.tryAgain),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is SearchLoaded) {
          final isLoading = state.loadingSubcategories.contains(widget.tabId);
          final subcategories = state.subcategories[widget.tabId];
          
          // Show shimmer while loading
          if (isLoading) {
            return const SubcategoryShimmer();
          }
          
          // Show shimmer if subcategories haven't been loaded yet (null)
          if (subcategories == null) {
            return const SubcategoryShimmer();
          }
          
          // Show empty state if subcategories are loaded but empty
          if (subcategories.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.lgPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: ResponsiveConstants.xlIconSize,
                      color: colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.5 : 0.4,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.mdSpacing),
                    Text(
                      AppLocalizations.of(context)!.noSubcategoriesFound,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xlFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveConstants.smSpacing),
                    Text(
                      AppLocalizations.of(context)!.tryDifferentSearchTerms,
                      textAlign: TextAlign.center,
                      style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                        color: colorScheme.onSurface.withValues(
                          alpha: isDark ? 0.7 : 0.6,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.lgSpacing),
                  ElevatedButton.icon(
                      onPressed: () {
                        if (!mounted) return;
                        // Fire-and-forget haptic + refresh to keep the button feeling snappy
                        HapticService.buttonClick();
                        try {
                          final bloc = context.read<SearchBloc>();
                          if (!bloc.isClosed) {
                            bloc.add(LoadSubcategories(widget.tabId));
                          }
                        } catch (e) {
                          debugPrint('⚠️ SearchTabContentWidget: Error refreshing subcategories: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.lgPadding,
                          vertical: ResponsiveConstants.smPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(AppLocalizations.of(context)!.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          return ExpandableCategoryListWidget(
            categories: subcategories,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
