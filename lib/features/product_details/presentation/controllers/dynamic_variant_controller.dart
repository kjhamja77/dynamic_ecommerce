import 'package:flutter/foundation.dart';
import '../../domain/entities/product_details.dart';

/// Value state enum for UI rendering
enum ValueState {
  fullyAvailable,      // Exists in in-stock variant AND compatible with current selection
  existsButIncompatible, // Exists in some variant but not with current selection (faded but clickable)
  doesNotExist,        // Does not exist in any in-stock variant (disabled)
}

/// Fully dynamic variant selection controller that works with unlimited attributes
/// and combinations. Uses ONLY attribute_id and value_id for matching.
/// 
/// This controller:
/// - Maintains selectedAttributes as Map<int, int> (attribute_id → value_id)
/// - Finds matching variants from variant_combinations
/// - Updates price, stock, variant_id, and images
/// - Handles "Out of Stock" scenarios when no match exists
class DynamicVariantController extends ChangeNotifier {
  /// The product details containing all variant data
  ProductDetails? _productDetails;
  
  /// Currently selected attributes: attribute_id → value_id
  Map<int, int> _selectedAttributes = {};
  
  /// Currently matched variant from variant_combinations
  VariantCombination? _selectedVariant;
  
  /// Current price (from matched variant or default)
  double _currentPrice = 0.0;
  
  /// Current stock status
  bool _inStock = true;
  
  /// Current quantity available
  int _quantityAvailable = 0;
  
  /// Current variant_id
  String _variantId = '';
  
  /// Current images (variant-specific or template fallback)
  List<String> _currentImages = [];
  
  /// Loading state for async operations
  bool _isLoading = false;

  // Getters
  Map<int, int> get selectedAttributes => Map.unmodifiable(_selectedAttributes);
  VariantCombination? get selectedVariant => _selectedVariant;
  double get currentPrice => _currentPrice;
  bool get inStock => _inStock;
  int get quantityAvailable => _quantityAvailable;
  String get variantId => _variantId;
  List<String> get currentImages => List.unmodifiable(_currentImages);
  bool get isLoading => _isLoading;
  ProductDetails? get productDetails => _productDetails;

  /// Initialize the controller with product details and selected variant
  /// CRITICAL: Always selects the first in-stock variant, ignoring any pre-existing
  /// selections in ProductDetails that might not match an in-stock variant
  void initialize(ProductDetails productDetails) {
    _productDetails = productDetails;
    
    debugPrint('🔄 DynamicVariantController.initialize() called');
    debugPrint('   Product ID: ${productDetails.id}');
    debugPrint('   Total variants: ${productDetails.variantCombinations.length}');
    debugPrint('   In-stock variants: ${productDetails.variantCombinations.where((v) => v.inStock && (v.quantityAvailable ?? 0) > 0).length}');
    debugPrint('   Current selection before init: $_selectedAttributes');
    
    // Initialize selectedAttributes from first in-stock variant
    // This ensures users always start with a valid, purchasable combination
    _initializeFromSelectedVariant();
    
    // Find and store the matching variant
    _updateMatchingVariant();
    
    debugPrint('✅ DynamicVariantController initialization complete');
    debugPrint('   Final selected attributes: $_selectedAttributes');
    debugPrint('   Matched variant ID: $_variantId');
    debugPrint('   In stock: $_inStock, Quantity: $_quantityAvailable');
    
    notifyListeners();
  }

  /// Update product details without resetting selection
  /// Use this when BLoC state changes but we want to preserve user's current selection
  void updateProductDetails(ProductDetails productDetails) {
    if (_productDetails?.id != productDetails.id) {
      // Different product - full reinitialize
      initialize(productDetails);
      return;
    }
    
    // Same product - just update reference and recalculate matching variant
    _productDetails = productDetails;
    
    debugPrint('🔄 DynamicVariantController.updateProductDetails() called');
    debugPrint('   Preserving selection: $_selectedAttributes');
    
    // Recalculate matching variant with updated product details
    _updateMatchingVariant();
    
    debugPrint('✅ DynamicVariantController product details updated');
    debugPrint('   Matched variant ID: $_variantId');
    debugPrint('   In stock: $_inStock, Quantity: $_quantityAvailable');
    
    notifyListeners();
  }

