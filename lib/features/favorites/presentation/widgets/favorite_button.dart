import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/biometric_bloc.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../../domain/entities/favorite_product.dart';
import '../../../../../core/services/haptic_service.dart';

class FavoriteButton extends StatefulWidget {
  final String productId;
  final String productName;
  final String brand;
  final double price;
  final String? imageUrl;
  final String? category;
  final bool isFavorite;
  final double size;
  final Color? color;
  final bool isCompact;

  const FavoriteButton({
    super.key,
    required this.productId,
    required this.productName,
    required this.brand,
    required this.price,
    this.imageUrl,
    this.category,
    this.isFavorite = false,
    this.size = 24.0,
    this.color,
    this.isCompact = true,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isGuest = false;
  // Removed unused tap flag

  @override
  void initState() {
    super.initState();
    _checkGuest();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _checkGuest() async {
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocListener<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state is FavoritesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          final currentIsFavorite = state is FavoritesLoaded 
              ? state.favoriteStatuses[widget.productId] ?? widget.isFavorite
              : widget.isFavorite;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _isGuest
                  ?showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    insetPadding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: EdgeInsets.all(ResponsiveConstants.lgPadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            // Icon Circle
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

                            // Title
                            Text(
                              AppLocalizations.of(context)!.guestUser,
                              style: AppFonts.getTextStyle(
                                fontSize: ResponsiveConstants.lgFontSize,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: ResponsiveConstants.xsSpacing),

                            // Subtitle
                            Text(
                              AppLocalizations.of(context)!.signInToUnlockFeatures,
                              style: AppFonts.getTextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: ResponsiveConstants.lgSpacing),

                            // Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // close dialog first
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
                  );
                },
              )
                :_toggleFavorite(context, currentIsFavorite),
              borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 20),
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(currentIsFavorite ? 1.1 : 1.0),
                      padding: widget.isCompact ? EdgeInsets.all(6) : EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: widget.isCompact ? 6 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: currentIsFavorite 
                              ? (widget.color ?? Colors.red) 
                              : Colors.grey.shade300,
                          width: widget.isCompact ? 0.5 : 1,
                        ),
                      ),
                      child: Icon(
                        currentIsFavorite ? Icons.favorite : Icons.favorite_border,
                        color: currentIsFavorite 
                            ? (widget.color ?? Colors.red) 
                            : Colors.grey.shade600,
                        size: widget.isCompact ? widget.size * 0.7 : widget.size * 0.8,
                      ),
                    ),
                  );
                },
              ).animate(
                target: currentIsFavorite ? 1 : 0,
              ).scale(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
              ),
            ),
          );
        },
      ),
    );
  }

  void _toggleFavorite(BuildContext context, bool currentIsFavorite) async {
    // Trigger tap animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Add haptic feedback
    await HapticService.selectionClick();

    final product = FavoriteProduct(
      id: widget.productId,
      name: widget.productName,
      brand: widget.brand,
      price: widget.price,
      imageUrl: widget.imageUrl,
      category: widget.category,
      addedAt: DateTime.now(),
    );

    context.read<FavoritesBloc>().add(
      ToggleFavorite(product, currentIsFavorite),
    );
  }
}
