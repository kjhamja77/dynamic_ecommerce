import '../entities/search_category.dart';
import '../entities/search_tab.dart';
import '../entities/search_subcategory.dart';
import '../entities/subcategory_details.dart';
import '../../data/models/search_params_model.dart';
import '../../data/models/search_results_model.dart';

abstract class SearchRepository {
  /// Get all search categories
  Future<List<SearchCategory>> getSearchCategories();
  
  /// Get search tabs (Women, Men, Kids)
  Future<List<SearchTab>> getSearchTabs();
  
  /// Get subcategories for a specific category
  Future<List<SearchSubcategory>> getSubcategories(String categoryId);
  
  /// Get nested subcategories for a specific subcategory (for multi-level support)
  Future<List<SearchSubcategory>> getNestedSubcategories(String subcategoryId);
  
  /// Get detailed subcategory with nested items
  Future<SubcategoryDetails> getSubcategoryDetails(String subcategoryId);
  
  /// Update selected search tab
  Future<void> updateSelectedTab(String tabId);
  
  /// Search for products/categories based on query
  Future<List<SearchCategory>> searchCategories(String query);
  
  /// Search for products with advanced filters
  Future<SearchResults> searchProducts(SearchParams params);
}