  /// Initialize selectedAttributes from the selected_variant in API response
  /// CRITICAL: Always selects ALL attributes from the first in-stock variant
  /// This ensures users start with a valid, purchasable combination
  void _initializeFromSelectedVariant() {
    if (_productDetails == null) return;
    
    // Find the first in-stock variant (prioritized for initial selection)
    final selectedVariant = _findSelectedVariantFromAPI();
    
    if (selectedVariant != null) {
      _selectedAttributes.clear();
      
      // Extract ALL attributes from the selected variant
      // This ensures we have a complete selection (size, color, material, etc.)
      for (final attr in selectedVariant.attributes) {
        final attrId = attr.attributeId;
        final valueId = attr.valueId;
        
        if (attrId != null && valueId != null) {
          final parsedAttrId = int.tryParse(attrId);
          final parsedValueId = int.tryParse(valueId);
          
          if (parsedAttrId != null && parsedValueId != null) {
            _selectedAttributes[parsedAttrId] = parsedValueId;
            
            // Debug: Log each attribute being selected
            final attrName = getAttributeNameById(parsedAttrId) ?? 'Attr$parsedAttrId';
            final valueName = getValueNameByIds(parsedAttrId, parsedValueId) ?? 'Val$parsedValueId';
            debugPrint('🎯 Initializing: $attrName = $valueName (attr_id: $parsedAttrId, value_id: $parsedValueId)');
          }
        }
      }
      
      debugPrint('✅ DynamicVariantController: Initialized ${_selectedAttributes.length} attributes from in-stock variant');
      debugPrint('   Selected attributes map: $_selectedAttributes');
      debugPrint('   Variant ID: ${selectedVariant.variantId}, Stock: ${selectedVariant.inStock}, Qty: ${selectedVariant.quantityAvailable}');
    } else {
      debugPrint('⚠️ DynamicVariantController: No variant found, using fallback initialization');
      // Fallback: Initialize from variantAttributeOptions if available
      _initializeFromVariantAttributeOptions();
    }
  }

  /// Fallback: Initialize from variantAttributeOptions
  /// CRITICAL: Only selects values that are part of in-stock variants
  void _initializeFromVariantAttributeOptions() {
    if (_productDetails == null) return;
    
    _selectedAttributes.clear();
    
    // Find first in-stock variant to use as reference
    final inStockVariant = _productDetails!.variantCombinations.firstWhere(
      (v) {
        final qty = v.quantityAvailable ?? 0;
        return v.inStock && qty > 0;
      },
      orElse: () => _productDetails!.variantCombinations.first,
    );
    
    // Extract attributes from the in-stock variant
    for (final attr in inStockVariant.attributes) {
      final attrId = attr.attributeId;
      final valueId = attr.valueId;
      
      if (attrId != null && valueId != null) {
        final parsedAttrId = int.tryParse(attrId);
        final parsedValueId = int.tryParse(valueId);
        
        if (parsedAttrId != null && parsedValueId != null) {
          _selectedAttributes[parsedAttrId] = parsedValueId;
          
          final attrName = getAttributeNameById(parsedAttrId) ?? 'Attr$parsedAttrId';
          final valueName = getValueNameByIds(parsedAttrId, parsedValueId) ?? 'Val$parsedValueId';
          debugPrint('🎯 Fallback: Initializing $attrName = $valueName');
        }
      }
    }
    
    debugPrint('✅ DynamicVariantController: Fallback initialized ${_selectedAttributes.length} attributes from in-stock variant');
    debugPrint('   Selected attributes: $_selectedAttributes');
  }

  /// Find the selected variant from API response
  /// ALWAYS prioritizes first in-stock variant for initial selection
  /// This ensures users always start with a valid, purchasable combination
  VariantCombination? _findSelectedVariantFromAPI() {
    if (_productDetails == null || _productDetails!.variantCombinations.isEmpty) {
      return null;
    }
    
    // CRITICAL: Always prioritize first in-stock variant for initial selection
    // This ensures the user starts with a valid combination that can be purchased
    final inStockVariant = _productDetails!.variantCombinations.firstWhere(
      (v) {
        final qty = v.quantityAvailable ?? 0;
        return v.inStock && qty > 0;
      },
      orElse: () => _productDetails!.variantCombinations.first,
    );
    
    debugPrint('🎯 DynamicVariantController: Found initial variant: variantId=${inStockVariant.variantId}, inStock=${inStockVariant.inStock}, qty=${inStockVariant.quantityAvailable}');
    
    return inStockVariant;
  }

