import '../models/product_model.dart';
import '../models/product_list_response_model.dart';
import '../models/product_category_model.dart';

abstract class ProductRemoteDataSource {
  // Get single product by ID (template or variant)
  Future<ProductModel> getProductById({
    required int productId,
    required String type, // 'template' or 'variant'
    int? templateId, // Required for variant type
  });

  // Get product list with pagination
  Future<ProductListResponseModel> getProductList({
    int limit = 20,
    int offset = 0,
  });

  // Get products by category
  Future<ProductListResponseModel> getProductsByCategory({
    required List<int> categoryIds,
    int limit = 20,
    int offset = 0,
  });

  // Search products
  Future<ProductListResponseModel> searchProducts({
    required String query,
    int limit = 20,
    int offset = 0,
  });

  // Get root categories
  Future<List<ProductCategoryModel>> getRootCategories({
    int maxDepth = 1,
  });

  // Get categories by parent ID
  Future<List<ProductCategoryModel>> getCategoriesByParentId({
    required int parentId,
    int maxDepth = 1,
  });

  // Get all categories with pagination
  Future<List<ProductCategoryModel>> getAllCategories({
    int maxDepth = 1,
    int limit = 20,
    int offset = 0,
  });
}


