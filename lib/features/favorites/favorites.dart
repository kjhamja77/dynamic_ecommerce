// Favorites Feature - Clean Architecture Implementation
// This file exports all the public APIs for the favorites feature

// Domain Layer
export 'domain/entities/favorite_product.dart';
export 'domain/repositories/favorites_repository.dart';
export 'domain/usecases/get_favorites_usecase.dart';
export 'domain/usecases/add_to_favorites_usecase.dart';
export 'domain/usecases/remove_from_favorites_usecase.dart';
export 'domain/usecases/check_favorite_status_usecase.dart';
export 'domain/usecases/clear_favorites_usecase.dart';

// Data Layer
export 'data/models/favorite_product_model.dart';
export 'data/repositories/favorites_repository_impl.dart';
export 'data/datasources/favorites_local_data_source.dart';
export 'data/datasources/favorites_remote_data_source.dart';

// Presentation Layer
export 'presentation/bloc/favorites_bloc.dart';
export 'presentation/bloc/favorites_event.dart';
export 'presentation/bloc/favorites_state.dart';
export 'presentation/pages/favorites_page.dart';
export 'presentation/widgets/favorite_product_card.dart';
export 'presentation/widgets/empty_favorites_widget.dart';
export 'presentation/widgets/favorite_button.dart';