  /// Get color value from variant (tries common attribute names)
  String? _getColorValue(VariantCombination variant) {
    const colorNames = ['COLOR NAME', 'color name', 'Color Name', 'color', 
                       'Color', 'COLOR', 'colour', 'Colour', 'اللون', 'لون'];
    
    for (final name in colorNames) {
      final value = variant.getAttributeValue(name);
      if (value != null && value.isNotEmpty) return value;
    }
    
    return null;
  }

  /// Get size value from variant
  String? _getSizeValue(VariantCombination variant) {
    const sizeNames = ['SIZE', 'size', 'Size'];
    
    for (final name in sizeNames) {
      final value = variant.getAttributeValue(name);
      if (value != null && value.isNotEmpty) return value;
    }
    
    // Also try primary variant label
    if (_productDetails != null && _productDetails!.primaryVariantLabel.isNotEmpty) {
      final value = variant.getAttributeValue(_productDetails!.primaryVariantLabel);
      if (value != null && value.isNotEmpty) return value;
    }
    
    return null;
  }

  /// Normalize string for comparison
  String _normalize(String s) => s.toLowerCase().trim();

  /// Select a value for an attribute
  /// This updates selectedAttributes and recalculates the matching variant
  /// Also handles auto-clearing conflicting attributes when selection becomes invalid
  void selectAttributeValue(int attributeId, int valueId) {
    debugPrint('🎯 DynamicVariantController: Selecting attribute $attributeId → value $valueId');
    debugPrint('   Before: $_selectedAttributes');
    
    // Store previous selection for conflict detection
    final previousSelection = Map<int, int>.from(_selectedAttributes);
    
    _selectedAttributes[attributeId] = valueId;
    
    // Check if this selection makes other attributes invalid
    // If so, auto-clear conflicting attributes
    _clearConflictingAttributes(attributeId, valueId);
    
    debugPrint('   After: $_selectedAttributes');
    
    // Recalculate matching variant
    _updateMatchingVariant();
    
    debugPrint('🔄 DynamicVariantController: Notifying listeners');
    debugPrint('   Final state: inStock=$_inStock, qty=$_quantityAvailable, variantId=$_variantId');
    
    notifyListeners();
  }
  
  /// Clear attributes that become invalid after selecting a new value
  /// CRITICAL FIX: Only clear attributes if the value doesn't exist at all (doesNotExist),
  /// NOT if it's just incompatible (existsButIncompatible). This preserves user selections
  /// even when they become temporarily incompatible, allowing "Out of stock" display instead
  /// of auto-switching to different values.
  void _clearConflictingAttributes(int selectedAttributeId, int selectedValueId) {
    if (_productDetails == null) return;
    
    // Check each other selected attribute to see if it's still valid
    final attributesToRemove = <int>[];
    
    for (final entry in _selectedAttributes.entries) {
      final attrId = entry.key;
      final valueId = entry.value;
      
      // Skip the attribute we just selected
      if (attrId == selectedAttributeId) continue;
      
      // CRITICAL FIX: Check the actual state of the value, not just availability
      // Only clear if value doesn't exist at all (doesNotExist), not if it's incompatible
      final valueState = getValueState(attrId, valueId);
      
      // Only remove if value doesn't exist in any variant
      // If it exists but is incompatible, keep it selected (will show "Out of stock")
      if (valueState == ValueState.doesNotExist) {
        attributesToRemove.add(attrId);
        debugPrint('⚠️ Clearing attribute $attrId (value $valueId does not exist in any variant)');
      } else {
        debugPrint('✅ Preserving attribute $attrId (value $valueId state: $valueState - exists but may be incompatible)');
      }
    }
    
    // Remove only attributes whose values don't exist at all
    for (final attrId in attributesToRemove) {
      _selectedAttributes.remove(attrId);
    }
    
    if (attributesToRemove.isNotEmpty) {
      debugPrint('✅ Cleared ${attributesToRemove.length} attribute(s) that don\'t exist');
    }
    
    // CRITICAL FIX: Disable auto-selection - preserve user's manual selections
    // Don't auto-select even if only one option remains - let user choose
    // _autoSelectSingleRemainingOptions(); // DISABLED to prevent auto-switching
  }
  
