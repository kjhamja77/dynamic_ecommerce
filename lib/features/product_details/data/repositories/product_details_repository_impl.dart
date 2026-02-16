import 'package:dartz/dartz.dart';
import 'dart:developer' as developer;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/repositories/product_details_repository.dart';
import '../models/product_details_model.dart';
import '../datasources/product_details_remote_data_source.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
import '../../../home/domain/entities/product.dart';

class ProductDetailsRepositoryImpl implements ProductDetailsRepository {
  final CartRepository cartRepository;
  final ProductDetailsRemoteDataSource? remoteDataSource;
  
  ProductDetailsRepositoryImpl({
    required this.cartRepository,
    this.remoteDataSource,
  });
  
  // Repository now uses API-only data, no demo/dummy data

  @override
  Future<Either<Failure, ProductDetails>> getProductDetails(String productId, {String productType = 'variant'}) async {
    try {
      // Always try to fetch from API first
      if (remoteDataSource != null) {
        developer.log('🌐 Fetching product details from API for: $productId, type: $productType');
        final productData = await remoteDataSource!.getProductDetails(productId, productType: productType);
        
        // Convert API response to ProductDetails model
        final productDetails = ProductDetailsModel.fromApiJson(productData);
        
        return Right(productDetails);
      }
      
      // If no remote data source, return error
      developer.log('❌ No remote data source available for product: $productId');
      return Left(ServerFailure('No data source available'));
    } catch (e) {
      developer.log('💥 Error getting product details: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String productId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> selectColor(String productId, String colorId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> selectSize(String productId, String sizeId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 200));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartItem>> addToCart(String productId, String colorId, String sizeId, int quantity) async {
    developer.log('🛒 [ADD_TO_CART_FLOW] Step 4 - Product Details Repository addToCart');
    developer.log('   Received: productId=$productId, colorId=$colorId, sizeId=$sizeId, quantity=$quantity');
    
    try {
      // Get the product details from API to create cart item
      developer.log('🔍 Fetching product details from API for cart: $productId');
      
      if (remoteDataSource == null) {
        developer.log('❌ No remote data source available');
        return Left(ServerFailure('No data source available'));
      }
      
      ProductDetails? productDetails;
      try {
        final productData = await remoteDataSource!.getProductDetails(productId);
        productDetails = ProductDetailsModel.fromApiJson(productData);
        developer.log('✅ Product fetched from API: ${productDetails.name}');
      } catch (e) {
        developer.log('❌ Failed to fetch product from API: $e');
        return Left(ServerFailure('Product not found'));
      }
      
      developer.log('✅ Product found: ${productDetails.name}');
      
      // Create a Product entity from ProductDetails for the cart
      developer.log('🏗️ Creating Product entity...');
      final product = Product(
        id: productId, // Use the actual product ID for API calls
        name: productDetails.name,
        description: productDetails.description,
        price: productDetails.price,
        originalPrice: productDetails.originalPrice,
        images: productDetails.images,
        category: 'Fashion', // Default category
        brand: productDetails.brand,
        type: 'variant', // Default type for product details
        rating: productDetails.rating.toDouble(),
        reviewCount: productDetails.reviewCount,
        isAvailable: true,
        sizes: productDetails.sizeOptions.map((s) => s.name).toList(),
        colors: productDetails.colorOptions.map((c) => c.name).toList(),
        createdAt: DateTime.now(),
      );
      developer.log('✅ Product entity created: ${product.name}');
      
      // Get the actual color and size names from the IDs or names
      String colorName;
      String sizeName;
      
      try {
        // Try to find by ID first
        colorName = productDetails.colorOptions.firstWhere((c) => c.id == colorId).name;
      } catch (e) {
        // If not found by ID, try to find by name
        try {
          colorName = productDetails.colorOptions.firstWhere((c) => c.name == colorId).name;
        } catch (e) {
          // If still not found, use the colorId as is (assuming it's already a name)
          colorName = colorId;
        }
      }
      
      try {
        // Try to find by ID first
        sizeName = productDetails.sizeOptions.firstWhere((s) => s.id == sizeId).name;
      } catch (e) {
        // If not found by ID, try to find by name
        try {
          sizeName = productDetails.sizeOptions.firstWhere((s) => s.name == sizeId).name;
        } catch (e) {
          // If still not found, use the sizeId as is (assuming it's already a name)
          sizeName = sizeId;
        }
      }
      
      // Create cart item with deterministic ID for merging
      developer.log('🛒 Creating CartItem...');
      final cartItemId = '${productId}_${colorId}_$sizeId'; // Deterministic ID for same variant
      developer.log('🔑 Generated cart item ID: $cartItemId');
      
      final cartItem = CartItem(
        id: cartItemId,
        product: product,
        quantity: quantity,
        selectedColor: colorName,
        selectedSize: sizeName,
        price: productDetails.price,
        addedAt: DateTime.now(),
      );
      developer.log('🛒 [ADD_TO_CART_FLOW] CartItem created: id=${cartItem.id}, quantity=${cartItem.quantity}');
      
      // Use the real cart API to add the item
      developer.log('🚀 Calling real cart API to add item...');
      final result = await cartRepository.addToCart(cartItem);
      
      return result.fold(
        (failure) {
          developer.log('❌ Cart API failed: ${failure.message}');
          return Left(failure);
        },
        (addedCartItem) {
          developer.log('✅ Cart API success: ${addedCartItem.product.name}');
          return Right(addedCartItem);
        },
      );
    } catch (e) {
      developer.log('💥 Exception occurred: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}