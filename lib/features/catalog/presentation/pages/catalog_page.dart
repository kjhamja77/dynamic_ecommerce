import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../home/presentation/widgets/common/product_card.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../../domain/models/catalog_args.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../filters/domain/entities/filter_criteria.dart';
import '../../../filters/domain/entities/filter_options.dart';
import '../../../filters_v2/presentation/pages/filters_loading_page.dart';
import '../../../filters/domain/repositories/filter_repository.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../widgets/catalog_shimmer.dart';
import '../../../../core/widgets/sort_sheet.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/widgets/app_pull_to_refresh.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../compare/presentation/cubit/compare_cubit.dart';
import '../../../compare/presentation/pages/compare_page.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';

class CatalogPage extends StatefulWidget {
  final CatalogArgs args;
  const CatalogPage({super.key, required this.args});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  bool _filtersApplied = false; // Flag to ensure filters are applied only once
  Future<FilterOptions?>? _filterOptionsFuture; // Cache filter options
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarVisible = true;
  double _lastScrollOffset = 0;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final currentOffset = _scrollController.offset;
    final scrollDelta = currentOffset - _lastScrollOffset;
    
    // Reduced threshold (3px) for faster, more responsive app bar animation
    if (scrollDelta > 3 && _isAppBarVisible && currentOffset > 10) {
      // Scrolling down - hide app bar
      setState(() => _isAppBarVisible = false);
    } else if (scrollDelta < -3 && !_isAppBarVisible) {
      // Scrolling up - show app bar immediately
      setState(() => _isAppBarVisible = true);
    }
    
    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CatalogBloc(
            fetchCatalogPage: di.sl(),
            filterDataSource: di.sl(),
            repository: di.sl(),
          )..add(LoadCatalog(widget.args)),
        ),
        BlocProvider(create: (_) => CompareCubit()),
      ],
      child: BlocListener<CatalogBloc, CatalogState>(
        listener: (context, state) {
          // Apply initial filters after catalog loads (only once)
          if (widget.args.initialFilters != null && 
              state is CatalogLoaded && 
              !_filtersApplied) {
            _filtersApplied = true; // Mark as applied to prevent duplicate application
            final criteria = widget.args.initialFilters!;
            final bloc = context.read<CatalogBloc>();
            
            // Apply filters after a short delay to ensure catalog is fully loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Pass FilterCriteria directly to preserve exact values
                bloc.add(UpdateCatalogFilters(
                  filterCriteria: criteria.copyWith(searchQuery: state.query), // Preserve search query
                ));
              }
            });
          }
        },
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            
            return Scaffold(
              backgroundColor: colorScheme.background,
              body: SafeArea(
                bottom: true,
                top: false,
                left: false,
                right: false,
                child: BlocBuilder<CatalogBloc, CatalogState>(
                builder: (context, state) {
                  if (state is CatalogInitial || state is CatalogLoading) {
                    return const CatalogShimmer();
                  }
                  if (state is CatalogError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppFonts.getTextStyle(color: colorScheme.onSurface),
                      ),
                    );
                  }
                  final s = state as CatalogLoaded;
                  return NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 && s.hasMore && !s.isLoadingMore) {
                        context.read<CatalogBloc>().add(const LoadMoreCatalog());
                      }
                      return false;
                    },
                    child: AppPullToRefresh(
                      onRefresh: () async {
                        final bloc = context.read<CatalogBloc>();
                        final current = bloc.state as CatalogLoaded;
                        bloc.add(UpdateCatalogFilters(
                          category: current.selectedCategory,
                          categoryIds: current.categoryIds, // Preserve categoryIds during refresh
                          brand: current.selectedBrand,
                          sortBy: current.sortBy,
                          query: current.query,
                          selectedColors: current.selectedColors,
                          sizes: current.sizes,
                          materials: current.materials,
                          seasons: current.seasons,
                          genders: current.genders,
                          minPrice: current.minPrice,
                          maxPrice: current.maxPrice,
                          minRating: current.minRating,
                          onSale: current.onSale,
                          inStock: current.inStock,
                        ));
                      },
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: Theme.of(context).platform == TargetPlatform.iOS
                            ? const ClampingScrollPhysics()
                            : const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            backgroundColor: colorScheme.background,
                            elevation: 0,
                            floating: true,
                            pinned: false,
                            snap: true,
                            leading: Navigator.of(context).canPop()
                                ? AnimatedOpacity(
                                    opacity: _isAppBarVisible ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 150),
                                    child: IconButton(
                                      tooltip: null,
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: colorScheme.onSurface,
                                      ),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                  )
                                : null,
                            title: AnimatedOpacity(
                              opacity: _isAppBarVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 150),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.args.title,
                                    style: AppFonts.getTextStyle(
                                      fontSize: ResponsiveConstants.titleFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                          Row(
                            children: [
                              if (s.isFiltering) ...[
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.filtering,
                                  style: AppFonts.getTextStyle(
                                    fontSize: ResponsiveConstants.smFontSize,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  '${s.totalCount} ${AppLocalizations.of(context)!.results}',
                                  style: AppFonts.getTextStyle(
                                    fontSize: ResponsiveConstants.smFontSize,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                            ),
                            actions: [
                        AnimatedOpacity(
                          opacity: _isAppBarVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          child: IconButton(
                            tooltip: null,
                            icon: Icon(
                              Icons.sort,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () {
                              final bloc = context.read<CatalogBloc>();
                              HapticService.buttonClick();
                              final currentState = bloc.state;
                              if (currentState is CatalogLoaded) {
                                _showSortSheet(context, currentState);
                              }
                            },
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _isAppBarVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 150),
                          child: IconButton(
                            tooltip: null,
                            icon: Icon(
                              Icons.tune,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final bloc = context.read<CatalogBloc>();
                            await HapticService.buttonClick();
                            final state = bloc.state as CatalogLoaded;

                            // Build categoryIds list - prioritize in this order:
                            // 1. categoryIds from state (set when filters were applied)
                            // 2. selectedCategoryId from state (set when catalog loads with categoryId)
                            // 3. categoryId from widget args (direct navigation to category catalog)
                            List<int> categoryIds = [];
                            if (state.categoryIds != null && state.categoryIds!.isNotEmpty) {
                              categoryIds = state.categoryIds!;
                            } else if (state.selectedCategoryId != null) {
                              // If categoryId is set in state, use it
                              final catId = int.tryParse(state.selectedCategoryId!);
                              if (catId != null) {
                                categoryIds = [catId];
                              }
                            } else if (widget.args.categoryId != null) {
                              // Fallback to categoryId from catalog args (for direct navigation)
                              final catId = int.tryParse(widget.args.categoryId!);
                              if (catId != null) {
                                categoryIds = [catId];
                              }
                            }
                            
                            print('🔍 CatalogPage: Opening filters with categoryIds: $categoryIds (from state.categoryIds: ${state.categoryIds}, state.selectedCategoryId: ${state.selectedCategoryId}, widget.args.categoryId: ${widget.args.categoryId})');

                            final criteria = await navigator.push<FilterCriteria>(
                              MaterialPageRoute(
                                builder: (_) => FiltersLoadingPage(
                                  initial: FilterCriteria(
                                    minPrice: state.minPrice,
                                    maxPrice: state.maxPrice,
                                    minRating: state.minRating,
                                    onSale: state.onSale,
                                    inStock: state.inStock,
                                    sizes: state.sizes,
                                    colors: state.selectedColors,
                                    materials: state.materials,
                                    seasons: state.seasons,
                                    genders: state.genders,
                                    brand: state.selectedBrand == AppLocalizations.of(context)!.all ? null : state.selectedBrand,
                                    category: state.selectedCategory == AppLocalizations.of(context)!.all ? null : state.selectedCategory,
                                    categoryIds: categoryIds, // Pass categoryIds if coming from category catalog page
                                    extraAttributes: state.extraAttributes,
                                  ),
                                  category: state.selectedCategory,
                                  brand: state.selectedBrand,
                                  query: state.query,
                                ),
                              ),
                            );

                            if (criteria != null && navigator.mounted) {
                              print('📤📤📤 CatalogPage: Received FilterCriteria from filters page 📤📤📤');
                              print('   ==========================================');
                              print('   Category IDs: ${criteria.categoryIds}');
                              print('   Brand IDs: ${criteria.brandIds}');
                              print('   Limit: ${criteria.limit}');
                              print('   Sort: ${criteria.sortByField} (${criteria.sortOrder})');
                              print('   Page: ${criteria.page}');
                              print('   ==========================================');
                              
                              // CRITICAL: Preserve FilterCriteria exactly as received from filters page
                              // Only add searchQuery if it's not already set in criteria (preserve existing search query)
                              final finalCriteria = criteria.searchQuery != null 
                                  ? criteria 
                                  : criteria.copyWith(searchQuery: state.query);
                              
                              // Verify copyWith didn't modify other fields
                              assert(
                                finalCriteria.limit == criteria.limit,
                                'copyWith must preserve limit: expected ${criteria.limit}, got ${finalCriteria.limit}',
                              );
                              assert(
                                finalCriteria.sortByField == criteria.sortByField,
                                'copyWith must preserve sortByField: expected ${criteria.sortByField}, got ${finalCriteria.sortByField}',
                              );
                              assert(
                                finalCriteria.sortOrder == criteria.sortOrder,
                                'copyWith must preserve sortOrder: expected ${criteria.sortOrder}, got ${finalCriteria.sortOrder}',
                              );
                              assert(
                                finalCriteria.brandIds == criteria.brandIds,
                                'copyWith must preserve brandIds: expected ${criteria.brandIds}, got ${finalCriteria.brandIds}',
                              );
                              
                              print('📤 CatalogPage: Final FilterCriteria (after preserving searchQuery):');
                              print('   Category IDs: ${finalCriteria.categoryIds}');
                              print('   Brand IDs: ${finalCriteria.brandIds}');
                              print('   Limit: ${finalCriteria.limit}');
                              print('   Sort: ${finalCriteria.sortByField} (${finalCriteria.sortOrder})');
                              print('   Search Query: ${finalCriteria.searchQuery}');
                              
                              // CRITICAL: Create event with FilterCriteria - this MUST be non-null
                              print('📤 CatalogPage: Creating UpdateCatalogFilters event with FilterCriteria');
                              print('   finalCriteria.limit: ${finalCriteria.limit}');
                              print('   finalCriteria.brandIds: ${finalCriteria.brandIds}');
                              print('   finalCriteria.sortByField: ${finalCriteria.sortByField}');
                              print('   finalCriteria.sortOrder: ${finalCriteria.sortOrder}');
                              
                              final event = UpdateCatalogFilters(
                                filterCriteria: finalCriteria, // This MUST be the FilterCriteria from filters page
                              );
                              
                              // Verify FilterCriteria is in the event IMMEDIATELY after creation
                              print('📤 CatalogPage: Event created, checking filterCriteria...');
                              print('   event.filterCriteria is null: ${event.filterCriteria == null}');
                              if (event.filterCriteria == null) {
                                print('❌❌❌ CRITICAL ERROR: Event does NOT have FilterCriteria!');
                                print('❌ This will cause the old path to be used, which will modify the FilterCriteria!');
                                print('❌ finalCriteria was: $finalCriteria');
                                throw StateError('FilterCriteria MUST be provided in UpdateCatalogFilters event');
                              }
                              
                              print('✅✅✅ CatalogPage: Event created with FilterCriteria');
                              print('   ✅ Limit: ${event.filterCriteria!.limit}');
                              print('   ✅ Sort: ${event.filterCriteria!.sortByField} (${event.filterCriteria!.sortOrder})');
                              print('   ✅ Brand IDs: ${event.filterCriteria!.brandIds}');
                              print('   ✅ Category IDs: ${event.filterCriteria!.categoryIds}');
                              print('   ✅ Full FilterCriteria: ${event.filterCriteria}');
                              
                              print('🚀 CatalogPage: Dispatching event to CatalogBloc...');
                              bloc.add(event);
                              print('✅ CatalogPage: Event dispatched successfully');
                            }
                          },
                          ),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(64),
                        child: SizedBox(
                          height: 64,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveConstants.mdPadding,
                              vertical: ResponsiveConstants.smPadding,
                            ),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                // Brand filter dropdown
                                if (widget.args.brand == null)
                                  Builder(
                                    builder: (context) {
                                      final l10n = AppLocalizations.of(context)!;
                                      // Filter out hardcoded 'All' and add localized "All" at the beginning
                                      final brandOptions = [
                                        l10n.all,
                                        ...s.brands.where((b) => b.toLowerCase() != 'all' && b != l10n.all),
                                      ];
                                      final isAllSelected = s.selectedBrand.toLowerCase() == 'all' || s.selectedBrand == l10n.all;
                                      // Show "Brand: Selected Brand" if a brand is selected, otherwise just "Brand"
                                      final displayLabel = isAllSelected 
                                          ? l10n.brand 
                                          : '${l10n.brand}: ${s.selectedBrand}';
                                      return _DropdownFilterChip(
                                        label: displayLabel,
                                        options: brandOptions,
                                        selected: isAllSelected ? l10n.all : s.selectedBrand,
                                        onSelected: (val) {
                                          // Convert localized "All" back to 'All' for the bloc
                                          final brandValue = val == l10n.all ? 'All' : val;
                                          context.read<CatalogBloc>().add(UpdateCatalogFilters(brand: brandValue));
                                        },
                                        icon: Icons.store_mall_directory_outlined,
                                      );
                                    },
                                  ),
                                SizedBox(width: ResponsiveConstants.xsSpacing),
                                // Color filter dropdown
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context)!;
                                    // Filter out hardcoded 'All' and add localized "All" at the beginning
                                    final colorOptions = [
                                      l10n.all,
                                      ...s.colors.where((c) => c.toLowerCase() != 'all' && c != l10n.all),
                                    ];
                                    // Show "Color: Selected Colors" if colors are selected, otherwise just "Color"
                                    final displayLabel = s.selectedColors.isEmpty 
                                        ? l10n.color 
                                        : s.selectedColors.length == 1
                                            ? '${l10n.color}: ${s.selectedColors.first}'
                                            : '${l10n.color}: ${s.selectedColors.join(', ')}';
                                    return _DropdownFilterChip(
                                      label: displayLabel,
                                      options: colorOptions,
                                      selected: s.selectedColors.isEmpty ? l10n.all : null,
                                      selectedMultiple: s.selectedColors.isEmpty ? null : s.selectedColors,
                                      onSelected: (val) {
                                        List<String> newSelectedColors;
                                        if (val == l10n.all) {
                                          newSelectedColors = [];
                                        } else {
                                          // Toggle color selection
                                          if (s.selectedColors.contains(val)) {
                                            newSelectedColors = List.from(s.selectedColors)..remove(val);
                                          } else {
                                            newSelectedColors = List.from(s.selectedColors)..add(val);
                                          }
                                        }
                                        context.read<CatalogBloc>().add(UpdateCatalogFilters(selectedColors: newSelectedColors));
                                      },
                                      icon: Icons.color_lens_outlined,
                                    );
                                  },
                                ),
                                SizedBox(width: ResponsiveConstants.xsSpacing),
                                // On Sale toggle
                                _SuggestionChip(
                                  label: AppLocalizations.of(context)!.onSale,
                                  selected: s.onSale,
                                  onTap: () => context.read<CatalogBloc>().add(UpdateCatalogFilters(onSale: !s.onSale)),
                                ),
                                SizedBox(width: ResponsiveConstants.xsSpacing),
                                // In Stock toggle
                                _SuggestionChip(
                                  label: AppLocalizations.of(context)!.inStock,
                                  selected: s.inStock,
                                  onTap: () => context.read<CatalogBloc>().add(UpdateCatalogFilters(inStock: !s.inStock)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // (Removed) Suggested Filters bar now part of SliverAppBar.bottom

                    // Active filter chips (exclude pure search query)
                    if (s.selectedCategory != 'All' || s.selectedBrand != 'All' || 
                         s.sizes.isNotEmpty || s.selectedColors.isNotEmpty || s.materials.isNotEmpty || s.seasons.isNotEmpty || 
                         s.genders.isNotEmpty || s.onSale || s.inStock || s.minRating != null || s.minPrice != null || s.maxPrice != null || (s.sortBy != 'newest_first' && s.sortBy.isNotEmpty))
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(ResponsiveConstants.mdPadding, 0, ResponsiveConstants.mdPadding, ResponsiveConstants.smPadding),
                          child: Wrap(
                            key: ValueKey('${s.minPrice}-${s.maxPrice}-${s.onSale}-${s.inStock}-${s.selectedCategory}-${s.selectedBrand}-${s.selectedColors.join(',')}'),
                            spacing: ResponsiveConstants.xsSpacing,
                            runSpacing: ResponsiveConstants.xsSpacing,
                            children: [
                              Builder(builder: (_) {
                                debugPrint('🎯 ActiveChips ⇒ minPrice=${s.minPrice}, maxPrice=${s.maxPrice}, onSale=${s.onSale}, inStock=${s.inStock}, brand=${s.selectedBrand}, category=${s.selectedCategory}');
                                return const SizedBox.shrink();
                              }),
                              // Category filter (suppress when pre-scoped via args)
                              if (s.selectedCategory != 'All' && widget.args.category == null) _FilterChip(
                                label: s.selectedCategory,
                                onDeleted: () => context.read<CatalogBloc>().add(const UpdateCatalogFilters(category: 'All')),
                              ),
                              // Brand filter
                              if (s.selectedBrand != 'All' && widget.args.brand == null) _FilterChip(
                                label: s.selectedBrand,
                                onDeleted: () => context.read<CatalogBloc>().add(const UpdateCatalogFilters(brand: 'All')),
                              ),
                              // Intentionally omit search query from active tags
                              // Price filters
                              if (s.minPrice != null) _FilterChip(
                                label: '${AppLocalizations.of(context)!.min}: ${context.read<CurrencyProvider>().formatPrice(s.minPrice!, locale: Localizations.localeOf(context))}',
                                onDeleted: () => context.read<CatalogBloc>().add(const UpdateCatalogFilters(clearMinPrice: true, minPrice: null)),
                              ),
                              if (s.maxPrice != null) _FilterChip(
                                label: '${AppLocalizations.of(context)!.max}: ${context.read<CurrencyProvider>().formatPrice(s.maxPrice!, locale: Localizations.localeOf(context))}',
                                onDeleted: () => context.read<CatalogBloc>().add(const UpdateCatalogFilters(clearMaxPrice: true, maxPrice: null)),
                              ),
                              // Rating filter
                              if (s.minRating != null) _FilterChip(
                                label: '${s.minRating!}+ Rating',
                                onDeleted: () => context.read<CatalogBloc>().add(UpdateCatalogFilters(minRating: null)),
                              ),
                              // On sale filter
                              if (s.onSale) _FilterChip(
                                label: AppLocalizations.of(context)!.onSaleFilter,
                                onDeleted: () => context.read<CatalogBloc>().add(UpdateCatalogFilters(onSale: false)),
                              ),
                              // In stock filter
                              if (s.inStock) _FilterChip(
                                label: AppLocalizations.of(context)!.inStockFilter,
                                onDeleted: () => context.read<CatalogBloc>().add(UpdateCatalogFilters(inStock: false)),
                              ),
                              // Sort filter (if not default - default is newest_first ID)
                              if (s.sortBy != 'newest_first' && s.sortBy.isNotEmpty)
                                Builder(
                                  builder: (context) {
                                    // Cache filter options to avoid multiple API calls
                                    _filterOptionsFuture ??= _getFilterOptions();
                                    return FutureBuilder<FilterOptions?>(
                                      future: _filterOptionsFuture,
                                      builder: (context, snapshot) {
                                        String sortLabel = s.sortBy; // Fallback to ID
                                        if (snapshot.hasData && snapshot.data != null) {
                                          final sortOption = snapshot.data!.sortingOptions.firstWhere(
                                            (option) => option.id == s.sortBy,
                                            orElse: () => snapshot.data!.sortingOptions.first,
                                          );
                                          sortLabel = sortOption.name;
                                        }
                                        return _FilterChip(
                                          label: '${AppLocalizations.of(context)!.sortBy}: $sortLabel',
                                          onDeleted: () => context.read<CatalogBloc>().add(const UpdateCatalogFilters(sortBy: 'newest_first')),
                                        );
                                      },
                                    );
                                  },
                                ),
                              // Size filters
                              ...s.sizes.map((size) => _FilterChip(
                                label: size,
                                onDeleted: () {
                                  final newSizes = List<String>.from(s.sizes)..remove(size);
                                  context.read<CatalogBloc>().add(UpdateCatalogFilters(sizes: newSizes));
                                },
                              )),
                              // Color filters
                              ...s.selectedColors.map((color) => _FilterChip(
                                label: color,
                                onDeleted: () {
                                  final newSelectedColors = List<String>.from(s.selectedColors)..remove(color);
                                  context.read<CatalogBloc>().add(UpdateCatalogFilters(selectedColors: newSelectedColors));
                                },
                              )),
                              // Material filters
                              ...s.materials.map((material) => _FilterChip(
                                label: material,
                                onDeleted: () {
                                  final newMaterials = List<String>.from(s.materials)..remove(material);
                                  context.read<CatalogBloc>().add(UpdateCatalogFilters(materials: newMaterials));
                                },
                              )),
                              // Season filters
                              ...s.seasons.map((season) => _FilterChip(
                                label: season,
                                onDeleted: () {
                                  final newSeasons = List<String>.from(s.seasons)..remove(season);
                                  context.read<CatalogBloc>().add(UpdateCatalogFilters(seasons: newSeasons));
                                },
                              )),
                              // Gender filters
                              ...s.genders.map((gender) => _FilterChip(
                                label: gender,
                                onDeleted: () {
                                  final newGenders = List<String>.from(s.genders)..remove(gender);
                                  context.read<CatalogBloc>().add(UpdateCatalogFilters(genders: newGenders));
                                },
                              )),
                              // Clear All button - show only when user applied removable filters (exclude pre-scoped args)
                              if (((widget.args.category == null) && s.selectedCategory != 'All') ||
                                  ((widget.args.brand == null) && s.selectedBrand != 'All') ||
                                  s.sizes.isNotEmpty || s.selectedColors.isNotEmpty || s.materials.isNotEmpty || s.seasons.isNotEmpty ||
                                  s.genders.isNotEmpty || s.onSale || s.inStock || s.minRating != null || s.minPrice != null || s.maxPrice != null || (s.sortBy != 'newest_first' && s.sortBy.isNotEmpty))
                                _ClearAllChip(
                                  onPressed: () => context.read<CatalogBloc>().add(UpdateCatalogFilters(
                                    category: widget.args.category ?? 'All',
                                    brand: widget.args.brand ?? 'All',
                                    query: s.query, // keep query
                                    sortBy: 'newest_first', // Default sort option ID
                                    minPrice: null,
                                    maxPrice: null,
                                    clearMinPrice: true,
                                    clearMaxPrice: true,
                                    minRating: null,
                                    onSale: false,
                                    inStock: false,
                                    sizes: const [],
                                    selectedColors: const [],
                                    materials: const [],
                                    seasons: const [],
                                    genders: const [],
                                  )),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // Grid
                    SliverPadding(
                      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                      sliver: s.isFiltering
                          ? SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveConstants.gridCrossAxisCount,
                                crossAxisSpacing: ResponsiveConstants.gridSpacing,
                                mainAxisSpacing: ResponsiveConstants.gridSpacing,
                                childAspectRatio: ResponsiveConstants.catalogGridChildAspectRatio,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => const CatalogShimmerTile(),
                                childCount: 8, // Show 8 shimmer tiles while filtering
                              ),
                            )
                          : SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveConstants.gridCrossAxisCount,
                                crossAxisSpacing: ResponsiveConstants.gridSpacing,
                                mainAxisSpacing: ResponsiveConstants.gridSpacing,
                                childAspectRatio: ResponsiveConstants.catalogGridChildAspectRatio,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final bool isExtra = index >= s.products.length;
                                  if (isExtra) {
                                    // Show shimmer tile while loading more
                                    return s.isLoadingMore ? const CatalogShimmerTile() : const SizedBox.shrink();
                                  }
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, (1 - value) * 12),
                                        child: Opacity(opacity: value, child: child),
                                      );
                                    },
                                    child: Stack(
                                      children: [
                                        _CatalogProductCard(product: s.products[index]),
                                        // Compare toggle - top left
                                        Positioned(
                                          left: 4,
                                          top: 4,
                                          child: BlocBuilder<CompareCubit, CompareState>(
                                            builder: (context, cState) {
                                              final product = s.products[index];
                                              final selected = cState.selected.any((p) => p.id == product.id);
                                              return GestureDetector(
                                                onTap: () {
                                                  final cubit = context.read<CompareCubit>();
                                                  if (!cubit.isSelected(product.id) && cubit.state.selected.length >= cubit.maxItems) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('You can compare up to 4 products.')),
                                                    );
                                                    return;
                                                  }
                                                  cubit.toggle(product);
                                                },
                                                child: Builder(
                                                  builder: (context) {
                                                    final theme = Theme.of(context);
                                                    final colorScheme = theme.colorScheme;
                                                    final isDark = theme.brightness == Brightness.dark;
                                                    
                                                    return Container(
                                                      padding: const EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: selected 
                                                            ? colorScheme.primary 
                                                            : colorScheme.surface,
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(
                                                          color: selected 
                                                              ? colorScheme.primary 
                                                              : colorScheme.outline.withValues(alpha: 0.3),
                                                          width: 0.5,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withValues(
                                                              alpha: isDark ? 0.3 : 0.1,
                                                            ),
                                                            blurRadius: 6,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        Icons.compare_arrows, 
                                                        size: 14, 
                                                        color: selected 
                                                            ? colorScheme.onPrimary 
                                                            : colorScheme.onSurface.withValues(alpha: 0.6),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // Favorite button - top right
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: FavoriteButton(
                                            productId: s.products[index].id,
                                            productName: s.products[index].name,
                                            brand: s.products[index].brand,
                                            price: s.products[index].price,
                                            imageUrl: s.products[index].images.isNotEmpty ? s.products[index].images.first : null,
                                            category: s.products[index].category,
                                            size: 20,
                                            isCompact: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                childCount: s.products.length + (s.isLoadingMore ? ResponsiveConstants.gridCrossAxisCount : 0),
                              ),
                            ),
                    ),

                    // Empty state (only show when not filtering)
                    if (s.products.isEmpty && !s.isFiltering)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: ResponsiveConstants.xlIconSize,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              SizedBox(height: ResponsiveConstants.smSpacing),
                              Text(
                                AppLocalizations.of(context)!.noProductsFound,
                                style: AppFonts.getTextStyle(
                                  fontSize: ResponsiveConstants.mdFontSize,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Footer state
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.mdPadding),
                        child: Builder(
                          builder: (context) {
                            final colorScheme = Theme.of(context).colorScheme;
                            return Center(
                              child: s.isLoadingMore
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        colorScheme.primary,
                                      ),
                                    )
                                  : s.hasMore
                                      ? Text(
                                          AppLocalizations.of(context)!.scrollToLoadMore, 
                                          style: AppFonts.getTextStyle(
                                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                        )
                                      : Text(
                                          AppLocalizations.of(context)!.youHaveReachedTheEnd, 
                                          style: AppFonts.getTextStyle(
                                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                        ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
              },
            ),
            ),
            floatingActionButton: BlocBuilder<CompareCubit, CompareState>(
              builder: (context, cState) {
                final count = cState.selected.length;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final fade = FadeTransition(opacity: animation, child: child);
                    return ScaleTransition(scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation), child: fade);
                  },
                  child: Builder(
                    builder: (context) {
                      final colorScheme = Theme.of(context).colorScheme;
                      return count < 2
                          ? const SizedBox.shrink(key: ValueKey('compare_hidden'))
                          : FloatingActionButton.extended(
                              key: const ValueKey('compare_fab'),
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              onPressed: () {
                                final cubit = context.read<CompareCubit>();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: cubit,
                                      child: const ComparePage(),
                                    ),
                                  ),
                                );
                              },
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.compare_arrows),
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                      child: Center(
                                        child: Text(
                                          count > 9 ? '9+' : '$count',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              label: Text(AppLocalizations.of(context)!.compare),
                            );
                    },
                  ),
                );
              },
            ),
            );
          },
        ),
      ),
    );
  }
}

Future<FilterOptions?> _getFilterOptions() async {
  final filterRepository = di.sl<FilterRepository>();
  final filterOptionsResult = await filterRepository.getFilterOptions();
  return filterOptionsResult.fold(
    (failure) {
      print('❌ Failed to load filter options: ${failure.message}');
      return null;
    },
    (options) => options,
  );
}

void _showSortSheet(BuildContext context, CatalogLoaded state) async {
  final bloc = context.read<CatalogBloc>();
  final l10n = AppLocalizations.of(context)!;
  
  // Fetch sorting options from API
  final filterOptions = await _getFilterOptions();
  
  if (filterOptions == null || filterOptions.sortingOptions.isEmpty) {
    // Fallback to default if API fails
    AppSnackBar.error(context, l10n.errorLoadingCountriesStates);
    return;
  }
  
  // Convert API sort options to UI sort options
  final uiSortOptions = filterOptions.sortingOptions.map((apiOption) {
    IconData icon;
    // Map icons based on sort option ID
    switch (apiOption.id) {
      case 'price_low_high':
        icon = Icons.south_rounded;
        break;
      case 'price_high_low':
        icon = Icons.north_rounded;
        break;
      case 'newest_first':
        icon = Icons.fiber_new_rounded;
        break;
      case 'best_selling':
        icon = Icons.trending_up_rounded;
        break;
      default:
        icon = Icons.sort_rounded;
    }
    
    return SortOption(
      label: apiOption.name, // Use name directly from API (already localized)
      icon: icon,
      subtitle: '', // API doesn't provide subtitle, can be empty or add description if needed
    );
  }).toList();
  
  // Find the currently selected sort option by matching state.sortBy (which is now the sort option ID) with API options
  String? selectedValue;
  
  // Try to match by ID first (state.sortBy stores the sort option ID, e.g., 'price_low_high')
  final selectedApiOption = filterOptions.sortingOptions.firstWhere(
    (option) => option.id == state.sortBy,
    orElse: () => filterOptions.sortingOptions.first,
  );
  selectedValue = selectedApiOption.name;
  
  final chosen = await showSortBottomSheet(
    context: context,
    selected: selectedValue,
    options: uiSortOptions,
    title: l10n.sortBy,
  );
  
  if (chosen != null && chosen != selectedValue) {
    // Find the selected API sort option by name
    final chosenApiOption = filterOptions.sortingOptions.firstWhere(
      (option) => option.name == chosen,
      orElse: () => filterOptions.sortingOptions.first,
    );
    
    // Pass the sort option ID - the BLoC will map this to sort_by and sort_order via FilterCriteria
    bloc.add(UpdateSortOption(chosenApiOption.id));
  }
}

// Inline filter row removed in favor of AppBar modal

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await HapticService.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 32, // Fixed height for consistency
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.mdPadding,
          vertical: ResponsiveConstants.xsPadding,
        ),
        decoration: BoxDecoration(
          color: selected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                Icons.check, 
                size: 16, 
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              SizedBox(width: ResponsiveConstants.xsSpacing),
            ],
            Text(
              label,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.smFontSize,
                fontWeight: FontWeight.w600,
                color: selected 
                    ? Theme.of(context).colorScheme.onPrimary 
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chooses the correct productType for ProductCard based on available fields.
class _CatalogProductCard extends StatelessWidget {
  final dynamic product;
  const _CatalogProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // Use the type field directly from the HomeProduct.Product
    String productType;
    try {
      print('═══════════════════════════════════════════════════════');
      print('🔍 _CatalogProductCard: Processing product from catalog');
      print('  📦 Product ID: ${product.id}');
      print('  📛 Product Name: ${product.name}');
      print('  🏷️  Product.type field from API: ${product.type}');
      
      // Use the type field directly from the product entity
      if (product.type == 'variant' || product.type == 'template') {
        productType = product.type;
        print('  ✅ Using product type from API: $productType');
      } else {
        // Fallback to variant if type is not recognized
        productType = 'variant';
        print('  ⚠️  Unknown type "${product.type}", using fallback: $productType');
      }
    } catch (e) {
      productType = 'variant';
      print('  ❌ Exception occurred, using default: $productType, error: $e');
    }

    print('  🎯 Final productType that will be passed to ProductCard: $productType');
    print('═══════════════════════════════════════════════════════');
    return ProductCard(
      product: product,
      productType: productType,
      showFavoriteBadge: false, // hide built-in badge; we render it in overlay next to compare
    );
  }
}

