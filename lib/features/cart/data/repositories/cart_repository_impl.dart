import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_item_model.dart';
import '../../../home/data/models/product_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  final CartRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CartData>> getCartItems() async {
    if (await networkInfo.isConnected) {
      try {
        final cartResponse = await remoteDataSource.getCartItems();
        debugPrint('CartRepositoryImpl.getCartItems: API response lines: ${cartResponse.lines.length}');
        for (final line in cartResponse.lines) {
          debugPrint('🛒 [CART_FLOW] getCartItems - Line: product_id=${line.productId}, quantity=${line.quantity}, product_name=${line.productName}');
        }
        // Convert cart lines to cart items for local storage
        final cartItems = <CartItemModel>[];
        final localCartItems = await localDataSource.getCart();

        for (final line in cartResponse.lines) {
          final cartItemModel = line.toCartItemModel();
          // Try to get product details from local storage to preserve additional info
          try {
            final existingItem = localCartItems.firstWhere(
              (item) => item.product.id == cartItemModel.product.id,
              orElse: () => cartItemModel,
            );
            // Preserve additional product details from local storage, but use API images
            final updatedProduct = ProductModel(
              id: cartItemModel.product.id,
              name: cartItemModel.product.name,
              description: existingItem.product.description.isNotEmpty 
                  ? existingItem.product.description 
                  : cartItemModel.product.description,
              price: cartItemModel.product.price,
              originalPrice: existingItem.product.originalPrice,
              images: cartItemModel.product.images, // Use API images
              category: existingItem.product.category.isNotEmpty 
                  ? existingItem.product.category 
                  : cartItemModel.product.category,
              brand: existingItem.product.brand.isNotEmpty 
                  ? existingItem.product.brand 
                  : cartItemModel.product.brand,
              type: existingItem.product.type,
              rating: existingItem.product.rating,
              reviewCount: existingItem.product.reviewCount,
              isAvailable: existingItem.product.isAvailable,
              sizes: existingItem.product.sizes.isNotEmpty 
                  ? existingItem.product.sizes 
                  : cartItemModel.product.sizes,
              colors: existingItem.product.colors.isNotEmpty 
                  ? existingItem.product.colors 
                  : cartItemModel.product.colors,
              createdAt: existingItem.product.createdAt,
            );
            cartItems.add(cartItemModel.copyWith(product: updatedProduct));
          } catch (e) {
            debugPrint('CartRepositoryImpl.getCartItems: No existing item found for ${cartItemModel.product.id}, using API data');
            cartItems.add(cartItemModel);
          }
        }
        await localDataSource.saveCart(cartItems);
        return Right(CartData(items: cartItems, response: cartResponse));
      } catch (e) {
        debugPrint('CartRepositoryImpl.getCartItems: API error: $e');
        try {
          final localItems = await localDataSource.getCart();
          return Right(CartData(items: localItems, response: null));
        } catch (localError) {
          return Left(CacheFailure('Failed to get cart items'));
        }
      }
    } else {
      try {
        final localItems = await localDataSource.getCart();
        return Right(CartData(items: localItems, response: null));
      } catch (e) {
        return Left(CacheFailure('Failed to get cart items'));
      }
    }
  }

  @override
  Future<Either<Failure, CartItem>> addToCart(CartItem cartItem) async {
    debugPrint('🛒 [ADD_TO_CART_FLOW] Step 5 - Cart Repository addToCart');
    debugPrint('   cartItem.product.id=${cartItem.product.id}, cartItem.quantity=${cartItem.quantity}');
    
    if (await networkInfo.isConnected) {
      try {
        final productId = int.tryParse(cartItem.product.id) ?? 0;
        debugPrint('   Calling remoteDataSource.addToCart(productId=$productId, quantity=${cartItem.quantity})');
        
        final cartResponse = await remoteDataSource.addToCart(
          productId,
          cartItem.quantity,
        );
        
        debugPrint('CartRepositoryImpl.addToCart: API response received');
        debugPrint('CartRepositoryImpl.addToCart: Response lines count: ${cartResponse.lines.length}');
        
        // Find the added item in the response and return it
        final addedLine = cartResponse.lines.firstWhere(
          (line) => line.productId == productId,
          orElse: () => cartResponse.lines.isNotEmpty ? cartResponse.lines.first : throw Exception('No cart lines in response'),
        );
        
        final addedCartItem = addedLine.toCartItemModel();
        debugPrint('🛒 [ADD_TO_CART_FLOW] Step 7 - API response received');
        debugPrint('   API returned quantity in response: ${addedLine.quantity}');
        debugPrint('   CartItem quantity (displayed in cart): ${addedCartItem.quantity}');
        
        // The API returns the total quantity in cart (cumulative), not just what was added
        // This is correct behavior - if there were already items in cart, quantity will be higher
        debugPrint('CartRepositoryImpl.addToCart: API returned total quantity ${addedCartItem.quantity} for product ${productId}');
        
        // Use the API's total quantity as it represents the current cart state
        final localCartItems = await localDataSource.getCart();
        final existingIndex = localCartItems.indexWhere(
          (item) => item.product.id == addedCartItem.product.id,
        );
        
        if (existingIndex != -1) {
          // Update existing item
          localCartItems[existingIndex] = CartItemModel.fromEntity(addedCartItem);
        } else {
          // Add new item
          localCartItems.add(CartItemModel.fromEntity(addedCartItem));
        }
        
        await localDataSource.saveCart(localCartItems);
        return Right(addedCartItem);
        
      } catch (e) {
        debugPrint('CartRepositoryImpl.addToCart: API error: $e');
        // Extract clean API message for stock errors (e.g. "Some products are out of stock")
        final errStr = e.toString();
        final isStockError = errStr.toLowerCase().contains('stock') ||
            errStr.toLowerCase().contains('available') ||
            errStr.toLowerCase().contains('quantity');
        final message = isStockError && errStr.contains('Exception:')
            ? errStr.replaceFirst(RegExp(r'^.*Exception:\s*'), '').trim()
            : 'Failed to add item to cart: $e';
        return Left(ServerFailure(message));
      }
    } else {
      try {
        // If offline, add to local storage only
        debugPrint('CartRepositoryImpl.addToCart: Offline mode, adding to local storage');
        final cartItems = await localDataSource.getCart();
        final existingIndex = cartItems.indexWhere(
          (item) => item.product.id == cartItem.product.id,
        );
        
        if (existingIndex != -1) {
          // Update existing item quantity
          final existingItem = cartItems[existingIndex];
          final updatedItem = existingItem.copyWith(
            quantity: existingItem.quantity + cartItem.quantity,
          );
          cartItems[existingIndex] = updatedItem;
          await localDataSource.saveCart(cartItems);
          return Right(updatedItem);
        } else {
          // Add new item
          final cartItemModel = CartItemModel.fromEntity(cartItem);
          cartItems.add(cartItemModel);
          await localDataSource.saveCart(cartItems);
          return Right(cartItem);
        }
      } catch (e) {
        debugPrint('CartRepositoryImpl.addToCart: Local storage error: $e');
        return Left(CacheFailure('Failed to add item to cart locally'));
      }
    }
  }

  @override
  Future<Either<Failure, CartItem>> updateCartItemQuantity(String cartItemId, int quantity) async {
    if (await networkInfo.isConnected) {
      try {
        final productId = int.tryParse(cartItemId) ?? 0;
        final cartResponse = await remoteDataSource.updateCartItemQuantity(productId, quantity);
        
        // Find the updated item in the response
        final updatedLine = cartResponse.lines.firstWhere(
          (line) => line.productId == productId,
          orElse: () => cartResponse.lines.first,
        );
        
        final updatedItem = updatedLine.toCartItemModel();
        
        // Update local storage
        final localCartItems = await localDataSource.getCart();
        final existingIndex = localCartItems.indexWhere(
          (item) => item.product.id == updatedItem.product.id,
        );
        
        if (existingIndex != -1) {
          localCartItems[existingIndex] = CartItemModel.fromEntity(updatedItem);
          await localDataSource.saveCart(localCartItems);
        }
        
        return Right(updatedItem);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final cartItems = await localDataSource.getCart();
        final itemIndex = cartItems.indexWhere((item) => item.product.id == cartItemId);
        
        if (itemIndex == -1) {
          return Left(CacheFailure('Cart item not found'));
        }

        if (quantity <= 0) {
          cartItems.removeAt(itemIndex);
          await localDataSource.saveCart(cartItems);
          return Right(cartItems[itemIndex]);
        }

        final updatedItem = cartItems[itemIndex].copyWith(quantity: quantity);
        cartItems[itemIndex] = updatedItem;
        await localDataSource.saveCart(cartItems);
        
        return Right(updatedItem);
      } catch (e) {
        return Left(CacheFailure('Failed to update cart item quantity'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String cartItemId) async {
    if (await networkInfo.isConnected) {
      try {
        final productId = int.tryParse(cartItemId) ?? 0;
        await remoteDataSource.removeFromCart(productId);
        
        // Update local storage
        final localCartItems = await localDataSource.getCart();
        localCartItems.removeWhere((item) => item.product.id == cartItemId);
        await localDataSource.saveCart(localCartItems);
        
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final cartItems = await localDataSource.getCart();
        cartItems.removeWhere((item) => item.product.id == cartItemId);
        await localDataSource.saveCart(cartItems);
        return const Right(null);
      } catch (e) {
        return Left(CacheFailure('Failed to remove item from cart'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCartByQuantity(String cartItemId, int quantity) async {
    if (await networkInfo.isConnected) {
      try {
        final productId = int.tryParse(cartItemId) ?? 0;
        await remoteDataSource.removeFromCartByQuantity(productId, quantity);
        
        // Update local storage
        final localCartItems = await localDataSource.getCart();
        final existingIndex = localCartItems.indexWhere(
          (item) => item.product.id == cartItemId,
        );
        
        if (existingIndex != -1) {
          final existingItem = localCartItems[existingIndex];
          final newQuantity = existingItem.quantity - quantity;
          
          if (newQuantity <= 0) {
            localCartItems.removeAt(existingIndex);
          } else {
            localCartItems[existingIndex] = existingItem.copyWith(quantity: newQuantity);
          }
          
          await localDataSource.saveCart(localCartItems);
        }
        
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final cartItems = await localDataSource.getCart();
        final itemIndex = cartItems.indexWhere((item) => item.product.id == cartItemId);
        
        if (itemIndex == -1) {
          return Left(CacheFailure('Cart item not found'));
        }

        final existingItem = cartItems[itemIndex];
        final newQuantity = existingItem.quantity - quantity;
        
        if (newQuantity <= 0) {
          cartItems.removeAt(itemIndex);
        } else {
          cartItems[itemIndex] = existingItem.copyWith(quantity: newQuantity);
        }
        
        await localDataSource.saveCart(cartItems);
        return const Right(null);
      } catch (e) {
        return Left(CacheFailure('Failed to remove item from cart by quantity'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.clearCart();
        await localDataSource.clearCart();
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        await localDataSource.clearCart();
        return const Right(null);
      } catch (e) {
        return Left(CacheFailure('Failed to clear cart'));
      }
    }
  }
}