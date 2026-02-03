import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/product_details_bloc.dart';
import '../../domain/entities/product_details.dart';
import '../widgets/collapsible_image_section_widget.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_details_shimmer.dart';
import '../widgets/add_to_cart_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/widgets/cart_button_with_badge.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/services/app_localization_service.dart';
import '../../../../core/services/language_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final String productType; 
  final bool openAddToCart;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    this.productType = 'variant', // Default to variant for backward compatibility
    this.openAddToCart = false,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late PageController _pageController;
  late ScrollController _scrollController;
  String? _lastLanguageCode;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController = ScrollController();
    
    final localizationService = AppLocalizationService();
    _lastLanguageCode = localizationService.currentLocale.languageCode;
    
    debugPrint('📱 ProductDetailsPage: Initializing');
    debugPrint('  - Product ID: ${widget.productId}');
    debugPrint('  - Product Type: ${widget.productType}');
    debugPrint('  - Product ID Type: ${widget.productId.runtimeType}');
    debugPrint('  - Product Type Type: ${widget.productType.runtimeType}');
    debugPrint('  - Current Language: $_lastLanguageCode');
    
    // Listen to language changes
    localizationService.addListener(_onLanguageChanged);
    
    // Ensure API language is synced with current app language before loading product
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentLanguage = localizationService.currentLocale.languageCode;
      await LanguageService().setFromAppLanguageCode(currentLanguage);
      debugPrint('🌐 ProductDetailsPage: Synced API language to: $currentLanguage');
      
      // Load product details with current language
      context.read<ProductDetailsBloc>().add(LoadProductDetails(widget.productId, productType: widget.productType));
      
       final cartState = context.read<CartBloc>().state;
      if (cartState is! CartLoaded && cartState is! CartUpdating) {
        context.read<CartBloc>().add(const LoadCart());
      }
    });
  }

  void _onLanguageChanged() {
    final localizationService = AppLocalizationService();
    final currentLanguage = localizationService.currentLocale.languageCode;
    
    // If language changed, reload product details with new language

    if (_lastLanguageCode != currentLanguage) {
      debugPrint('🌐 ProductDetailsPage: Language changed from $_lastLanguageCode to $currentLanguage, reloading product...');
      _lastLanguageCode = currentLanguage;
      
      // Sync API language and reload product

      LanguageService().setFromAppLanguageCode(currentLanguage).then((_) {
        if (mounted) {
          context.read<ProductDetailsBloc>().add(LoadProductDetails(widget.productId, productType: widget.productType));
        }
      });
    }
  }


  @override
  void dispose() {
    AppLocalizationService().removeListener(_onLanguageChanged);
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: BlocConsumer<ProductDetailsBloc, ProductDetailsState>(
        listener: (context, state) {
          if (state is ProductDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppLocalizations.of(context)!.error}: ${state.message}'),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is ProductDetailsAddedToCart) {
            AppSnackBar.success(
              context,
              AppLocalizations.of(context)!.addedToCartSuccessfully,
              actionLabel: AppLocalizations.of(context)!.cart,
              onAction: () async {
                await HapticService.buttonClick();
                final rootNav = NavigationService.currentState;
                // Close any dialogs/sheets if possible
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                // Navigate to cart using root navigator to avoid disposed context
                rootNav?.push(
                  MaterialPageRoute(
                    builder: (_) => const CartPage(),
                  ),
                );
              },
            );
          } else if (state is ProductDetailsQuantityClamped) {
            // Show dialog when quantity was clamped
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (dialogContext) {
                final loc = AppLocalizations.of(dialogContext)!;
                return AlertDialog(
                  title: Text(
                    loc.ok,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.lgFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Text(
                    state.message,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        loc.ok,
                        style: AppFonts.getTextStyle(
                          fontSize: ResponsiveConstants.mdFontSize,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
        builder: (context, state) {
          if (state is ProductDetailsLoading) {
            return const ProductDetailsShimmer();
          }

          if (state is ProductDetailsError) {
            return _buildErrorState(state.message);
          }

          if (state is ProductDetailsLoaded) {
            // If requested via route args, open add-to-cart once after load
            if (widget.openAddToCart) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AddToCartBottomSheet.show(context, state.productDetails, context.read<ProductDetailsBloc>());
              });
            }
            // return SizedBox();
            return _buildProductDetails(state.productDetails);
          }

          return const ProductDetailsShimmer();
        },
      ),
      bottomNavigationBar: BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
        builder: (context, state) {
          if (state is ProductDetailsLoaded) {
            final bool isAvailable = _isProductInStock(state.productDetails);
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.smPadding,
                vertical: ResponsiveConstants.mdPadding,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.dark ? 0.4 : 0.1,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isAvailable
                        ? () async {
                            await HapticService.buttonClick();
                            AddToCartBottomSheet.show(context, state.productDetails, context.read<ProductDetailsBloc>());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isAvailable) ...[
                          Icon(
                            Icons.shopping_cart,
                            size: ResponsiveConstants.mdIconSize,
                          ),
                          SizedBox(width: ResponsiveConstants.smSpacing),
                        ],
                        Text(
                          isAvailable ? AppLocalizations.of(context)!.addToCart : AppLocalizations.of(context)!.outOfStock,
                          style: AppFonts.getTextStyle(
                            fontSize: ResponsiveConstants.mdFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveConstants.errorIconSize,
            color: colorScheme.error,
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          Text(
            AppLocalizations.of(context)!.somethingWentWrong,
            style: AppFonts.getTextStyle(
              fontSize: ResponsiveConstants.xlFontSize,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            message,
            style: AppFonts.getTextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.mdSpacing),
          ElevatedButton(
            onPressed: () async {
              await HapticService.buttonClick();
              context.read<ProductDetailsBloc>().add(LoadProductDetails(widget.productId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(AppLocalizations.of(context)!.tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(ProductDetails productDetails) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Collapsing App Bar with Image
        SliverAppBar(
          expandedHeight: ResponsiveConstants.productDetailsAppBarHeight, // Responsive image section height
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: colorScheme.background,
          leading: _buildBackButton(),
          title: _buildAppBarTitle(productDetails),
          iconTheme: IconThemeData(
            color: colorScheme.onBackground,
          ),
          actions: [
            _buildShareButton(),
            const CartButtonWithBadge(),
            Padding(
              padding: EdgeInsets.only(right: ResponsiveConstants.smPadding),
              child: FavoriteButton(
                productId: productDetails.id,
                productName: productDetails.name,
                brand: productDetails.brand,
                price: productDetails.price,
                imageUrl: productDetails.images.isNotEmpty ? productDetails.images.first : null,
                category: null,
                isFavorite: productDetails.isFavorite,
                size: ResponsiveConstants.mdIconSize,
                isCompact: true,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: CollapsibleImageSectionWidget(
              productDetails: productDetails,
              pageController: _pageController,
            ),
          ),
        ),
        
        // Product Info Section (scrolls up to cover image)
        ProductInfoSection(
          productDetails: productDetails,
        ),
        //
        // Bottom padding
        SliverToBoxAdapter(
          child: SizedBox(height: ResponsiveConstants.lgSpacing),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        color: colorScheme.onBackground,
        size: ResponsiveConstants.mdIconSize,
      ),
      onPressed: () async {
        await HapticService.buttonClick();
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildAppBarTitle(ProductDetails productDetails) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productDetails.brand,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.smFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        Text(
          productDetails.name,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.mdFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  bool _isProductInStock(ProductDetails productDetails) {
    // If variant combinations exist, consider in stock only if any variant is in stock or has positive quantity
    if (productDetails.variantCombinations.isNotEmpty) {
      for (final v in productDetails.variantCombinations) {
        if (v.inStock || (v.quantityAvailable != null && v.quantityAvailable! > 0)) {
          return true;
        }
      }
      return false;
    }
    // Fallback: if no variant info, assume available (cannot determine otherwise)
    return true;
  }


  Widget _buildShareButton() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return IconButton(
      icon: Icon(
        Icons.share,
        color: colorScheme.onBackground,
        size: ResponsiveConstants.mdIconSize,
      ),
      onPressed: () async {
        await HapticService.buttonClick();
        final state = context.read<ProductDetailsBloc>().state;
        if (state is ProductDetailsLoaded) {
          final p = state.productDetails;
          final image = p.images.isNotEmpty ? p.images.first : '';
          // Compose full website URL if available
          String? fullUrl;
          try {
            final String? websitePath = p.websiteUrl;
            if (websitePath != null && websitePath.isNotEmpty) {
              final base = AppConstants.baseUrl;
              fullUrl = websitePath.startsWith('http') ? websitePath : (base.endsWith('/') ? base.substring(0, base.length - 1) : base) + websitePath;
            }
          } catch (_) {}
          final List<String> lines = [];
          // Prefix line encouraging to check the product
          try {
            // Some generated localization files may not include the key yet; guard to avoid crashes
            // ignore: unnecessary_nullable_for_final_variable_declarations
            final localized = AppLocalizations.of(context);
            if (localized == null) {
              lines.add('Check out this product:');
            } else {
              // Fallback without referencing missing getter directly
              final dynamic dyn = localized;
              final prefix = ((){ try { return dyn.checkOutThisProduct as String; } catch(_) { return 'Check out this product:'; }})();
              lines.add(prefix);
            }
          } catch (_) {
            lines.add('Check out this product:');
          }
          lines.add('${p.brand} — ${p.name}');
          lines.add('');
          lines.add('Price: ${p.price.toStringAsFixed(2)}');
          if (fullUrl != null) {
            lines.add('');
            lines.add(fullUrl);
          }
          if (image.isNotEmpty) {
            lines.add('');
            lines.add('Image: $image');
          }
          final message = lines.join('\n');
          Share.share(message, subject: p.name);
        }
      },
    );
  }
}
