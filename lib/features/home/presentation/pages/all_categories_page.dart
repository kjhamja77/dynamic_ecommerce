import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/constants/responsive_constants.dart';
import 'package:zalando_clone_app/core/widgets/app_loading_widget.dart';
import 'package:zalando_clone_app/core/constants/app_constants.dart';
import 'package:zalando_clone_app/features/catalog/domain/models/catalog_args.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';
import 'package:zalando_clone_app/core/di/injection_container.dart';
import 'package:zalando_clone_app/features/search/domain/services/category_service.dart';
import 'package:zalando_clone_app/features/home/presentation/widgets/sections/featured_categories_section.dart';

String _tr(BuildContext context, {required String en, required String ar}) {
  return Directionality.of(context) == TextDirection.rtl ? ar : en;
}

class AllCategoriesPage extends StatefulWidget {
  final List<CategoryData> categories;
  final String? title;

  const AllCategoriesPage({super.key, required this.categories, this.title});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  List<CategoryData> _remoteCategories = const [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = sl<CategoryService>();
      final result = await service.getAllCategories(
        maxDepth: 1,
        limit: 100,
        offset: 0,
      );

      result.fold(
        (failure) {
          _errorMessage = failure.message;
          _remoteCategories = const [];
        },
        (productCategories) {
          _remoteCategories = productCategories.map((c) {
            String imageUrl = '';
            if (c.image != null && c.image!.isNotEmpty) {
              imageUrl = c.image!.startsWith('http')
                  ? c.image!
                  : '${AppConstants.baseUrl}${c.image!.startsWith('/') ? c.image! : '/${c.image!}'}';
            }
            return CategoryData(
              id: c.id.toString(),
              name: c.name,
              imageUrl: imageUrl,
              productCount: c.productCount.toString(),
              color: Colors.grey.shade200,
            );
          }).toList();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _remoteCategories = const [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        title: Text(
          widget.title?.isNotEmpty == true ? widget.title! : 'All Categories',
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: AppLoadingWidget.small(
          message: 'Loading...',
          showMessage: false,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          'Failed to load categories',
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.mdFontSize,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }

    // Merge categories coming from page components (widget.categories)
    // with categories loaded from the API, placing component categories first.
    final List<CategoryData> baseCategories = widget.categories;
    final List<CategoryData> mergedCategories = [
      ...baseCategories,
      ..._remoteCategories.where(
        (remote) => !baseCategories.any((local) => local.id == remote.id),
      ),
    ];

    if (mergedCategories.isEmpty) {
      return const Center(child: SizedBox.shrink());
    }

    return Padding(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveConstants.gridCrossAxisCount,
          crossAxisSpacing: ResponsiveConstants.gridSpacing,
          mainAxisSpacing: ResponsiveConstants.gridSpacing,
          childAspectRatio: 0.78,
        ),
        itemCount: mergedCategories.length,
        itemBuilder: (context, index) {
          final category = mergedCategories[index];
          return _CategoryTile(category: category);
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryData category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final imageBgColor = isDark ? colorScheme.surfaceContainerHighest : category.color;
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
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 2,
                    spreadRadius: 0.5,
                    offset: const Offset(0.5, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveConstants.mdRadius),
                  topRight: Radius.circular(ResponsiveConstants.mdRadius),
                ),
                child: Container(
                  width: double.infinity,
                  color: imageBgColor,
                  child: category.imageUrl.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.category_outlined,
                            color: colorScheme.onSurfaceVariant,
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
                              color: colorScheme.onSurfaceVariant,
                              size: ResponsiveConstants.lgIconSize,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.smPadding,
                vertical: ResponsiveConstants.xsSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.getTextStyle(
                      fontSize: ResponsiveConstants.mdFontSize,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  // Keep the product count logic available, but hide it from
                  // the All Categories card UI as requested.
                  // Text(
                  //   _tr(context, en: '${category.productCount} products', ar: '${category.productCount} منتج'),
                  //   style: AppFonts.getTextStyle(
                  //     fontSize: ResponsiveConstants.smFontSize,
                  //     color: colorScheme.onSurfaceVariant,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
