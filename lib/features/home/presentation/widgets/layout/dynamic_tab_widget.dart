import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zalando_clone_app/features/home/presentation/constants/home_constants.dart';
import 'package:zalando_clone_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:zalando_clone_app/features/home/domain/entities/page.dart' as home_page;
import '../dynamic_page_widget.dart';
import '../welcome_section_widget.dart';
import '../../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class DynamicTabWidget extends StatefulWidget {
  final TabController innerTabController;
  final String outerTab;
  final ScrollController? scrollController;
  final int userId;

  /// Called when [HomeBloc] has more pages than [innerTabController.length]
  /// so the parent can recreate the controller (never truncate tabs).
  final VoidCallback? onTabCountMismatch;

  const DynamicTabWidget({
    super.key,
    required this.innerTabController,
    required this.outerTab,
    required this.userId,
    this.scrollController,
    this.onTabCountMismatch,
  });

  @override
  State<DynamicTabWidget> createState() => _DynamicTabWidgetState();
}

class _DynamicTabWidgetState extends State<DynamicTabWidget> {
  @override
  void initState() {
    super.initState();
    // Don't load pages here - they're already loaded by DynamicHomeTabWidget
    // This prevents duplicate API calls
  }

  void _loadPages() {
    context.read<HomeBloc>().add(LoadPages(widget.userId, forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Welcome Section - now driven by API texts
        const WelcomeSectionWidget(),
        
        // Dynamic Inner TabBar based on API data
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              if (state.pages.isNotEmpty) {
                final sortedPages = List<home_page.Page>.from(state.pages)
                  ..sort((a, b) => ((a.order ?? a.id).compareTo(b.order ?? b.id)));
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDynamicTabBar(sortedPages),
                    if (state.isFetchingPages)
                      const _ShimmerLine(height: 2),
                  ],
                );
              } else {
                // While fetching first pages, show shimmer line to avoid empty flash
                if (state.isFetchingPages) {
                  return const _ShimmerLine(height: 2);
                }
                // No pages and not fetching → truly empty
                return const SizedBox.shrink();
              }
            } else if (state is HomeError) {
              return _buildErrorTabBar(state.message);
            } else {
              // During loading/initial states, don't render stale tabs from cache.
              // Show only a loading line until HomeLoaded arrives.
              if (state is HomeLoading || state is HomeInitial) {
                return const SizedBox(
                  height: 2,
                  child: _ShimmerLine(height: 2),
                );
              }
              return const SizedBox.shrink();
            }
          },
        ),
        
        // Dynamic TabBarView content
        Expanded(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoaded) {
                if (state.pages.isNotEmpty) {
                  final sortedPages = List<home_page.Page>.from(state.pages)
                    ..sort((a, b) => ((a.order ?? a.id).compareTo(b.order ?? b.id)));
                  return _buildDynamicTabView(sortedPages);
                } else {
                  // When there are no pages (e.g. immediately after a locale
                  // change or during initial load), always show the shared
                  // home skeleton instead of the CMS/admin "Add pages" empty
                  // state. This prevents the brief flash shown in the screenshot.
                  return const HomeSkeleton();
                }
              } else if (state is HomeError) {
                return _buildErrorContent(state.message);
              } else {
                // During loading/initial states, avoid rendering stale page views
                // tied to previous tab definitions.
                if (state is HomeLoading || state is HomeInitial) {
                  return const HomeSkeleton();
                }
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }


  Widget _buildDynamicTabBar(List<home_page.Page> pages) {
    // Normalize to match the controller length exactly to avoid assertion errors
    final basePages = pages.isEmpty ? [_createFallbackPage()] : pages;
    final int targetLen = widget.innerTabController.length;
    List<home_page.Page> effectivePages;
    if (basePages.length == targetLen) {
      effectivePages = basePages;
    } else if (basePages.length > targetLen) {
      // Never truncate extra API tabs: the inner TabController is stale short.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          widget.onTabCountMismatch?.call();
        }
      });
      return const SizedBox(
        height: 48,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _ShimmerLine(height: 2),
        ),
      );
    } else {
      // Pad with fallback pages to reach the controller length
      effectivePages = List<home_page.Page>.from(basePages);
      while (effectivePages.length < targetLen) {
        effectivePages.add(_createFallbackPage());
      }
    }
    
    return Container(
      color: HomeConstants.backgroundColor,
      child: TabBar(
        controller: widget.innerTabController,
        onTap: (index) async {
          await HapticService.selectionClick();
        },
        isScrollable: true,
        indicatorColor: HomeConstants.primaryColor,
        indicatorWeight: HomeConstants.indicatorWeight,
        labelColor: HomeConstants.primaryColor,
        labelStyle: AppFonts.getTextStyle(fontSize: HomeConstants.innerTabFontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelColor: Colors.grey.shade600,
        unselectedLabelStyle: AppFonts.getTextStyle(fontSize: HomeConstants.innerTabFontSize,
          fontWeight: FontWeight.w400,
        ),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
        // Use only `text` to avoid Flutter assertion: 'text == null || child == null'
        tabs: effectivePages.map((page) => Tab(text: page.name)).toList(),
      ),
    );
  }

  Widget _buildErrorTabBar(String errorMessage) {
    return Container(
      color: HomeConstants.backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load pages: $errorMessage',
              style: AppFonts.getTextStyle(fontSize: HomeConstants.innerTabFontSize,
                color: Colors.red.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await HapticService.buttonClick();
              _loadPages();
            },
            child: Text(
              'Retry',
              style: AppFonts.getTextStyle(fontSize: HomeConstants.innerTabFontSize,
                color: HomeConstants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildDynamicTabView(List<home_page.Page> pages) {
    // Normalize to match the controller length exactly to avoid assertion errors
    final basePages = pages.isEmpty ? [_createFallbackPage()] : pages;
    final int targetLen = widget.innerTabController.length;
    List<home_page.Page> effectivePages;
    if (basePages.length == targetLen) {
      effectivePages = basePages;
    } else if (basePages.length > targetLen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          widget.onTabCountMismatch?.call();
        }
      });
      return const HomeSkeleton();
    } else {
      // Pad with fallback pages to reach the controller length
      effectivePages = List<home_page.Page>.from(basePages);
      while (effectivePages.length < targetLen) {
        effectivePages.add(_createFallbackPage());
      }
    }
    
    final int currentIndex = widget.innerTabController.index.clamp(
      0,
      targetLen > 0 ? targetLen - 1 : 0,
    );

    return TabBarView(
      controller: widget.innerTabController,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(effectivePages.length, (index) {
        final page = effectivePages[index];
        final ScrollController? controllerForPage =
            (index == currentIndex) ? widget.scrollController : null;
        return DynamicPageWidget(
          pageId: page.id,
          scrollController: controllerForPage,
        );
      }),
    );
  }

  Widget _buildErrorContent(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade600),
          const SizedBox(height: 16),
          Text(
            'Failed to load content',
            style: AppFonts.getTextStyle(fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: AppFonts.getTextStyle(fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await HapticService.buttonClick();
              _loadPages();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Retry',
              style: AppFonts.getTextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Add pages to show them here',
            style: AppFonts.getTextStyle(fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'No pages are currently available.\nAdd some pages to get started.',
            style: AppFonts.getTextStyle(fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Create a fallback page when no pages are available
  home_page.Page _createFallbackPage() {
    return home_page.Page(
      id: -1, // Use negative ID to indicate fallback
      name: 'Home',
      order: 0,
      description: 'Welcome to our store',
      isActive: true,
    );
  }
}

class _ShimmerLine extends StatefulWidget {
  final double height;
  const _ShimmerLine({required this.height});

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
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
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
                end: Alignment(1.0 + 2.0 * _controller.value, 0),
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                ],
                stops: const [0.1, 0.3, 0.6],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(color: Colors.grey.shade300),
          );
        },
      ),
    );
  }
}