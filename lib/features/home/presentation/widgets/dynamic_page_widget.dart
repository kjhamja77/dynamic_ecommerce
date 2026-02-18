
import 'package:flutter/material.dart';
import '../../../../../core/services/haptic_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../widgets/banner/banner_carousel_widget.dart';
import '../widgets/sections/featured_categories_section.dart';
import '../widgets/sections/featured_brands_section.dart';
import '../widgets/sections/special_offers_section.dart';
import '../widgets/fashion/fashion_stories_section.dart';
import '../../domain/entities/banner.dart' as home_banner;
import '../../domain/entities/component.dart';
import '../bloc/home_bloc.dart';
import 'dynamic_component_renderer.dart';
import '../widgets/empty_states/page_components_empty_state.dart';
import '../../../../core/widgets/app_pull_to_refresh.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/app_localization_service.dart';

/// Safely cast a value to String, handling bool and null cases
String _safeStringCast(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is bool) return value.toString();
  return value.toString();
}

/// Safely cast a value to String, but return empty string for bool values (to avoid showing "false")
String _safeStringCastNonNull(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is bool) return ''; // Don't show "false" or "true" as text
  return value.toString();
}

class DynamicPageWidget extends StatefulWidget {
  final int pageId;
  final ScrollController? scrollController;

  const DynamicPageWidget({
    super.key,
    required this.pageId,
    this.scrollController,
  });

  @override
  State<DynamicPageWidget> createState() => _DynamicPageWidgetState();
}

class _DynamicPageWidgetState extends State<DynamicPageWidget> {
  // Component loading is triggered by DynamicHomeTabWidget to avoid duplicate loads

