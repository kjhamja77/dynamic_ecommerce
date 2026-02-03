import 'package:equatable/equatable.dart';
import '../../domain/entities/onboarding_page.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingPage> pages;
  final int currentPageIndex;
  final bool isLastPage;

  const OnboardingLoaded({
    required this.pages,
    required this.currentPageIndex,
  }) : isLastPage = currentPageIndex == pages.length - 1;

  OnboardingLoaded copyWith({
    List<OnboardingPage>? pages,
    int? currentPageIndex,
  }) {
    return OnboardingLoaded(
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }

  @override
  List<Object?> get props => [pages, currentPageIndex, isLastPage];
}

class OnboardingCompleted extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
