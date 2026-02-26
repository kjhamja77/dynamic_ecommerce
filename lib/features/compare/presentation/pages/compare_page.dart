import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../home/domain/entities/product.dart';
import '../../presentation/cubit/compare_cubit.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../product_details/domain/usecases/get_product_details.dart';
import '../../../product_details/domain/entities/product_details.dart';
import '../../../../core/providers/currency_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../l10n/app_localizations.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  String _tr(BuildContext context, String en, String ar) {
    return Localizations.localeOf(context).languageCode.toLowerCase() == 'ar' ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_tr(context, 'Compare', 'مقارنة')),
        centerTitle: true,
        actions: [
          BlocBuilder<CompareCubit, CompareState>(
            builder: (context, s) {
              if (s.selected.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => context.read<CompareCubit>().clear(),
                child: Text(AppLocalizations.of(context)!.clear, style: const TextStyle(color: Colors.black)),
              );
            },
          )
        ],
      ),
      body: BlocBuilder<CompareCubit, CompareState>(
        builder: (context, state) {
          final items = state.selected;
          if (items.length < 2) {
            return Center(
              child: Text(_tr(context, 'Select at least 2 products to compare', 'اختر على الأقل منتجين للمقارنة'), style: AppFonts.getTextStyle()),
            );
          }
          return FutureBuilder<List<ProductDetails>>(
            future: _loadDetailsMulti(items),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return _CompareShimmer(count: items.length.clamp(2, 4));
              }
              if (!snapshot.hasData || snapshot.data!.length < 2) {
                return Center(child: Text(_tr(context, 'Failed to load product details', 'فشل تحميل تفاصيل المنتج'), style: AppFonts.getTextStyle()));
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderRowMulti(
                          products: items,
                          onRemoveAt: (i) => context.read<CompareCubit>().remove(items[i].id),
                        ),
                        SizedBox(height: ResponsiveConstants.lgSpacing),
                        _DynamicFeaturesGridMulti(details: snapshot.data!),
                        SizedBox(height: ResponsiveConstants.xlSpacing),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CompareCubit, CompareState>(
        builder: (context, state) {
          if (state.selected.length < 2) return const SizedBox.shrink();
          return SafeArea(
            minimum: EdgeInsets.only(bottom: ResponsiveConstants.mdPadding),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              padding: EdgeInsets.fromLTRB(
                ResponsiveConstants.mdPadding,
                ResponsiveConstants.mdPadding,
                ResponsiveConstants.mdPadding,
                0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int i = 0; i < state.selected.length; i++) ...[
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            final p = state.selected[i];
                            Navigator.of(context).pushNamed(
                              '/product-details',
                              arguments: {
                                'productId': p.id,
                                'productType': p.type,
                                'cardPreview': {
                                  'imageUrl': p.images.isNotEmpty ? p.images.first : null,
                                  'brand': p.brand,
                                  'productTitle': p.name,
                                  'price': p.price,
                                },
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('${_tr(context, 'View', 'عرض')} ${_shortName(state.selected[i])}', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      if (i != state.selected.length - 1) const SizedBox(width: 12),
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final Product left;
  final Product right;
  final VoidCallback onLeftRemove;
  final VoidCallback onRightRemove;
  const _HeaderRow({
    required this.left,
    required this.right,
    required this.onLeftRemove,
    required this.onRightRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _HeaderColumn(product: left, onRemove: onLeftRemove)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'ضد' : 'VS', style: AppFonts.getTextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
        ),
        Expanded(child: _HeaderColumn(product: right, onRemove: onRightRemove)),
      ],
    );
  }

}

class _HeaderColumn extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;
  const _HeaderColumn({required this.product, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: Container(
                width: 96,
                height: 96,
                color: Colors.grey.shade100,
                child: product.images.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.contain,
                        placeholder: (c, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (c, _, __) => const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.image_not_supported),
              ),
            ),
            Positioned(
              bottom: -10,
              left: 48 - 14,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/product-details',
                      arguments: {
                        'productId': product.id,
                        'productType': product.type,
                        'openAddToCart': true,
                        'cardPreview': {
                          'imageUrl': product.images.isNotEmpty ? product.images.first : null,
                          'brand': product.brand,
                          'productTitle': product.name,
                          'price': product.price,
                        },
                      },
                    );
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(Icons.add, size: 16, color: Colors.grey.shade600),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          product.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          currency.formatPrice(product.price, locale: Localizations.localeOf(context)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.getTextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _HeaderRowMulti extends StatelessWidget {
  final List<Product> products;
  final void Function(int index) onRemoveAt;
  const _HeaderRowMulti({required this.products, required this.onRemoveAt});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < products.length; i++) ...[
            SizedBox(
              width: 160,
              child: _HeaderColumn(product: products[i], onRemove: () => onRemoveAt(i)),
            ),
            if (i != products.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 8, right: 8),
                child: Text('VS', style: AppFonts.getTextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
              ),
          ],
        ],
      ),
    );
  }
}

class _DynamicFeaturesGrid extends StatelessWidget {
  final ProductDetails left;
  final ProductDetails? right;
  const _DynamicFeaturesGrid({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final dividerColor = Colors.grey.shade300;
    Widget sectionHeader(String title) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            title.toUpperCase(),
            style: AppFonts.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );

    Widget cell(String text, {bool roundLeftEdge = false, bool roundRightEdge = false}) => Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: dividerColor),
            borderRadius: BorderRadius.only(
              topLeft: roundLeftEdge ? const Radius.circular(12) : Radius.zero,
              bottomLeft: roundLeftEdge ? const Radius.circular(12) : Radius.zero,
              topRight: roundRightEdge ? const Radius.circular(12) : Radius.zero,
              bottomRight: roundRightEdge ? const Radius.circular(12) : Radius.zero,
            ),
          ),
          constraints: const BoxConstraints(minHeight: 60),
          child: Text(
            text.isEmpty ? '—' : text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
          ),
        );

    Widget two(String leftText, String? rightText) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cell(leftText, roundLeftEdge: true)),
              const SizedBox(width: 1),
              Expanded(child: cell(rightText ?? '—', roundRightEdge: true)),
            ],
          ),
        );

    String joinOrDash(List<String> list) => list.isEmpty ? '—' : list.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الميزات' : 'Features', textAlign: TextAlign.center, style: AppFonts.getTextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
        const SizedBox(height: 12),

        sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'السعر' : 'Price'),
        two(
          currency.formatPrice(left.price, locale: Localizations.localeOf(context)),
          right != null ? currency.formatPrice(right!.price, locale: Localizations.localeOf(context)) : null,
        ),

        sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'العلامة التجارية' : 'Brand'),
        two(left.brand, right?.brand),

        if (left.features.isNotEmpty || (right?.features.isNotEmpty ?? false)) ...[
          sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'الميزات الرئيسية' : 'Key Features'),
          two(joinOrDash(left.features), right?.features != null ? joinOrDash(right!.features) : null),
        ],

        if (left.materialsList.isNotEmpty || (right?.materialsList.isNotEmpty ?? false)) ...[
          sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'الخامات' : 'Materials'),
          two(joinOrDash(left.materialsList), right?.materialsList != null ? joinOrDash(right!.materialsList) : null),
        ],

        // Sizes
        if (left.sizeOptions.isNotEmpty || (right?.sizeOptions.isNotEmpty ?? false)) ...[
          sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'المقاسات' : 'Sizes'),
          two(joinOrDash(left.sizeOptions.map((e) => e.name).toList()), right?.sizeOptions != null ? joinOrDash(right!.sizeOptions.map((e) => e.name).toList()) : null),
        ],

        // Colors
        if (left.colorOptions.isNotEmpty || (right?.colorOptions.isNotEmpty ?? false)) ...[
          sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'الألوان' : 'Colors'),
          two(joinOrDash(left.colorOptions.map((e) => e.name).toList()), right?.colorOptions != null ? joinOrDash(right!.colorOptions.map((e) => e.name).toList()) : null),
        ],

        // Other variant attributes (dynamic)
        for (final attrName in _collectVariantAttributeNames(left, right ?? left)) ...[
          sectionHeader(attrName),
          two(_valuesForAttribute(left, attrName), right != null ? _valuesForAttribute(right!, attrName) : null),
        ],

        if ((left.careInstructions).isNotEmpty || ((right?.careInstructions ?? '').isNotEmpty)) ...[
          sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'تعليمات العناية' : 'Care Instructions'),
          two(left.careInstructions, (right?.careInstructions ?? '').isNotEmpty ? right!.careInstructions : null),
        ],

        if (left.heelHeightCm != null || (right?.heelHeightCm != null)) ...[
          sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'ارتفاع الكعب (سم)' : 'Heel Height (cm)'),
          two(left.heelHeightCm?.toStringAsFixed(1) ?? '—', (right?.heelHeightCm != null) ? right!.heelHeightCm!.toStringAsFixed(1) : null),
        ] else ...[
        sectionHeader(Localizations.localeOf(context).languageCode == 'ar' ? 'المخزون' : 'Stock'),
        two(
          left.inStock ? (Localizations.localeOf(context).languageCode == 'ar' ? 'متوفر' : 'In stock') : (Localizations.localeOf(context).languageCode == 'ar' ? 'غير متوفر' : 'Out of stock'),
          right == null ? null : (right!.inStock ? (Localizations.localeOf(context).languageCode == 'ar' ? 'متوفر' : 'In stock') : (Localizations.localeOf(context).languageCode == 'ar' ? 'غير متوفر' : 'Out of stock')),
        ),
        ],
      ],
    );
  }

  // Collect attribute names from variantAttributeOptions excluding color/size which are shown above
  List<String> _collectVariantAttributeNames(ProductDetails l, ProductDetails r) {
    final Set<String> names = {};
    void addAll(List<VariantAttributeOption> opts) {
      for (final o in opts) {
        final n = o.attributeName.trim();
        if (n.isEmpty) continue;
        final lower = n.toLowerCase();
        if (lower == 'color' || lower == 'colour' || lower == 'size' || lower == 'اللون') continue;
        names.add(n);
      }
    }
    addAll(l.variantAttributeOptions);
    addAll(r.variantAttributeOptions);
    return names.toList();
  }

  String _valuesForAttribute(ProductDetails d, String attributeName) {
    try {
      final opt = d.variantAttributeOptions.firstWhere((o) => o.attributeName.toLowerCase() == attributeName.toLowerCase());
      if (opt.values.isEmpty) return '—';
      return opt.values.map((v) => v.name).toList().join(', ');
    } catch (_) {
      return '—';
    }
  }
}

