import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../entities/page.dart';
import '../entities/component.dart';
import '../../../product/domain/entities/product_category.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<Product>>> getFeaturedProducts();
  Future<Either<Failure, List<Product>>> getProductsByCategory(String category);
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, List<ProductCategory>>> getRootCategories();
  Future<Either<Failure, List<Product>>> searchProducts(String query);
  Future<Either<Failure, List<Product>>> getProductsByBrand(String brand);
  Future<Either<Failure, List<Page>>> getPages(
    int userId, {
    bool forceRefresh = false,
  });
  Future<Either<Failure, PageComponents>> getPageComponents(
    int componentId,
    int page,
    int pageSize, {
    bool forceRefresh = false,
  });
  Future<Either<Failure, List<String>>> getWelcomeTexts({
    bool forceRefresh = false,
  });
}
