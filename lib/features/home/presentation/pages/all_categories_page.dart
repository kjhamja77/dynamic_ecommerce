import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/featured_categories_section.dart';
import 'package:zalando_clone_app/core/constants/app_constants.dart';
import 'package:zalando_clone_app/features/catalog/domain/models/catalog_args.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

String _tr(BuildContext context, {required String en, required String ar}) {
  return Directionality.of(context) == TextDirection.rtl ? ar : en;
}

class AllCategoriesPage extends StatelessWidget {
  final List<CategoryData> categories;
  final String? title;

  const AllCategoriesPage({super.key, required this.categories, this.title});

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
          title?.isNotEmpty == true ? title! : 'All Categories',
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
            childAspectRatio: 0.78,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryTile(category: category);
          },
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryData category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
          await HapticService.buttonClick();
          print('═══════════════════════════════════════════════════════');
          print('📁 All Categories: Opening catalog');
          print('  📛 Category Name: ${category.name}');
          print('  🆔 Category ID (being passed): ${category.id}');
          print('═══════════════════════════════════════════════════════');
          Navigator.pushNamed(
          context,
          '/catalog',
          arguments: CatalogArgs(
            title: category.name, 
            categoryId: category.id, // Category ID - NOT attribute value
          ),
        );
        },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                child: category.imageUrl.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.category_outlined,
                          color: Colors.grey.shade400,
                          size: ResponsiveConstants.lgIconSize,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: category.imageUrl.startsWith('http')
                            ? category.imageUrl
                            : AppConstants.baseUrl + (category.imageUrl.startsWith('/') ? category.imageUrl : '/${category.imageUrl}'),
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
                            Icons.category_outlined,
                            color: Colors.grey.shade400,
                            size: ResponsiveConstants.lgIconSize,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveConstants.smSpacing),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.mdFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            _tr(context, en: '${category.productCount} products', ar: '${category.productCount} منتج'),
            style: AppFonts.getTextStyle(fontSize: ResponsiveConstants.smFontSize,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
