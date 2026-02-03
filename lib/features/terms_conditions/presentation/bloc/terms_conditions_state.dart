import '../../domain/entities/terms_conditions.dart';

abstract class TermsConditionsState {}

class TermsConditionsInitial extends TermsConditionsState {}

class TermsConditionsLoading extends TermsConditionsState {}

class TermsConditionsLoaded extends TermsConditionsState {
  final TermsConditionsResponse termsConditions;

  TermsConditionsLoaded({required this.termsConditions});
}

class TermsConditionsError extends TermsConditionsState {
  final String message;

  TermsConditionsError({required this.message});
}
