import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/theme/app_fonts.dart';

class SplashContent extends StatefulWidget {
  const SplashContent({super.key});

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _controller.forward();
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

    final primaryColor = colorScheme.primary;
    final primaryColorLight = Color.alphaBlend(
      primaryColor.withValues(alpha: 0.12),
      isDark ? colorScheme.surface : Colors.white,
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.background,
                  primaryColorLight,
                  colorScheme.background,
                ]
              : [
                  Colors.white,
                  primaryColorLight,
                  Colors.white,
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with animations
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surface : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.5)
                                : primaryColor.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.shopping_bag_outlined,
                            size: 80,
                            color: primaryColor,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  delay: 1500.ms,
                  duration: 1500.ms,
                  color: primaryColor.withValues(alpha: 0.3),
                )
                .then()
                .shake(hz: 2, curve: Curves.easeInOut),

            SizedBox(height: ResponsiveConstants.xlSpacing),

            // App Name with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Kardosi',
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.xxlFontSize,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0, duration: 800.ms),

            SizedBox(height: ResponsiveConstants.smSpacing),

            // Tagline with fade animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Fashion. Style. You.',
                style: AppFonts.getTextStyle(
                  fontSize: ResponsiveConstants.mdFontSize,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? colorScheme.onSurface.withValues(alpha: 0.7)
                      : Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0, duration: 800.ms),

            SizedBox(height: ResponsiveConstants.xxlSpacing * 2),

            // Loading indicator
            FadeTransition(
              opacity: _fadeAnimation,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    backgroundColor: isDark
                        ? colorScheme.onSurface.withValues(alpha: 0.1)
                        : primaryColor.withValues(alpha: 0.1),
                  ),
                ),
            )
                .animate()
                .fadeIn(delay: 1400.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
