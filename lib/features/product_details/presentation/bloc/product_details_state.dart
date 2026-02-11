part of 'product_details_bloc.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsLoaded extends ProductDetailsState {
  final ProductDetails productDetails;
  final int quantity;
  final bool isAdding;
  /// True while we are recomputing variant/attribute availability
  /// (e.g. after a color/attribute selection) so the UI can show a loader.
  final bool isVariantFilterLoading;

  const ProductDetailsLoaded(
    this.productDetails, {
    this.quantity = 1,
    this.isAdding = false,
    this.isVariantFilterLoading = false,
  });

  ProductDetailsLoaded copyWith({
    ProductDetails? productDetails,
    int? quantity,
    bool? isAdding,
    bool? isVariantFilterLoading,
  }) {
    return ProductDetailsLoaded(
      productDetails ?? this.productDetails,
      quantity: quantity ?? this.quantity,
      isAdding: isAdding ?? this.isAdding,
      isVariantFilterLoading:
          isVariantFilterLoading ?? this.isVariantFilterLoading,
    );
  }

  @override
  List<Object?> get props =>
      [productDetails, quantity, isAdding, isVariantFilterLoading];
}

class ProductDetailsError extends ProductDetailsState {
  final String message;

  const ProductDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductDetailsAddedToCart extends ProductDetailsState {}

class ProductDetailsQuantityClamped extends ProductDetailsState {
  final String message;
  final int quantityAdded;

  const ProductDetailsQuantityClamped(this.message, this.quantityAdded);

  @override
  List<Object?> get props => [message, quantityAdded];
}
