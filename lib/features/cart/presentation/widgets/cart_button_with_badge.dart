import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/theme/app_fonts.dart';
import '../bloc/cart_bloc.dart';
import '../pages/cart_page.dart';

/// A cart button widget with a badge showing the number of items in the cart.
/// Uses BLoC to listen to cart state changes and updates the badge accordingly.
class CartButtonWithBadge extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;
  final bool showBadge;

  const CartButtonWithBadge({
    super.key,
    this.iconColor,
    this.iconSize,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        int itemCount = 0;

        if (state is CartLoaded) {
          itemCount = state.totalItems;
        } else if (state is CartUpdating) {
          itemCount = state.cartItems.fold(
            0,
            (sum, item) => sum + item.quantity,
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: iconColor ?? colorScheme.onSurface,
                size: iconSize ?? ResponsiveConstants.mdIconSize,
              ),
              onPressed: () async {
                await HapticService.buttonClick();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CartPage(),
                  ),
                );
              },
            ),
            if (showBadge && itemCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.all(itemCount > 99 ? 2 : 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                  constraints: BoxConstraints(
                    minWidth: itemCount > 99 ? 18 : 20,
                    minHeight: itemCount > 99 ? 18 : 20,
                  ),
                  child: Center(
                    child: Text(
                      itemCount > 99 ? '99+' : itemCount.toString(),
                      style: AppFonts.getTextStyle(
                        fontSize: itemCount > 99 ? 8 : 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}







