import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashInitialized extends SplashState {
  final bool shouldShowOnboarding;
  final bool shouldShowLanguageSelection;

  const SplashInitialized({
    required this.shouldShowOnboarding,
    this.shouldShowLanguageSelection = false,
  });

  @override
  List<Object?> get props => [shouldShowOnboarding, shouldShowLanguageSelection];
}

class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}
