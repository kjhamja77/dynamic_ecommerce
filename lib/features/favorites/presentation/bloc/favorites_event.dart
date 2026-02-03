import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_product.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class AddToFavorites extends FavoritesEvent {
  final FavoriteProduct product;

  const AddToFavorites(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromFavorites extends FavoritesEvent {
  final String productId;

  const RemoveFromFavorites(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CheckFavoriteStatus extends FavoritesEvent {
  final String productId;

  const CheckFavoriteStatus(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final FavoriteProduct product;
  final bool isFavorite;

  const ToggleFavorite(this.product, this.isFavorite);

  @override
  List<Object?> get props => [product, isFavorite];
}