  /// Auto-select attributes that have only one valid option remaining
  /// This improves UX by reducing clicks needed
  void _autoSelectSingleRemainingOptions() {
    if (_productDetails == null) return;
    
    for (final attrOption in _productDetails!.variantAttributeOptions) {
      final attrId = attrOption.attributeId;
      if (attrId == null) continue;
      
      final parsedAttrId = int.tryParse(attrId);
      if (parsedAttrId == null) continue;
      
      // Skip if already selected
      if (_selectedAttributes.containsKey(parsedAttrId)) continue;
      
      // Get available values for this attribute
      final availableValues = getAvailableValuesForAttribute(parsedAttrId);
      
      // If only one option available, auto-select it
      if (availableValues.length == 1) {
        final singleValueId = availableValues.first;
        _selectedAttributes[parsedAttrId] = singleValueId;
        debugPrint('✨ Auto-selected attribute $parsedAttrId → value $singleValueId (only option)');
      }
    }
  }

  /// Update the matching variant based on current selectedAttributes
  void _updateMatchingVariant() {
    if (_productDetails == null) {
      _setNoVariantState();
      return;
    }
    
    // If no attributes selected yet, don't set a variant (wait for initial selection)
    if (_selectedAttributes.isEmpty) {
      _setNoVariantState();
      return;
    }
    
    // Find ALL matching variants from variant_combinations
    final matchingVariants = _findAllMatchingVariants();
    
    if (matchingVariants.isNotEmpty) {
      // Use the first matching variant for price, images, and variantId
      // But sum quantities from ALL matching variants
      _selectedVariant = matchingVariants.first;
      // Use variant-specific price if available, otherwise fallback to template price
      _currentPrice = _selectedVariant?.price ?? _productDetails!.price;
      
      // CRITICAL: Sum quantities from ALL matching variants
      int totalQuantity = 0;
      bool hasInStock = false;
      
      for (final variant in matchingVariants) {
        final qty = variant.quantityAvailable ?? 0;
        if (variant.inStock && qty > 0) {
          hasInStock = true;
          totalQuantity += qty.toInt();
        }
      }
      
      _inStock = hasInStock && totalQuantity > 0;
      _quantityAvailable = totalQuantity;
      _variantId = matchingVariants.first.variantId; // Use first variant's ID for cart operations
      
      // Update images
      _updateImages();
      
      debugPrint('✅ DynamicVariantController: Found ${matchingVariants.length} matching variant(s)');
      debugPrint('   Total quantity (summed): $_quantityAvailable');
      debugPrint('   Price: $_currentPrice, Stock: $_inStock');
      debugPrint('   Variant ID (first): $_variantId');
      debugPrint('   Selected attributes: $_selectedAttributes');
      
      // Log details of all matching variants for debugging
      for (int i = 0; i < matchingVariants.length; i++) {
        final v = matchingVariants[i];
        debugPrint('   Variant $i: variantId=${v.variantId}, qty=${v.quantityAvailable}, inStock=${v.inStock}, price=${v.price}');
      }
    } else {
      _setNoVariantState();
      debugPrint('❌ DynamicVariantController: No matching variant found for selection: $_selectedAttributes');
    }
  }

  /// Find ALL matching variants from variant_combinations
  /// Returns all variants where ALL {attribute_id, value_id} pairs match selectedAttributes
  List<VariantCombination> _findAllMatchingVariants() {
    if (_productDetails == null) return [];
    
    final matching = <VariantCombination>[];
    debugPrint('🔍 _findAllMatchingVariants: Searching ${_productDetails!.variantCombinations.length} variants');
    debugPrint('   Selected attributes: $_selectedAttributes');
    
    for (final variant in _productDetails!.variantCombinations) {
      if (_variantMatchesSelection(variant)) {
        matching.add(variant);
        final qty = variant.quantityAvailable ?? 0;
        debugPrint('   ✅ Match found: variantId=${variant.variantId}, qty=$qty, inStock=${variant.inStock}');
      }
    }
    
    debugPrint('   Total matches: ${matching.length}');
    return matching;
  }

