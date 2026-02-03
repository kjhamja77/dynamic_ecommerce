import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';
// import '../../../../core/widgets/app_loading_widget.dart';
import '../widgets/search_shimmer.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_categories_widget.dart';
import '../widgets/search_tab_content_widget.dart';
import '../../../home/presentation/widgets/welcome_section_widget.dart';
import 'search_input_page.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  List<String> _tabNames = []; // Will be updated dynamically

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabNames.length, 
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    
    // Set initial tab to second tab (index 1) if available, otherwise 0
    if (_tabNames.isNotEmpty && _tabNames.length > 1) {
      _tabController.index = 1;
    } else if (_tabNames.isNotEmpty) {
      _tabController.index = 0;
    }
    
    // Load initial data using the combined method to prevent race conditions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final bloc = context.read<SearchBloc>();
        final state = bloc.state;
        if (state is! SearchLoaded && state is! SearchLoading) {
          bloc.add(const LoadSearchData());
        } else if (state is SearchLoaded) {
          _updateTabsFromState(state);
        }
      } catch (e) {
        debugPrint('⚠️ SearchPage: Failed to load initial data (bloc may be closed): $e');
      }
    });
  }

  void _updateTabsFromState(SearchLoaded state) {
    if (!mounted) return;
    
    final newTabNames = state.tabs.map((tab) => tab.title.toLowerCase()).toList();
    
    // Only update if the tabs have actually changed
    if (_tabNames.toString() != newTabNames.toString()) {
      setState(() {
        _tabNames = newTabNames;
        
        // CRITICAL: Always recreate TabController if length changed or if it's 0
        // This ensures TabController length always matches TabBarView children count
        if (_tabController.length != _tabNames.length || _tabNames.isEmpty) {
          _tabController.dispose();
          // Use at least 1 to prevent TabController error (even if tabs are empty)
          final controllerLength = _tabNames.isEmpty ? 1 : _tabNames.length;
          _tabController = TabController(
            length: controllerLength,
            vsync: this,
            animationDuration: const Duration(milliseconds: 200),
          );
          
          // Set initial tab to first tab (index 0)
          if (_tabNames.isNotEmpty) {
            _tabController.index = 0;
            
            // Load subcategories for the initial tab only if not already loaded
            final initialTabId = state.tabs[0].id;
            final subcategories = state.subcategories[initialTabId];
            final isLoading = state.loadingSubcategories.contains(initialTabId);
            
            if (subcategories == null && !isLoading && mounted) {
              try {
                context.read<SearchBloc>().add(LoadSubcategories(initialTabId));
              } catch (e) {
                debugPrint('⚠️ SearchPage: Failed to add LoadSubcategories event: $e');
              }
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // This method is called when user types in the search field
    // For now, we don't need to do anything here since navigation is handled by onTapNavigate
  }

  void _navigateToSearchInput() {
    // Navigate to search input page when user taps the search field
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SearchBloc>(),
          child: const SearchInputPage(),
        ),
      ),
    );
  }

  void _onTabChanged(int index) async {
    if (!mounted) return;
    await HapticService.selectionClick();
    
    try {
      final bloc = context.read<SearchBloc>();
      final selectedTabId = _tabNames[index];
      bloc.add(SelectSearchTab(selectedTabId));
      
      // Only load subcategories if they haven't been loaded yet
      final currentState = bloc.state;
      if (currentState is SearchLoaded) {
        final subcategories = currentState.subcategories[selectedTabId];
        final isLoading = currentState.loadingSubcategories.contains(selectedTabId);
        
        // Only load if not already loaded and not currently loading
        if (subcategories == null && !isLoading && mounted) {
          bloc.add(LoadSubcategories(selectedTabId));
        }
      }
    } catch (e) {
      debugPrint('⚠️ SearchPage: Failed to handle tab change (bloc may be closed): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchLoaded && state.tabs.isNotEmpty) {
            _updateTabsFromState(state);
          }
        },
        builder: (context, state) {
          if (state is SearchInitial || state is SearchLoading) {
            return const SearchShimmer();
          }

          // Handle ProductSearchLoaded state by showing the normal search page
          if (state is ProductSearchLoaded || state is ProductSearchLoading || state is ProductSearchError) {
            // Reload the search data to get back to SearchLoaded state
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              try {
                context.read<SearchBloc>().add(const LoadSearchData());
              } catch (e) {
                debugPrint('⚠️ SearchPage: Failed to reload search data (bloc may be closed): $e');
              }
            });
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
                      if (!mounted) return;
                      await HapticService.buttonClick();
                      try {
                        context.read<SearchBloc>().add(const LoadSearchData());
                      } catch (e) {
                        debugPrint('⚠️ SearchPage: Failed to retry (bloc may be closed): $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }

          if (state is SearchLoaded) {
            return Column(
              children: [
                // Welcome Section with animated promo messages
                const WelcomeSectionWidget(),
                
                // Search Bar
                SearchBarWidget(
                  controller: _searchController,
                  onSearchChanged: _onSearchChanged,
                  onTapNavigate: _navigateToSearchInput,
                ),

                // Category Tabs (only show if there are tabs AND TabController length matches)
                if (state.tabs.isNotEmpty && _tabController.length == state.tabs.length) ...[
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: TabBar(
                            controller: _tabController,
                            onTap: _onTabChanged,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelColor: Theme.of(context).colorScheme.onSurface,
                            labelStyle: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            unselectedLabelStyle: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w400,
                            ),
                            labelPadding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              ),
                              insets: EdgeInsets.symmetric(
                                horizontal: ResponsiveConstants.mdPadding,
                              ),
                            ),
                            indicatorSize: TabBarIndicatorSize.label,
                            splashFactory: NoSplash.splashFactory,
                            splashBorderRadius: BorderRadius.zero,
                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                            dividerColor: Colors.transparent,
                            tabs: state.tabs.map((tab) {
                              final isLoading = state.loadingSubcategories.contains(tab.id);
                              final tabIndex = state.tabs.indexOf(tab);
                              final isSelected = _tabController.index == tabIndex;
                              return Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(tab.title),
                                    if (isLoading) ...[
                                      SizedBox(width: ResponsiveConstants.smSpacing),
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isSelected ? Colors.black : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Refresh categories/subcategories (same idea as the home screen refresh)
                        IconButton(
                          tooltip: AppLocalizations.of(context)!.refresh,
                          onPressed: () async {
                            if (!mounted) return;
                            await HapticService.buttonClick();
                            try {
                              final bloc = context.read<SearchBloc>();
                              // Check if bloc is still active before adding events
                              bloc.add(const LoadSearchData());
                              // Load subcategories again after refresh
                              bloc.add(const LoadAllSubcategories());
                            } catch (e) {
                              debugPrint('⚠️ SearchPage: Failed to add refresh events (bloc may be closed): $e');
                            }
                          },
                          icon: Icon(
                            Icons.refresh,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: ResponsiveConstants.lgSpacing),

                  // Tab Content
                  // CRITICAL: Only build TabBarView if TabController length matches tabs count
                  // This prevents "Controller's length property (0) does not match" error
                  Expanded(
                    child: _tabController.length == state.tabs.length && state.tabs.isNotEmpty
                        ? TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(state.tabs.length, (index) {
                              final tab = state.tabs[index];
                              return SearchTabContentWidget(
                                tabId: tab.id,
                                tabTitle: tab.title,
                                tabIndex: index,
                              );
                            }),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                ] else ...[
                  // Show categories directly when no tabs are available
                  Expanded(
                    child: SearchCategoriesWidget(
                      searchQuery: state.searchQuery,
                      selectedTabIndex: 0,
                    ),
                  ),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}
