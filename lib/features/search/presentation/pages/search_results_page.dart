import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../home/presentation/widgets/common/product_card.dart';
import '../../../home/domain/entities/product.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../../data/models/search_params_model.dart';
import '../../data/models/search_product_model.dart';
import '../widgets/search_results_shimmer.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';
import '../../../catalog/domain/models/catalog_args.dart';

class SearchResultsPage extends StatefulWidget {
  final String? searchQuery;
  
  const SearchResultsPage({super.key, this.searchQuery});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _searchTriggered = false;
  bool _hasResults = false;
  ProductSearchLoaded? _cachedResults;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
    
    // Redirect to CatalogPage to show results with full catalog UI
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CatalogPage(
              args: CatalogArgs(
                title: widget.searchQuery!,
                query: widget.searchQuery!,
              ),
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    if (!_searchTriggered && widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchTriggered = true;
      print('SearchResultsPage - Triggering search: "${widget.searchQuery}"');
      
      // Add a small delay to ensure the bloc is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<SearchBloc>().add(SearchProducts(
            SearchParams(searchTerm: widget.searchQuery!)
          ));
        }
      });
    }
  }

  void _performNewSearch(String query) {
    if (query.trim().isNotEmpty) {
      print('SearchResultsPage - Redirecting to CatalogPage with query: "$query"');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CatalogPage(
            args: CatalogArgs(
              title: query.trim(),
              query: query.trim(),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          _buildAppBar(context),
          
          // Content
          Expanded(
            child: BlocListener<SearchBloc, SearchState>(
              listener: (context, state) {
                print('SearchResultsPage - State changed: ${state.runtimeType}');
                
                // Mark that we have results once we get them
                if (state is ProductSearchLoaded) {
                  _hasResults = true;
                  _cachedResults = state; // Cache the results
                  print('SearchResultsPage - Results loaded, setting _hasResults = true and caching results');
                  return;
                }
                
                // While loading a new search, keep cached results to avoid flicker
                if (state is ProductSearchLoading) {
                  print('SearchResultsPage - Loading new results, keeping cached results to prevent flicker');
                  return;
                }
                
                // If we have a search query and we're not in a product search state, trigger search
                if (widget.searchQuery != null && 
                    widget.searchQuery!.isNotEmpty && 
                    !_searchTriggered &&
                    !_hasResults &&
                    !(state is ProductSearchLoading || state is ProductSearchLoaded || state is ProductSearchError)) {
                  print('SearchResultsPage - Triggering search from listener for state: ${state.runtimeType}');
                  _triggerSearch();
                }
              },
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  print('SearchResultsPage - Building with state: ${state.runtimeType}');
                  return _buildContent(context, state);
                },
              ),
            ),
                  ),
                ],
              ),
            );
          }
          
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Top App Bar
          AppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () async {
          await HapticService.buttonClick();
          Navigator.of(context).pop();
        },
            ),
            title: Text(
                          AppLocalizations.of(context)!.searchResults,
                      style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.titleFontSize,
                        fontWeight: FontWeight.w600,
                            color: Colors.black,
                      ),
                    ),
          ),
          
          // Search Bar
          _buildSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _performNewSearch,
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
                          ],
                        ),
    );
  }

  Widget _buildContent(BuildContext context, SearchState state) {
    print('SearchResultsPage - _buildContent: ${state.runtimeType}, searchTriggered: $_searchTriggered, hasResults: $_hasResults');
    
    // Handle product search states FIRST - these take absolute priority
    if (state is ProductSearchLoading) {
      print('SearchResultsPage - Showing ProductSearchLoading');
      return _buildLoadingState(context, state.searchQuery);
    }
    
    if (state is ProductSearchError) {
      print('SearchResultsPage - Showing ProductSearchError');
      return _buildErrorState(context, state);
    }
    
    if (state is ProductSearchLoaded) {
      print('SearchResultsPage - Showing ProductSearchLoaded with ${state.results.products.length} products');
      // IMPORTANT: Once we have results, we never go back to loading
      return _buildResultsState(context, state);
    }
    
    // If we have cached results, show them to prevent flickering
    if (_hasResults && _cachedResults != null) {
      print('SearchResultsPage - Showing cached results to prevent flickering');
      return _buildResultsState(context, _cachedResults!);
    }
    
    // For any other state (SearchLoaded, SearchInitial, etc.) with a search query
    // Show loading only if we haven't completed a search yet
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty && !_hasResults) {
      print('SearchResultsPage - Showing loading for search query: ${widget.searchQuery}');
      return _buildLoadingState(context, widget.searchQuery!);
    }
    
    // Only show empty state if there's no search query
    print('SearchResultsPage - Showing empty state');
    return _buildEmptyState(context);
  }

  Widget _buildLoadingState(BuildContext context, String query) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          child: Text(
            '${AppLocalizations.of(context)!.loading} "$query"...',
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.mdFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const Expanded(child: SearchResultsShimmer()),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, ProductSearchError state) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
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
              AppLocalizations.of(context)!.error,
                              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: ResponsiveConstants.smSpacing),
                            Text(
              state.message,
                              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            ElevatedButton(
              onPressed: () async {
          await HapticService.buttonClick();
          _searchTriggered = false;
                _triggerSearch();
        },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveConstants.lgPadding,
                  vertical: ResponsiveConstants.mdPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.tryAgain),
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildResultsState(BuildContext context, ProductSearchLoaded state) {
    if (state.results.products.isEmpty) {
      return _buildNoResultsState(context, state.searchQuery);
    }
    
    return CustomScrollView(
      physics: Theme.of(context).platform == TargetPlatform.iOS
          ? const ClampingScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
            child: Text(
              '${state.results.products.length} ${AppLocalizations.of(context)!.results}: "${state.searchQuery}"',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveConstants.gridCrossAxisCount,
              crossAxisSpacing: ResponsiveConstants.gridSpacing,
              mainAxisSpacing: ResponsiveConstants.gridSpacing,
              childAspectRatio: ResponsiveConstants.gridChildAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final sp = state.results.products[index];
                final hp = _convertSearchProductToProduct(sp);
                String productType;
                try {
                  print('🔍 SearchResultsPage: Processing product');
                  print('  - Product ID: ${hp.id}');
                  print('  - Product Name: ${hp.name}');
                  print('  - Product Type: ${hp.type}');
                  
                  // Use the type field directly from the converted HomeProduct.Product
                  if (hp.type == 'variant' || hp.type == 'template') {
                    productType = hp.type;
                    print('  - Using product type: $productType');
                  } else {
                    // Fallback to variant if type is not recognized
                    productType = 'variant';
                    print('  - Unknown type "${hp.type}", using fallback: $productType');
                  }
                } catch (e) {
                  productType = 'variant';
                  print('  - Exception occurred, using default: $productType, error: $e');
                }
                return ProductCard(
                  product: hp,
                  productType: productType,
                );
              },
              childCount: state.results.products.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsState(BuildContext context, String query) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: ResponsiveConstants.xlIconSize,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: ResponsiveConstants.lgSpacing),
            Text(
              AppLocalizations.of(context)!.noResultsFound,
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.lgFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: ResponsiveConstants.smSpacing),
            Text(
              '${AppLocalizations.of(context)!.noResultsFoundFor} "$query"',
              style: AppFonts.getTextStyle(
                fontSize: ResponsiveConstants.mdFontSize,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
              AppLocalizations.of(context)!.tryDifferentSearchTerms,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.smFontSize,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: ResponsiveConstants.xlIconSize,
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
          ],
        ),
      ),
    );
  }

  // Helper method to convert SearchProductModel to Product
  Product _convertSearchProductToProduct(SearchProductModel searchProduct) {
    return Product(
      id: searchProduct.id.toString(),
      name: searchProduct.name,
      description: searchProduct.description,
      price: searchProduct.price,
      originalPrice: null,
      images: searchProduct.images.map((img) => _constructFullImageUrl(img.image)).toList(),
      category: searchProduct.primaryCategoryName,
      brand: searchProduct.brand,
      type: 'variant', // Default to variant for search products
      rating: 4.5,
      reviewCount: 100,
      isAvailable: searchProduct.qtyAvailable > 0,
      sizes: ['S', 'M', 'L'],
      colors: searchProduct.availableColors.cast<String>(),
      createdAt: DateTime.tryParse(searchProduct.createDate) ?? DateTime.now(),
      materials: [],
      heelHeightCm: null,
      heelType: null,
      dimensions: null,
      closureType: null,
      strapType: null,
      capacity: null,
      soleType: null,
      upperMaterial: null,
      liningMaterial: null,
      careInstructions: null,
      features: <String>[],
      favourite: false,
    );
  }

  String _constructFullImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    return '${AppConstants.baseUrl}${imagePath.startsWith('/') ? imagePath.substring(1) : imagePath}';
  }
}