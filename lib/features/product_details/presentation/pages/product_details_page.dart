import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../bloc/product_details_bloc.dart';
import '../../domain/entities/product_details.dart';
import '../widgets/collapsible_image_section_widget.dart';
import '../widgets/color_selection_widget.dart';
import '../widgets/product_image_section_widget.dart';
import '../widgets/product_info_section.dart';
import '../widgets/preview_header.dart';
import '../widgets/product_details_shimmer.dart';
import '../widgets/add_to_cart_bottom_sheet.dart';
import '../../domain/entities/product_details_card_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/dynamic_variant_controller.dart';
import 'package:share_plus/share_plus.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/widgets/cart_button_with_badge.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/services/app_localization_service.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/utils/image_cache_utils.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final String productType;
  final bool openAddToCart;
  /// Preview data from the product card (image, brand, title, price)
  /// to show immediately while full details are loading.
  final ProductDetailsCardPreview? cardPreview;

  const ProductDetailsPage({
    super.key,
    required this.productId,
    this.productType = 'variant', // Default to variant for backward compatibility
    this.openAddToCart = false,
    this.cardPreview,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with AutomaticKeepAliveClientMixin<ProductDetailsPage> {
  late PageController _pageController;
  late ScrollController _scrollController;
  late DynamicVariantController _variantController;
  late final AppLocalizationService _localizationService;
  String? _lastLanguageCode;
  bool _isControllerInitialized = false;
  bool _hasOpenedAddToCartFromRoute = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _localizationService = AppLocalizationService();
    _pageController = PageController();
    _scrollController = ScrollController();
    _variantController = DynamicVariantController();
    
    _lastLanguageCode = _localizationService.currentLocale.languageCode;
    
    debugPrint('📱 ProductDetailsPage: Initializing');
    debugPrint('  - Product ID: ${widget.productId}');
    debugPrint('  - Product Type: ${widget.productType}');
    debugPrint('  - Product ID Type: ${widget.productId.runtimeType}');
    debugPrint('  - Product Type Type: ${widget.productType.runtimeType}');
    debugPrint('  - Current Language: $_lastLanguageCode');
    
    // Listen to language changes
    _localizationService.addListener(_onLanguageChanged);
    print('product id from the catalog list selected ${widget.productId}');
    // Ensure API language is synced with current app language before loading product
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentLanguage = _localizationService.currentLocale.languageCode;
      // Fire-and-forget language sync so that product loading can start immediately.
      // This avoids blocking the initial load on any async I/O inside LanguageService.
      unawaited(
        LanguageService()
            .setFromAppLanguageCode(currentLanguage)
            .then((_) => debugPrint(
                  '🌐 ProductDetailsPage: Synced API language to: $currentLanguage',
                )),
      );

      // Load product details with current language without waiting for the sync call
      context.read<ProductDetailsBloc>().add(LoadProductDetails(
            widget.productId,
            productType: widget.productType,
            cardPreview: widget.cardPreview,
          ));

      final cartState = context.read<CartBloc>().state;
      if (cartState is! CartLoaded && cartState is! CartUpdating) {
        context.read<CartBloc>().add(const LoadCart());
      }
    });
  }

  void _onLanguageChanged() {
    final currentLanguage = _localizationService.currentLocale.languageCode;
    
    // If language changed, reload product details with new language

    if (_lastLanguageCode != currentLanguage) {
      debugPrint('🌐 ProductDetailsPage: Language changed from $_lastLanguageCode to $currentLanguage, reloading product...');
      _lastLanguageCode = currentLanguage;
      
      // Sync API language and reload product

      LanguageService().setFromAppLanguageCode(currentLanguage).then((_) {
        if (mounted) {
          context.read<ProductDetailsBloc>().add(LoadProductDetails(
                widget.productId,
                productType: widget.productType,
                cardPreview: widget.cardPreview,
              ));
        }
      });
    }
  }


  @override
  void dispose() {
    _localizationService.removeListener(_onLanguageChanged);
    _pageController.dispose();
    _scrollController.dispose();
    _variantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final colorScheme = theme.colorScheme;
    
    return ChangeNotifierProvider<DynamicVariantController>.value(
      value: _variantController,
      child: Scaffold(
      // Let the main image extend behind the app bar/status bar so the
      // header looks like the reference design.
      extendBodyBehindAppBar: true,
      backgroundColor: colorScheme.background,
        body: BlocConsumer<ProductDetailsBloc, ProductDetailsState>(
        listener: (context, state) {
          // Initialize dynamic variant controller ONLY on first load
          // Don't re-initialize on every state change (like color selection) to avoid resetting selection
          if (state is ProductDetailsLoaded && !_isControllerInitialized) {
            debugPrint('🔄 ProductDetailsPage: Initializing variant controller with product details (first load)');
            _variantController.initialize(state.productDetails);
            _isControllerInitialized = true;
            debugPrint('✅ ProductDetailsPage: Variant controller initialized');
            debugPrint('   Selected attributes: ${_variantController.selectedAttributes}');
            debugPrint('   Variant ID: ${_variantController.variantId}');
            debugPrint('   In Stock: ${_variantController.inStock}');
            debugPrint('   Quantity: ${_variantController.quantityAvailable}');
          } else if (state is ProductDetailsLoaded && _isControllerInitialized) {
            // On subsequent state changes (like color selection), update product details
            // but preserve user's current selection
            debugPrint('🔄 ProductDetailsPage: Product details updated, syncing controller (preserving selection)');
            _variantController.updateProductDetails(state.productDetails);
          }
          
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
          }
        },
        builder: (context, state) {
          if (state is ProductDetailsError) {
            return _buildErrorState(state.message);
          }

          if (state is ProductDetailsLoading) {
            if (state.cardPreview != null) {
              return _buildProductDetailsBody(cardPreview: state.cardPreview);
            }
            return const ProductDetailsShimmer();
          }

          if (state is ProductDetailsLoaded) {
            if (widget.openAddToCart && !_hasOpenedAddToCartFromRoute) {
              _hasOpenedAddToCartFromRoute = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final variantController = context.read<DynamicVariantController>();
                AddToCartBottomSheet.show(
                  context,
                  context.read<ProductDetailsBloc>(),
                  variantController,
                );
              });
            }
            return _buildProductDetailsBody(productDetails: state.productDetails);
          }

          return const ProductDetailsShimmer();
        },
      ),
      bottomNavigationBar: Consumer<DynamicVariantController>(
        builder: (context, variantController, _) {
          return BlocBuilder<ProductDetailsBloc, ProductDetailsState>(
            builder: (context, state) {
              final isLoaded = state is ProductDetailsLoaded;
              final isLoading = state is ProductDetailsLoading;
              if (isLoaded || isLoading) {
                final bool isOutOfStock =
                    isLoaded ? !variantController.inStock : true;

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
                    // Disable until loaded; then use stock rule (out of stock = disabled).
                    onPressed: (!isLoaded || isOutOfStock)
                        ? null
                        : () async {
                            await HapticService.buttonClick();
                            AddToCartBottomSheet.show(
                              context,
                              context.read<ProductDetailsBloc>(),
                              variantController,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isOutOfStock ? colorScheme.surface : primary,
                      foregroundColor: isOutOfStock
                          ? colorScheme.onSurface.withValues(alpha: 0.6)
                          : colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoaded && !isOutOfStock) ...[
                          Icon(
                            Icons.shopping_cart,
                            size: ResponsiveConstants.mdIconSize,
                          ),
                          SizedBox(width: ResponsiveConstants.smSpacing),
                        ],
                        SizedBox(width: ResponsiveConstants.smSpacing),
                        Text(
                          !isLoaded
                              ? AppLocalizations.of(context)!.loading
                              : isOutOfStock
                                  ? AppLocalizations.of(context)!.outOfStock
                                  : AppLocalizations.of(context)!.addToCart,
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
          );
        },
      ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return AppErrorView(
      message: message,
      onRetry: () async {
        await HapticService.buttonClick();
        context.read<ProductDetailsBloc>().add(
              LoadProductDetails(
                widget.productId,
                productType: widget.productType,
                cardPreview: widget.cardPreview,
              ),
            );
      },
    );
  }

  /// Builds the same product details UI. Pass [productDetails] when loaded,
  /// or [cardPreview] when still loading so passed values show and rest are skeletons.
  Widget _buildProductDetailsBody({
    ProductDetails? productDetails,
    ProductDetailsCardPreview? cardPreview,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaSize = MediaQuery.sizeOf(context);
    final screenWidth = mediaSize.width;
    final topInset = MediaQuery.paddingOf(context).top;
    // Use the original header ratio; the image section itself now
    // fills the full height of this area, so no gaps remain.
    final headerHeight = screenWidth * 1.4;
    final isLoaded = productDetails != null;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App bar disappears when scrolling down and reappears when scrolling up (floating).
        // App bar floats on top of the main image, similar to the
        // reference design, with the image visible behind it.
        // Let the header image extend behind the status bar for a full-bleed look.
        SliverSafeArea(
          top: false,
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final collapseTrigger = (headerHeight - (kToolbarHeight + topInset)).clamp(0.0, double.infinity);
              final isCollapsed = constraints.scrollOffset >= collapseTrigger;
              return SliverAppBar(
                // Fixed header height so preview and final image share exactly
                // the same space and we avoid jumps when data arrives.
                expandedHeight: headerHeight,
                floating: !isLoaded,
                snap: !isLoaded,
                pinned: true,
                toolbarHeight: kToolbarHeight,
                collapsedHeight: kToolbarHeight,
                titleSpacing: 0,
                elevation: isCollapsed ? 1 : 0,
                scrolledUnderElevation: 1,
                backgroundColor: isCollapsed ? colorScheme.surface : Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
                leading: Padding(
                  padding: EdgeInsets.only(left: ResponsiveConstants.mdPadding),
                  child: _buildBackButton(),
                ),
                // Keep title visible in both expanded and collapsed states
                // so users always see product context while scrolling.
                title: isLoaded
                    ? _buildAppBarTitle(productDetails!)
                    : (cardPreview != null
                        ? _buildAppBarTitleFromPreview(cardPreview)
                        : null),
                iconTheme: IconThemeData(color: colorScheme.onBackground),
                actions: [
                  _buildShareButton(productDetails: productDetails, cardPreview: cardPreview),
                  const CartButtonWithBadge(),
                  Padding(
                    padding: EdgeInsetsDirectional.only(end: ResponsiveConstants.mdPadding),
                    child: isLoaded
                        ? Consumer<DynamicVariantController>(
                            builder: (context, variantController, _) {
                              final String favProductId =
                                  variantController.variantId.isNotEmpty
                                      ? variantController.variantId
                                      : productDetails!.id;
                              final List<String> currentImages =
                                  variantController.currentImages.isNotEmpty
                                      ? variantController.currentImages
                                      : productDetails!.images;
                              final double favPrice = variantController.currentPrice > 0
                                  ? variantController.currentPrice
                                  : productDetails!.price;
                              return FavoriteButton(
                                productId: favProductId,
                                productName: productDetails!.name,
                                brand: productDetails!.brand,
                                price: favPrice,
                                imageUrl: currentImages.isNotEmpty ? currentImages.first : null,
                                category: null,
                                isFavorite: productDetails!.isFavorite,
                                size: ResponsiveConstants.mdIconSize,
                                isCompact: true,
                              );
                            },
                          )
                        : (cardPreview != null
                            ? FavoriteButton(
                                productId: widget.productId,
                                productName: cardPreview.productTitle,
                                brand: cardPreview.brand,
                                price: cardPreview.price,
                                imageUrl: cardPreview.imageUrl,
                                category: null,
                                isFavorite: false,
                                size: ResponsiveConstants.mdIconSize,
                                isCompact: true,
                              )
                            : const SizedBox.shrink()),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: isLoaded
                      ? Consumer<DynamicVariantController>(
                          builder: (context, variantController, _) {
                            // Main API image header.
                            return CollapsibleImageSectionWidget(
                              productDetails: productDetails!,
                              pageController: _pageController,
                              variantImageUrls: variantController.currentImages,
                              scrollWithPage: true,
                              showColorSelection: false,
                            );
                          },
                        )
                      : (cardPreview != null
                          ? PreviewHeader(preview: cardPreview!)
                          : Container(color: colorScheme.background)),
                ),
              );
            },
          ),
        ),
        if (isLoaded)
          SliverToBoxAdapter(
            child: Consumer<DynamicVariantController>(
              builder: (context, variantController, _) {
                final currentProduct = productDetails!;
                final colorScheme = Theme.of(context).colorScheme;
                return Container(
                  color: colorScheme.surface,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveConstants.smPadding,
                    vertical: ResponsiveConstants.smSpacing,
                  ),
                  child: ColorSelectionWidget(
                    productDetails: currentProduct,
                    overlayOnImage: false,
                  ),
                );
              },
            ),
          ),
        // When loading with only preview data, skip rendering the preview
        // image in the main details scroll. We want to show a stable loader
        // first and then the final image once details are ready, instead of
        // briefly showing the preview image again and then replacing it.
        ProductInfoSection(
          productDetails: productDetails,
          cardPreview: cardPreview,
          scrollController: _scrollController,
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: isLoaded &&
                    productDetails != null &&
                    productDetails!.optionalProducts.isEmpty &&
                    productDetails!.accessoryProducts.isEmpty &&
                    productDetails!.alternativeProducts.isEmpty
                ? ResponsiveConstants.smSpacing
                : ResponsiveConstants.lgSpacing,
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarTitleFromPreview(ProductDetailsCardPreview preview) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      '${preview.brand} - ${preview.productTitle}',
      style: AppFonts.getTextStyle(
        fontSize: ResponsiveConstants.mdFontSize,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPreviewImage(ProductDetailsCardPreview preview) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      child: preview.imageUrl != null && preview.imageUrl!.isNotEmpty
          ? Center(
              child: CachedNetworkImage(
                imageUrl: preview.imageUrl!,
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(color: colorScheme.surface),
                errorWidget: (_, __, ___) => Container(color: colorScheme.surface),
              ),
            )
          : null,
    );
  }

  /// Preview image + color skeleton for loading state; scrolls with the page. Image shown at full size from aspect ratio.
  Widget _buildPreviewImageSection(ProductDetailsCardPreview preview) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AdaptivePreviewImage(preview: preview),
        Padding(
          padding: EdgeInsets.only(
            left: ResponsiveConstants.mdSpacing,
            right: ResponsiveConstants.mdSpacing,
            bottom: ResponsiveConstants.mdSpacing,
          ),
          child: const ColorSelectionSkeleton(),
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

    return Text(
      '${productDetails.brand} - ${productDetails.name}',
      style: AppFonts.getTextStyle(
        fontSize: ResponsiveConstants.mdFontSize,
        fontWeight: FontWeight.w600,
        color: colorScheme.onBackground,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }



  Widget _buildShareButton({
    ProductDetails? productDetails,
    ProductDetailsCardPreview? cardPreview,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(
        Icons.share,
        color: colorScheme.onBackground,
        size: ResponsiveConstants.mdIconSize,
      ),
      onPressed: () async {
        await HapticService.buttonClick();
        if (productDetails != null) {
          final p = productDetails;
          final image = p.images.isNotEmpty ? p.images.first : '';
          String? fullUrl;
          try {
            final String? websitePath = p.websiteUrl;
            if (websitePath != null && websitePath.isNotEmpty) {
              final base = AppConstants.baseUrl;
              fullUrl = websitePath.startsWith('http')
                  ? websitePath
                  : (base.endsWith('/')
                      ? base.substring(0, base.length - 1)
                      : base) +
                      websitePath;
            }
          } catch (_) {}
          final List<String> lines = [];
          try {
            final localized = AppLocalizations.of(context);
            if (localized == null) {
              lines.add('Check out this product:');
            } else {
              final dynamic dyn = localized;
              final prefix = (() {
                try {
                  return dyn.checkOutThisProduct as String;
                } catch (_) {
                  return 'Check out this product:';
                }
              })();
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
          Share.share(lines.join('\n'), subject: p.name);
        } else if (cardPreview != null) {
          final lines = [
            '${cardPreview.brand} — ${cardPreview.productTitle}',
            '',
            'Price: ${cardPreview.price}',
            if (cardPreview.imageUrl != null && cardPreview.imageUrl!.isNotEmpty)
              '\nImage: ${cardPreview.imageUrl}',
          ];
          Share.share(lines.join('\n'), subject: cardPreview.productTitle);
        }
      },
    );
  }
}

/// Sizes the preview image by its aspect ratio so it shows in full (no cropping) in the preview/shimmer state.
class _AdaptivePreviewImage extends StatefulWidget {
  final ProductDetailsCardPreview preview;

  const _AdaptivePreviewImage({required this.preview});

  @override
  State<_AdaptivePreviewImage> createState() => _AdaptivePreviewImageState();
}

class _AdaptivePreviewImageState extends State<_AdaptivePreviewImage> {
  double? _aspectRatio;
  String? _lastResolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolveAspectRatio();
  }

  @override
  void didUpdateWidget(_AdaptivePreviewImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preview.imageUrl != widget.preview.imageUrl) {
      _lastResolvedUrl = null;
      _aspectRatio = null;
      _resolveAspectRatio();
    }
  }

  Future<void> _resolveAspectRatio() async {
    final url = widget.preview.imageUrl;
    if (url == null || url.isEmpty) {
      if (mounted) setState(() => _aspectRatio = 0.6);
      return;
    }
    if (_lastResolvedUrl == url) return;
    _lastResolvedUrl = url;
    try {
      final data = await ImageCacheUtils.getAuthenticatedImageData(url);
      final imageUrl = data['url'] as String;
      final headers = data['headers'] as Map<String, String>;
      final provider = NetworkImage(imageUrl, headers: headers);
      final completer = provider.resolve(const ImageConfiguration());
      if (!mounted) return;
      completer.addListener(ImageStreamListener((ImageInfo info, bool _) {
        if (!mounted) return;
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (w > 0 && h > 0) {
          setState(() => _aspectRatio = h / w);
        }
      }, onError: (dynamic _, StackTrace? __) {
        if (mounted) setState(() => _aspectRatio = 0.6);
      }));
    } catch (_) {
      if (mounted) setState(() => _aspectRatio = 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final ratio = _aspectRatio ?? 0.6;
    final minH = width * 0.4;
    final maxH = 2.0 * 1.sh;
    final height = (width * ratio).clamp(minH, maxH);
    final preview = widget.preview;

    // Decide how to render the preview image:
    // - Taller images fill more vertically and can be shown covering the header.
    // - Flatter/smaller images are centered and scaled to width.
    const double tallThreshold = 1.2;
    final bool isTallImage = ratio >= tallThreshold;
    final BoxFit fit = isTallImage ? BoxFit.cover : BoxFit.fitWidth;
    final Alignment alignment =
        isTallImage ? Alignment.topCenter : Alignment.center;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        color: colorScheme.surface,
        child: preview.imageUrl != null && preview.imageUrl!.isNotEmpty
            ? Center(
                child: CachedNetworkImage(
                  imageUrl: preview.imageUrl!,
                  fit: fit,
                  alignment: alignment,
                  placeholder: (_, __) => const ProductImageLoader(),
                  errorWidget: (_, __, ___) => Container(color: colorScheme.surface),
                ),
              )
            : null,
      ),
    );
  }
}
