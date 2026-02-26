import 'package:flutter/material.dart';
import '../../features/splash/splash.dart';
import '../../core/app/auth_wrapper.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/catalog/domain/models/catalog_args.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/onboarding/onboarding.dart';
import '../../features/settings/settings.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/terms_page.dart';
import '../../features/terms_conditions/presentation/bloc/terms_conditions_bloc.dart';
import '../../features/cart/cart.dart';
import '../../features/language_selection/presentation/pages/language_selection_page.dart';
import '../../features/auth/presentation/pages/number_verification_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/bloc/biometric_bloc.dart';
import '../../features/product_details/presentation/pages/product_details_page.dart';
import '../../features/product_details/presentation/bloc/product_details_bloc.dart';
import '../../features/product_details/domain/entities/product_details_card_preview.dart';
import '../navigation/page_transitions.dart';
import '../di/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/home/presentation/pages/story_detail_page.dart';
import '../../features/offline/presentation/pages/offline_page.dart';
import '../../features/compare/presentation/pages/compare_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Splash page - fade transition for smooth app start
        return PageTransitions.fadeTransition(
          page: const SplashPage(),
          settings: settings,
          duration: const Duration(milliseconds: 800),
        );
      case '/language-selection':
        // Language selection - slide from bottom for modal-like feel
        return PageTransitions.slideFromBottom(
          page: const LanguageSelectionPage(),
          settings: settings,
        );
      case '/sign-in':
        // Sign in page - use app-level AuthBloc so login state is visible after navigating to /main
        return PageTransitions.slideFromRight(
          page: BlocProvider(
            create: (context) => di.sl<BiometricBloc>(),
            child: const LoginPage(),
          ),
          settings: settings,
        );
      case '/main':
        // Main app entry - slide from right for forward navigation
        return PageTransitions.slideFromRight(
          page: const AuthWrapper(),
          settings: settings,
        );
      case '/catalog':
        // Catalog page - slide and fade for smooth product browsing
        final args = settings.arguments as CatalogArgs;
        return PageTransitions.slideAndFade(
          page: CatalogPage(args: args),
          settings: settings,
          slideOffset: const Offset(1.0, 0.0),
        );
      case '/favorites':
        // Favorites page - slide from right for consistent navigation
        return PageTransitions.slideFromRight(
          page: const FavoritesPage(),
          settings: settings,
        );
      case '/onboarding':
        // Onboarding - slide from bottom for welcome experience
        return PageTransitions.slideFromBottom(
          page: const OnboardingPage(),
          settings: settings,
          duration: const Duration(milliseconds: 500),
        );
      case '/settings':
        // Settings page - slide from right for consistent navigation
        return PageTransitions.slideFromRight(
          page: const SettingsPage(),
          settings: settings,
        );
      case '/privacy':
        return PageTransitions.slideFromRight(
          page: const PrivacyPolicyPage(),
          settings: settings,
        );
      case '/terms':
        return PageTransitions.slideFromRight(
          page: BlocProvider(
            create: (context) => di.sl<TermsConditionsBloc>(),
            child: const TermsPage(),
          ),
          settings: settings,
        );
      case '/cart':
        // Cart page - slide from bottom for shopping cart feel
        return PageTransitions.slideFromBottom(
          page: const CartPage(),
          settings: settings,
        );
      case '/verify-mobile':
        // Mobile verification - slide from right with slight scale for importance
        final args = settings.arguments as NumberVerificationArgs;
        return PageTransitions.slideAndFade(
          page: NumberVerificationPage(args: args),
          settings: settings,
          slideOffset: const Offset(1.0, 0.0),
        );
      case '/product-details':
        // Product details - MaterialPageRoute for native Hero animation support
        final args = settings.arguments as Map<String, dynamic>;
        final cardPreview = ProductDetailsCardPreview.fromMap(
          args['cardPreview'] as Map<String, dynamic>?,
        );
        print('🚀 AppRouter: Creating ProductDetailsPage');
        print('  - Product ID: ${args['productId']}');
        print('  - Product Type: ${args['productType']}');
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<ProductDetailsBloc>(),
            child: ProductDetailsPage(
              productId: args['productId'] as String,
              productType: args['productType'] as String? ?? 'variant',
              openAddToCart: args['openAddToCart'] as bool? ?? false,
              cardPreview: cardPreview,
            ),
          ),
          settings: settings,
        );
      case '/story':
        final args = settings.arguments as Map<String, dynamic>;
        final String title = args['title'] as String? ?? '';
        final String? imageUrl = args['imageUrl'] as String?;
        final String htmlBody = args['htmlBody'] as String? ?? '';
        return PageTransitions.slideFromRight(
          page: StoryDetailPage(title: title, imageUrl: imageUrl, htmlBody: htmlBody),
          settings: settings,
        );
      
      case '/offline':
        // Offline page - no transition, immediate replacement
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OfflinePage(
            fromPage: args?['fromPage'],
            pageData: args?['pageData'],
          ),
          settings: settings,
        );
      case '/compare':
        return PageTransitions.slideFromRight(
          page: const ComparePage(),
          settings: settings,
        );
      default:
        // Default fallback - fade transition
        return PageTransitions.fadeTransition(
          page: const SplashPage(),
          settings: settings,
        );
    }
  }
}

// AuthWrapper is defined in core/app/auth_wrapper.dart