  /// Find matching variant from variant_combinations (kept for backward compatibility)
  /// A variant matches if ALL its {attribute_id, value_id} pairs match selectedAttributes
  VariantCombination? _findMatchingVariant() {
    final matching = _findAllMatchingVariants();
    return matching.isNotEmpty ? matching.first : null;
  }

  /// Check if a variant matches the current selection
  /// Returns true if ALL selected attributes match the variant's attributes
  bool _variantMatchesSelection(VariantCombination variant) {
    // For each selected attribute, check if variant has matching attribute_id and value_id
    for (final entry in _selectedAttributes.entries) {
      final selectedAttrId = entry.key;
      final selectedValueId = entry.value;
      
      // Find matching attribute in variant
      final matchingAttr = variant.attributes.firstWhere(
        (attr) {
          final attrId = attr.attributeId;
          final valueId = attr.valueId;
          
          if (attrId == null || valueId == null) return false;
          
          final parsedAttrId = int.tryParse(attrId);
          final parsedValueId = int.tryParse(valueId);
          
          return parsedAttrId == selectedAttrId && parsedValueId == selectedValueId;
        },
        orElse: () => const VariantAttribute(
          attributeName: '',
          valueName: '',
        ),
      );
      
      // If no matching attribute found, this variant doesn't match
      if (matchingAttr.attributeName.isEmpty) {
        return false;
      }
    }
    
    return true;
  }

  /// Set state when no matching variant exists
  void _setNoVariantState() {
    _selectedVariant = null;
    _inStock = false;
    _quantityAvailable = 0;
    _variantId = '';
    
    // Keep current price and images as fallback
    if (_productDetails != null) {
      _currentPrice = _productDetails!.price;
      _currentImages = List.from(_productDetails!.images);
    }
  }

  /// Update images based on selected variant
  void _updateImages() {
    if (_productDetails == null) return;
    
    if (_variantId.isNotEmpty) {
      // Check if variant has specific images
      final variantImages = _productDetails!.variantImagesMap[_variantId];
      
      if (variantImages != null && variantImages.isNotEmpty) {
        _currentImages = List.from(variantImages);
        debugPrint('🖼️ DynamicVariantController: Using variant images (${variantImages.length} images)');
        return;
      }
    }
    
    // Fallback to template images
    _currentImages = List.from(_productDetails!.images);
    debugPrint('🖼️ DynamicVariantController: Using template images (${_currentImages.length} images)');
  }

  /// Get the state of a specific value for an attribute
  /// Returns one of three states: fullyAvailable, existsButIncompatible, or doesNotExist
  ValueState getValueState(int attributeId, int valueId) {
    if (_productDetails == null) return ValueState.doesNotExist;
    
    // Step 1: Check if value exists in ANY in-stock variant (product-level existence)
    final existsInStock = _valueExistsInAnyInStockVariant(attributeId, valueId);
    
    if (!existsInStock) {
      return ValueState.doesNotExist;
    }
    
    // Step 2: Check compatibility with current selection
    final tempSelection = Map<int, int>.from(_selectedAttributes);
    tempSelection.remove(attributeId);
    
    // If no other selections, value is fully available
    if (tempSelection.isEmpty) {
      return ValueState.fullyAvailable;
    }
    
    // Check if value is compatible with current selection
    final isCompatible = _isValueCompatibleWithSelection(attributeId, valueId, tempSelection);
    
    if (isCompatible) {
      return ValueState.fullyAvailable;
    } else {
      // Value exists but not compatible - still clickable but faded
      return ValueState.existsButIncompatible;
    }
  }
  
