import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_product.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteProduct> favorites;
  final Map<String, bool> favoriteStatuses;

  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteStatuses,
  });

  @override
  List<Object?> get props => [favorites, favoriteStatuses];

  FavoritesLoaded copyWith({
    List<FavoriteProduct>? favorites,
    Map<String, bool>? favoriteStatuses,
  }) {
    return FavoritesLoaded(
      favorites: favorites ?? this.favorites,
      favoriteStatuses: favoriteStatuses ?? this.favoriteStatuses,
    );
  }
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

class FavoriteStatusUpdated extends FavoritesState {
  final String productId;
  final bool isFavorite;

  const FavoriteStatusUpdated(this.productId, this.isFavorite);

  @override
  List<Object?> get props => [productId, isFavorite];
}
