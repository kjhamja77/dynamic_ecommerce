import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection_container.dart' as di;
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/welcome_bloc.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/splash/splash.dart';
import '../../features/onboarding/onboarding.dart';
import '../../features/settings/settings.dart';
import '../../features/cart/cart.dart';
import '../../features/addresses/addresses.dart';

List<BlocProvider> createAppBlocProviders() {
  return [
    BlocProvider<AuthBloc>(
      create: (_) => di.sl<AuthBloc>(),
    ),
    BlocProvider<HomeBloc>(
      create: (_) => di.sl<HomeBloc>(),
    ),
    BlocProvider<WelcomeBloc>(
      create: (_) => di.sl<WelcomeBloc>(),
    ),
    BlocProvider<FavoritesBloc>(
      create: (_) => di.sl<FavoritesBloc>(),
    ),
    BlocProvider<ProfileBloc>(
      create: (_) => di.sl<ProfileBloc>(),
    ),
    BlocProvider<SplashBloc>(
      create: (_) => di.sl<SplashBloc>(),
    ),
    BlocProvider<OnboardingBloc>(
      create: (_) => di.sl<OnboardingBloc>(),
    ),
    BlocProvider<SettingsBloc>(
      create: (_) => di.sl<SettingsBloc>(),
    ),
    BlocProvider<CartBloc>(
      create: (_) => di.sl<CartBloc>(),
    ),
    BlocProvider<AddressBloc>(
      create: (_) => di.sl<AddressBloc>(),
    ),
  ];
}


