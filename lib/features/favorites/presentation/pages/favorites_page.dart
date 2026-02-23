import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../widgets/favorite_product_card.dart';
import '../widgets/favorites_shimmer.dart';
import '../widgets/empty_favorites_widget.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/app_pull_to_refresh.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/navigation/navigation_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/bloc/biometric_bloc.dart';

class FavoritesPage extends StatefulWidget {
  final Function(int)? onTabChanged;
  
  const FavoritesPage({super.key, this.onTabChanged});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final Map<String, bool> _removingItems = {};
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkIfGuest();
    // Only load if we don't have data already
    final currentState = context.read<FavoritesBloc>().state;
    if (currentState is! FavoritesLoaded) {
      context.read<FavoritesBloc>().add(LoadFavorites());
    }
  }

  Future<void> _checkIfGuest() async {
    try {
      final storage = di.sl<FlutterSecureStorage>();
      final cached = await storage.read(key: AppConstants.userKey);
      final isGuest = (cached ?? '').toLowerCase().contains('guest: true');
      if (mounted) {
        setState(() {
          _isGuest = isGuest;
        });
      }
    } catch (_) {}
  }

  void _markItemAsRemoving(String productId) {
    setState(() {
      _removingItems[productId] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.favorites,
          style: AppFonts.getTextStyle(
            fontSize: ResponsiveConstants.lgFontSize,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
        ),
        backgroundColor: colorScheme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        centerTitle: true,
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              if (state is FavoritesLoaded && state.favorites.isNotEmpty) {
                return IconButton(
                  onPressed: _showClearConfirmation,
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    color: colorScheme.error,
                    size: ResponsiveConstants.mdIconSize,
                  ),
                  tooltip: AppLocalizations.of(context)!.clearFavorites,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _isGuest ? _buildGuestLockedView() : BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const FavoritesShimmer();
          } else if (state is FavoritesLoaded) {
            if (state.favorites.isEmpty) {
              return EmptyFavoritesWidget(onTabChanged: widget.onTabChanged);
            }
            return AppPullToRefresh(
              onRefresh: () async {
                context.read<FavoritesBloc>().add(LoadFavorites());
                await Future.delayed(const Duration(milliseconds: 300));
              },
              child: _buildFavoritesList(state),
            );
          } else if (state is FavoritesError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGuestLockedView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.4 : 0.1,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 44,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: ResponsiveConstants.mdSpacing),
                Text(
                  AppLocalizations.of(context)!.guestFavorites,
                  style: AppFonts.getTextStyle(
                    fontSize: ResponsiveConstants.lgFontSize,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.xsSpacing),
                Text(
                  AppLocalizations.of(context)!.signInToUnlockFeatures,
                  style: AppFonts.getTextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveConstants.lgSpacing),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushAuth(
                        BlocProvider(
                          create: (context) => di.sl<BiometricBloc>(),
                          child: const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.signIn,
                      style: AppFonts.getTextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesLoaded state) {
    return CustomScrollView(
      slivers: [
        // Header with count wrapped in SliverToBoxAdapter
        SliverToBoxAdapter(
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(ResponsiveConstants.mdPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) {
                      final colorScheme = Theme.of(context).colorScheme;
                      
                      return Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 24,
                          ),
                          SizedBox(width: ResponsiveConstants.smSpacing),
                          Text(
                            '${state.favorites.length} ${state.favorites.length == 1 ? AppLocalizations.of(context)!.item : AppLocalizations.of(context)!.items}',
                            style: AppFonts.getTextStyle(
                              fontSize: ResponsiveConstants.mdFontSize,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),

        // Favorites list
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveConstants.mdPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = state.favorites[index];
                final isRemoving = _removingItems[product.id] ?? false;
                
                return AnimatedSlide(
                  offset: isRemoving ? const Offset(1.0, 0.0) : Offset.zero,
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: isRemoving ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 1200),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveConstants.mdSpacing),
                      child: FavoriteProductCard(
                        product: product, 
                        isFavorite: true,
                        onAddToCart: () => _markItemAsRemoving(product.id),
                        onTabChanged: widget.onTabChanged,
                      ),
                    ),
                  ),
                );
              },
              childCount: state.favorites.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return AppErrorView(
      message: message,
      onRetry: () => context.read<FavoritesBloc>().add(LoadFavorites()),
    );
  }

  void _showClearConfirmation() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)!.clearAllFavorites,
          style: AppFonts.getTextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.clearAllFavoritesDescription,
          style: AppFonts.getTextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: AppFonts.getTextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<FavoritesBloc>().add(ClearFavorites());
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.clearAll),
          ),
        ],
      ),
    );
  }
}
