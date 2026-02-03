import 'package:flutter/foundation.dart';
import '../../features/filters/data/datasources/filter_remote_data_source.dart';

class BrandMappingService {
  static final BrandMappingService _instance = BrandMappingService._internal();
  factory BrandMappingService() => _instance;
  BrandMappingService._internal();

  Map<String, int>? _brandNameToIdMap;
  Map<int, String>? _brandIdToNameMap;
  FilterRemoteDataSource? _dataSource;

  void initialize(FilterRemoteDataSource dataSource) {
    _dataSource = dataSource;
  }

  /// Get brand ID from brand name
  Future<int?> getBrandId(String brandName) async {
    await _ensureMappingLoaded();
    final id = _brandNameToIdMap?[brandName];
    debugPrint('🏷️ BrandMappingService: Brand "$brandName" → ID: $id');
    return id;
  }

  /// Get brand name from brand ID
  Future<String?> getBrandName(int brandId) async {
    await _ensureMappingLoaded();
    return _brandIdToNameMap?[brandId];
  }

  /// Get all available brand names
  Future<List<String>> getAllBrandNames() async {
    await _ensureMappingLoaded();
    return _brandNameToIdMap?.keys.toList() ?? [];
  }

  /// Load brand mapping from API if not already loaded
  Future<void> _ensureMappingLoaded() async {
    if (_brandNameToIdMap != null || _dataSource == null) return;

    try {
      debugPrint('🔄 BrandMappingService: Loading brand mapping from API...');
      
      // Fetch all brands from API (increase limit to get all brands)
      final brands = await _dataSource!.getBrands(page: 1, limit: 100);
      
      debugPrint('✅ BrandMappingService: Loaded ${brands.length} brands from API');
      
      // Create bidirectional mapping
      _brandNameToIdMap = {};
      _brandIdToNameMap = {};
      
      for (final brand in brands) {
        _brandNameToIdMap![brand.name] = brand.id;
        _brandIdToNameMap![brand.id] = brand.name;
        debugPrint('   Brand: "${brand.name}" → ID: ${brand.id}');
      }
      
      debugPrint('🎯 BrandMappingService: Mapping created with ${_brandNameToIdMap!.length} brands');
    } catch (e) {
      debugPrint('❌ BrandMappingService: Failed to load brand mapping: $e');
      
      // Fallback to static mapping if API fails
      debugPrint('🔄 BrandMappingService: Using fallback static mapping...');
      _brandNameToIdMap = {
        'Nike': 1,
        'Adidas': 2,
        'Levis': 3,
        'Herman Miller': 11,
        'IKEA': 12,
        'West Elm': 13,
        'CB2': 14,
        'Pottery Barn': 15,
        'Crate & Barrel': 16,
      };
      
      _brandIdToNameMap = {};
      for (final entry in _brandNameToIdMap!.entries) {
        _brandIdToNameMap![entry.value] = entry.key;
      }
    }
  }

  /// Update mapping with fresh brand data
  void updateMapping(Map<String, int> brandMapping) {
    debugPrint('🔄 BrandMappingService: Updating mapping with ${brandMapping.length} brands');
    _brandNameToIdMap = Map.from(brandMapping);
    _brandIdToNameMap = {};
    for (final entry in brandMapping.entries) {
      _brandIdToNameMap![entry.value] = entry.key;
    }
    debugPrint('✅ BrandMappingService: Mapping updated successfully');
  }

  /// Clear cached mapping (useful for refresh)
  void clearCache() {
    debugPrint('🧹 BrandMappingService: Clearing cache...');
    _brandNameToIdMap = null;
    _brandIdToNameMap = null;
  }

  /// Get debug info about current mapping
  Future<Map<String, dynamic>> getDebugInfo() async {
    await _ensureMappingLoaded();
    return {
      'total_brands': _brandNameToIdMap?.length ?? 0,
      'brands': _brandNameToIdMap ?? {},
      'is_loaded': _brandNameToIdMap != null,
    };
  }
}
