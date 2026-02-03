// Onboarding Feature - Clean Architecture Implementation
// This file exports all the public APIs for the onboarding feature

// Domain Layer
export 'domain/entities/onboarding_page.dart' hide OnboardingPage;
export 'domain/repositories/onboarding_repository.dart';
export 'domain/usecases/check_onboarding_status.dart';
export 'domain/usecases/complete_onboarding.dart';

// Data Layer
export 'data/models/onboarding_page_model.dart';
export 'data/repositories/onboarding_repository_impl.dart';
export 'data/datasources/onboarding_local_data_source.dart';

// Presentation Layer
export 'presentation/bloc/onboarding_bloc.dart';
export 'presentation/bloc/onboarding_event.dart';
export 'presentation/bloc/onboarding_state.dart';
export 'presentation/pages/onboarding_page.dart';
export 'presentation/widgets/onboarding_content.dart';
export 'presentation/widgets/page_indicator.dart';
export 'presentation/widgets/onboarding_button.dart';
export 'presentation/widgets/onboarding_shimmer.dart';
export 'presentation/widgets/onboarding_empty_state.dart';
