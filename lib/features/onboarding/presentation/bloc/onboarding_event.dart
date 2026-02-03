import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOnboardingPages extends OnboardingEvent {}

class NextPage extends OnboardingEvent {}

class PreviousPage extends OnboardingEvent {}

class CompleteOnboardingEvent extends OnboardingEvent {}

class SkipOnboarding extends OnboardingEvent {}

class SetPageIndex extends OnboardingEvent {
  final int index;
  const SetPageIndex(this.index);

  @override
  List<Object?> get props => [index];
}
