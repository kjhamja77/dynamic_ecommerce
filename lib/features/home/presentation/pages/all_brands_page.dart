import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/featured_brands_section.dart';
import 'package:zalando_clone_app/core/constants/app_constants.dart';
import 'package:zalando_clone_app/features/catalog/domain/models/catalog_args.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

String _tr(BuildContext context, {required String en, required String ar}) {
  return Directionality.of(context) == TextDirection.rtl ? ar : en;
}

class AllBrandsPage extends StatelessWidget {
  final List<BrandData> brands;
  final String? title;

  const AllBrandsPage({super.key, required this.brands, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          title?.isNotEmpty == true ? title! : 'All Brands',
          style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveConstants.gridCrossAxisCount,
            crossAxisSpacing: ResponsiveConstants.gridSpacing,
            mainAxisSpacing: ResponsiveConstants.gridSpacing,
            childAspectRatio: 0.86,
          ),
          itemCount: brands.length,
          itemBuilder: (context, index) {
            final brand = brands[index];
            return _BrandTile(brand: brand);
          },
        ),
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  final BrandData brand;

  const _BrandTile({required this.brand});

  Widget _buildBrandImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.business,
            color: Colors.grey.shade400,
            size: ResponsiveConstants.lgIconSize,
          ),
        ),
      );
    }
    final resolvedUrl = imageUrl.startsWith('http')
        ? imageUrl
        : AppConstants.baseUrl + (imageUrl.startsWith('/') ? imageUrl : '/$imageUrl');
    return CachedNetworkImage(
      imageUrl: resolvedUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Center(
        child: AppLoadingWidget.small(
          message: 'Loading...',
          showMessage: false,
        ),
      ),
      errorWidget: (context, url, error) => Center(
        child: Icon(
          Icons.business,
          color: Colors.grey.shade400,
          size: ResponsiveConstants.lgIconSize,
        ),
      ),
    );
  }

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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                child: _buildBrandImage(brand.logoUrl),
              ),
            ),
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            brand.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveConstants.xsSpacing),
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
            SizedBox(height: ResponsiveConstants.xsSpacing + (ResponsiveConstants.xsSpacing / 2)),
          SizedBox(height: ResponsiveConstants.xsSpacing),
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