  /// Constructs full image URL from relative path (same logic as DynamicComponentRenderer)
  String _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) {
      print('🔍 DynamicPageWidget._resolveImageUrl - Raw is null/empty, returning empty string');
      return '';
    }
    
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      print('🔍 DynamicPageWidget._resolveImageUrl - Trimmed is empty, returning empty string');
      return '';
    }
    
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      print('🔍 DynamicPageWidget._resolveImageUrl - Already full URL: "$trimmed"');
      return trimmed;
    }
    
    // Import the base URL from app constants
    const String baseUrl = AppConstants.baseUrl;
    
    // Debug logging
    print('🔍 DynamicPageWidget._resolveImageUrl - Raw: "$raw"');
    print('🔍 DynamicPageWidget._resolveImageUrl - Trimmed: "$trimmed"');
    print('🔍 DynamicPageWidget._resolveImageUrl - Base: "$baseUrl"');
    
    try {
      String finalUrl;
      if (trimmed.startsWith('/')) {
        // For paths starting with '/', combine with base URL
        finalUrl = baseUrl.endsWith('/') ? baseUrl + trimmed.substring(1) : baseUrl + trimmed;
      } else {
        // For paths not starting with '/', add '/' between base and path
        finalUrl = baseUrl.endsWith('/') ? baseUrl + trimmed : baseUrl + '/' + trimmed;
      }
      
      print('🔍 DynamicPageWidget._resolveImageUrl - Final URL: "$finalUrl"');
      
      // Validate the URL before returning
      final uri = Uri.tryParse(finalUrl);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        print('❌ DynamicPageWidget._resolveImageUrl - Invalid URL generated: "$finalUrl"');
        return '';
      }
      
      return finalUrl;
    } catch (e) {
      print('❌ DynamicPageWidget._resolveImageUrl - Error resolving URL: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // When language is changing, show skeleton instead of mixed-language
        // dynamic content (e.g. "Happy New Year" header).
        final localizationService = AppLocalizationService();
        if (localizationService.isChangingLanguage) {
          return _SkeletonPage(scrollController: widget.scrollController);
        }

        // Skeletons while fetching components initially
        if (state is HomeLoaded && state.isFetchingComponents && state.fetchingComponentsForPageId == widget.pageId && !state.componentsByPageId.containsKey(widget.pageId)) {
          return const _SkeletonPage();
        }
        if (state is HomeLoading) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: const [
              LinearProgressIndicator(minHeight: 2),
            ],
          );
        }

        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.errorLoadingPage,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
          await HapticService.buttonClick();
          context.read<HomeBloc>().add(
                          LoadPageComponents(
                            componentId: widget.pageId,
                            page: 1,
                            pageSize: 10,
                          ),
                        );
        },
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          );
        }

        if (state is HomeLoaded) {
          // Not fetched yet for this page → show skeleton instead of empty
          final pcForThis = state.componentsByPageId[widget.pageId];
          debugPrint('🔍 DynamicPageWidget: pageId=${widget.pageId}, componentsByPageId keys: ${state.componentsByPageId.keys.toList()}, pcForThis: ${pcForThis != null ? 'found' : 'null'}');
          if (pcForThis == null) {
            debugPrint('🔍 DynamicPageWidget: Showing skeleton for page ${widget.pageId}');
            return _SkeletonPage(scrollController: widget.scrollController);
          }
          // Fetched but empty → show skeleton instead of admin empty-state text
          if (pcForThis.pageComponents.isEmpty) {
            // For end-users we prefer to show a skeleton while page
            // components are (re)loading, instead of "add components"
            // admin guidance.
            return _SkeletonPage(scrollController: widget.scrollController);
          }

          final pc = pcForThis;

          // Build page using existing demo widgets, feeding API data where possible
          final widgets = <Widget>[];
          
          // Sort components by sequence to ensure correct API order
          final sortedComponents = List<Component>.from(pc.pageComponents);
          sortedComponents.sort((Component a, Component b) => a.sequence.compareTo(b.sequence));
          
          for (final c in sortedComponents) {
            switch (c.type.toLowerCase()) {
              case 'banner':
                // Keep banner children in their natural order from API
                final sortedBannerChildren = c.children
                    .where((ch) => ch.valueType == 'banner_content')
                    .cast<ComponentChild>()
                    .toList();
                // Don't sort - maintain API order
                
                final banners = sortedBannerChildren
                    .map((ch) {
                      final b = ch.content['banner'] as Map<String, dynamic>?;
                      final id = (b?['id'] as int?) ?? ch.componentId;
                      final String? rawImagePath = _safeStringCast(b?['image']).isNotEmpty ? _safeStringCast(b?['image']) : null;
                      
                      print('🔍 Banner Image Debug:');
                      print('   Raw API data: b?["image"] = ${b?['image']}');
                      print('   After _safeStringCast: "$rawImagePath"');
                      
                      // Resolve the image URL properly
                      final String imageUrl = _resolveImageUrl(rawImagePath);
                      
                      print('   Final resolved URL: "$imageUrl"');
                      
                      return home_banner.Banner(
                        id: id.toString(),
                        title: _safeStringCastNonNull(b?['name']),
                        description: _safeStringCastNonNull(b?['description']),
                        imageUrl: imageUrl.isNotEmpty
                            ? imageUrl
                            : 'https://picsum.photos/seed/$id/800/400',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                    })
                    .toList();
                if (banners.isNotEmpty) {
                  widgets.add(Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: BannerCarouselWidget(banners: banners, height: 200),
                  ));
                }
                break;
              case 'product':
                widgets.add(DynamicComponentRenderer(component: c));
                break;
              case 'category':
                // Keep category children in their natural order from API
                final sortedCategoryChildren = c.children
                    .where((ch) => ch.valueType == 'category_content')
                    .cast<ComponentChild>()
                    .toList();
                // Don't sort - maintain API order
                
                final apiCats = sortedCategoryChildren
                    .map((ch) {
                      final m = ch.content['category'] as Map<String, dynamic>?;
                      // Extract category ID from category object (NOT attribute value)
                      final int id = (m?['id'] as int?) ?? ch.componentId;
                      final String name = _safeStringCast(m?['name']);
                      final String? img = _safeStringCast(m?['image']).isNotEmpty ? _safeStringCast(m?['image']) : null;
                      print('📁 Creating CategoryData: name=$name, categoryId=$id (from category.id)');
                      return CategoryData(
                        id: id.toString(), // Category ID - NOT attribute value
                        name: name,
                        imageUrl: (img != null && img.isNotEmpty)
                            ? img
                            : 'https://picsum.photos/seed/cat$id/300/300',
                        productCount: '',
                        color: Colors.blue.shade100,
                      );
                    })
                    .toList();
                widgets.add(FeaturedCategoriesSection(title: c.name, categories: apiCats));
                break;
              case 'brand':
                // Keep brand children in their natural order from API
                final sortedBrandChildren = c.children
                    .where((ch) => ch.valueType == 'brand_content')
                    .cast<ComponentChild>()
                    .toList();
                // Don't sort - maintain API order
                
                final brands = sortedBrandChildren
                    .map((ch) {
                      final m = ch.content['brand'] as Map<String, dynamic>?;
                      final int id = (m?['id'] as int?) ?? ch.componentId;
                      final String name = _safeStringCast(m?['name']);
                      final String? img = _safeStringCast(m?['image']).isNotEmpty ? _safeStringCast(m?['image']) : null;
                      return BrandData(
                        id: id.toString(),
                        name: name,
                        logoUrl: (img != null && img.isNotEmpty)
                            ? img
                            : 'https://picsum.photos/seed/brand$id/200/200',
                        productCount: '',
                        isPremium: true,
                      );
                    })
                    .toList();
                widgets.add(FeaturedBrandsSection(title: c.name, brands: brands));
                break;
              case 'offer':
                // Keep offer children in their natural order from API
                final sortedOfferChildren = c.children
                    .where((ch) => ch.valueType == 'offer_content')
                    .cast<ComponentChild>()
                    .toList();
                // Don't sort - maintain API order
                
                final offers = sortedOfferChildren
                    .map((ch) {
                      final m = ch.content['offer'] as Map<String, dynamic>?;
                      final int id = (m?['id'] as int?) ?? ch.componentId;
                      final String title = _safeStringCast(m?['name']);
                      final String desc = _safeStringCast(m?['description']);
                      final String? img = _safeStringCast(m?['image']).isNotEmpty ? _safeStringCast(m?['image']) : null;
                      final String discount = ((m?['tags'] as List?)?.isNotEmpty ?? false)
                          ? _safeStringCast(((m?['tags'] as List).first as Map)['name'])
                          : '';
                      
                      // Extract filter data from the offer content
                      final filters = m?['filters'] as Map<String, dynamic>?;
                      final offerFilters = OfferFilterData.fromMap(filters);
                      
                      // Resolve the image URL properly
                      final String imageUrl = _resolveImageUrl(img);
                      print('🖼️ Offer Image - Raw: "$img" → Resolved: "$imageUrl"');
                      print('🎯 Offer Filters - Name: $title, Filters: $filters');
                      
                      return SpecialOfferData(
                        id: id.toString(),
                        title: title,
                        description: desc,
                        imageUrl: imageUrl.isNotEmpty
                            ? imageUrl
                            : 'https://picsum.photos/seed/offer$id/400/200',
                        discount: discount,
                        timeLeft: '',
                        backgroundColor: Colors.orange.shade50,
                        textColor: Colors.orange.shade700,
                        filters: offerFilters,
                      );
                    })
                    .toList();
                widgets.add(SpecialOffersSection(title: c.name, offers: offers));
                break;
              case 'story':
                // Keep story children in their natural order from API
                final sortedStoryChildren = c.children
                    .where((ch) => ch.valueType == 'story_content')
                    .cast<ComponentChild>()
                    .toList();
                // Don't sort - maintain API order
                
                final stories = sortedStoryChildren
                    .map((ch) {
                      final m = ch.content['story'] as Map<String, dynamic>?;
                      final String heading = _safeStringCast(m?['heading']);
                      final String subHeading = _safeStringCast(m?['sub_heading']);
                      final String? img = _safeStringCast(m?['image']).isNotEmpty ? _safeStringCast(m?['image']) : null;
                      final String html = _safeStringCast(m?['content_html']).trim();
                      
                      // Resolve the image URL properly
                      final String imageUrl = _resolveImageUrl(img);
                      print('🖼️ Story Image - Raw: "$img" → Resolved: "$imageUrl"');
                      
                      return StoryData(
                        id: ch.componentId.toString(),
                        title: heading,
                        author: subHeading,
                        imageUrl: imageUrl.isNotEmpty
                            ? imageUrl
                            : 'https://picsum.photos/seed/story${ch.componentId}/400/300',
                        subHeading: subHeading,
                        htmlBody: html,
                      );
                    })
                    .toList();
                widgets.add(FashionStoriesSection(title: c.name, stories: stories));
                break;
              default:
                widgets.add(DynamicComponentRenderer(component: c));
            }
          }

          return AppPullToRefresh(
            onRefresh: () async {
              context.read<HomeBloc>().add(
                    LoadPageComponents(
                      componentId: widget.pageId,
                      page: 1,
                      pageSize: 10,
                    ),
                  );
            },
            child: ListView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 12),
                if (state.isFetchingComponents) const _ShimmerDivider(),
                ...widgets,
              ],
            ),
          );
        }

        return AppPullToRefresh(
          onRefresh: () async {
            context.read<HomeBloc>().add(
                  LoadPageComponents(
                    componentId: widget.pageId,
                    page: 1,
                    pageSize: 10,
                  ),
                );
          },
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: PageComponentsEmptyState(
                onRefresh: () {
                  context.read<HomeBloc>().add(
                        LoadPageComponents(
                          componentId: widget.pageId,
                          page: 1,
                          pageSize: 10,
                        ),
                      );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// --------------------- Shimmer Skeletons ---------------------

/// Public home skeleton widget that can be reused by other home
/// layout widgets (tabs, containers) without exposing the private
/// implementation details of the skeleton.
class HomeSkeleton extends StatelessWidget {
  final ScrollController? scrollController;
  const HomeSkeleton({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return _SkeletonPage(scrollController: scrollController);
  }
}

class _SkeletonPage extends StatelessWidget {
  final ScrollController? scrollController;
  
  const _SkeletonPage({this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        _SkeletonBanner(height: 200),
        SizedBox(height: 16),
        _SkeletonChipsRow(),
        SizedBox(height: 16),
        _SkeletonGrid(),
        SizedBox(height: 16),
        _SkeletonOfferList(),
      ],
    );
  }
}

class _ShimmerBase extends StatefulWidget {
  final Widget child;
  const _ShimmerBase({required this.child});

  @override
  State<_ShimmerBase> createState() => _ShimmerBaseState();
}

class _ShimmerBaseState extends State<_ShimmerBase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = isDark 
        ? colorScheme.outline.withValues(alpha: 0.3)
        : Colors.grey.shade300;
    final highlightColor = isDark
        ? colorScheme.outline.withValues(alpha: 0.5)
        : Colors.grey.shade100;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
            end: Alignment(1.0 + 2.0 * _controller.value, 0),
            colors: [
              baseColor,
              highlightColor,
              baseColor,
            ],
            stops: const [0.1, 0.3, 0.6],
          ).createShader(rect),
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SkeletonBanner extends StatelessWidget {
  final double height;
  const _SkeletonBanner({required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveConstants.mdPadding,
        vertical: ResponsiveConstants.smPadding,
      ),
      child: _ShimmerBase(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _SkeletonChipsRow extends StatelessWidget {
  const _SkeletonChipsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => const _ShimmerBase(
          child: CircleAvatar(radius: 36, backgroundColor: Colors.grey),
        ),
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => _ShimmerBase(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonOfferList extends StatelessWidget {
  const _SkeletonOfferList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.mdPadding),
      child: Column(
        children: List.generate(
          2,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ShimmerBase(
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerDivider extends StatelessWidget {
  const _ShimmerDivider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: _ShimmerBase(
        child: SizedBox(height: 2, width: double.infinity, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))),
      ),
    );
  }
}

class PageTabsWidget extends StatelessWidget {
  const PageTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded && state.pages.isNotEmpty) {
          return DefaultTabController(
            length: state.pages.length,
            child: Column(
              children: [
                TabBar(
                  onTap: (index) async {
                    await HapticService.selectionClick();
                  },
                  isScrollable: true,
                  tabs: state.pages.map((page) {
                    return Tab(
                      text: page.name,
                      icon: Icon(_getIconForPageType(page.name)),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: state.pages.map((page) {
                      return DynamicPageWidget(pageId: page.id);
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is HomeLoading) {
          // While the home page is (re)loading – for example after a
          // locale change – show the full-page skeleton instead of a
          // circular progress indicator so the UX stays consistent.
          return const HomeSkeleton();
        }

        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.errorLoadingPages,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
          await HapticService.buttonClick();
          context.read<HomeBloc>().add(const LoadPages(1));
        },
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Text(AppLocalizations.of(context)!.noPagesAvailable),
        );
      },
    );
  }

  IconData _getIconForPageType(String pageName) {
    switch (pageName.toLowerCase()) {
      case 'fashion':
        return Icons.shopping_bag;
      case 'trends':
        return Icons.trending_up;
      case 'new season':
        return Icons.fiber_new;
      case 'winter picks':
        return Icons.ac_unit;
      default:
        return Icons.pages;
    }
  }
}
