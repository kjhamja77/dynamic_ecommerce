import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zalando_clone_app/core/theme/app_fonts.dart';
import '../../../../core/utils/image_cache_utils.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/widgets/authenticated_cached_image.dart';
import '../../domain/entities/component.dart';
import '../../domain/entities/banner.dart' as home_banner;
import '../../domain/entities/product.dart';
import 'banner/banner_carousel_widget.dart';
import 'common/product_card.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../catalog/domain/models/catalog_args.dart';
import '../pages/story_detail_page.dart';
import '../../../../core/services/haptic_service.dart';
import 'package:zalando_clone_app/features/filters/domain/entities/filter_criteria.dart';
import 'package:zalando_clone_app/features/home/presentation/theme/home_decorations.dart';

/// Safely cast a value to String, but return empty string for bool values (to avoid showing "false")
String _safeStringCastNonNull(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is bool) return ''; // Don't show "false" or "true" as text
  return value.toString();
}

/// Returns true if the string contains Arabic characters.
bool _containsArabic(String value) {
  // Arabic Unicode blocks: 0600–06FF, 0750–077F, 08A0–08FF, FB50–FDFF, FE70–FEFF
  final arabicRegex = RegExp(r"[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]");
  return arabicRegex.hasMatch(value);
}

class DynamicComponentRenderer extends StatelessWidget {
  final Component component;

  const DynamicComponentRenderer({
    super.key,
    required this.component,
  });

