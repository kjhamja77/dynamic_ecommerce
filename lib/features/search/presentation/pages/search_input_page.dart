import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/search_bloc.dart';
import 'search_results_page.dart';
import '../../data/datasources/search_local_data_source.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../l10n/app_localizations.dart';

class SearchInputPage extends StatefulWidget {
  const SearchInputPage({super.key});

  @override
  State<SearchInputPage> createState() => _SearchInputPageState();
}

class _SearchInputPageState extends State<SearchInputPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Persist to recent searches
      try {
        final sl = GetIt.instance;
        if (sl.isRegistered<SearchLocalDataSource>()) {
          sl<SearchLocalDataSource>().addRecentSearch(query);
        }
      } catch (_) {}
      // Navigate to search results page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<SearchBloc>(),
            child: SearchResultsPage(searchQuery: query),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
            size: ResponsiveConstants.mdIconSize,
          ),
          onPressed: () async {
            await HapticService.buttonClick();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          AppLocalizations.of(context)!.search,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveConstants.mdPadding,
              vertical: ResponsiveConstants.smPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
                onChanged: (_) => setState(() {}),
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchHint,
                  hintStyle: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: ResponsiveConstants.lgIconSize,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade500,
                            size: ResponsiveConstants.mdIconSize,
                          ),
                          onPressed: () async {
          await HapticService.buttonClick();
          _searchController.clear();
                            setState(() {
        });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.mdPadding,
                    vertical: ResponsiveConstants.smPadding,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
        children: [
          // Search suggestions or recent searches could go here
          Expanded(
            child: _buildEmptyState(context),
          ),
          
            // Search button - moved up from bottom with SafeArea padding
          Padding(
              padding: EdgeInsets.only(
                left: ResponsiveConstants.mdPadding,
                right: ResponsiveConstants.mdPadding,
                top: ResponsiveConstants.smPadding,
                bottom: ResponsiveConstants.mdPadding,
              ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchController.text.trim().isNotEmpty ? _performSearch : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveConstants.mdPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.search,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final sl = GetIt.instance;
    List<String> recent = [];
    try {
      if (sl.isRegistered<SearchLocalDataSource>()) {
        recent = sl<SearchLocalDataSource>().getRecentSearches();
      }
    } catch (_) {}
 
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: ResponsiveConstants.xxlIconSize,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                Text(
                  AppLocalizations.of(context)!.startSearching,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.lgFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.smSpacing),
                Text(
                  AppLocalizations.of(context)!.enterSearchTerm,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.mdFontSize,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.xlSpacing),
                if (recent.isNotEmpty) ...[
                  Text(
                    AppLocalizations.of(context)!.recentSearches,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.mdSpacing),
                  Wrap(
                    spacing: ResponsiveConstants.smSpacing,
                    runSpacing: ResponsiveConstants.smSpacing,
                    children: recent
                        .map((q) => _buildSearchSuggestionChip(q, context))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSuggestionChip(String suggestion, BuildContext context) {
    return InkWell(
      onTap: () async {
          await HapticService.buttonClick();
          _searchController.text = suggestion;
        setState(() {
        });
        _performSearch();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.mdPadding,
          vertical: ResponsiveConstants.smPadding,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          suggestion,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.smFontSize,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}