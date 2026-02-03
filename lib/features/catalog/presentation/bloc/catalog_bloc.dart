import 'package:flutter_bloc/flutter_bloc.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';
import '../../../home/domain/entities/product.dart';
import '../../domain/usecases/fetch_catalog_page.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../../filters/data/datasources/filter_remote_data_source.dart';
import '../../../../core/services/brand_mapping_service.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final FetchCatalogPage fetchCatalogPage;
  final FilterRemoteDataSource filterDataSource;
  final CatalogRepository repository;

  CatalogBloc({
    required this.fetchCatalogPage,
    required this.filterDataSource,
    required this.repository,
  }) : super(CatalogInitial()) {
    on<LoadCatalog>(_onLoad);
    on<UpdateCatalogFilters>(_onUpdateFilters);
    on<LoadMoreCatalog>(_onLoadMore);
    on<UpdateSortOption>(_onUpdateSortOption);
  }

  Future<void> _onLoad(LoadCatalog event, Emitter<CatalogState> emit) async {
    // Extract categoryIds from initialFilters if present, otherwise use categoryId from args
    List<int>? categoryIds = event.args.initialFilters?.categoryIds;
    if ((categoryIds == null || categoryIds.isEmpty) && event.args.categoryId != null) {
      // If no categoryIds from filters but categoryId is provided, use it
      final catId = int.tryParse(event.args.categoryId!);
      if (catId != null) {
        categoryIds = [catId];
      }
    }
    print('🚀 CatalogBloc: Loading catalog with args: category=${event.args.category}, categoryId=${event.args.categoryId}, categoryIds=$categoryIds');
    emit(CatalogLoading());
    final resp = await fetchCatalogPage(
      page: 1,
      pageSize: 20,
      category: event.args.category,
      categoryId: event.args.categoryId,
      categoryIds: categoryIds, // Pass categoryIds from initialFilters if present
      brand: event.args.brand,
      sortBy: 'newest_first', // Default sort option ID from API
      query: event.args.query,
      featured: event.args.featured,
    );
    
    print('📊 CatalogBloc: Received ${resp.items.length} products');

    final List<Product> items = resp.items;
    final List<String> categories = ['All', ...{...items.map((p) => p.category)}];

    // Fetch all available brands from API instead of just from current products
    List<String> brands = ['All'];
    try {
      print('🔄 CatalogBloc: Fetching all available brands from API...');
      final apiBrands = await filterDataSource.getBrands(page: 1, limit: 100);
      final brandNames = apiBrands.map((brand) => brand.name).toList();
      brands = ['All', ...brandNames];
      print('✅ CatalogBloc: Loaded ${brandNames.length} brands from API: ${brandNames.join(', ')}');
      
      // Initialize and update BrandMappingService with fetched brands
      BrandMappingService().initialize(filterDataSource);
      final brandMap = <String, int>{};
      for (final brand in apiBrands) {
        brandMap[brand.name] = brand.id;
      }
      BrandMappingService().updateMapping(brandMap);
      print('🗺️ CatalogBloc: Updated BrandMappingService with ${brandMap.length} brands');
    } catch (e) {
      print('⚠️ CatalogBloc: Failed to fetch brands from API, using fallback: $e');
      // Fallback to brands from current products
      brands = ['All', ...{...items.map((p) => p.brand)}];
      
      // Still try to initialize the service for future use
      try {
        BrandMappingService().initialize(filterDataSource);
      } catch (initError) {
        print('⚠️ CatalogBloc: Failed to initialize BrandMappingService: $initError');
      }
    }
    
    // Fetch colors from attributes API (COLOR NAME) to populate color menu comprehensively
    List<String> availableColors = ['All'];
    try {
      final attrs = await filterDataSource.getAttributes(page: 1, limit: 100);
      print('🎨 CatalogBloc: Fetched ${attrs.length} attributes from API');
      for (final a in attrs) {
        final name = a.name.toLowerCase();
        final type = a.type.toLowerCase();
        print('🎨 CatalogBloc: Checking attribute - name: "${a.name}", type: "${a.type}"');
        // Match "COLOR NAME" attribute (type: "color" or name contains "color")
        if ((type == 'color' || name.contains('color name') || name == 'color name')) {
          final colorValues = a.values.map((v) => v.name).where((n) => n.trim().isNotEmpty).toList();
          print('🎨 CatalogBloc: Found COLOR NAME attribute with ${colorValues.length} color values');
          availableColors.addAll(colorValues);
        }
      }
      // make unique while preserving order
      final seen = <String>{};
      availableColors = availableColors.where((c) => seen.add(c)).toList();
      print('🎨 CatalogBloc: Total unique colors: ${availableColors.length} (including All)');
    } catch (e) {
      print('⚠️ CatalogBloc: Failed to fetch colors from attributes API: $e');
      // fallback to colors present in items
      availableColors = ['All', ...{...items.expand((p) => p.colors)}];
      print('🎨 CatalogBloc: Using fallback colors from products: ${availableColors.length}');
    }

    // Fetch price bounds from filter-options API
    double? minBound;
    double? maxBound;
    try {
      final opts = await filterDataSource.getFilterOptions();
      minBound = opts.priceRange?.minPrice;
      maxBound = opts.priceRange?.maxPrice;
      print('💰 CatalogBloc: Price bounds from API min=$minBound max=$maxBound');
    } catch (e) {
      print('⚠️ CatalogBloc: Failed to fetch filter-options: $e');
    }

    emit(CatalogLoaded(
      products: items,
      categories: categories,
      brands: brands,
      selectedCategory: event.args.category ?? 'All',
      selectedCategoryId: event.args.categoryId,
      categoryIds: categoryIds, // Store categoryIds from initialFilters
      selectedBrand: event.args.brand ?? 'All',
      sortBy: 'newest_first', // Default sort option ID from API
      query: event.args.query,
      page: resp.page,
      hasMore: resp.hasMore,
      totalCount: resp.totalCount, // Use total count from API response
      minPrice: null,
      maxPrice: null,
      priceMinBound: minBound,
      priceMaxBound: maxBound,
      minRating: null,
      onSale: false,
      inStock: false,
      sizes: const [],
      colors: availableColors,
      selectedColors: const [],
      materials: const [],
      seasons: const [],
      genders: const [],
    ));
  }

  Future<void> _onUpdateFilters(UpdateCatalogFilters event, Emitter<CatalogState> emit) async {
    final s = state;
    if (s is! CatalogLoaded) return;

    // CRITICAL: FilterCriteria MUST be provided when coming from filters page
    // If it's null, something is wrong with the flow
    print('🔍🔍🔍 CatalogBloc._onUpdateFilters called');
    print('   event.filterCriteria is null: ${event.filterCriteria == null}');
    if (event.filterCriteria == null) {
      print('❌❌❌ CRITICAL ERROR: FilterCriteria is NULL in UpdateCatalogFilters event!');
      print('❌ This should NEVER happen when filters are applied from the filters page.');
      print('❌ Falling back to old path, but this will lose filter values (limit, sort, etc.)');
      print('❌ Check CatalogPage to ensure FilterCriteria is passed correctly.');
      print('❌ Event details: category=${event.category}, brand=${event.brand}, categoryIds=${event.categoryIds}, brandIds=${event.brandIds}');
    } else {
      print('✅ FilterCriteria IS provided in event!');
    }

    // ALWAYS prefer FilterCriteria if provided - this preserves exact values from filters page
    if (event.filterCriteria != null) {
      print('✅✅✅ CatalogBloc: Using FilterCriteria directly from filters page ✅✅✅');
      print('   ==========================================');
      print('   Category IDs: ${event.filterCriteria!.categoryIds}');
      print('   Brand IDs: ${event.filterCriteria!.brandIds}');
      print('   Limit: ${event.filterCriteria!.limit}');
      print('   Sort: ${event.filterCriteria!.sortByField} (${event.filterCriteria!.sortOrder})');
      print('   Page: ${event.filterCriteria!.page}');
      print('   ==========================================');
      
      // Update UI state from FilterCriteria
      final criteria = event.filterCriteria!;
      final interim = s.copyWith(
        isFiltering: true,
        minPrice: criteria.minPrice,
        maxPrice: criteria.maxPrice,
        onSale: criteria.onSale,
        inStock: criteria.inStock,
        selectedColors: criteria.colors,
        sizes: criteria.sizes,
        materials: criteria.materials,
        seasons: criteria.seasons,
        genders: criteria.genders,
        selectedCategory: criteria.category ?? s.selectedCategory,
        selectedBrand: criteria.brand ?? s.selectedBrand,
        query: criteria.searchQuery ?? s.query,
        extraAttributes: criteria.extraAttributes,
        categoryIds: criteria.categoryIds,
      );
      emit(interim);
      
      // CRITICAL: Call repository with FilterCriteria directly - NO modifications
      // This preserves the exact FilterCriteria as built in the filters page
      print('🚀 CatalogBloc: Calling repository.fetchProductsWithFilterCriteria with EXACT FilterCriteria');
      final resp = await repository.fetchProductsWithFilterCriteria(
        criteria: criteria,
      );
      
      final items = List<Product>.from(resp.items);
      print('📊 CatalogBloc: Filter update returned ${items.length} products');
      final List<String> categories = ['All', ...{...items.map((p) => p.category)}];
      
      emit(s.copyWith(
        products: items,
        categories: categories,
        hasMore: resp.hasMore,
        isLoadingMore: false,
        isFiltering: false,
        minPrice: criteria.minPrice,
        maxPrice: criteria.maxPrice,
        onSale: criteria.onSale,
        inStock: criteria.inStock,
        selectedColors: criteria.colors,
        sizes: criteria.sizes,
        materials: criteria.materials,
        seasons: criteria.seasons,
        genders: criteria.genders,
        selectedCategory: criteria.category ?? s.selectedCategory,
        selectedBrand: criteria.brand ?? s.selectedBrand,
        query: criteria.searchQuery ?? s.query,
        extraAttributes: criteria.extraAttributes,
        categoryIds: criteria.categoryIds,
      ));
      return;
    }

    // Fallback to individual parameters (for backward compatibility)
    print('⚠️⚠️⚠️ CatalogBloc: Using OLD path with individual parameters (filterCriteria was NULL) ⚠️⚠️⚠️');
    print('🔄 CatalogBloc: Updating filters from individual parameters...');
    print('   Brand: ${event.brand ?? s.selectedBrand}');
    print('   Category: ${event.category ?? s.selectedCategory}');
    print('   CategoryId: ${s.selectedCategoryId}');
    print('   SelectedColors: ${event.selectedColors ?? s.selectedColors}');
    print('   Query: ${event.query ?? s.query}');
    print('   OnSale: ${event.onSale ?? s.onSale}');
    print('   InStock: ${event.inStock ?? s.inStock}');
    print('   MinPrice: ${event.minPrice ?? s.minPrice}');
    print('   MaxPrice: ${event.maxPrice ?? s.maxPrice}');
    print('   MinRating: ${event.minRating ?? s.minRating}');
    print('   Sizes: ${event.sizes ?? s.sizes}');
    print('   Materials: ${event.materials ?? s.materials}');
    print('   Seasons: ${event.seasons ?? s.seasons}');
    print('   Genders: ${event.genders ?? s.genders}');
    print('   SortBy: ${event.sortBy ?? s.sortBy}');
    print('   ExtraAttributes: ${event.extraAttributes ?? s.extraAttributes}');

    // Show filtering shimmer while loading and update visible filter tags immediately
    // When filtering (query is null), clear the search query
    // When searching (query is provided), use the provided query
    final queryToUse = event.query ?? s.query;
    
    final interim = s.copyWith(
      isFiltering: true,
      minPrice: (event.clearMinPrice == true) ? null : (event.minPrice ?? s.minPrice),
      maxPrice: (event.clearMaxPrice == true) ? null : (event.maxPrice ?? s.maxPrice),
      onSale: event.onSale ?? s.onSale,
      inStock: event.inStock ?? s.inStock,
      selectedColors: event.selectedColors ?? s.selectedColors,
      sizes: event.sizes ?? s.sizes,
      materials: event.materials ?? s.materials,
      seasons: event.seasons ?? s.seasons,
      genders: event.genders ?? s.genders,
      selectedCategory: event.category ?? s.selectedCategory,
      selectedBrand: event.brand ?? s.selectedBrand,
      sortBy: event.sortBy ?? s.sortBy,
      query: queryToUse,
      extraAttributes: event.extraAttributes ?? s.extraAttributes,
    );
    print('🟡 Interim state set (UI should update chips immediately): min=${interim.minPrice}, max=${interim.maxPrice}');
    emit(interim);

    final sort = event.sortBy ?? s.sortBy;
    // Use the same query logic as interim state
    // Preserve query when applying filters after search
    final queryForApi = event.query ?? s.query;
    
    // Use limit from event if provided, otherwise default to 20
    final finalPageSize = event.limit ?? 20;
    print('📋 CatalogBloc (old path): Using pageSize: $finalPageSize (from event.limit: ${event.limit})');
    
    final resp = await fetchCatalogPage(
      page: 1,
      pageSize: finalPageSize, // Use limit from FilterCriteria if provided
      category: event.category ?? s.selectedCategory,
      categoryId: s.selectedCategoryId,
      categoryIds: event.categoryIds ?? s.categoryIds, // Preserve categoryIds if not provided
      brand: event.brand ?? s.selectedBrand,
      brandIds: event.brandIds, // Pass brand IDs directly from filter
      sortBy: sort,
      sortByField: event.sortByField, // Pass sort field directly from filter
      sortOrder: event.sortOrder, // Pass sort order directly from filter
      limit: event.limit, // Pass limit directly from filter
      query: queryForApi, // Preserve query when applying filters after search
      featured: false,
      minPrice: (event.clearMinPrice == true) ? null : (event.minPrice ?? s.minPrice),
      maxPrice: (event.clearMaxPrice == true) ? null : (event.maxPrice ?? s.maxPrice),
      minRating: event.minRating ?? s.minRating,
      onSale: event.onSale ?? s.onSale,
      inStock: event.inStock ?? s.inStock,
      sizes: event.sizes ?? s.sizes,
      colors: event.selectedColors ?? s.selectedColors,
      materials: event.materials ?? s.materials,
      seasons: event.seasons ?? s.seasons,
      genders: event.genders ?? s.genders,
      extraAttributes: event.extraAttributes ?? s.extraAttributes,
    );

    // Note: Sorting is now handled server-side via sort_by and sort_order parameters
    // No need for client-side sorting since API handles it
    final items = List<Product>.from(resp.items);
    print('📊 CatalogBloc: Filter update returned ${items.length} products');
    final List<String> categories = ['All', ...{...items.map((p) => p.category)}];
    
    // If categoryIds are provided but category name is not set, extract from returned products
    String finalCategory = event.category ?? s.selectedCategory;
    if (event.categoryIds != null && event.categoryIds!.isNotEmpty && finalCategory == 'All') {
      // Try to get category name from returned products
      if (items.isNotEmpty) {
        final productCategory = items.first.category;
        if (productCategory.isNotEmpty && productCategory != 'All') {
          finalCategory = productCategory;
          print('📋 CatalogBloc: Extracted category name from products: $finalCategory');
        }
      }
    }
    
    // Keep the existing brands list from state (don't regenerate from filtered products)
    final List<String> brands = s.brands;
    // Refresh colors from attributes API to keep color menu complete regardless of current results
    List<String> availableColors = ['All'];
    try {
      final attrs = await filterDataSource.getAttributes(page: 1, limit: 100);
      print('🎨 CatalogBloc: Refreshing colors - fetched ${attrs.length} attributes');
      for (final a in attrs) {
        final name = a.name.toLowerCase();
        final type = a.type.toLowerCase();
        // Match "COLOR NAME" attribute (type: "color" or name contains "color name")
        if ((type == 'color' || name.contains('color name') || name == 'color name')) {
          final colorValues = a.values.map((v) => v.name).where((n) => n.trim().isNotEmpty).toList();
          print('🎨 CatalogBloc: Found COLOR NAME attribute with ${colorValues.length} color values');
          availableColors.addAll(colorValues);
        }
      }
      final seen = <String>{};
      availableColors = availableColors.where((c) => seen.add(c)).toList();
      print('🎨 CatalogBloc: Refreshed colors: ${availableColors.length} total');
    } catch (e) {
      print('⚠️ CatalogBloc: Failed to refresh colors: $e');
      availableColors = ['All', ...{...items.expand((p) => p.colors)}];
    }
    
    print('✅ CatalogBloc: Filter update completed successfully');
    print('   Products: ${items.length}');
    print('   Categories: ${categories.length}');
    print('   Available Colors: ${availableColors.length}');

    final finalState = s.copyWith(
      products: items,
      categories: categories,
      brands: brands,
      selectedCategory: finalCategory,
      selectedBrand: event.brand ?? s.selectedBrand,
      categoryIds: event.categoryIds ?? s.categoryIds, // Preserve categoryIds from filter
      sortBy: sort,
      query: event.query ?? s.query,
      page: resp.page,
      hasMore: resp.hasMore,
      totalCount: resp.totalCount, // Use total count from API response
      isFiltering: false, // Filter loading complete
      minPrice: (event.clearMinPrice == true) ? null : (event.minPrice ?? s.minPrice),
      maxPrice: (event.clearMaxPrice == true) ? null : (event.maxPrice ?? s.maxPrice),
      minRating: event.minRating ?? s.minRating,
      onSale: event.onSale ?? s.onSale,
      inStock: event.inStock ?? s.inStock,
      sizes: event.sizes ?? s.sizes,
      colors: availableColors,
      selectedColors: event.selectedColors ?? s.selectedColors,
      materials: event.materials ?? s.materials,
      seasons: event.seasons ?? s.seasons,
      genders: event.genders ?? s.genders,
      extraAttributes: event.extraAttributes ?? s.extraAttributes,
    );
    print('🟢 Final state emitted: min=${finalState.minPrice}, max=${finalState.maxPrice}, products=${finalState.products.length}');
    emit(finalState);
  }

  // Filtering is fully delegated to repository via FetchCatalogPage

  Future<void> _onLoadMore(LoadMoreCatalog event, Emitter<CatalogState> emit) async {
    final s = state;
    if (s is! CatalogLoaded || !s.hasMore) return;

    emit(s.copyWith(isLoadingMore: true));
    final nextPage = s.page + 1;
    // In a real app, fetch from repository with pagination and current filters
    // Using usecase here for structure (still backed by mock repo)
    final resp = await fetchCatalogPage(
      page: nextPage,
      pageSize: 20,
      category: s.selectedCategory,
      categoryId: s.selectedCategoryId,
      categoryIds: s.categoryIds, // Preserve categoryIds during pagination
      brand: s.selectedBrand,
      sortBy: s.sortBy,
      query: s.query,
      featured: false,
      minPrice: s.minPrice,
      maxPrice: s.maxPrice,
      minRating: s.minRating,
      onSale: s.onSale,
      inStock: s.inStock,
      sizes: s.sizes,
      colors: s.selectedColors,
      materials: s.materials,
      seasons: s.seasons,
      genders: s.genders,
      extraAttributes: s.extraAttributes,
    );

    emit(s.copyWith(
      products: [...s.products, ...resp.items],
      page: resp.page,
      hasMore: resp.hasMore,
      totalCount: resp.totalCount, // Update total count from API (should remain same across pages)
      isLoadingMore: false,
    ));
  }

  Future<void> _onUpdateSortOption(UpdateSortOption event, Emitter<CatalogState> emit) async {
    final s = state;
    if (s is! CatalogLoaded) return;

    print('🔄 CatalogBloc: Updating sort option to: ${event.sortBy}');
    
    // Show loading state while sorting
    emit(s.copyWith(isFiltering: true));

    try {
      // Fetch products with new sort option
      final resp = await fetchCatalogPage(
        page: 1,
        pageSize: 20,
        category: s.selectedCategory,
        categoryId: s.selectedCategoryId,
        categoryIds: s.categoryIds, // Preserve categoryIds during sorting
        brand: s.selectedBrand,
        sortBy: event.sortBy,
        query: s.query, // Preserve query during sorting
        featured: false,
        minPrice: s.minPrice,
        maxPrice: s.maxPrice,
        minRating: s.minRating,
        onSale: s.onSale,
        inStock: s.inStock,
        sizes: s.sizes,
        colors: s.selectedColors,
        materials: s.materials,
        seasons: s.seasons,
        genders: s.genders,
        extraAttributes: s.extraAttributes,
      );

      // Note: Sorting is now handled server-side via sort_by and sort_order parameters
      // No need for client-side sorting since API handles it
      final sorted = List<Product>.from(resp.items);

      emit(s.copyWith(
        products: sorted,
        sortBy: event.sortBy, // Store sort option ID (e.g., 'price_low_high')
        page: resp.page,
        hasMore: resp.hasMore,
        totalCount: resp.totalCount, // Update total count from API
        isFiltering: false,
      ));

      print('✅ CatalogBloc: Sort updated successfully with ${resp.items.length} products');
    } catch (e) {
      print('❌ CatalogBloc: Error updating sort: $e');
      // Revert to previous state on error
      emit(s.copyWith(isFiltering: false));
    }
  }
}


