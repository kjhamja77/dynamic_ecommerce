# Navigation Animations System

This system provides professional, user-friendly page transition animations throughout the Zalando clone app. All animations are designed to be smooth, consistent, and enhance the user experience.

## Features

- **Multiple Animation Types**: Slide, fade, scale, zoom, and combined animations
- **Context-Aware**: Different animations for different page types (product details, cart, auth, etc.)
- **Easy to Use**: Simple extension methods and helper classes
- **Consistent**: All animations follow the same timing and easing curves
- **Professional**: Smooth, modern animations that feel native

## Animation Types

### Basic Animations

1. **Slide from Right** - Most common for forward navigation
2. **Slide from Bottom** - For modals and bottom sheets
3. **Slide from Left** - For back navigation
4. **Fade** - For subtle transitions
5. **Scale** - For important pages
6. **Slide and Fade** - Combined for smooth transitions
7. **Zoom** - For product details
8. **Hero** - For special pages

### Page-Specific Animations

- **Product Details**: Zoom animation for immersive experience
- **Cart**: Slide from bottom for shopping cart feel
- **Checkout**: Slide and fade for smooth flow
- **Profile/Settings**: Slide from right for consistent navigation
- **Favorites**: Slide from right for consistent navigation
- **Search**: Slide from right for consistent navigation
- **Catalog**: Slide and fade for smooth browsing
- **Auth Pages**: Slide from right for consistent navigation
- **Modals**: Slide from bottom for modal-like feel
- **Payment**: Slide and fade for secure feeling
- **Address**: Slide from right for consistent navigation
- **Orders**: Slide from right for consistent navigation

## Usage Examples

### 1. Using Extension Methods (Recommended)

```dart
import 'package:zalando_clone_app/core/navigation/navigation_service.dart';

// Navigate to product details with zoom animation
context.pushProductDetails(ProductDetailsPage(product: product));

// Navigate to cart with slide from bottom
context.pushCart(CartPage());

// Navigate to checkout with slide and fade
context.pushCheckout(CheckoutPage());

// Navigate to profile with slide from right
context.pushProfile(ProfilePage());

// Navigate to favorites with slide from right
context.pushFavorites(FavoritesPage());

// Navigate to search with slide from right
context.pushSearch(SearchPage());

// Navigate to catalog with slide and fade
context.pushCatalog(CatalogPage());

// Navigate to auth pages with slide from right
context.pushAuth(LoginPage());

// Navigate to modal with slide from bottom
context.pushModal(FilterModal());

// Navigate to payment with slide and fade
context.pushPayment(PaymentPage());

// Navigate to address with slide from right
context.pushAddress(AddressPage());

// Navigate to orders with slide from right
context.pushOrders(OrdersPage());
```

### 2. Using NavigationService

```dart
import 'package:zalando_clone_app/core/navigation/navigation_service.dart';

// Direct navigation service calls
NavigationService.pushSlideFromRight(SomePage());
NavigationService.pushSlideFromBottom(SomeModal());
NavigationService.pushFade(SomePage());
NavigationService.pushScale(SomeImportantPage());
NavigationService.pushSlideAndFade(SomePage());
NavigationService.pushZoom(ProductDetailsPage());
```

### 3. Using PageNavigationAnimations

```dart
import 'package:zalando_clone_app/core/navigation/navigation_service.dart';

// Page-specific navigation
PageNavigationAnimations.toProductDetails(ProductDetailsPage());
PageNavigationAnimations.toCart(CartPage());
PageNavigationAnimations.toCheckout(CheckoutPage());
PageNavigationAnimations.toProfile(ProfilePage());
PageNavigationAnimations.toFavorites(FavoritesPage());
PageNavigationAnimations.toSearch(SearchPage());
PageNavigationAnimations.toCatalog(CatalogPage());
PageNavigationAnimations.toAuth(LoginPage());
PageNavigationAnimations.toModal(FilterModal());
PageNavigationAnimations.toPayment(PaymentPage());
PageNavigationAnimations.toAddress(AddressPage());
PageNavigationAnimations.toOrders(OrdersPage());
```

### 4. Using AnimatedNavigationButton

```dart
import 'package:zalando_clone_app/core/navigation/navigation_helper_widget.dart';

// Wrap any widget with navigation
Container(
  child: Text('Go to Product'),
).withNavigation(
  destination: ProductDetailsPage(product: product),
  animationType: NavigationAnimationType.productDetails,
);

// Or use the button directly
AnimatedNavigationButton(
  destination: CartPage(),
  animationType: NavigationAnimationType.cart,
  child: Icon(Icons.shopping_cart),
);
```

## Animation Timing

All animations use consistent timing from `AppConstants`:

- **Short Animation**: 200ms (for quick transitions)
- **Medium Animation**: 300ms (most common, default)
- **Long Animation**: 500ms (for special pages like onboarding)

## Easing Curves

- **Slide animations**: `Curves.easeInOutCubic` for smooth motion
- **Fade animations**: `Curves.easeInOut` for natural fade
- **Scale animations**: `Curves.easeOutBack` for bouncy feel
- **Zoom animations**: `Curves.easeOutCubic` for smooth zoom

## Best Practices

1. **Use appropriate animations for page types**:
   - Product details → Zoom
   - Cart → Slide from bottom
   - Settings → Slide from right
   - Modals → Slide from bottom

2. **Keep animations consistent**:
   - Same animation type for similar page types
   - Consistent timing across the app

3. **Don't over-animate**:
   - Use subtle animations for frequent navigation
   - Reserve special animations for important pages

4. **Test on different devices**:
   - Ensure animations are smooth on all devices
   - Consider performance on older devices

## Migration Guide

### Before (Old Navigation)
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailsPage(product: product),
  ),
);
```

### After (New Animated Navigation)
```dart
context.pushProductDetails(ProductDetailsPage(product: product));
```

## Implementation Details

The navigation system is built on top of Flutter's `PageRouteBuilder` and provides:

1. **PageTransitions**: Core animation classes
2. **NavigationService**: Global navigation service
3. **PageNavigationAnimations**: Page-specific navigation methods
4. **NavigationExtension**: Context extension methods
5. **AnimatedNavigationButton**: Widget wrapper for easy navigation

All animations are optimized for performance and provide a professional, modern feel to the app.