  /// Check if a value exists in ANY in-stock variant (product-level check)
  bool _valueExistsInAnyInStockVariant(int attributeId, int valueId) {
    if (_productDetails == null) return false;
    
    for (final variant in _productDetails!.variantCombinations) {
      final qty = variant.quantityAvailable ?? 0;
      if (!variant.inStock || qty <= 0) continue;
      
      // Check if this variant has this attribute/value pair
      for (final attr in variant.attributes) {
        final vAttrId = attr.attributeId;
        final vValueId = attr.valueId;
        
        if (vAttrId == null || vValueId == null) continue;
        
        final parsedAttrId = int.tryParse(vAttrId);
        final parsedValueId = int.tryParse(vValueId);
        
        if (parsedAttrId == attributeId && parsedValueId == valueId) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Check if a value is compatible with current selection
  /// Uses attribute_value_combinations if available, otherwise checks variant combinations
  bool _isValueCompatibleWithSelection(int attributeId, int valueId, Map<int, int> selection) {
    if (_productDetails == null || selection.isEmpty) return true;
    
    // Try using attribute_value_combinations first
    if (_productDetails!.attributeValueCombinations.isNotEmpty) {
      return _isValueCompatibleViaCombinations(attributeId, valueId, selection);
    }
    
    // Fallback: Check variant combinations directly
    return _isValueCompatibleViaVariants(attributeId, valueId, selection);
  }
  
  /// Check compatibility using attribute_value_combinations
  bool _isValueCompatibleViaCombinations(int attributeId, int valueId, Map<int, int> selection) {
    // For each selected value, check if valueId appears in its combinations
    for (final entry in selection.entries) {
      final selectedValueId = entry.value;
      final valueIdStr = selectedValueId.toString();
      
      final availableCombinations = _productDetails!.attributeValueCombinations[valueIdStr];
      if (availableCombinations == null || availableCombinations.isEmpty) {
        // No combinations data for this value - can't determine compatibility
        continue;
      }
      
      // Check if valueId is in the available combinations for this selected value
      final valueIdStrTarget = valueId.toString();
      if (!availableCombinations.contains(valueIdStrTarget)) {
        // This value is not compatible with this selected value
        return false;
      }
    }
    
    // Also check reverse: for the value being checked, see if selected values are in its combinations
    final valueIdStr = valueId.toString();
    final valueCombinations = _productDetails!.attributeValueCombinations[valueIdStr];
    if (valueCombinations != null && valueCombinations.isNotEmpty) {
      for (final entry in selection.entries) {
        final selectedValueIdStr = entry.value.toString();
        if (!valueCombinations.contains(selectedValueIdStr)) {
          // Selected value not in this value's combinations
          return false;
        }
      }
    }
    
    return true;
  }
  
  /// Check compatibility by searching variant combinations directly
  bool _isValueCompatibleViaVariants(int attributeId, int valueId, Map<int, int> selection) {
    // Find a variant that has both this value AND all selected values
    for (final variant in _productDetails!.variantCombinations) {
      final qty = variant.quantityAvailable ?? 0;
      if (!variant.inStock || qty <= 0) continue;
      
      // Check if variant has this value
      bool hasThisValue = false;
      for (final attr in variant.attributes) {
        final vAttrId = int.tryParse(attr.attributeId ?? '');
        final vValueId = int.tryParse(attr.valueId ?? '');
        if (vAttrId == attributeId && vValueId == valueId) {
          hasThisValue = true;
          break;
        }
      }
      
      if (!hasThisValue) continue;
      
      // Check if variant has all selected values
      bool hasAllSelected = true;
      for (final entry in selection.entries) {
        final selectedAttrId = entry.key;
        final selectedValueId = entry.value;
        
        bool found = false;
        for (final attr in variant.attributes) {
          final vAttrId = int.tryParse(attr.attributeId ?? '');
          final vValueId = int.tryParse(attr.valueId ?? '');
          if (vAttrId == selectedAttrId && vValueId == selectedValueId) {
            found = true;
            break;
          }
        }
        
        if (!found) {
          hasAllSelected = false;
          break;
        }
      }
      
      if (hasAllSelected) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Get available values for a specific attribute based on current selection
  /// Returns a set of value_ids that are FULLY AVAILABLE (compatible + in stock)
  /// Note: UI should show ALL values and use getValueState() to determine their appearance
  Set<int> getAvailableValuesForAttribute(int attributeId) {
    if (_productDetails == null) return {};
    
    final availableValueIds = <int>{};
    
    // Build a temporary selection without this attribute
    final tempSelection = Map<int, int>.from(_selectedAttributes);
    tempSelection.remove(attributeId);
    
    debugPrint('🔍 Calculating availability for attribute $attributeId');
    debugPrint('   Temp selection (without this attr): $tempSelection');
    
    // Get all values for this attribute and check their states
    for (final attrOption in _productDetails!.variantAttributeOptions) {
      final attrId = attrOption.attributeId;
      if (attrId == null || int.tryParse(attrId) != attributeId) continue;
      
      for (final value in attrOption.values) {
        final valueId = int.tryParse(value.id);
        if (valueId == null) continue;
        
        final state = getValueState(attributeId, valueId);
        if (state == ValueState.fullyAvailable) {
          availableValueIds.add(valueId);
        }
      }
      break; // Found the attribute, no need to continue
    }
    
    debugPrint('   Fully available values: $availableValueIds');
    return availableValueIds;
  }
  
  /// Get valid values from attribute_value_combinations for a given attribute
  /// Uses intersection logic when multiple values are selected
  Set<int> _getValidValuesFromCombinations(int attributeId, Map<int, int> selectedAttributes) {
    if (_productDetails == null || selectedAttributes.isEmpty) {
      return {};
    }
    
    final Set<int> validValueIds = {};
    
    // Collect all available value sets from selected values
    final List<Set<int>> availableSets = [];
    
    for (final entry in selectedAttributes.entries) {
      final selectedValueId = entry.value;
      final valueIdStr = selectedValueId.toString();
      
      // Look up this value in attribute_value_combinations
      final availableCombinations = _productDetails!.attributeValueCombinations[valueIdStr];
      
      if (availableCombinations != null && availableCombinations.isNotEmpty) {
        // Convert to set of integers
        final valueIds = availableCombinations
            .map((id) => int.tryParse(id))
            .whereType<int>()
            .toSet();
        
        // Filter to only values for the target attribute
        final filteredForAttribute = <int>{};
        for (final valueId in valueIds) {
          // Check if this value_id belongs to the target attribute
          if (_isValueIdForAttribute(valueId, attributeId)) {
            filteredForAttribute.add(valueId);
          }
        }
        
        if (filteredForAttribute.isNotEmpty) {
          availableSets.add(filteredForAttribute);
          debugPrint('   Selected value $selectedValueId → ${filteredForAttribute.length} available for attr $attributeId');
        }
      }
    }
    
    // Intersect all sets: only values that appear in ALL selected values' combinations
    if (availableSets.isEmpty) {
      // No combinations found - return empty (will fall back to stock-based logic)
      return {};
    }
    
    // Start with first set, then intersect with others using retainAll
    validValueIds.addAll(availableSets.first);
    
    for (int i = 1; i < availableSets.length; i++) {
      validValueIds.retainAll(availableSets[i]);
    }
    
    debugPrint('   Intersected ${availableSets.length} sets → ${validValueIds.length} valid values');
    
    return validValueIds;
  }
  
  /// Check if a value_id belongs to a specific attribute
  bool _isValueIdForAttribute(int valueId, int attributeId) {
    if (_productDetails == null) return false;
    
    // Check all variant attribute options to find which attribute this value belongs to
    for (final attrOption in _productDetails!.variantAttributeOptions) {
      final attrId = attrOption.attributeId;
      if (attrId == null || int.tryParse(attrId) != attributeId) continue;
      
      // Check if this value_id exists in this attribute's values
      for (final value in attrOption.values) {
        if (int.tryParse(value.id) == valueId) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Get in-stock values for an attribute based on current selection
  /// Returns value_ids that have at least one in-stock variant matching the selection
  Set<int> _getInStockValuesForAttribute(int attributeId, Map<int, int> selectedAttributes) {
    if (_productDetails == null) return {};
    
    final inStockValueIds = <int>{};
    
    // Find all variants that match selected attributes AND are in stock
    for (final variant in _productDetails!.variantCombinations) {
      final qty = variant.quantityAvailable ?? 0;
      final isInStock = variant.inStock && qty > 0;
      
      if (!isInStock) continue;
      
      // Check if variant matches selected attributes
      bool matches = true;
      if (selectedAttributes.isNotEmpty) {
        for (final entry in selectedAttributes.entries) {
          final selectedAttrId = entry.key;
          final selectedValueId = entry.value;
          
          bool foundMatch = false;
          for (final attr in variant.attributes) {
            final vAttrId = attr.attributeId;
            final vValueId = attr.valueId;
            
            if (vAttrId == null || vValueId == null) continue;
            
            final parsedAttrId = int.tryParse(vAttrId);
            final parsedValueId = int.tryParse(vValueId);
            
            if (parsedAttrId == selectedAttrId && parsedValueId == selectedValueId) {
              foundMatch = true;
              break;
            }
          }
          
          if (!foundMatch) {
            matches = false;
            break;
          }
        }
      }
      
      if (!matches) continue;
      
      // Collect value_id for this attribute from matching variant
      for (final attr in variant.attributes) {
        final vAttrId = attr.attributeId;
        final vValueId = attr.valueId;
        
        if (vAttrId == null || vValueId == null) continue;
        
        final parsedAttrId = int.tryParse(vAttrId);
        final parsedValueId = int.tryParse(vValueId);
        
        if (parsedAttrId == attributeId && parsedValueId != null) {
          inStockValueIds.add(parsedValueId);
        }
      }
    }
    
    return inStockValueIds;
  }
  
  /// Get stock information for a specific attribute value
  /// Returns a map with stock details: {inStock, quantity, variantIds}
  Map<String, dynamic> getStockInfoForValue(int attributeId, int valueId) {
    if (_productDetails == null) {
      return {'inStock': false, 'quantity': 0, 'variantIds': <String>[]};
    }
    
    int totalQuantity = 0;
    bool hasInStock = false;
    final variantIds = <String>[];
    
    // Build temp selection with this value
    final tempSelection = Map<int, int>.from(_selectedAttributes);
    tempSelection[attributeId] = valueId;
    
    // Find all variants that match this selection
    for (final variant in _productDetails!.variantCombinations) {
      // Check if variant matches the selection
      bool matches = true;
      for (final entry in tempSelection.entries) {
        final selectedAttrId = entry.key;
        final selectedValueId = entry.value;
        
        bool foundMatch = false;
        for (final attr in variant.attributes) {
          final vAttrId = int.tryParse(attr.attributeId ?? '');
          final vValueId = int.tryParse(attr.valueId ?? '');
          
          if (vAttrId == selectedAttrId && vValueId == selectedValueId) {
            foundMatch = true;
            break;
          }
        }
        
        if (!foundMatch) {
          matches = false;
          break;
        }
      }
      
      if (!matches) continue;
      
      // This variant matches - collect stock info
      final qty = variant.quantityAvailable ?? 0;
      if (variant.inStock && qty > 0) {
        hasInStock = true;
        totalQuantity += qty.toInt();
        variantIds.add(variant.variantId);
      }
    }
    
    return {
      'inStock': hasInStock,
      'quantity': totalQuantity,
      'variantIds': variantIds,
    };
  }

  /// Check if a specific value is available for an attribute
  bool isValueAvailable(int attributeId, int valueId) {
    final availableValues = getAvailableValuesForAttribute(attributeId);
    return availableValues.contains(valueId);
  }

  /// Get attribute name by ID (for display purposes)
  String? getAttributeNameById(int attributeId) {
    if (_productDetails == null) return null;
    
    for (final attrOption in _productDetails!.variantAttributeOptions) {
      final attrId = attrOption.attributeId;
      if (attrId != null && int.tryParse(attrId) == attributeId) {
        return attrOption.attributeName;
      }
    }
    
    return null;
  }

  /// Get value name by IDs (for display purposes)
  String? getValueNameByIds(int attributeId, int valueId) {
    if (_productDetails == null) return null;
    
    for (final attrOption in _productDetails!.variantAttributeOptions) {
      final attrId = attrOption.attributeId;
      if (attrId != null && int.tryParse(attrId) == attributeId) {
        for (final value in attrOption.values) {
          if (int.tryParse(value.id) == valueId) {
            return value.name;
          }
        }
      }
    }
    
    return null;
  }

  /// Reset to initial state
  void reset() {
    _selectedAttributes.clear();
    _selectedVariant = null;
    _currentPrice = 0.0;
    _inStock = true;
    _quantityAvailable = 0;
    _variantId = '';
    _currentImages = [];
    _isLoading = false;
    _productDetails = null;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