Future<List<ProductDetails>> _loadDetails(Product left, Product right) async {
  final usecase = di.sl<GetProductDetails>();
  final leftRes = await usecase.call(left.id);
  final rightRes = await usecase.call(right.id);
  return [
    leftRes.fold((_) => _fallbackFromProduct(left), (d) => d),
    rightRes.fold((_) => _fallbackFromProduct(right), (d) => d),
  ];
}

Future<List<ProductDetails>> _loadDetailsMulti(List<Product> products) async {
  final usecase = di.sl<GetProductDetails>();
  final futures = products.map((p) => usecase.call(p.id)).toList();
  final results = await Future.wait(futures);
  final List<ProductDetails> out = [];
  for (int i = 0; i < results.length; i++) {
    out.add(results[i].fold((_) => _fallbackFromProduct(products[i]), (d) => d));
  }
  return out;
}

ProductDetails _fallbackFromProduct(Product p) {
  return ProductDetails(
    id: p.id,
    brand: p.brand,
    name: p.name,
    description: p.description,
    price: p.price,
    originalPrice: p.originalPrice,
    rating: p.rating.toInt(),
    reviewCount: p.reviewCount,
    images: p.images,
    colorOptions: const [],
    sizeOptions: const [],
    selectedColor: '',
    selectedSize: '',
    isFavorite: p.favourite,
    hasDiscount: (p.originalPrice != null && p.originalPrice! > p.price),
    discountPercentage: p.originalPrice != null && p.originalPrice! > 0 ? (100 - (p.price / p.originalPrice! * 100)).round() : null,
    features: p.features ?? const [],
    material: p.materials?.join(', ') ?? '',
    materialsList: p.materials ?? const [],
    materialOptions: const [],
    careInstructions: p.careInstructions ?? '',
    websiteUrl: null,
    heelHeightCm: p.heelHeightCm,
    heelType: p.heelType,
    heelHeightOptions: const [],
    selectedHeelHeightCm: null,
    isPlusMember: false,
    pointsEarned: 0,
    optionalProducts: const [],
    accessoryProducts: const [],
    alternativeProducts: const [],
    variantCombinations: const [],
    primaryVariantLabel: 'Size',
    inStock: p.isAvailable,
  );
}
class _FeaturesGrid extends StatelessWidget {
  final Product left;
  final Product right;
  const _FeaturesGrid({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.grey.shade300;
    Widget sectionHeader(String title) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            title.toUpperCase(),
            style: AppFonts.getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
        );

    Widget cell(String text, {bool roundedLeft = false, bool roundedRight = false}) => Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: dividerColor),
            borderRadius: BorderRadius.only(
              bottomLeft: roundedLeft ? const Radius.circular(8) : Radius.zero,
              bottomRight: roundedRight ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          child: Text(text, style: AppFonts.getTextStyle(fontWeight: FontWeight.w600)),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Features',
          textAlign: TextAlign.center,
          style: AppFonts.getTextStyle(fontWeight: FontWeight.w700, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        // Category
        sectionHeader('Category'),
        Row(children: [
          Expanded(child: cell(left.category.isNotEmpty ? left.category : '—')),
          const SizedBox(width: 1),
          Expanded(child: cell(right.category.isNotEmpty ? right.category : '—')),
        ]),

        // Availability
        sectionHeader('Availability'),
        Row(children: [
          Expanded(child: cell(left.isAvailable ? 'In stock' : 'Out of stock')),
          const SizedBox(width: 1),
          Expanded(child: cell(right.isAvailable ? 'In stock' : 'Out of stock')),
        ]),

        // Colors
        sectionHeader('Colors'),
        Row(children: [
          Expanded(child: cell(left.colors.isNotEmpty ? left.colors.join(', ') : '—')),
          const SizedBox(width: 1),
          Expanded(child: cell(right.colors.isNotEmpty ? right.colors.join(', ') : '—')),
        ]),

        // Sizes
        sectionHeader('Sizes'),
        Row(children: [
          Expanded(child: cell(left.sizes.isNotEmpty ? left.sizes.join(', ') : '—', roundedLeft: true)),
          const SizedBox(width: 1),
          Expanded(child: cell(right.sizes.isNotEmpty ? right.sizes.join(', ') : '—', roundedRight: true)),
        ]),
      ],
    );
  }
}

