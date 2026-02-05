import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// removed unused GoogleFonts import
import 'dart:developer' as developer;
// removed unused HomeBloc import
import '../constants/home_constants.dart';

import '../widgets/layout/dynamic_home_tab_widget.dart';
import '../widgets/layout/home_content_widget.dart';
import '../widgets/favorites_content_widget.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../search/presentation/bloc/search_bloc.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../../core/services/haptic_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _outerTabController;
  late final Widget _searchTab;
  late final Widget _profileTab;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 400;
      if (shouldShow != _showScrollToTop) {
        setState(() {
          _showScrollToTop = shouldShow;
        });
      }
      
    });
    _outerTabController = TabController(
      length: HomeConstants.outerTabs.length,
      vsync: this,
      animationDuration: HomeConstants.tabAnimationDuration,
    );

    // Build Search tab once to preserve its state and bloc instance
    _searchTab = BlocProvider(
      create: (context) => sl<SearchBloc>(),
      child: const SearchPage(),
    );

    // Build Profile tab once to preserve its state and bloc instance
    _profileTab = BlocProvider(
      create: (context) => sl<ProfileBloc>(),
      child: const ProfilePage(),
    );

    // Inner tabs are handled dynamically within DynamicHomeTabWidget now

    // Load pages, cart data, and favorites data sequentially to avoid overwhelming server
    // Featured products are loaded through dynamic components in DynamicHomeTabWidget
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Pages are loaded by DynamicHomeTabWidget to avoid duplicate fetches
      // Wait a bit before loading cart to avoid simultaneous requests
      await Future.delayed(const Duration(milliseconds: 200));
      context.read<CartBloc>().add(const LoadCart());
      
      // Wait a bit before loading favorites to avoid simultaneous requests
      await Future.delayed(const Duration(milliseconds: 200));
      context.read<FavoritesBloc>().add(LoadFavorites());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _outerTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      // Simple timed popup ad when entering Home
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      backgroundColor: colorScheme.background,
      elevation: HomeConstants.elevation,
      toolbarHeight: 0,
      leadingWidth: 48,
      centerTitle: false,
      bottom: TabBar(
        controller: _outerTabController,
        onTap: (index) async {
          await HapticService.selectionClick();
        },
        isScrollable: true,
        indicatorColor: HomeConstants.primaryColor,
        indicatorWeight: HomeConstants.indicatorWeight,
        labelColor: HomeConstants.primaryColor,
        labelStyle: AppFonts.getTextStyle(
          fontSize: HomeConstants.tabFontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
        unselectedLabelStyle: AppFonts.getTextStyle(
          fontSize: HomeConstants.tabFontSize,
          fontWeight: FontWeight.w400,
        ),
        splashFactory: NoSplash.splashFactory,
        splashBorderRadius: BorderRadius.zero,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: HomeConstants.outerTabIcons.asMap().entries.map((entry) {
          int index = entry.key;
          IconData icon = entry.value;

          // Special handling for favorites tab with badge
          if (index == 2) {
            // Favorites tab - show 0 for guest users (they cannot access favorites)
            return Tab(
              icon: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (prev, curr) => curr is Authenticated || prev is Authenticated,
                builder: (context, authState) {
                  final isGuest = authState is Authenticated && authState.user.isGuest;
                  return BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, state) {
                      int itemCount = 0;
                      if (!isGuest && state is FavoritesLoaded) {
                        itemCount = state.favorites.length;
                      }

                      return Stack(
                        children: [
                          _buildTabIcon(icon, index),
                          if (itemCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  itemCount > 99 ? '99+' : '$itemCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          }

          // Special handling for cart tab with badge
          if (index == 3) {
            // Cart tab
            return Tab(
              icon: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int itemCount = 0;
                  if (state is CartLoaded) {
                    itemCount = state.uniqueItemsCount;
                  }

                  // Debug logging for cart state changes
                  developer.log(
                    '🏠 Cart tab badge - State: ${state.runtimeType}, Items: $itemCount',
                  );
                  developer.log(
                    '🏠 Home CartBloc instance: ${context.read<CartBloc>().hashCode}',
                  );

                  return Stack(
                    children: [
                      _buildTabIcon(icon, index),
                      if (itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              itemCount > 99 ? '99+' : '$itemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          }

          return Tab(icon: _buildTabIcon(icon, index));
        }).toList(),
      ),
    );
  }

  Widget _buildTabIcon(IconData icon, int index) {
    return AnimatedBuilder(
      animation: _outerTabController,
      builder: (context, child) {
        final isActive = _outerTabController.index == index;

        // Return outlined icon for active tab, filled icon for inactive
        if (isActive) {
          return Icon(_getOutlinedIcon(icon), size: HomeConstants.iconSize);
        } else {
          return Icon(icon, size: HomeConstants.iconSize);
        }
      },
    );
  }

  IconData _getOutlinedIcon(IconData filledIcon) {
    // Map filled icons to their outlined equivalents
    switch (filledIcon) {
      case Icons.home:
        return Icons.home_outlined;
      case Icons.search:
        return Icons.search_outlined;
      case Icons.favorite:
        return Icons.favorite_border;
      case Icons.shopping_cart:
        return Icons.shopping_cart_outlined;
      case Icons.person:
        return Icons.person_outlined;
      default:
        return filledIcon;
    }
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () async {
          await HapticService.buttonClick();
          FocusScope.of(context).unfocus();
        },
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _outerTabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: HomeConstants.outerTabs.asMap().entries.map((entry) {
                      int index = entry.key;
                      String outerTab = entry.value;
                      return _buildOuterTabContent(index, outerTab);
                    }).toList(),
                  ),
                ),
              ],
            ),
            // Use SafeArea and ignore pointer when hidden to avoid stealing TabBar gestures
            Positioned(
              right: 16,
              bottom: 16,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 8, right: 8),
                child: IgnorePointer(
                  ignoring: !_showScrollToTop,
                  child: AnimatedScale(
                    scale: _showScrollToTop ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showScrollToTop ? 1 : 0,
                      child: FloatingActionButton(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          await HapticService.buttonClick();
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                            );
                          }
                        },
                        child: const Icon(Icons.arrow_upward),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // removed unused _refreshHome method

  Widget _buildOuterTabContent(int index, String outerTab) {
    // Only Home screen (Logo tab) shows inner TabBar
    if (index == 0) {
      return DynamicHomeTabWidget(
        outerTabController: _outerTabController,
        outerTabIndex: index,
        scrollController: _scrollController,
      );
    }

    // Other outer tabs show their content directly without inner TabBar
    switch (index) {
      case 1: // Search
        return _searchTab;
      case 2: // Favorites
        return FavoritesContentWidget(
          onTabChanged: (index) {
            _outerTabController.animateTo(index);
          },
        );
      case 3: // Cart
        return CartPage(
          onTabChanged: (index) {
            _outerTabController.animateTo(index);
          },
        );
      case 4: // Profile
        return _profileTab;
      default:
        return const HomeContentWidget();
    }
  }
}
