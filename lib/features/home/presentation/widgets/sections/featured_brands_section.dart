import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/core/widgets/section_header.dart';
import 'package:zalando_clone_app/features/catalog/domain/models/catalog_args.dart';
import 'package:zalando_clone_app/features/home/presentation/pages/all_brands_page.dart';
import 'package:zalando_clone_app/core/navigation/navigation_service.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import '../../../../../core/constants/app_constants.dart';
import '../common/no_image_data_placeholder.dart';

String _tr(BuildContext context, {required String en, required String ar}) {
  return Directionality.of(context) == TextDirection.rtl ? ar : en;
}

class FeaturedBrandsSection extends StatelessWidget {
  final String? title;
  final List<BrandData>? brands;
  const FeaturedBrandsSection({super.key, this.title, this.brands});

  @override
  Widget build(BuildContext context) {
    if (brands != null && brands!.isEmpty) {
      return const SizedBox.shrink();
    }
    final data = brands ?? _getFeaturedBrands();
    return Container(
      margin: EdgeInsets.only(
        top: ResponsiveConstants.smSpacing,
        bottom: ResponsiveConstants.smSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title?.isNotEmpty == true
                ? title!
                : _tr(context, en: 'Featured Brands', ar: 'علامات تجارية مميزة'),
            actionText: _tr(context, en: 'View All', ar: 'عرض الكل'),
            onAction: () {
              final brands = data;
              context.pushCatalog(
                AllBrandsPage(brands: brands, title: title?.isNotEmpty == true ? title! : _tr(context, en: 'Featured Brands', ar: 'علامات تجارية مميزة')),
              );
            },
          ),
          
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          // Horizontal Brands List
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
              itemCount: data.length,
              separatorBuilder: (context, index) => SizedBox(width: ResponsiveConstants.mdSpacing),
              itemBuilder: (context, index) {
                final brand = data[index];
                return SizedBox(
                  width: 120,
                  child: _BrandCard(brand: brand),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<BrandData> _getFeaturedBrands() {
    return [
      BrandData(
        id: '1',
        name: 'Nike',
        logoUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200&h=200&fit=crop',
        productCount: '1.2k+',
        isPremium: true,
      ),
      BrandData(
        id: '2',
        name: 'Adidas',
        logoUrl: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=200&h=200&fit=crop',
        productCount: '980+',
        isPremium: true,
      ),
      BrandData(
        id: '3',
        name: 'Levi\'s',
        logoUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=200&h=200&fit=crop',
        productCount: '750+',
        isPremium: false,
      ),
      BrandData(
        id: '4',
        name: 'Zara',
        logoUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=200&h=200&fit=crop',
        productCount: '650+',
        isPremium: false,
      ),
      BrandData(
        id: '5',
        name: 'H&M',
        logoUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=200&h=200&fit=crop',
        productCount: '890+',
        isPremium: false,
      ),
      BrandData(
        id: '6',
        name: 'Apple',
        logoUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200&h=200&fit=crop',
        productCount: '320+',
        isPremium: true,
      ),
      
      // New brands from assets
      BrandData(
        id: '7',
        name: 'Vizzano',
        logoUrl: 'assets/images/brands/vizzano.jpg',
        productCount: '150+',
        isPremium: true,
      ),
      BrandData(
        id: '8',
        name: 'Molekinha',
        logoUrl: 'assets/images/brands/molkina.jpg',
        productCount: '200+',
        isPremium: false,
      ),
      BrandData(
        id: '9',
        name: 'BRSport',
        logoUrl: 'assets/images/brands/brsport.jpg',
        productCount: '180+',
        isPremium: false,
      ),
      BrandData(
        id: '10',
        name: 'Molekinho',
        logoUrl: 'assets/images/brands/molekinho.jpg',
        productCount: '120+',
        isPremium: false,
      ),
      BrandData(
        id: '11',
        name: 'Actvitta',
        logoUrl: 'assets/images/brands/actvitta.jpg',
        productCount: '95+',
        isPremium: false,
      ),
      BrandData(
        id: '12',
        name: 'Bera Rio',
        logoUrl: 'assets/images/brands/berario.jpg',
        productCount: '160+',
        isPremium: false,
      ),
      BrandData(
        id: '13',
        name: 'Modare',
        logoUrl: 'assets/images/brands/modare.jpg',
        productCount: '140+',
        isPremium: false,
      ),
      BrandData(
        id: '14',
        name: 'Moleca',
        logoUrl: 'assets/images/brands/moleca.jpg',
        productCount: '110+',
        isPremium: false,
      ),
    ];
  }
}

class _BrandCard extends StatelessWidget {
  Widget _buildBrandImage(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return const NoImageDataPlaceholder(compact: true);
    }
    // Align image resolution/URL handling with AllBrandsPage
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const NoImageDataPlaceholder(compact: true),
      );
    }
    // Use the same resolution/absolute URL handling as AllBrandsPage
    // Mirror AllBrandsPage: if relative, prefix with baseUrl
    final resolvedUrl = imageUrl.startsWith('http')
        ? imageUrl
        : AppConstants.baseUrl + (imageUrl.startsWith('/') ? imageUrl : '/$imageUrl');
    return CachedNetworkImage(
      imageUrl: resolvedUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: AppLoadingWidget.small(
          message: 'Loading...',
          showMessage: false,
        ),
      ),
      errorWidget: (context, url, error) =>
          const NoImageDataPlaceholder(compact: true),
    );
  }
  final BrandData brand;

  const _BrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
          await HapticService.buttonClick();
          Navigator.pushNamed(
          context,
          '/catalog',
          arguments: CatalogArgs(title: brand.name, brand: brand.name),
        );
        },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Brand Logo - Fixed position at top
          Container(
            width: ResponsiveConstants.lgIconSize * 2,
            height: ResponsiveConstants.lgIconSize * 2,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              child: _buildBrandImage(brand.logoUrl),
            ),
          ),
          
          SizedBox(height: ResponsiveConstants.smSpacing),
          
          // Brand Name - Fixed position below logo
          Text(
            brand.name,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: ResponsiveConstants.xsSpacing),
          
          // Premium Badge - Fixed position below name
          if (brand.isPremium)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.xsSpacing,
                vertical: ResponsiveConstants.xsSpacing / 2,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(ResponsiveConstants.xsRadius),
              ),
              child: Text(
                _tr(context, en: 'Premium', ar: 'مميز'),
                style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            )
          else
            // Placeholder to maintain consistent spacing
            SizedBox(height: ResponsiveConstants.xsSpacing + (ResponsiveConstants.xsSpacing / 2)),
          
          SizedBox(height: ResponsiveConstants.xsSpacing),
          
          // Product Count - Fixed position at bottom
          Text(
            _tr(context, en: '${brand.productCount} products', ar: '${brand.productCount} منتج'),
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.xsFontSize,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class BrandData {
  final String id;
  final String name;
  final String logoUrl;
  final String productCount;
  final bool isPremium;

  const BrandData({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.productCount,
    required this.isPremium,
  });
}