class _DropdownFilterChip extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selected;
  final List<String>? selectedMultiple; // For multi-select (e.g., colors)
  final void Function(String value) onSelected;
  final IconData icon;

  const _DropdownFilterChip({
    required this.label,
    required this.options,
    required this.selected,
    this.selectedMultiple,
    required this.onSelected,
    required this.icon,
  });

  bool _isFilterApplied(BuildContext context) {
    if (selectedMultiple != null && selectedMultiple!.isNotEmpty) {
      return true;
    }
    if (selected != null) {
      final l10n = AppLocalizations.of(context)!;
      return selected!.toLowerCase() != 'all' && selected != l10n.all;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final currentContext = context;
        await HapticService.buttonClick();
        if (currentContext.mounted) {
          final theme = Theme.of(currentContext);
          final colorScheme = theme.colorScheme;
          
          final result = await showModalBottomSheet<String>(
            context: currentContext,
            showDragHandle: true,
            backgroundColor: colorScheme.surface,
            builder: (ctx) {
            return SafeArea(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                itemBuilder: (_, index) {
                  final opt = options[index];
                  // Check if selected (single or multiple)
                  final isSel = selectedMultiple != null 
                      ? selectedMultiple!.contains(opt)
                      : selected == opt;
                  return ListTile(
                    leading: Icon(icon, color: colorScheme.onSurface),
                    title: Text(
                      opt,
                      style: AppFonts.getTextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSel 
                        ? Icon(Icons.check, color: colorScheme.primary) 
                        : null,
                    onTap: () => Navigator.pop(ctx, opt),
                  );
                },
                separatorBuilder: (_, __) => Divider(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  height: 1,
                ),
                itemCount: options.length,
              ),
            );
          },
          );
          if (result != null) {
            onSelected(result);
          }
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 32, // Fixed height for consistency
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveConstants.smPadding,
          vertical: ResponsiveConstants.xsPadding,
        ),
        decoration: BoxDecoration(
          // Show selected state with primary background if filter is applied
          color: _isFilterApplied(context)
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isFilterApplied(context)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 16, 
              color: _isFilterApplied(context) 
                  ? Theme.of(context).colorScheme.onPrimary 
                  : Theme.of(context).colorScheme.onSurface,
            ),
            SizedBox(width: ResponsiveConstants.xsSpacing),
            Flexible(
              child: Text(
                label,
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.smFontSize,
                  fontWeight: FontWeight.w600,
                  color: _isFilterApplied(context) 
                      ? Theme.of(context).colorScheme.onPrimary 
                      : Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: ResponsiveConstants.xsSpacing),
            Icon(
              Icons.keyboard_arrow_down, 
              size: 16, 
              color: _isFilterApplied(context) 
                  ? Theme.of(context).colorScheme.onPrimary 
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple, uniform filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 32, // Fixed height for uniformity
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppFonts.getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () async {
                await HapticService.buttonClick();
                onDeleted();
              },
              child: Icon(
                Icons.close,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple Clear All button in red
class _ClearAllChip extends StatelessWidget {
  final VoidCallback onPressed;

  const _ClearAllChip({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await HapticService.warning();
        onPressed();
      },
      child: Container(
        height: 32, // Same height as filter chips
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.clear_all,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.clearAll,
                style: AppFonts.getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

