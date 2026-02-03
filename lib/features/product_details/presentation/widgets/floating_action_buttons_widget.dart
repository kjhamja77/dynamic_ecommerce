import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/product_details_bloc.dart';
import '../../domain/entities/product_details.dart';
import '../../../../core/services/haptic_service.dart';

class FloatingActionButtonsWidget extends StatelessWidget {
  final ProductDetails productDetails;

  const FloatingActionButtonsWidget({
    super.key,
    required this.productDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0.25.sh, // Position at 25% from top
      right: 16.w, // Use responsive width
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.notifications_none,
            color: Theme.of(context).colorScheme.onSurface,
            onTap: () async {
              await HapticService.buttonClick();
              // TODO: Implement notifications
            },
          ),
          SizedBox(height: 12.h),
          _buildFavoriteButton(context),
          SizedBox(height: 12.h),
          _buildActionButton(
            icon: Icons.shopping_bag_outlined,
            color: Theme.of(context).colorScheme.onSurface,
            onTap: () async {
              await HapticService.buttonClick();
              // TODO: Implement quick add to cart
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.4 : 0.1,
                  ),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.w,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () async {
        await HapticService.buttonClick();
        context.read<ProductDetailsBloc>().add(
          ToggleFavoriteEvent(productDetails.id),
        );
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.4 : 0.1,
              ),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Icon(
          productDetails.isFavorite
              ? Icons.favorite
              : Icons.favorite_border,
          color: productDetails.isFavorite
              ? Colors.orange
              : colorScheme.onSurface,
          size: 24.w,
        ),
      ),
    );
  }
}
