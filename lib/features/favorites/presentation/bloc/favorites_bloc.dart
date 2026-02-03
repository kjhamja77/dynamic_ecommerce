import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favorite_product.dart';
import '../../domain/usecases/add_to_favorites_usecase.dart';
import '../../domain/usecases/remove_from_favorites_usecase.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/check_favorite_status_usecase.dart';
import '../../domain/usecases/clear_favorites_usecase.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavorites;
  final AddToFavoritesUseCase addToFavorites;
  final RemoveFromFavoritesUseCase removeFromFavorites;
  final CheckFavoriteStatusUseCase checkFavoriteStatus;
  final ClearFavoritesUseCase clearFavorites;

  FavoritesBloc({
    required this.getFavorites,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.checkFavoriteStatus,
    required this.clearFavorites,
  }) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
    on<ClearFavorites>(_onClearFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    // Only show loading if we don't have cached data
    if (state is! FavoritesLoaded) {
      emit(FavoritesLoading());
    }
    
    final result = await getFavorites();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (favorites) {
        final statuses = <String, bool>{};
        for (final favorite in favorites) {
          statuses[favorite.id] = true;
        }
        emit(FavoritesLoaded(favorites: favorites, favoriteStatuses: statuses));
      },
    );
  }

  Future<void> _onAddToFavorites(AddToFavorites event, Emitter<FavoritesState> emit) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      // Optimistic update - add item immediately to UI
      final updatedFavorites = List<FavoriteProduct>.from(currentState.favorites);
      final newFavorite = FavoriteProduct(
        id: event.product.id,
        name: event.product.name,
        brand: event.product.brand,
        price: event.product.price,
        imageUrl: event.product.imageUrl,
        category: event.product.category,
        addedAt: event.product.addedAt,
      );
      updatedFavorites.add(newFavorite);
      
      final updatedStatuses = Map<String, bool>.from(currentState.favoriteStatuses);
      updatedStatuses[event.product.id] = true;
      
      emit(FavoritesLoaded(favorites: updatedFavorites, favoriteStatuses: updatedStatuses));
      
      // Background sync
      final result = await addToFavorites(event.product);
      result.fold(
        (failure) {
          // Revert optimistic update on failure
          emit(FavoritesLoaded(favorites: currentState.favorites, favoriteStatuses: currentState.favoriteStatuses));
          emit(FavoritesError(failure.message));
        },
        (_) {
          // Success - keep the optimistic state
        },
      );
    } else {
      // Fallback to loading if not in loaded state
      final result = await addToFavorites(event.product);
      result.fold(
        (failure) => emit(FavoritesError(failure.message)),
        (_) => add(LoadFavorites()),
      );
    }
  }

  Future<void> _onRemoveFromFavorites(RemoveFromFavorites event, Emitter<FavoritesState> emit) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      // Optimistic update - remove item immediately from UI
      final updatedFavorites = List<FavoriteProduct>.from(currentState.favorites);
      updatedFavorites.removeWhere((item) => item.id == event.productId);
      
      final updatedStatuses = Map<String, bool>.from(currentState.favoriteStatuses);
      updatedStatuses[event.productId] = false;
      
      emit(FavoritesLoaded(favorites: updatedFavorites, favoriteStatuses: updatedStatuses));
      
      // Background sync
      final result = await removeFromFavorites(event.productId);
      result.fold(
        (failure) {
          // Revert optimistic update on failure
          emit(FavoritesLoaded(favorites: currentState.favorites, favoriteStatuses: currentState.favoriteStatuses));
          emit(FavoritesError(failure.message));
        },
        (_) {
          // Success - keep the optimistic state
        },
      );
    } else {
      // Fallback to loading if not in loaded state
      final result = await removeFromFavorites(event.productId);
      result.fold(
        (failure) => emit(FavoritesError(failure.message)),
        (_) => add(LoadFavorites()),
      );
    }
  }

  Future<void> _onCheckFavoriteStatus(CheckFavoriteStatus event, Emitter<FavoritesState> emit) async {
    final result = await checkFavoriteStatus(event.productId);
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (isFavorite) => emit(FavoriteStatusUpdated(event.productId, isFavorite)),
    );
  }

  Future<void> _onClearFavorites(ClearFavorites event, Emitter<FavoritesState> emit) async {
    final result = await clearFavorites();
    result.fold(
      (failure) => emit(FavoritesError(failure.message)),
      (_) => emit(const FavoritesLoaded(favorites: [], favoriteStatuses: {})),
    );
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) async {
    if (event.isFavorite) {
      add(RemoveFromFavorites(event.product.id));
    } else {
      add(AddToFavorites(event.product));
    }
  }
}