  /// Constructs full image URL from relative path
  String _constructImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else {
      return '${AppConstants.baseUrl}${imagePath.startsWith('/') ? imagePath : '/$imagePath'}';
    }
  }

  /// Unified cached image widget used across components for consistent
  /// loading and error states.
  Widget _buildCachedImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? placeholderColor,
    IconData errorIcon = Icons.image_not_supported,
  }) {
    final String url = ImageCacheUtils.addCacheBuster(imageUrl);
    final Color bg = placeholderColor ?? Colors.grey.shade200;
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => Container(
        width: width,
        height: height,
        color: bg,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, _, __) => Container(
        width: width,
        height: height,
        color: bg,
        child: Icon(errorIcon, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (component.type.toLowerCase()) {
      case 'text':
        return _buildTextComponent(context);
      case 'banner':
        return _buildBannerComponent();
      case 'product':
        return _buildProductComponent();
      case 'category':
        return _buildCategoryComponent();
      case 'brand':
        return _buildBrandComponent();
      case 'story':
        return _buildStoryComponent();
      case 'offer':
        return _buildOfferComponent();
      default:
        return _buildUnknownComponent();
    }
  }

  Widget _buildTextComponent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final children = component.children.toList();
    // Don't sort - maintain API order

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      child: Column(
        crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (children[i].valueType == 'text_content') ...[
              Builder(builder: (context) {
                final content = children[i].content['text'] as Map<String, dynamic>?;
                final String heading = (content?['heading'] as String?)?.trim() ?? '';
                final String subHeading = (content?['sub_heading'] as String?)?.trim() ?? '';
                final String headingColorHex = (content?['heading_font_color'] as String?) ?? '';
                final String subHeadingColorHex = (content?['sub_heading_font_color'] as String?) ?? '';
                Color? _fromHex(String hex) {
                  if (hex.isEmpty) return null;
                  final buffer = StringBuffer();
                  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
                  buffer.write(hex.replaceFirst('#', ''));
                  return Color(int.parse(buffer.toString(), radix: 16));
                }

                if (heading.isEmpty && subHeading.isEmpty) return const SizedBox.shrink();

                final bool isHeadingArabic = _containsArabic(heading);
                final bool isSubHeadingArabic = _containsArabic(subHeading);
                final TextDirection headingDir = isHeadingArabic ? TextDirection.rtl : (isRtl ? TextDirection.rtl : TextDirection.ltr);
                final TextDirection subHeadingDir = isSubHeadingArabic ? TextDirection.rtl : (isRtl ? TextDirection.rtl : TextDirection.ltr);

                final bool useRtl = isHeadingArabic || isSubHeadingArabic || isRtl;
                return Container(
                  width: double.infinity,
                  // In dark mode give text sections a dark card background
                  // instead of a bright bar.
                  color: theme.brightness == Brightness.dark
                      ? colorScheme.surface
                      : Colors.transparent,
                  alignment: useRtl ? Alignment.centerRight : Alignment.centerLeft,
                  child: Directionality(
                    textDirection: useRtl ? TextDirection.rtl : TextDirection.ltr,
                    child: Column(
                      crossAxisAlignment: (isHeadingArabic || isRtl) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (heading.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              heading,
                              textAlign: headingDir == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                              textDirection: headingDir,
                              style: AppFonts.getTextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: _fromHex(headingColorHex) ??
                                    colorScheme.onSurface,
                                letterSpacing: -0.2,
                                height: 1.15,
                              ),
                            ),
                          ),
                        if (heading.isNotEmpty && subHeading.isNotEmpty) const SizedBox(height: 4),
                        if (subHeading.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              subHeading,
                              textAlign: subHeadingDir == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                              textDirection: subHeadingDir,
                              style: AppFonts.getTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _fromHex(subHeadingColorHex) ??
                                    colorScheme.onSurface.withValues(alpha: 0.75),
                                height: 1.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            if (i != children.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildBannerComponent() {
    print('🔍 _buildBannerComponent - Building banner component');
    final List<home_banner.Banner> banners = component.children
        .where((child) => child.valueType == 'banner_content')
        .map((child) {
          final content = child.content['banner'] as Map<String, dynamic>?;
          final String title = _safeStringCastNonNull(content?['name']);
          final String description = _safeStringCastNonNull(content?['description']);
          final String? rawImagePath = content?['image'] as String?;
          
          print('🔍 _buildBannerComponent - Raw image path: "$rawImagePath"');
          final String imageUrl = _resolveImageUrl(rawImagePath);
          print('🔍 _buildBannerComponent - Resolved image URL: "$imageUrl"');
          
          final int id = (content?['id'] as int?) ?? child.componentId;
          return home_banner.Banner(
            id: id.toString(),
            title: title,
            description: description,
            imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://picsum.photos/seed/${id}/800/400',
            actionUrl: null,
            actionText: null,
            isActive: true,
            sortOrder: component.sequence,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        })
        .toList();

    if (banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.smPadding),
      child: BannerCarouselWidget(
        banners: banners,
        height: 200,
        showIndicators: true,
        autoPlay: true,
      ),
    );
  }

  String _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) {
      print('🔍 DynamicComponentRenderer._resolveImageUrl - Raw is null/empty, returning empty string');
      return '';
    }
    
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      print('🔍 DynamicComponentRenderer._resolveImageUrl - Trimmed is empty, returning empty string');
      return '';
    }
    
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      print('🔍 DynamicComponentRenderer._resolveImageUrl - Already full URL: "$trimmed"');
      return trimmed;
    }
    
    final String base = AppConstants.baseUrl;
    
    // Debug logging
    print('🔍 DynamicComponentRenderer._resolveImageUrl - Raw: "$raw"');
    print('🔍 DynamicComponentRenderer._resolveImageUrl - Trimmed: "$trimmed"');
    print('🔍 DynamicComponentRenderer._resolveImageUrl - Base: "$base"');
    
    try {
      String finalUrl;
      if (trimmed.startsWith('/')) {
        // For paths starting with '/', combine with base URL
        finalUrl = base.endsWith('/') ? base + trimmed.substring(1) : base + trimmed;
      } else {
        // For paths not starting with '/', add '/' between base and path
        finalUrl = base.endsWith('/') ? base + trimmed : base + '/' + trimmed;
      }
      
      print('🔍 DynamicComponentRenderer._resolveImageUrl - Final URL: "$finalUrl"');
      
      // Validate the URL before returning
      final uri = Uri.tryParse(finalUrl);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        print('❌ DynamicComponentRenderer._resolveImageUrl - Invalid URL generated: "$finalUrl"');
        return '';
      }
      
      return finalUrl;
    } catch (e) {
      print('❌ DynamicComponentRenderer._resolveImageUrl - Error resolving URL: $e');
      return '';
    }
  }

  Widget _buildProductComponent() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            component.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate card width for 2 columns with spacing
              final screenWidth = constraints.maxWidth;
              final spacing = 12.0;
              final cardWidth = (screenWidth - spacing) / 2;
              
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: component.children
                    .where((child) => child.valueType == 'product_content')
                    .map((child) => SizedBox(
                          width: cardWidth,
                          child: _buildProductCardFromChild(child),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCardFromChild(dynamic child) {
    final content = child.content['product'] as Map<String, dynamic>?;
    
    // Extract product data from API response
    final Map<String, dynamic>? productTemplate =
        content?['product_template'] as Map<String, dynamic>?;
    final String templateName =
        (productTemplate?['name'] as String?)?.trim() ?? '';
    final String rawDisplayName =
        (content?['display_name'] as String?)?.trim() ?? '';
    final String rawName =
        (content?['name'] as String?)?.trim() ?? '';
    final String rawDescription =
        (content?['description'] as String?)?.trim() ?? '';

    // Heuristic to pick the best title
    String effectiveName = templateName.isNotEmpty
        ? templateName
        : (rawDisplayName.isNotEmpty ? rawDisplayName : rawName);
    if ((effectiveName.isEmpty || !_containsArabic(effectiveName)) &&
        _containsArabic(rawDescription)) {
      effectiveName = rawDescription;
    }

    final String type = (content?['type'] as String?) ?? 'variant';
    final String? image = content?['image'] as String?;
    final num price = (content?['price'] as num?) ?? 0;
    final int productId = (content?['id'] as int?) ?? child.componentId;
    
    // Brand can be nested object or simple string
    String brandName = '';
    final dynamic brandObj = content?['brand'];
    if (brandObj is Map<String, dynamic>) {
      brandName = (brandObj['name'] as String?) ?? '';
    } else if (brandObj is String) {
      brandName = brandObj;
    }
    
    // Construct full image URL
    final String? fullImageUrl = image != null && image.isNotEmpty
        ? (image.startsWith('http') 
            ? image 
            : '${AppConstants.baseUrl}${image.startsWith('/') ? image.substring(1) : image}')
        : null;
    
    // Create Product entity for ProductCard
    final Product product = Product(
      id: productId.toString(),
      name: effectiveName,
      description: rawDescription,
      price: price.toDouble(),
      originalPrice: null,
      images: fullImageUrl != null ? [fullImageUrl] : [],
      category: 'Featured',
      brand: brandName,
      type: type,
      rating: 4.5,
      reviewCount: 100,
      isAvailable: true,
      sizes: ['S', 'M', 'L'],
      colors: ['Black', 'White'],
      createdAt: DateTime.now(),
    );
    
    return ProductCard(
      product: product,
      productType: type,
    );
  }

  Widget _buildCategoryComponent() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(component.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: component.children.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final child = component.children[index];
                if (child.valueType != 'category_content') return const SizedBox.shrink();
                final content = child.content['category'] as Map<String, dynamic>?;
                final String name = (content?['name'] as String?) ?? '';
                final String? image = content?['image'] as String?;
                final int? categoryId = (content?['id'] as int?) ?? (content?['id'] as num?)?.toInt();
                
                return GestureDetector(
                  onTap: () async {
                    if (categoryId != null) {
                      await HapticService.buttonClick();
                      print('🎯 Category Navigation from Page Component - Name: $name, ID: $categoryId');
                      Navigator.pushNamed(
                        context,
                        '/catalog',
                        arguments: CatalogArgs(
                          title: name,
                          categoryId: categoryId.toString(),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.blue.shade100,
                        child: (image == null || image.isEmpty)
                            ? const Icon(Icons.category_outlined, color: Colors.white)
                            : ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: _constructImageUrl(image),
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 72,
                                    height: 72,
                                    color: Colors.blue.shade100,
                                    child: const Icon(Icons.category_outlined, color: Colors.white),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 72,
                                    height: 72,
                                    color: Colors.blue.shade100,
                                    child: const Icon(Icons.category_outlined, color: Colors.white),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 80,
                        child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandComponent() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(component.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: (() {
              final sortedChildren = component.children.toList();
              // Don't sort - maintain API order
              return sortedChildren;
            })().map((child) {
              if (child.valueType != 'brand_content') return const SizedBox.shrink();
              final content = child.content['brand'] as Map<String, dynamic>?;
              final String name = (content?['name'] as String?) ?? '';
              final String? image = content?['image'] as String?;
              return Chip(
                avatar: image != null && image.isNotEmpty
                    ? CircleAvatar(
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _constructImageUrl(image),
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 32,
                              height: 32,
                              color: Colors.green.shade100,
                              child: const Icon(Icons.store_mall_directory_outlined, size: 16),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 32,
                              height: 32,
                              color: Colors.green.shade100,
                              child: const Icon(Icons.store_mall_directory_outlined, size: 16),
                            ),
                          ),
                        ),
                      )
                    : const CircleAvatar(child: Icon(Icons.store_mall_directory_outlined, size: 16)),
                label: Text(name),
                backgroundColor: Colors.green.shade100,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryComponent() {
    print('📰 _buildStoryComponent: Rendering stories...');
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (() {
          final sortedChildren = component.children
              .where((c) => c.valueType == 'story_content')
              .toList();
          // Don't sort - maintain API order
          print('📰 Found ${sortedChildren.length} story items');
          return sortedChildren;
        })().map((child) {
          final content = child.content['story'] as Map<String, dynamic>?;
          final String heading = (content?['heading'] as String?) ?? '';
          final String subHeading = (content?['sub_heading'] as String?) ?? '';
          final String? image = content?['image'] as String?;
          final String html = (content?['content_html'] as String?)?.trim() ?? '';
          print('📰 Story item id=${child.componentId} heading="$heading" sub="$subHeading" image=${image ?? 'null'} htmlLen=${html.length}');
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.hardEdge,
            child: Builder(
              builder: (ctx) => InkWell(
                onTap: () {
                  print('🖱️ Tap story id=${child.componentId} heading="$heading" -> navigate to details');
                  Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => StoryDetailPage(
                        title: heading,
                        imageUrl: image != null && image.isNotEmpty ? _constructImageUrl(image) : null,
                        htmlBody: html,
                        subTitle: subHeading,
                        heroTag: image != null && image.isNotEmpty ? 'story_${child.componentId}' : null,
                      ),
                    ),
                  );
                },
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image != null && image.isNotEmpty)
                  Hero(
                    tag: 'story_${child.componentId}',
                    child: _buildCachedImage(
                      _constructImageUrl(image),
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            heading,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            subHeading,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              ),
            ),
            )
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOfferComponent() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final bool isRtl = Directionality.of(context) == TextDirection.rtl;
              return Text(
                component.name,
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              );
            },
          ),
          const SizedBox(height: 8),
          ...(() {
            final sortedChildren = component.children
                .where((c) => c.valueType == 'offer_content')
                .toList();
            // Don't sort - maintain API order
            return sortedChildren;
          })().map((child) {
            final content = child.content['offer'] as Map<String, dynamic>?;
            final String title = (content?['name'] as String?) ?? '';
            final String desc = (content?['description'] as String?) ?? '';
            final String? img = content?['image'] as String?;
            final List<dynamic> tags = (content?['tags'] as List<dynamic>?) ?? const [];
            
            // Resolve the image URL properly
            final String imageUrl = _constructImageUrl(img);
            print('🖼️ DynamicComponentRenderer Offer Image - Raw: "$img" → Resolved: "$imageUrl"');
            
            return Builder(
              builder: (context) {
                final bool isRtl = Directionality.of(context) == TextDirection.rtl;
                return Container(
                  margin: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
                  child: GestureDetector(
                onTap: () => _navigateToOfferFilters(context, content),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                          end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                          colors: [
                            const Color(0xFFFF6B35), // Vibrant orange
                            const Color(0xFFFF8C42), // Lighter orange
                            const Color(0xFFFFA07A), // Soft coral
                          ],
                        ),
                        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                        boxShadow: homeCardBoxShadow(context, [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ]),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ResponsiveConstants.lgRadius),
                        child: Stack(
                          children: [
                            // Main content
                            Padding(
                              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                              child: Row(
                                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                                children: [
                                  // Left side - Content
                    Expanded(
                                    child: Column(
                            crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                        // Tags badge (NEW, etc.)
                                        if (tags.isNotEmpty)
                                          Container(
                                            margin: EdgeInsets.only(
                                              bottom: ResponsiveConstants.xsSpacing,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: ResponsiveConstants.smPadding,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.4),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              (tags.first as Map)['name'] as String? ?? 'NEW',
                                              style: AppFonts.getTextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        
                                        // Title
                              Text(
                                title,
                                          style: AppFonts.getTextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                textAlign: isRtl ? TextAlign.right : TextAlign.left,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                              ),
                                        
                                        if (desc.isNotEmpty) ...[
                                          SizedBox(height: ResponsiveConstants.xsSpacing),
                                Text(
                                  desc,
                                            style: AppFonts.getTextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white.withValues(alpha: 0.9),
                                            ),
                                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        
                                        SizedBox(height: ResponsiveConstants.smSpacing),
                                        
                                        // Shop now indicator
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                                          children: [
                                            Text(
                                              isRtl ? 'تسوق الآن' : 'Shop Now',
                                              style: AppFonts.getTextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              isRtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(width: ResponsiveConstants.mdSpacing),
                                  
                                  // Right side - Product Image
                                  if (imageUrl.isNotEmpty)
                                    Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                                        boxShadow: homeCardBoxShadow(context, [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 15,
                                            offset: const Offset(0, 6),
                                            spreadRadius: 0,
                                          ),
                                        ]),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(ResponsiveConstants.mdRadius),
                                        child: AuthenticatedCachedImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.2),
                                                  Colors.white.withValues(alpha: 0.1),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                          ),
                                          errorWidget: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.2),
                                                  Colors.white.withValues(alpha: 0.1),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.local_offer,
                                                color: Colors.white.withValues(alpha: 0.6),
                                                size: 48,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            // Decorative corner accent
                            Positioned(
                              top: 0,
                              right: isRtl ? null : 0,
                              left: isRtl ? 0 : null,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: isRtl ? Radius.zero : Radius.circular(ResponsiveConstants.lgRadius),
                                    topLeft: isRtl ? Radius.circular(ResponsiveConstants.lgRadius) : Radius.zero,
                                  ),
                                  gradient: RadialGradient(
                                    center: isRtl ? Alignment.topLeft : Alignment.topRight,
                                    radius: 1.5,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.15),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
              ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUnknownComponent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                component.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (component.description.isNotEmpty)
                Text(
                  component.description,
                  style: const TextStyle(fontSize: 14),
                ),
              Text(
                'Type: ${component.type}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to catalog page with offer filters
  void _navigateToOfferFilters(BuildContext context, Map<String, dynamic>? content) {
    if (content == null) return;
    
    final filters = content['filters'] as Map<String, dynamic>?;
    if (filters == null) return;
    
    final offerName = content['name'] as String? ?? 'Special Offer';
    
    // Extract filter criteria from offer filters map
    final List<dynamic> categoryIdsRaw = filters['offer_category_id'] as List<dynamic>? ?? [];
    final List<dynamic> brandIdsRaw = filters['offer_brand_id'] as List<dynamic>? ?? [];
    // New API key is `offer_product_ids` (list). Keep old key fallback.
    final dynamic productIdRaw =
        filters['offer_product_ids'] ?? filters['offer_product_id'];
    final String? keyword = filters['offer_keyword'] as String?;
    
    // Convert to proper types
    final List<int> categoryIds = categoryIdsRaw.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).where((e) => e > 0).toList();
    final List<int> brandIds = brandIdsRaw.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).where((e) => e > 0).toList();
    
    // Handle product ID (can be null, int, or list)
    List<int> productIds = [];
    if (productIdRaw != null) {
      if (productIdRaw is int) {
        productIds = [productIdRaw];
      } else if (productIdRaw is List) {
        productIds = productIdRaw.map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0).where((e) => e > 0).toList();
      } else {
        final parsed = int.tryParse(productIdRaw.toString());
        if (parsed != null && parsed > 0) {
          productIds = [parsed];
        }
      }
    }
    
    // Debug: show exactly what we extracted from the offer component
    debugPrint('🎯 [Offer → Catalog] Offer tapped: $offerName');
    debugPrint('   🔹 Raw filters map: $filters');
    debugPrint('   🔹 Parsed categoryIds: $categoryIds');
    debugPrint('   🔹 Parsed brandIds: $brandIds');
    debugPrint('   🔹 Parsed productIds: $productIds');
    debugPrint('   🔹 Parsed keyword (offer_keyword): $keyword');
    
    // Build FilterCriteria specifically for filter-search:
    // - Always send brand IDs and product IDs as lists
    // - Use offer_keyword as search_term
    // - Also forward category IDs from offer_category_id
    final filterCriteria = FilterCriteria(
      categoryIds: categoryIds,
      brandIds: brandIds,
      productIds: productIds,
      searchQuery: keyword?.isNotEmpty == true ? keyword : null,
      omitPaginationInRequest: true,
    );
    
    // Debug: log the exact pieces that will go into filter-search body
    debugPrint('📦 [Offer → Catalog] FilterCriteria built for filter-search:');
    debugPrint('   ➤ category_ids (FilterCriteria.categoryIds): ${filterCriteria.categoryIds}');
    debugPrint('   ➤ brand_ids    (FilterCriteria.brandIds): ${filterCriteria.brandIds}');
    debugPrint('   ➤ product_ids  (FilterCriteria.productIds): ${filterCriteria.productIds}');
    debugPrint('   ➤ search_term  (FilterCriteria.searchQuery): ${filterCriteria.searchQuery}');
    debugPrint('   ➤ omitPaginationInRequest: ${filterCriteria.omitPaginationInRequest} (page/limit not sent)');
    
    // Navigate to catalog with combined filters
    debugPrint('🚀 [Offer → Catalog] Navigating to /catalog with initialFilters from offer...');
    Navigator.pushNamed(
      context,
      '/catalog',
      arguments: CatalogArgs(
        title: offerName,
        initialFilters: filterCriteria,
      ),
    );
  }
}