class _DynamicFeaturesGridMulti extends StatelessWidget {
  final List<ProductDetails> details;
  const _DynamicFeaturesGridMulti({required this.details});

  @override
  Widget build(BuildContext context) {
    if (details.length < 2) return const SizedBox.shrink();
    // Render two at a time; if odd count, last page shows single left and placeholder right
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < details.length; i += 2) ...[
            SizedBox(
              width: MediaQuery.of(context).size.width - (ResponsiveConstants.mdPadding * 2),
              child: _DynamicFeaturesGrid(
                left: details[i],
                right: (i + 1 < details.length) ? details[i + 1] : null,
              ),
            ),
            if (i + 2 < details.length) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

String _shortName(Product p) {
  final n = p.name.trim();
  if (n.length <= 14) return n;
  return '${n.substring(0, 14)}…';
}

class _CompareShimmer extends StatelessWidget {
  final int count;
  const _CompareShimmer({this.count = 2});

  @override
  Widget build(BuildContext context) {
    final cols = count.clamp(2, 4);
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
      child: Column(
        children: [
          // Make header horizontally scrollable to avoid overflow for 4 items
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < cols; i++) ...[
                  _circle(),
                  if (i != cols - 1) _line(width: 24, height: 16),
                ]
              ],
            ),
          ),
          SizedBox(height: ResponsiveConstants.lgSpacing),
          _line(width: 80, height: 12),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _rowBox(cols),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _line(width: 80, height: 12),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _rowBox(cols),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _line(width: 80, height: 12),
          SizedBox(height: ResponsiveConstants.smSpacing),
          _rowBox(cols),
        ],
      ),
    );
  }

  Widget _rowBox(int cols) {
    return Row(
      children: [
        for (int i = 0; i < cols; i++) ...[
          Expanded(child: _box()),
          if (i != cols - 1) const SizedBox(width: 8),
        ]
      ],
    );
  }

  Widget _box() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        
        final baseColor = isDark 
            ? colorScheme.outline.withValues(alpha: 0.3)
            : Colors.grey.shade300;
        final highlightColor = isDark
            ? colorScheme.outline.withValues(alpha: 0.5)
            : Colors.grey.shade100;
        
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _circle() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        
        final baseColor = isDark 
            ? colorScheme.outline.withValues(alpha: 0.3)
            : Colors.grey.shade300;
        final highlightColor = isDark
            ? colorScheme.outline.withValues(alpha: 0.5)
            : Colors.grey.shade100;
        
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _line({required double width, required double height}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        
        final baseColor = isDark 
            ? colorScheme.outline.withValues(alpha: 0.3)
            : Colors.grey.shade300;
        final highlightColor = isDark
            ? colorScheme.outline.withValues(alpha: 0.5)
            : Colors.grey.shade100;
        
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}

  