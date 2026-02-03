import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
// import '../../../../core/widgets/app_loading_widget.dart';
import 'search_shimmer.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import 'expandable_category_list_widget.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class SearchCategoriesWidget extends StatefulWidget {
  final String? searchQuery;
  final int selectedTabIndex;

  const SearchCategoriesWidget({
    super.key,
    this.searchQuery,
    required this.selectedTabIndex,
  });

  @override
  State<SearchCategoriesWidget> createState() => _SearchCategoriesWidgetState();
}

class _SearchCategoriesWidgetState extends State<SearchCategoriesWidget> {
  @override
  void initState() {
    super.initState();
    // Load subcategories for categories that have them
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubcategories();
    });
  }

  void _loadSubcategories() {
    // Load all subcategories at once to avoid race conditions
    context.read<SearchBloc>().add(const LoadAllSubcategories());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        
        if (state is SearchInitial || state is SearchLoading) {
          return const SearchShimmer();
        }

        if (state is SearchError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveConstants.xlIconSize,
                  color: Colors.red.shade400,
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  '${AppLocalizations.of(context)!.error}: ${state.message}',
                  style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.red.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                ElevatedButton(
                  onPressed: () async {
          await HapticService.buttonClick();
          context.read<SearchBloc>().add(const LoadSearchData());
        },
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          );
        }

        if (state is SearchLoaded) {
          final categories = state.categories;
          
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: ResponsiveConstants.xlIconSize,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Text(
                    widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                        ? '${AppLocalizations.of(context)!.noResultsFoundFor} "${widget.searchQuery}"'
                        : AppLocalizations.of(context)!.noCategoriesAvailable,
                    style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ExpandableCategoryListWidget(
            categories: categories,
            searchQuery: widget.searchQuery,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
