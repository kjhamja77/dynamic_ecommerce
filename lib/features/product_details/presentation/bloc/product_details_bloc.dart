import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:developer' as developer;
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/usecases/get_product_details.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/select_color.dart';
import '../../domain/usecases/select_size.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../../core/services/app_localization_service.dart';

part 'product_details_event.dart';
part 'product_details_state.dart';

class ProductDetailsBloc extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final GetProductDetails getProductDetails;
  final ToggleFavorite toggleFavorite;
  final SelectColor selectColor;
  final SelectSize selectSize;
  final AddToCart addToCart;
  final CartBloc cartBloc;

  ProductDetailsBloc({
    required this.getProductDetails,
    required this.toggleFavorite,
    required this.selectColor,
    required this.selectSize,
    required this.addToCart,
    required this.cartBloc,
  }) : super(ProductDetailsInitial()) {
    developer.log('🏗️ ProductDetailsBloc constructed with CartBloc: ${cartBloc.runtimeType}');
    on<LoadProductDetails>(_onLoadProductDetails);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<SelectColorEvent>(_onSelectColor);
    on<SelectSizeEvent>(_onSelectSize);
    on<AddToCartEvent>(_onAddToCart);
    on<SelectMaterialEvent>(_onSelectMaterial);
    on<SelectHeelHeightEvent>(_onSelectHeelHeight);
    on<FilterVariantsByAttributeEvent>(_onFilterVariantsByAttribute);
    on<IncrementQuantityEvent>(_onIncrementQty);
    on<DecrementQuantityEvent>(_onDecrementQty);
    on<ResetAddingStateEvent>(_onResetAddingState);
    on<SelectVariantByIdEvent>(_onSelectVariantById);
  }

  /// Stock rule for variant combinations.
  /// Some backends don't send `quantityAvailable` consistently; when it's null we treat it as "unknown quantity"
  /// and allow selection as long as `inStock` is true.
  bool _isVariantInStock(VariantCombination v) {
    final qty = v.quantityAvailable;
    return v.inStock && (qty == null || qty > 0);
  }

  String _norm(String s) => s.toLowerCase().trim();

  static bool _isColorAttributeKey(String key) {
    final k = key.toLowerCase();
    return k == 'color name' || k == 'color' || k == 'colour' || k == 'اللون' || k == 'لون';
  }

  /// Get color value from a variant (tries common attribute names).
  String? _getVariantColorValue(VariantCombination v) {
    const colorAttrNames = [
      'COLOR NAME', 'color name', 'Color Name', 'color', 'Color', 'COLOR',
      'colour', 'Colour', 'اللون', 'لون',
    ];
    for (final attrName in colorAttrNames) {
      final value = v.getAttributeValue(attrName);
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Returns true when variant's color value matches the selected value (handles Arabic/English).
  /// Variants from API typically have English; selectedValue may be Arabic when app is in Arabic.
  bool _colorValuesMatch(ProductDetails pd, String? variantValue, String selectedValue) {
    if (variantValue == null || variantValue.isEmpty) return false;
    final nV = _norm(variantValue);
    final nS = _norm(selectedValue);
    if (nV == nS) return true;
    for (final color in pd.colorOptions) {
      final nameNorm = _norm(color.name);
      final displayNorm = color.displayName != null ? _norm(color.displayName!) : '';
      if (nameNorm.isEmpty) continue;
      if (nameNorm != nV) continue;
      if (nS == nameNorm || nS == displayNorm) return true;
      if (displayNorm.isNotEmpty && (nS.contains(displayNorm) || displayNorm.contains(nS))) return true;
    }
    return false;
  }

  /// Best-effort attribute value lookup from a variant combination.
  /// The API is not consistent with attribute names (e.g. SIZE vs Legs vs Arabic),
  /// so we try common aliases + a fuzzy fallback. This prevents "everything disabled"
  /// when names don't match exactly.
  String? _getComboValueForAttribute(
    ProductDetails product,
    VariantCombination combo,
    String attributeName,
  ) {
    final lower = _norm(attributeName);

    final List<String> keys = <String>[attributeName];

    bool isSizeKey() {
      final p = _norm(product.primaryVariantLabel);
      return lower == 'size' ||
          lower == 'القياس' ||
          lower == 'المقاس' ||
          (p.isNotEmpty && lower == p) ||
          lower.contains('size') ||
          lower.contains('قياس') ||
          lower.contains('مقاس');
    }

    bool isColorKey() {
      return lower == 'color' ||
          lower == 'colour' ||
          lower == 'color name' ||
          lower == 'اللون' ||
          lower.contains('color') ||
          lower.contains('colour') ||
          lower.contains('لون');
    }

    bool isMaterialKey() {
      return lower == 'material' ||
          lower == 'material name' ||
          lower.contains('material') ||
          lower.contains('مادة') ||
          lower.contains('المادة');
    }

    bool isHeightKey() {
      return lower == 'height' ||
          lower == 'heel height' ||
          lower.contains('height') ||
          lower.contains('heel') ||
          lower.contains('ارتفاع');
    }

    if (isSizeKey()) {
      if (product.primaryVariantLabel.isNotEmpty) keys.add(product.primaryVariantLabel);
      keys.addAll(const ['SIZE', 'size', 'Size', 'القياس', 'المقاس']);
    } else if (isColorKey()) {
      keys.addAll(const [
        'COLOR NAME',
        'color name',
        'Color Name',
        'COLOR',
        'color',
        'Color',
        'COLOUR',
        'colour',
        'Colour',
        'اللون',
        'لون',
      ]);
    } else if (isMaterialKey()) {
      keys.addAll(const [
        'MATERIAL NAME',
        'material name',
        'Material Name',
        'MATERIAL',
        'material',
        'Material',
        'المادة',
      ]);
    } else if (isHeightKey()) {
      keys.addAll(const [
        'HEIGHT',
        'height',
        'Height',
        'HEEL HEIGHT',
        'heel height',
        'Heel Height',
        'ارتفاع',
      ]);
    }

    // Exact(ish) lookup (case-insensitive is handled by getAttributeValue).
    for (final k in keys) {
      final v = combo.getAttributeValue(k);
      if (v != null && v.isNotEmpty) return v;
    }

    // Fuzzy fallback: try "contains" matching on attribute name.
    for (final attr in combo.attributes) {
      final a = _norm(attr.attributeName);
      if (a == lower || a.contains(lower) || lower.contains(a)) {
        final v = attr.valueName;
        if (v.isNotEmpty) return v;
      }
    }

    return null;
  }
  
  void _onResetAddingState(
    ResetAddingStateEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is ProductDetailsLoaded) {
      final currentState = state as ProductDetailsLoaded;
      emit(currentState.copyWith(isAdding: false));
    }
  }

  /// When a selector (color/material/other) knows the exact variantId that
  /// should be active, this handler updates the ProductDetails images using
  /// the shared helper on the entity and re-emits the loaded state.
  Future<void> _onSelectVariantById(
    SelectVariantByIdEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    final blocState = state;
    if (blocState is! ProductDetailsLoaded) return;

    final product = blocState.productDetails;
    final variantId = event.variantId;

    // Update only the images based on this concrete variantId; all other
    // selection state (color, size, material, etc.) stays as-is.
    final updatedProduct = product.withImagesForVariant(variantId);

    debugPrint(
      '🧪 _onSelectVariantById → variantId=$variantId, '
      'newImagesCount=${updatedProduct.images.length}, '
      'images=${updatedProduct.images}',
    );

    emit(ProductDetailsLoaded(
      updatedProduct,
      quantity: blocState.quantity,
      isAdding: blocState.isAdding,
    ));
  }
  Future<void> _onSelectMaterial(
    SelectMaterialEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state is ProductDetailsLoaded) {
      final s = state as ProductDetailsLoaded;
      final p = s.productDetails;
      
      // Check if this material has any in-stock variants with current selections
      bool hasInStockVariant = false;
      if (p.selectedSize.isNotEmpty && p.selectedColor.isNotEmpty) {
        for (final v in p.variantCombinations) {
          final bool sizeMatch = v.hasAttributeValue(p.primaryVariantLabel, p.selectedSize) ||
                               v.hasAttributeValue('size', p.selectedSize) ||
                               v.hasAttributeValue('SIZE', p.selectedSize);
          // Get actual color name from variantAttributeOptions
          String? actualColorName;
          for (final opt in p.variantAttributeOptions) {
            final attrNameLower = opt.attributeName.toLowerCase();
            if ((attrNameLower == 'color name' || 
                 attrNameLower == 'color' || 
                 attrNameLower == 'colour' ||
                 attrNameLower == 'اللون') && 
                opt.selectedValue.isNotEmpty) {
              actualColorName = opt.selectedValue;
              break;
            }
          }
          if (actualColorName == null && p.selectedColor.isNotEmpty) {
            actualColorName = p.selectedColor;
          }
          
          String normalize(String s) => s.toLowerCase().trim();
          final String? variantColorName = v.getAttributeValue('COLOR NAME');
          final bool colorMatch = actualColorName != null && 
                                variantColorName != null &&
                                normalize(variantColorName) == normalize(actualColorName);
          final bool materialMatch = v.hasAttributeValue('MATERIAL NAME', event.material) ||
                                   v.hasAttributeValue('material name', event.material);
          
          if (sizeMatch && colorMatch && materialMatch) {
            final isInStock = v.inStock && (v.quantityAvailable == null || v.quantityAvailable! > 0);
            if (isInStock) {
              hasInStockVariant = true;
              break;
            }
          }
        }
        
        // If no in-stock variant exists for this material combination, don't allow selection
        if (!hasInStockVariant) {
          developer.log('⚠️ Cannot select material ${event.material}: no in-stock variants for size ${p.selectedSize} and color ${p.selectedColor}');
          return;
        }
      }
      
      var updated = ProductDetails(
        id: p.id,
        brand: p.brand,
        name: p.name,
        description: p.description,
        price: p.price,
        originalPrice: p.originalPrice,
        rating: p.rating,
        reviewCount: p.reviewCount,
        images: p.images,
        colorOptions: p.colorOptions,
        sizeOptions: p.sizeOptions,
        variantAttributeOptions: p.variantAttributeOptions,
        selectedColor: p.selectedColor,
        selectedSize: p.selectedSize,
        isFavorite: p.isFavorite,
        hasDiscount: p.hasDiscount,
        discountPercentage: p.discountPercentage,
        features: p.features,
        material: p.material,
        materialsList: p.materialsList,
        materialOptions: p.materialOptions,
        selectedMaterial: event.material,
        careInstructions: p.careInstructions,
        heelHeightCm: p.heelHeightCm,
        heelType: p.heelType,
        heelHeightOptions: p.heelHeightOptions,
        selectedHeelHeightCm: p.selectedHeelHeightCm,
        isPlusMember: p.isPlusMember,
        pointsEarned: p.pointsEarned,
        optionalProducts: p.optionalProducts,
        accessoryProducts: p.accessoryProducts,
        alternativeProducts: p.alternativeProducts,
        variantCombinations: p.variantCombinations,
        primaryVariantLabel: p.primaryVariantLabel,
        tags: p.tags,
        variantImagesMap: p.variantImagesMap,
      );
      
      // Sync stock & quantity with the newly selected variant combination
      int nextQuantity = s.quantity;
      final VariantCombination? selectedVariant = _findSelectedVariant(updated);
      if (selectedVariant != null) {
        final double? quantityAvailable = selectedVariant.quantityAvailable;
        bool variantInStock = selectedVariant.inStock;

        if (quantityAvailable != null) {
          // Check if there's already an item in cart with this variant ID
          int existingCartQuantity = 0;
          final variantIdToCheck = selectedVariant.variantId;
          // Convert variantId to String for comparison (cart items use String IDs)
          final variantIdStr = variantIdToCheck.toString();
          if (cartBloc.state is CartLoaded) {
            final cartState = cartBloc.state as CartLoaded;
            try {
              final existingItem = cartState.cartItems.firstWhere(
                (item) => item.product.id.toString() == variantIdStr,
              );
              existingCartQuantity = existingItem.quantity;
            } catch (e) {
              // Item not found in cart, existingCartQuantity remains 0
            }
          }
          
          final maxAllowed = quantityAvailable.toInt();
          final available = maxAllowed - existingCartQuantity;
          
          if (maxAllowed <= 0 || available <= 0) {
            variantInStock = false;
            nextQuantity = 1;
          } else {
            // Clamp to available quantity (accounting for cart items)
            if (nextQuantity > available) {
              nextQuantity = available;
            }
            if (nextQuantity <= 0) {
              nextQuantity = 1;
            }
          }
          
          developer.log('🧵 Material selected: ${event.material}, variantId=${selectedVariant.variantId}, totalAvailable=$maxAllowed, inCart=$existingCartQuantity, available=$available, adjustedQty=$nextQuantity');
        }

        updated = updated.copyWith(
          inStock: variantInStock,
          selectedVariantQuantityAvailable: selectedVariant.quantityAvailable?.toInt(),
        );
        if (updated.variantImagesMap.isNotEmpty) {
          updated = updated.withImagesForVariant(selectedVariant.variantId);
        }
      }
      
      emit(ProductDetailsLoaded(updated, quantity: nextQuantity, isAdding: false));
    }
  }

  Future<void> _onSelectHeelHeight(
    SelectHeelHeightEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state is ProductDetailsLoaded) {
      final s = state as ProductDetailsLoaded;
      final p = s.productDetails;
      
      // Check if this heel height has any in-stock variants with current selections
      bool hasInStockVariant = false;
      final heightStr = event.heelHeightCm.toStringAsFixed(1);
      
      // Get actual color name from variantAttributeOptions
      String? actualColorName;
      for (final opt in p.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if ((attrNameLower == 'color name' || 
             attrNameLower == 'color' || 
             attrNameLower == 'colour' ||
             attrNameLower == 'اللون') && 
            opt.selectedValue.isNotEmpty) {
          actualColorName = opt.selectedValue;
          break;
        }
      }
      if (actualColorName == null && p.selectedColor.isNotEmpty) {
        actualColorName = p.selectedColor;
      }
      
      if (p.selectedSize.isNotEmpty && actualColorName != null && actualColorName.isNotEmpty) {
        String normalize(String s) => s.toLowerCase().trim();
        for (final v in p.variantCombinations) {
          final bool sizeMatch = v.hasAttributeValue(p.primaryVariantLabel, p.selectedSize) ||
                               v.hasAttributeValue('size', p.selectedSize) ||
                               v.hasAttributeValue('SIZE', p.selectedSize);
          final String? variantColorName = v.getAttributeValue('COLOR NAME');
          final bool colorMatch = variantColorName != null && 
                                normalize(variantColorName) == normalize(actualColorName);
          final bool materialMatch = p.selectedMaterial == null || 
                                   p.selectedMaterial!.isEmpty ||
                                   v.hasAttributeValue('MATERIAL NAME', p.selectedMaterial!) ||
                                   v.hasAttributeValue('material name', p.selectedMaterial!);
          final bool heightMatch = v.hasAttributeValue('HEIGHT', heightStr) ||
                                 v.hasAttributeValue('height', heightStr);
          
          if (sizeMatch && colorMatch && materialMatch && heightMatch) {
            final isInStock = v.inStock && (v.quantityAvailable == null || v.quantityAvailable! > 0);
            if (isInStock) {
              hasInStockVariant = true;
              break;
            }
          }
        }
        
        // If no in-stock variant exists for this heel height combination, don't allow selection
        if (!hasInStockVariant) {
          developer.log('⚠️ Cannot select heel height ${heightStr}cm: no in-stock variants for current selections');
          return;
        }
      }
      
      var updated = ProductDetails(
        id: p.id,
        brand: p.brand,
        name: p.name,
        description: p.description,
        price: p.price,
        originalPrice: p.originalPrice,
        rating: p.rating,
        reviewCount: p.reviewCount,
        images: p.images,
        colorOptions: p.colorOptions,
        sizeOptions: p.sizeOptions,
        variantAttributeOptions: p.variantAttributeOptions,
        selectedColor: p.selectedColor,
        selectedSize: p.selectedSize,
        isFavorite: p.isFavorite,
        hasDiscount: p.hasDiscount,
        discountPercentage: p.discountPercentage,
        features: p.features,
        material: p.material,
        materialsList: p.materialsList,
        materialOptions: p.materialOptions,
        selectedMaterial: p.selectedMaterial,
        careInstructions: p.careInstructions,
        heelHeightCm: event.heelHeightCm,
        heelType: p.heelType,
        heelHeightOptions: p.heelHeightOptions,
        selectedHeelHeightCm: event.heelHeightCm,
        isPlusMember: p.isPlusMember,
        pointsEarned: p.pointsEarned,
        optionalProducts: p.optionalProducts,
        accessoryProducts: p.accessoryProducts,
        alternativeProducts: p.alternativeProducts,
        variantCombinations: p.variantCombinations,
        primaryVariantLabel: p.primaryVariantLabel,
        tags: p.tags,
        variantImagesMap: p.variantImagesMap,
      );
      
      // Sync stock & quantity with the newly selected variant combination
      int nextQuantity = s.quantity;
      final VariantCombination? selectedVariant = _findSelectedVariant(updated);
      if (selectedVariant != null) {
        final double? quantityAvailable = selectedVariant.quantityAvailable;
        bool variantInStock = selectedVariant.inStock;

        if (quantityAvailable != null) {
          // Check if there's already an item in cart with this variant ID
          int existingCartQuantity = 0;
          final variantIdToCheck = selectedVariant.variantId;
          // Convert variantId to String for comparison (cart items use String IDs)
          final variantIdStr = variantIdToCheck.toString();
          if (cartBloc.state is CartLoaded) {
            final cartState = cartBloc.state as CartLoaded;
            try {
              final existingItem = cartState.cartItems.firstWhere(
                (item) => item.product.id.toString() == variantIdStr,
              );
              existingCartQuantity = existingItem.quantity;
            } catch (e) {
              // Item not found in cart, existingCartQuantity remains 0
            }
          }
          
          final maxAllowed = quantityAvailable.toInt();
          final available = maxAllowed - existingCartQuantity;
          
          if (maxAllowed <= 0 || available <= 0) {
            variantInStock = false;
            nextQuantity = 1;
          } else {
            // Clamp to available quantity (accounting for cart items)
            if (nextQuantity > available) {
              nextQuantity = available;
            }
            if (nextQuantity <= 0) {
              nextQuantity = 1;
            }
          }
          
          developer.log('👠 Heel height selected: ${event.heelHeightCm}cm, variantId=${selectedVariant.variantId}, totalAvailable=$maxAllowed, inCart=$existingCartQuantity, available=$available, adjustedQty=$nextQuantity');
        }

        updated = updated.copyWith(
          inStock: variantInStock,
          selectedVariantQuantityAvailable: selectedVariant.quantityAvailable?.toInt(),
        );
        if (updated.variantImagesMap.isNotEmpty) {
          updated = updated.withImagesForVariant(selectedVariant.variantId);
        }
      }
      
      emit(ProductDetailsLoaded(updated, quantity: nextQuantity, isAdding: false));
    }
  }

  Future<void> _onFilterVariantsByAttribute(
    FilterVariantsByAttributeEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    final blocState = state;
    if (blocState is! ProductDetailsLoaded) return;

    final currentProduct = blocState.productDetails;

    developer.log(
      '🧩 FilterVariantsByAttributeEvent: ${event.attributeName}="${event.attributeValue}"',
      name: 'ProductDetails/VariantFilter',
    );
    developer.log(
      '   Current selections: size="${currentProduct.selectedSize}", color="${currentProduct.selectedColor}", '
      'material="${currentProduct.selectedMaterial ?? ''}", height="${currentProduct.selectedHeelHeightCm?.toStringAsFixed(1) ?? ''}"',
      name: 'ProductDetails/VariantFilter',
    );
    developer.log(
      '   Variants: count=${currentProduct.variantCombinations.length}',
      name: 'ProductDetails/VariantFilter',
    );
    // Step 1: capture current selections and apply the new selection
    final Map<String, String> selectedByAttribute = {};
    for (final opt in currentProduct.variantAttributeOptions) {
      selectedByAttribute[opt.attributeName] = opt.selectedValue;
    }
    selectedByAttribute[event.attributeName] = event.attributeValue;
    developer.log(
      '   selectedByAttribute(after)=$selectedByAttribute',
      name: 'ProductDetails/VariantFilter',
    );

    // Step 2: compute availability per attribute value using variant_combinations
    // A value is available if there exists at least one variant that:
    //  - matches ALL currently selected attribute values (excluding the attribute we are evaluating if it differs)
    //  - and has this candidate value for the attribute being evaluated
    final List<VariantAttributeOption> recomputedOptions = [];
    for (final attrOption in currentProduct.variantAttributeOptions) {
      final String attributeName = attrOption.attributeName;

      // Debug: Log when checking Material availability
      final bool isMaterialAttr = attributeName.toLowerCase().contains('material');
      if (isMaterialAttr) {
        developer.log(
          '🔍 Checking Material availability for size="${selectedByAttribute[currentProduct.primaryVariantLabel] ?? selectedByAttribute['SIZE'] ?? 'none'}", '
          'color="${selectedByAttribute['COLOR NAME'] ?? selectedByAttribute['color'] ?? 'none'}"',
          name: 'ProductDetails/MaterialCheck',
        );
      }

      final List<VariantAttributeValue> newValues = attrOption.values.map((value) {
        bool isAvailable = false;
        int matchesTried = 0;
        int matchesStock = 0;

        for (final combo in currentProduct.variantCombinations) {
          bool matchesSelections = true;

          // CRITICAL FIX: Only require critical attributes (Size and Color) when checking availability
          // Optional attributes (Material, Height, Brand) should NOT block availability checks
          // This allows users to change sizes/colors even when other attributes are selected
          
          // Helper to check if an attribute is critical (Size or Color)
          bool isCriticalAttribute(String attrName) {
            final attrLower = attrName.toLowerCase();
            return attrLower == 'size' ||
                   attrLower == 'القياس' ||
                   attrLower == currentProduct.primaryVariantLabel.toLowerCase() ||
                   attrLower == 'color' ||
                   attrLower == 'colour' ||
                   attrLower == 'color name' ||
                   attrLower == 'اللون';
          }
          
          // First, check if the candidate value for this attribute matches
          final String? comboValForThisAttr = _getComboValueForAttribute(
            currentProduct,
            combo,
            attributeName,
          );
          if (comboValForThisAttr == null || 
              comboValForThisAttr.toLowerCase() != value.name.toLowerCase()) {
            matchesSelections = false;
            if (isMaterialAttr && matchesTried < 3) {
              developer.log(
                '   Material value "${value.name}": combo has "${comboValForThisAttr ?? 'null'}" for attr "$attributeName" → no match',
                name: 'ProductDetails/MaterialCheck',
              );
            }
          }
          
          // Then, only check critical attributes (Size and Color) if they are selected
          // CRITICAL: When checking availability for non-critical attributes (Material, Height),
          // we should NOT require other non-critical attributes to match. This allows users to
          // freely switch between materials/heights without disabling each other.
          // Only Size and Color are required to match.
          if (matchesSelections) {
            // Check if the attribute we're evaluating is non-critical
            final bool isEvaluatingNonCritical = !isCriticalAttribute(attributeName);
            
            for (final entry in selectedByAttribute.entries) {
              final String selAttr = entry.key;
              final String selValue = entry.value;

              // Skip if this is the attribute we're evaluating (already checked above)
              if (selAttr == attributeName) continue;
              
              // CRITICAL FIX: If we're evaluating a non-critical attribute (e.g., Material),
              // and another non-critical attribute is selected (e.g., Height), skip it.
              // This prevents Material from being disabled when Height is selected, and vice versa.
              // Only require critical attributes (Size, Color) to match.
              if (isEvaluatingNonCritical && !isCriticalAttribute(selAttr)) {
                continue; // Skip non-critical attributes when evaluating non-critical attributes
              }
              
              // Only check critical attributes (Size and Color) when evaluating critical attributes
              if (!isCriticalAttribute(selAttr)) continue;
              
              // When evaluating availability, allow trying the candidate value for this attribute
              final String mustMatchValue = selValue;
              final String? comboVal = _getComboValueForAttribute(
                currentProduct,
                combo,
                selAttr,
              );
              if (comboVal == null || comboVal.toLowerCase() != mustMatchValue.toLowerCase()) {
                matchesSelections = false;
                break;
              }
            }
          }

          // Check if variant is in stock
          final isInStock = _isVariantInStock(combo);
          if (matchesSelections) {
            matchesTried += 1;
            if (isInStock) {
              matchesStock += 1;
              isAvailable = true;
              if (isMaterialAttr) {
                developer.log(
                  '   ✅ Material value "${value.name}" is AVAILABLE (variantId=${combo.variantId}, matched=$matchesTried)',
                  name: 'ProductDetails/MaterialCheck',
                );
              }
              break;
            } else if (isMaterialAttr && matchesTried <= 2) {
              developer.log(
                '   ⚠️ Material value "${value.name}": variant matches but OUT OF STOCK (variantId=${combo.variantId})',
                name: 'ProductDetails/MaterialCheck',
              );
            }
          }
        }

        if (!isAvailable) {
          // Very useful signal when everything becomes disabled:
          // it tells us whether it's selection mismatch or stock mismatch.
          if (isMaterialAttr) {
            developer.log(
              '   🔻 Material value "${value.name}" DISABLED: matched=$matchesTried variants, inStockMatched=$matchesStock',
              name: 'ProductDetails/MaterialCheck',
            );
          } else {
            developer.log(
              '   🔻 Disabled value: attr="$attributeName" value="${value.name}" '
              '(matched=$matchesTried, inStockMatched=$matchesStock)',
              name: 'ProductDetails/VariantFilter',
            );
          }
        }

        // CRITICAL: Only mark as selected if it's available AND matches the selected value
        // Unavailable values should NEVER be selected
        final bool isSelected = isAvailable && 
                               selectedByAttribute[attributeName]?.toLowerCase() == value.name.toLowerCase();
        return VariantAttributeValue(
          id: value.id,
          name: value.name,
          isAvailable: isAvailable,
          isSelected: isSelected,
        );
      }).toList();

      // SAFETY NET: if all options for this attribute ended up disabled, relax the rule.
      // This prevents UX where tapping any option makes *everything* greyed out due to
      // minor data inconsistencies in the variant combinations (e.g. naming mismatch).
      final disabledCount = newValues.where((v) => !v.isAvailable).length;
      if (disabledCount == newValues.length) {
        developer.log(
          '⚠️ All values disabled for attribute "$attributeName" – relaxing availability (enabling all).',
          name: 'ProductDetails/VariantFilter',
        );
        final selectedValueForAttr =
            selectedByAttribute[attributeName]?.toLowerCase();
        for (var i = 0; i < newValues.length; i++) {
          final v = newValues[i];
          newValues[i] = VariantAttributeValue(
            id: v.id,
            name: v.name,
            isAvailable: true,
            // If user has a selected value for this attribute, reflect it visually.
            // Otherwise keep previous selection flag.
            isSelected: selectedValueForAttr != null &&
                    v.name.toLowerCase() == selectedValueForAttr
                ? true
                : v.isSelected,
          );
        }
      }

      // CRITICAL: For Material/Height/Brand, if only one option exists, ensure it's available and selected
      final attrNameLower = attributeName.toLowerCase();
      final bool isMaterialHeightOrBrand = attrNameLower == 'material' ||
                                           attrNameLower == 'material name' ||
                                           attrNameLower == 'height' ||
                                           attrNameLower == 'heel height' ||
                                           attrNameLower == 'brand';

      if (isMaterialHeightOrBrand && newValues.length == 1) {
        // Only one option exists - always make it available and selected
        final singleValue = newValues.first;
        if (!singleValue.isAvailable || !singleValue.isSelected) {
          newValues[0] = VariantAttributeValue(
            id: singleValue.id,
            name: singleValue.name,
            isAvailable: true, // Force available for single option
            isSelected: true, // Auto-select single option
          );
          developer.log('✅ Single option for ${attributeName}: "${singleValue.name}" - marked as available and selected');
        }
        // Update selectedValue to match the single option
        selectedByAttribute[attributeName] = singleValue.name;
      }

      recomputedOptions.add(VariantAttributeOption(
        attributeName: attributeName,
        values: newValues,
        selectedValue: selectedByAttribute[attributeName] ?? '',
      ));

      final disabledCountAfter = newValues.where((v) => !v.isAvailable).length;
      if (isMaterialAttr) {
        developer.log(
          '📊 Material summary: total=${newValues.length} enabled=${newValues.length - disabledCountAfter} disabled=$disabledCountAfter '
          'selected="${selectedByAttribute[attributeName] ?? ''}"',
          name: 'ProductDetails/MaterialCheck',
        );
      } else {
        developer.log(
          '   Attr "$attributeName": total=${newValues.length} enabled=${newValues.length - disabledCountAfter} disabled=$disabledCountAfter '
          'selected="${selectedByAttribute[attributeName] ?? ''}"',
          name: 'ProductDetails/VariantFilter',
        );
      }
    }

    // Step 3: update images if selection narrows to a specific variant (optional heuristic)
    List<String> filteredImages = currentProduct.images;
    // Try to find a unique matching, in-stock variant for the current selections
    final matching = currentProduct.variantCombinations.where((combo) {
      for (final entry in selectedByAttribute.entries) {
        final v = _getComboValueForAttribute(currentProduct, combo, entry.key);
        if (v == null || v.toLowerCase() != entry.value.toLowerCase()) return false;
      }
      return true;
    }).toList();

    if (matching.length == 1) {
      // Prefer the exact variant image when a unique variant is matched
      final only = matching.first;
      final variantImgPath = '/web/image/product.product/${only.variantId}/image_1920';
      filteredImages = ['${AppConstants.baseUrl}${variantImgPath.startsWith('/') ? variantImgPath.substring(1) : variantImgPath}'];
    }

    // Step 4: compute selectedSize/selectedColor from recomputed options
    // CRITICAL: When event is for HEIGHT/MATERIAL (non-size), preserve current size.
    // Otherwise size can wrongly change (e.g. 39→40) due to attribute ordering or
    // multiple attributes matching the size condition.
    String newSelectedSize = currentProduct.selectedSize;
    String newSelectedColor = currentProduct.selectedColor;
    final isSizeChangeEvent = event.attributeName.toLowerCase() == 'size' ||
        event.attributeName.toLowerCase() == currentProduct.primaryVariantLabel.toLowerCase() ||
        event.attributeName.toLowerCase().contains('size');

    for (final opt in recomputedOptions) {
      if (opt.attributeName.toLowerCase() == currentProduct.primaryVariantLabel.toLowerCase() ||
          opt.attributeName.toLowerCase() == 'size') {
        if (isSizeChangeEvent) {
          newSelectedSize = opt.selectedValue;
        }
        // When changing height/material: keep currentProduct.selectedSize unchanged
      }
      if (['color','colour','اللون','color name'].contains(opt.attributeName.toLowerCase())) {
        newSelectedColor = opt.selectedValue;
      }
    }

    // Step 5: update overall availability based on the *currently selected* combination.
    // If there is no variant that matches all selected attributes (size, color, etc.),
    // we must treat the current combination as out of stock even if other variants exist.
    bool newInStock;
    if (matching.isEmpty) {
      // No variant matches the current selection → this combination is out of stock.
      newInStock = false;
      developer.log(
        '📦 No matching variants for current selection (size="$newSelectedSize", color="$newSelectedColor"). '
        'Marking inStock = false for this combination.',
        name: 'ProductDetails/Stock',
      );
    } else {
      // At least one matching variant exists; consider it in stock only if any matching
      // variant is actually available according to _isVariantInStock (inStock flag + qty).
      final hasAvailable = matching.any(_isVariantInStock);
      newInStock = hasAvailable;
      developer.log(
        '📦 Found ${matching.length} matching variants for current selection '
        '(size="$newSelectedSize", color="$newSelectedColor"), '
        'availableMatches=$hasAvailable → inStock=$newInStock',
        name: 'ProductDetails/Stock',
      );
    }
    
    // Step 6: If size was changed, update color availability
    
    List<ColorOption> updatedColorOptions = currentProduct.colorOptions;
    final isSizeAttribute = event.attributeName.toLowerCase() == 'size' ||
                           event.attributeName.toLowerCase() == currentProduct.primaryVariantLabel.toLowerCase() ||
                           event.attributeName.toLowerCase().contains('size');
    
    if (isSizeAttribute && newSelectedSize.isNotEmpty) {
      developer.log('🔍 ========== UPDATING COLOR AVAILABILITY FOR SIZE ==========');
      developer.log('🔍 Selected size: "$newSelectedSize"');
      
      // Helper functions
      bool _containsArabic(String text) {
        if (text.isEmpty) return false;
        final arabicRegex = RegExp(r'[\u0600-\u06FF]');
        return arabicRegex.hasMatch(text);
      }
      
      String normalize(String s) => s.toLowerCase().trim();
      
      String? getVariantColorValue(VariantCombination v) {
        final colorAttrNames = ['COLOR NAME', 'color name', 'Color Name', 'color', 'Color', 'COLOR', 'colour', 'Colour', 'اللون', 'لون'];
        for (final attrName in colorAttrNames) {
          final value = v.getAttributeValue(attrName);
          if (value != null && value.isNotEmpty) {
            return value;
          }
        }
        return null;
      }
      
      // Get English name for selected size from variantAttributeOptions
      // CRITICAL: Must match SIZE attribute, not BRAND or other attributes
      String? selectedSizeEnglishName;
      for (final opt in recomputedOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        // Only match actual SIZE attributes, not BRAND or other attributes
        final isSizeAttribute = (attrNameLower == 'size' || 
                                attrNameLower == 'القياس' ||
                                (currentProduct.primaryVariantLabel.isNotEmpty && 
                                 attrNameLower == currentProduct.primaryVariantLabel.toLowerCase())) &&
                               attrNameLower != 'brand' &&
                               attrNameLower != 'العلامة التجارية';
        
        if (isSizeAttribute && opt.selectedValue.isNotEmpty) {
          selectedSizeEnglishName = opt.selectedValue; // Should be English from model
          developer.log('📏 Found size name from variantAttributeOptions: attribute="$attrNameLower", value="$selectedSizeEnglishName"');
          break;
        }
      }
      
      // If not found, try to extract from the event value directly
      if (selectedSizeEnglishName == null || selectedSizeEnglishName.isEmpty) {
        // The event.attributeValue should be the size name
        if (event.attributeValue.isNotEmpty && !_containsArabic(event.attributeValue)) {
          selectedSizeEnglishName = event.attributeValue;
          developer.log('📏 Using event.attributeValue as size: "$selectedSizeEnglishName"');
        } else {
          selectedSizeEnglishName = newSelectedSize;
          developer.log('📏 Fallback: Using newSelectedSize: "$selectedSizeEnglishName"');
        }
      }
      
      final String selectedSizeForMatching = selectedSizeEnglishName;
      developer.log('📏 Using size for matching: "$selectedSizeForMatching"');
      
      // Build color availability map for this size
      final Map<String, bool> colorAvailabilityMap = {};
      for (final v in currentProduct.variantCombinations) {
        // Check if variant matches the selected size
        bool primaryMatch = v.hasAttributeValue('SIZE', selectedSizeForMatching) ||
                           v.hasAttributeValue('size', selectedSizeForMatching) ||
                           v.hasAttributeValue('Size', selectedSizeForMatching);
        
        if (!primaryMatch && currentProduct.primaryVariantLabel.isNotEmpty) {
          primaryMatch = v.hasAttributeValue(currentProduct.primaryVariantLabel, selectedSizeForMatching);
        }
        
        if (!primaryMatch) {
          primaryMatch = v.hasAttributeValue('BRAND', selectedSizeForMatching) ||
                        v.hasAttributeValue('brand', selectedSizeForMatching) ||
                        v.hasAttributeValue('Brand', selectedSizeForMatching);
        }
        
        if (!primaryMatch) {
          for (final attr in v.attributes) {
            final attrName = attr.attributeName.toLowerCase();
            final attrValue = attr.valueName;
            final isSizeAttribute = attrName.contains('size') ||
                                   attrName == currentProduct.primaryVariantLabel.toLowerCase() ||
                                   attrName == 'brand' ||
                                   attrName == 'القياس';
            if (isSizeAttribute && normalize(attrValue) == normalize(selectedSizeForMatching)) {
              primaryMatch = true;
              break;
            }
          }
        }
        
        if (!primaryMatch) continue;
        
        final colorValue = getVariantColorValue(v);
        if (colorValue != null && colorValue.isNotEmpty) {
          final normalizedColor = normalize(colorValue);
          final isInStock = _isVariantInStock(v);
          
          if (!colorAvailabilityMap.containsKey(normalizedColor)) {
            colorAvailabilityMap[normalizedColor] = isInStock;
          } else if (isInStock) {
            colorAvailabilityMap[normalizedColor] = true;
          }
          
          // CRITICAL: Store by ColorOption ID (not variant value_id)
          // The variant has value_id (e.g., 5418), but ColorOption has id (e.g., 224)
          // We need to map the variant's color value name to ColorOption.id
          String? variantColorValueId;
          String? variantColorValueName;
          for (final attr in v.attributes) {
            final attrName = attr.attributeName.toLowerCase();
            if (attrName == 'color name' || attrName == 'color' || attrName == 'colour' || attrName == 'اللون') {
              variantColorValueId = attr.valueId;
              variantColorValueName = attr.valueName;
              break;
            }
          }
          
          // Find the ColorOption that matches this variant's color value
          if (variantColorValueName != null) {
            final normalizedVariantColorName = normalize(variantColorValueName);
            for (final colorOpt in currentProduct.colorOptions) {
              // Match by checking if variant color value name matches ColorOption's displayName or name
              final colorOptDisplayNormalized = colorOpt.displayName != null ? normalize(colorOpt.displayName!) : '';
              final colorOptNameNormalized = normalize(colorOpt.name);
              
              // If variant color value matches ColorOption displayName (Arabic) or name (English)
              if (normalizedVariantColorName == colorOptDisplayNormalized || 
                  normalizedVariantColorName == colorOptNameNormalized ||
                  (colorOpt.name.startsWith('COLOR_ID_') && colorOptDisplayNormalized == normalizedVariantColorName)) {
                // Use ColorOption.id (e.g., 224) not variant value_id (e.g., 5418)
                final colorIdKey = 'COLOR_ID_${colorOpt.id}';
                if (!colorAvailabilityMap.containsKey(colorIdKey)) {
                  colorAvailabilityMap[colorIdKey] = isInStock;
                } else if (isInStock) {
                  colorAvailabilityMap[colorIdKey] = true;
                }
                developer.log('🔍 Mapped variant color "$variantColorValueName" (variant_value_id=$variantColorValueId) to ColorOption ID ${colorOpt.id}');
                break;
              }
            }
            
            // Also store by variant's value_id as fallback (in case we can't match by name)
            if (variantColorValueId != null) {
              final variantColorIdKey = 'COLOR_ID_$variantColorValueId';
              if (!colorAvailabilityMap.containsKey(variantColorIdKey)) {
                colorAvailabilityMap[variantColorIdKey] = isInStock;
              } else if (isInStock) {
                colorAvailabilityMap[variantColorIdKey] = true;
              }
            }
          }
        }
      }
      
      developer.log('🔍 Color availability map for size "$selectedSizeForMatching": ${colorAvailabilityMap.entries.map((e) => '${e.key}:${e.value}').toList()}');
      
        // Update color options with availability
        updatedColorOptions = currentProduct.colorOptions.map((color) {
        String colorNameForMatching = color.name; // Use English name from ColorOption
        
        // If name is COLOR_ID_X, try to get from variantAttributeOptions
        if (colorNameForMatching.startsWith('COLOR_ID_')) {
          for (final opt in recomputedOptions) {
            final attrNameLower = opt.attributeName.toLowerCase();
            if (attrNameLower == 'color name' || attrNameLower == 'color' || attrNameLower == 'colour' || attrNameLower == 'اللون') {
              try {
                final matchedValue = opt.values.firstWhere((v) => v.id == color.id);
                if (!_containsArabic(matchedValue.name)) {
                  colorNameForMatching = matchedValue.name;
                  break;
                }
              } catch (e) {
                // ID not found, continue
              }
            }
          }
        }
        
        // Try multiple matching strategies (works for both English and Arabic)
        final normalizedColorName = normalize(colorNameForMatching);
        bool isAvailable = false;
        
        // Strategy 1: Direct name match (normalized)
        isAvailable = colorAvailabilityMap[normalizedColorName] ?? false;
        if (isAvailable) {
          developer.log('🎨 Color "${color.displayNameOrName}" (ID: ${color.id}): Found via direct name match "$normalizedColorName"');
        }
        
        // Strategy 2: ID-based matching for COLOR_ID_X (CRITICAL for Arabic)
        if (!isAvailable && color.name.startsWith('COLOR_ID_')) {
          isAvailable = colorAvailabilityMap[color.name] ?? false;
          if (isAvailable) {
            developer.log('🎨 Color "${color.displayNameOrName}" (ID: ${color.id}): Found via ID key "${color.name}"');
          }
        }
        
        // Strategy 3: Match by displayName (Arabic) if name is COLOR_ID_X
        if (!isAvailable && color.name.startsWith('COLOR_ID_') && color.displayName != null) {
          final normalizedDisplayName = normalize(color.displayName!);
          isAvailable = colorAvailabilityMap[normalizedDisplayName] ?? false;
          if (isAvailable) {
            developer.log('🎨 Color "${color.displayNameOrName}" (ID: ${color.id}): Found via displayName match "$normalizedDisplayName"');
          }
        }
        
        // Strategy 4: Flexible name matching (partial/contains)
        if (!isAvailable && colorAvailabilityMap.isNotEmpty) {
          for (final entry in colorAvailabilityMap.entries) {
            final normalizedMapColor = entry.key;
            // Skip ID-based keys for name matching (already tried above)
            if (normalizedMapColor.startsWith('COLOR_ID_')) continue;
            // Try exact match, partial match, or contains match
            if (normalizedColorName == normalizedMapColor ||
                normalizedColorName.contains(normalizedMapColor) ||
                normalizedMapColor.contains(normalizedColorName)) {
              isAvailable = entry.value;
              if (isAvailable) {
                developer.log('🎨 Color "${color.displayNameOrName}" (ID: ${color.id}): Found via flexible matching "$normalizedColorName" ~= "$normalizedMapColor"');
                break;
              }
            }
          }
        }
        
        // Strategy 5: Try matching displayName (Arabic) with variant color names
        if (!isAvailable && color.displayName != null) {
          final normalizedDisplayName = normalize(color.displayName!);
          for (final entry in colorAvailabilityMap.entries) {
            final normalizedMapColor = entry.key;
            if (normalizedMapColor.startsWith('COLOR_ID_')) continue;
            if (normalizedDisplayName == normalizedMapColor ||
                normalizedDisplayName.contains(normalizedMapColor) ||
                normalizedMapColor.contains(normalizedDisplayName)) {
              isAvailable = entry.value;
              if (isAvailable) {
                developer.log('🎨 Color "${color.displayNameOrName}" (ID: ${color.id}): Found via displayName flexible matching "$normalizedDisplayName" ~= "$normalizedMapColor"');
                break;
              }
            }
          }
        }
        
        // CRITICAL: Only mark as selected if it's available AND matches newSelectedColor
        // Unavailable colors should NEVER be selected
        final bool isSelected = isAvailable && 
                               newSelectedColor.isNotEmpty &&
                               normalize(colorNameForMatching) == normalize(newSelectedColor);
        
        return ColorOption(
          id: color.id,
          name: color.name,
          displayName: color.displayName,
          code: color.code,
          images: color.images,
          isSelected: isSelected, // CRITICAL: Only true if available AND matches newSelectedColor
          isAvailable: isAvailable,
        );
      }).toList();
      
      developer.log('🔍 Updated ${updatedColorOptions.length} color options for size "$selectedSizeForMatching"');
      
      // If current selected color is unavailable, find first available color
      if (newSelectedColor.isNotEmpty) {
        final normalizedCurrentColor = normalize(newSelectedColor);
        bool currentColorIsAvailable = false;
        for (final colorOpt in updatedColorOptions) {
          final colorNameFromOpt = colorOpt.name;
          if (normalize(colorNameFromOpt) == normalizedCurrentColor && colorOpt.isAvailable) {
            currentColorIsAvailable = true;
            break;
          }
        }
        
        if (!currentColorIsAvailable) {
          developer.log('⚠️ Current color "$newSelectedColor" is not available for size "$selectedSizeForMatching", finding first available color...');
          final firstAvailable = updatedColorOptions.firstWhere(
            (c) => c.isAvailable,
            orElse: () => updatedColorOptions.first,
          );
          if (firstAvailable.isAvailable) {
            // Get the English name for the first available color
            String? firstAvailableColorName = firstAvailable.name;
            if (firstAvailableColorName.startsWith('COLOR_ID_')) {
              // Try to get from variantAttributeOptions
              for (final opt in recomputedOptions) {
                final attrNameLower = opt.attributeName.toLowerCase();
                if (attrNameLower == 'color name' || attrNameLower == 'color' || attrNameLower == 'colour' || attrNameLower == 'اللون') {
                  try {
                    final matchedValue = opt.values.firstWhere((v) => v.id == firstAvailable.id);
                    firstAvailableColorName = matchedValue.name;
                    break;
                  } catch (e) {
                    // ID not found, continue
                  }
                }
              }
            }
            if (firstAvailableColorName != null && firstAvailableColorName.isNotEmpty) {
              newSelectedColor = firstAvailableColorName;
              developer.log('✅ Switched to first available color: "$newSelectedColor"');
            } else {
              newSelectedColor = '';
              developer.log('⚠️ Could not determine color name for first available color');
            }
          } else {
            newSelectedColor = ''; // No available colors
            developer.log('⚠️ No available colors found for size "$selectedSizeForMatching"');
          }
        }
      }
    }
    
    // Step 7: build updated product with new selections
    var updatedProduct = currentProduct.copyWith(
      variantAttributeOptions: recomputedOptions,
      colorOptions: updatedColorOptions,
      images: filteredImages,
      selectedSize: newSelectedSize,
      selectedColor: newSelectedColor,
      inStock: newInStock,
    );
    
    // Step 7: sync quantity & stock with the matched variant (if any)
    int nextQuantity = blocState.quantity;
    final VariantCombination? selectedVariant = _findSelectedVariant(updatedProduct);
    if (selectedVariant != null) {
      final double? quantityAvailable = selectedVariant.quantityAvailable;
      bool variantInStock = selectedVariant.inStock;
      
      if (quantityAvailable != null) {
        // Check if there's already an item in cart with this variant ID
        int existingCartQuantity = 0;
        final variantIdToCheck = selectedVariant.variantId;
        if (cartBloc.state is CartLoaded) {
          final cartState = cartBloc.state as CartLoaded;
          try {
            final existingItem = cartState.cartItems.firstWhere(
              (item) => item.product.id == variantIdToCheck,
            );
            existingCartQuantity = existingItem.quantity;
          } catch (e) {
            // Item not found in cart, existingCartQuantity remains 0
          }
        }
        
        final maxAllowed = quantityAvailable.toInt();
        final available = maxAllowed - existingCartQuantity;
        
        if (maxAllowed <= 0 || available <= 0) {
          // No stock for this combination
          variantInStock = false;
          nextQuantity = 1;
        } else {
          // Clamp to available quantity (accounting for cart items)
          if (nextQuantity > available) {
            nextQuantity = available;
          }
          if (nextQuantity <= 0) {
            nextQuantity = 1;
          }
        }
        
        developer.log('🔍 Filter variant: variantId=${selectedVariant.variantId}, totalAvailable=$maxAllowed, inCart=$existingCartQuantity, available=$available, adjustedQty=$nextQuantity');
      }
      
      updatedProduct = updatedProduct.copyWith(
        inStock: variantInStock,
        selectedVariantQuantityAvailable: selectedVariant.quantityAvailable?.toInt(),
      );
      if (updatedProduct.variantImagesMap.isNotEmpty) {
        updatedProduct = updatedProduct.withImagesForVariant(selectedVariant.variantId);
      }
    } else {
      updatedProduct = updatedProduct.copyWith(selectedVariantQuantityAvailable: null);
    }

    emit(ProductDetailsLoaded(updatedProduct, quantity: nextQuantity, isAdding: false));
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(ProductDetailsLoading());
    
    developer.log('🔄 ProductDetailsBloc: Loading product details');
    developer.log('  - Product ID: ${event.productId}');
    developer.log('  - Product Type: ${event.productType}');
    developer.log('  - Product ID Type: ${event.productId.runtimeType}');
    developer.log('  - Product Type Type: ${event.productType.runtimeType}');
    
    final result = await getProductDetails(event.productId, productType: event.productType);
    
    result.fold(
      (failure) => emit(ProductDetailsError(failure.message)),
      (productDetails) {
        developer.log('🔢 Setting initial quantity to 1 for product: ${productDetails.name}');
        
        // Helper to get color value from variant trying multiple attribute names
        String? getVariantColorValue(VariantCombination v) {
          final colorAttrNames = ['COLOR NAME', 'color name', 'Color Name', 'color', 'Color', 'COLOR', 'colour', 'Colour', 'اللون', 'لون'];
          for (final attrName in colorAttrNames) {
            final value = v.getAttributeValue(attrName);
            if (value != null && value.isNotEmpty) {
              return value;
            }
          }
          return null;
        }
        
        String normalize(String s) => s.toLowerCase().trim();
        
        // Update size options to reflect availability based on ALL variant combinations
        final updatedSizeOptions = productDetails.sizeOptions.map((size) {
          bool hasInStockVariant = false;
          
          for (final v in productDetails.variantCombinations) {
            final bool sizeMatch = v.hasAttributeValue(productDetails.primaryVariantLabel, size.name) ||
                                  v.hasAttributeValue('size', size.name) ||
                                  v.hasAttributeValue('SIZE', size.name);
            if (!sizeMatch) continue;
            
            // Check stock (treat null quantity as available when inStock=true)
            final isInStock = _isVariantInStock(v);
            if (isInStock) {
              hasInStockVariant = true;
              break;
            }
          }
          
          return SizeOption(
            id: size.id,
            name: size.name,
            isAvailable: hasInStockVariant,
            isRecommended: size.isRecommended,
            isSelected: size.isSelected,
          );
        }).toList();
        
        // Get initially selected size (if any)
        String? initialSelectedSize = productDetails.selectedSize;
        if (initialSelectedSize.isEmpty) {
          // Try to get from variantAttributeOptions
          for (final opt in productDetails.variantAttributeOptions) {
            final attrNameLower = opt.attributeName.toLowerCase();
            if ((attrNameLower == 'size' || 
                 attrNameLower == productDetails.primaryVariantLabel.toLowerCase()) &&
                opt.selectedValue.isNotEmpty) {
              initialSelectedSize = opt.selectedValue;
              break;
            }
          }
        }
        // Debug: log initial SIZE when entering product details screen
        developer.log('########### "${initialSelectedSize ?? ''}"',
            name: 'ProductDetails/InitialSize');
        
        // Align variantAttributeOptions (SIZE attribute) with the initial selected size
        final List<VariantAttributeOption> updatedVariantAttributeOptions =
            productDetails.variantAttributeOptions.map((opt) {
          final attrNameLower = opt.attributeName.toLowerCase();
          final bool isSizeAttribute =
              attrNameLower == 'size' ||
              attrNameLower == 'القياس' ||
              attrNameLower == productDetails.primaryVariantLabel.toLowerCase();

          // 1) For SIZE: align selection with initialSelectedSize from model
          if (isSizeAttribute &&
              initialSelectedSize != null &&
              initialSelectedSize.isNotEmpty) {
            final normalizedTarget = initialSelectedSize.toLowerCase().trim();
            final newValues = opt.values.map((v) {
              final isSelected =
                  v.name.toLowerCase().trim() == normalizedTarget;
              return VariantAttributeValue(
                id: v.id,
                name: v.name,
                isAvailable: v.isAvailable,
                isSelected: isSelected,
              );
            }).toList();

            return VariantAttributeOption(
              attributeName: opt.attributeName,
              values: newValues,
              selectedValue: initialSelectedSize,
            );
          }

          // 2) For non-color attributes with ONLY ONE option (e.g. MATERIAL, HEIGHT, BRAND):
          //    auto-select that single option by default.
          final bool isColorAttribute =
              attrNameLower == 'color' ||
              attrNameLower == 'colour' ||
              attrNameLower == 'color name' ||
              attrNameLower == 'اللون';

          if (!isColorAttribute && opt.values.length == 1) {
            final v = opt.values.first;
            final singleSelected = VariantAttributeValue(
              id: v.id,
              name: v.name,
              isAvailable: true,
              isSelected: true,
            );

            return VariantAttributeOption(
              attributeName: opt.attributeName,
              values: [singleSelected],
              selectedValue: v.name,
            );
          }

          // 3) Otherwise, keep as-is
          return opt;
        }).toList();
        
        // Update color options to reflect availability
        // If a size is selected, check availability for that size; otherwise check all variants
        List<ColorOption> updatedColorOptions = productDetails.colorOptions.map((color) {
          // Get the actual color name from variantAttributeOptions (for matching)
          String? colorNameForMatching;
          for (final opt in productDetails.variantAttributeOptions) {
            final attrNameLower = opt.attributeName.toLowerCase();
            if (attrNameLower == 'color name' || 
                attrNameLower == 'color' || 
                attrNameLower == 'colour' ||
                attrNameLower == 'اللون') {
              try {
                final matchedValue = opt.values.firstWhere(
                  (v) => v.id == color.id,
                );
                colorNameForMatching = matchedValue.name;
                break;
              } catch (e) {
                // ID not found, continue
              }
            }
          }
          if (colorNameForMatching == null || colorNameForMatching.isEmpty) {
            colorNameForMatching = color.name;
          }
          // Fallback for Arabic: use displayName when name is placeholder/empty
          if ((colorNameForMatching == null || colorNameForMatching.isEmpty || colorNameForMatching.startsWith('COLOR_ID_')) &&
              color.displayName != null && color.displayName!.isNotEmpty) {
            colorNameForMatching = color.displayName;
          }
          
          // Check if this color has any in-stock variants
          bool hasInStockVariant = false;
          final normalizedColorName = normalize(colorNameForMatching ?? '');
          // CRITICAL: Empty string causes "x".contains("") = true, incorrectly matching all variants (Arabic bug)
          final hasValidColorName = normalizedColorName.isNotEmpty;
          
          for (final v in productDetails.variantCombinations) {
            final variantColorName = getVariantColorValue(v);
            if (variantColorName == null) continue;
            
            final normalizedVariant = normalize(variantColorName);
            final colorMatch = hasValidColorName && normalizedVariant.isNotEmpty &&
                (normalizedVariant == normalizedColorName ||
                 (normalizedColorName.isNotEmpty && normalizedVariant.contains(normalizedColorName)) ||
                 (normalizedVariant.isNotEmpty && normalizedColorName.contains(normalizedVariant)));
            
            if (!colorMatch) continue;
            
            // If a size is selected, check if this variant matches that size
            if (initialSelectedSize != null && initialSelectedSize.isNotEmpty) {
              final bool sizeMatch = v.hasAttributeValue(productDetails.primaryVariantLabel, initialSelectedSize) ||
                                   v.hasAttributeValue('size', initialSelectedSize) ||
                                   v.hasAttributeValue('SIZE', initialSelectedSize);
              if (!sizeMatch) continue;
            }
            
            // Check stock (treat null quantity as available when inStock=true)
            final qty = v.quantityAvailable;
            final isInStock = _isVariantInStock(v);
            if (isInStock) {
              hasInStockVariant = true;
              break;
            }
          }
          
          developer.log('🎨 Initial load: Color "${color.displayNameOrName}" (${colorNameForMatching}) - Available: $hasInStockVariant${initialSelectedSize != null && initialSelectedSize.isNotEmpty ? " (for size $initialSelectedSize)" : ""}');
          
          return ColorOption(
            id: color.id,
            name: color.name,
            displayName: color.displayName,
            code: color.code,
            images: color.images,
            isSelected: color.isSelected,
            isAvailable: hasInStockVariant,
          );
        }).toList();

        // UX rule: when there is ONLY one color option, do not disable it.
        // Even if stock heuristics consider it unavailable, we always want
        // the single color to remain selectable and not visually greyed out.
        if (updatedColorOptions.length == 1) {
          final only = updatedColorOptions.first;
          updatedColorOptions = [
            ColorOption(
              id: only.id,
              name: only.name,
              displayName: only.displayName,
              code: only.code,
              images: only.images,
              // Force it to be both available and selected for better UX.
              isSelected: true,
              isAvailable: true,
            ),
          ];
          developer.log(
            '🎨 Single color detected on initial load → forcing available & selected: "${only.displayNameOrName}"',
            name: 'ProductDetails/ColorOptions',
          );
        }
        
        // Derive defaults for Material and Height when there is only ONE option
        String? initialSelectedMaterial = productDetails.selectedMaterial;
        double? initialSelectedHeelHeight = productDetails.selectedHeelHeightCm;

        for (final opt in updatedVariantAttributeOptions) {
          final attrNameLower = opt.attributeName.toLowerCase();

          // MATERIAL NAME / MATERIAL
          final bool isMaterialAttribute =
              attrNameLower == 'material' ||
              attrNameLower == 'material name';
          if (isMaterialAttribute &&
              opt.values.length == 1 &&
              (initialSelectedMaterial == null ||
                  initialSelectedMaterial.isEmpty)) {
            initialSelectedMaterial = opt.values.first.name;
          }

          // HEIGHT / HEEL HEIGHT (value is usually like "7cm")
          final bool isHeightAttribute =
              attrNameLower == 'height' || attrNameLower == 'heel height';
          if (isHeightAttribute &&
              opt.values.length == 1 &&
              initialSelectedHeelHeight == null) {
            final raw = opt.values.first.name;
            final numeric = double.tryParse(
              raw.replaceAll(RegExp('[^0-9\\.]'), ''),
            );
            if (numeric != null) {
              initialSelectedHeelHeight = numeric;
            }
          }
        }
        
        // Sync stock & quantity with the initially selected variant combination
        var updatedProduct = productDetails.copyWith(
          sizeOptions: updatedSizeOptions,
          colorOptions: updatedColorOptions,
          variantAttributeOptions: updatedVariantAttributeOptions,
          selectedSize: initialSelectedSize ?? productDetails.selectedSize,
          selectedMaterial:
              initialSelectedMaterial ?? productDetails.selectedMaterial,
          selectedHeelHeightCm:
              initialSelectedHeelHeight ?? productDetails.selectedHeelHeightCm,
        );
        // Debug: ensure initial model size and BLoC selected size/material/height are aligned
        developer.log(
          '########### "${initialSelectedSize ?? ''}", initial selected size :"${updatedProduct.selectedSize}", '
          'material :"${updatedProduct.selectedMaterial}", heelHeight :"${updatedProduct.selectedHeelHeightCm}"',
          name: 'ProductDetails/InitialSelections',
        );
        int initialQuantity = 1;
        
        final VariantCombination? selectedVariant = _findSelectedVariant(updatedProduct);
        if (selectedVariant != null) {
          final double? quantityAvailable = selectedVariant.quantityAvailable;
          bool variantInStock = selectedVariant.inStock;
          
          developer.log('📦 Initial variant: variantId=${selectedVariant.variantId}, inStock=$variantInStock, quantityAvailable=$quantityAvailable');
          
          // Check stock: if quantity is known, require > 0. If unknown (null), rely on inStock flag.
          final qty = quantityAvailable;
          if (qty != null) {
            variantInStock = variantInStock && qty > 0;
          }
          
          if (qty != null && qty > 0) {
            final int maxAllowed = qty.toInt();
            // Ensure initial quantity doesn't exceed available stock
            initialQuantity = initialQuantity > maxAllowed ? maxAllowed : initialQuantity;
            if (initialQuantity <= 0) {
              initialQuantity = 1;
            }
          } else {
            initialQuantity = 1;
          }
          
          updatedProduct = updatedProduct.copyWith(
            inStock: variantInStock,
            selectedVariantQuantityAvailable: selectedVariant.quantityAvailable?.toInt(),
          );
          if (updatedProduct.variantImagesMap.isNotEmpty) {
            updatedProduct = updatedProduct.withImagesForVariant(selectedVariant.variantId);
          }
        }
        
        emit(ProductDetailsLoaded(updatedProduct, quantity: initialQuantity, isAdding: false));
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state is ProductDetailsLoaded) {
      final currentState = state as ProductDetailsLoaded;
      final currentProduct = currentState.productDetails;
      
      // Optimistically update UI
      final updatedProduct = ProductDetails(
        id: currentProduct.id,
        brand: currentProduct.brand,
        name: currentProduct.name,
        description: currentProduct.description,
        price: currentProduct.price,
        originalPrice: currentProduct.originalPrice,
        rating: currentProduct.rating,
        reviewCount: currentProduct.reviewCount,
        images: currentProduct.images,
        colorOptions: currentProduct.colorOptions,
        sizeOptions: currentProduct.sizeOptions,
        variantAttributeOptions: currentProduct.variantAttributeOptions,
        selectedColor: currentProduct.selectedColor,
        selectedSize: currentProduct.selectedSize,
        isFavorite: !currentProduct.isFavorite,
        hasDiscount: currentProduct.hasDiscount,
        discountPercentage: currentProduct.discountPercentage,
        features: currentProduct.features,
        material: currentProduct.material,
        materialsList: currentProduct.materialsList,
        materialOptions: currentProduct.materialOptions,
        selectedMaterial: currentProduct.selectedMaterial,
        careInstructions: currentProduct.careInstructions,
        heelHeightCm: currentProduct.heelHeightCm,
        heelType: currentProduct.heelType,
        heelHeightOptions: currentProduct.heelHeightOptions,
        selectedHeelHeightCm: currentProduct.selectedHeelHeightCm,
        isPlusMember: currentProduct.isPlusMember,
        pointsEarned: currentProduct.pointsEarned,
        optionalProducts: currentProduct.optionalProducts,
        accessoryProducts: currentProduct.accessoryProducts,
        alternativeProducts: currentProduct.alternativeProducts,
        variantCombinations: currentProduct.variantCombinations,
        primaryVariantLabel: currentProduct.primaryVariantLabel,
        tags: currentProduct.tags,
      );
      
      emit(ProductDetailsLoaded(updatedProduct, quantity: currentState.quantity, isAdding: currentState.isAdding));
      
      final result = await toggleFavorite(event.productId);
      result.fold(
        (failure) {
          // Revert on failure
          emit(ProductDetailsLoaded(currentProduct, quantity: currentState.quantity, isAdding: currentState.isAdding));
          emit(ProductDetailsError(failure.message));
        },
        (_) => emit(ProductDetailsLoaded(updatedProduct, quantity: currentState.quantity, isAdding: currentState.isAdding)),
      );
    }
  }

  Future<void> _onSelectColor(
    SelectColorEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    if (state is ProductDetailsLoaded) {
      final currentState = state as ProductDetailsLoaded;
      final currentProduct = currentState.productDetails;
      
      // Find the selected color option from colorOptions (for display purposes)
      final selectedColorOption = currentProduct.colorOptions.firstWhere(
        (color) => color.id == event.colorId,
        orElse: () => currentProduct.colorOptions.first,
      );
      
      // CRITICAL: Always use English names for matching (same logic for Arabic & English).
      // Root cause of English-only bugs: ColorOption.name can be "COLOR_ID_XXX" when API
      // doesn't fill it for English; id comparison can fail (string vs number). Fix: build
      // colorId→EnglishName from variantAttributeOptions once with robust id keys and use it first.
      String? actualColorName;

      bool containsArabic(String text) {
        if (text.isEmpty) return false;
        final arabicRegex = RegExp(r'[\u0600-\u06FF]');
        return arabicRegex.hasMatch(text);
      }

      String? getVariantColorValue(VariantCombination v) {
        const colorAttrNames = ['COLOR NAME', 'color name', 'Color Name', 'color', 'Color', 'COLOR', 'colour', 'Colour', 'اللون', 'لون'];
        for (final attrName in colorAttrNames) {
          final value = v.getAttributeValue(attrName);
          if (value != null && value.isNotEmpty) return value;
        }
        return null;
      }

      // ZERO (permanent fix): Build colorId→English name from variantAttributeOptions with robust id keys.
      // Works for both languages; avoids wrong "first" color when English API sends placeholder names.
      final Map<String, String> colorIdToEnglishName = {};
      for (final opt in currentProduct.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if (attrNameLower != 'color name' && attrNameLower != 'color' && attrNameLower != 'colour' && attrNameLower != 'اللون') continue;
        for (final val in opt.values) {
          final idStr = val.id.toString().trim();
          if (idStr.isEmpty) continue;
          if (!containsArabic(val.name) && val.name.trim().isNotEmpty) {
            colorIdToEnglishName[idStr] = val.name.trim();
          }
        }
        break;
      }
      actualColorName = colorIdToEnglishName[event.colorId] ?? colorIdToEnglishName[event.colorId.toString().trim()];
      if (actualColorName != null && actualColorName.isNotEmpty) {
        developer.log('✅ Using colorId→name from variantAttributeOptions (locale-agnostic): "$actualColorName" for colorId=${event.colorId}');
      }

      // PRIMARY: ColorOption.name when not placeholder (e.g. English API sometimes fills it)
      if ((actualColorName == null || actualColorName.isEmpty) && selectedColorOption.name.isNotEmpty && !containsArabic(selectedColorOption.name) && !selectedColorOption.name.startsWith('COLOR_ID_')) {
        actualColorName = selectedColorOption.name;
        developer.log('✅ Using ColorOption.name: "$actualColorName" for color ID ${event.colorId}');
      }

      // SECONDARY: Single-value lookup from variantAttributeOptions (keep for compatibility)
      if (actualColorName == null || actualColorName.isEmpty) {
        VariantAttributeOption? colorAttrOption;
        for (final opt in currentProduct.variantAttributeOptions) {
          final attrNameLower = opt.attributeName.toLowerCase();
          if (attrNameLower == 'color name' || attrNameLower == 'color' || attrNameLower == 'colour' || attrNameLower == 'اللون') {
            colorAttrOption = opt;
            break;
          }
        }
        if (colorAttrOption != null) {
          try {
            final matchedValue = colorAttrOption.values.firstWhere(
              (v) => v.id.toString().trim() == event.colorId.toString().trim(),
            );
            if (!containsArabic(matchedValue.name) && matchedValue.name.isNotEmpty) {
              actualColorName = matchedValue.name;
              developer.log('✅ Using variantAttributeOptions (secondary): "$actualColorName" for color ID ${event.colorId}');
            }
          } catch (_) {}
        }
      }

      // TERTIARY: From variant combinations – match display name to variant color, or use colorId map (no .first)
      if (actualColorName == null || actualColorName.isEmpty || containsArabic(actualColorName)) {
        final Set<String> uniqueEnglishColorNames = {};
        for (final v in currentProduct.variantCombinations) {
          final String? variantColorName = getVariantColorValue(v);
          if (variantColorName != null && variantColorName.isNotEmpty && !containsArabic(variantColorName)) {
            uniqueEnglishColorNames.add(variantColorName);
          }
        }
        if (uniqueEnglishColorNames.isNotEmpty) {
          String? matchedEnglishName;
          final displayNorm = selectedColorOption.displayNameOrName.toLowerCase().trim();
          final isPlaceholder = selectedColorOption.name.startsWith('COLOR_ID_') || displayNorm.isEmpty;
          if (!isPlaceholder) {
            for (final v in currentProduct.variantCombinations) {
              final String? variantColorName = getVariantColorValue(v);
              if (variantColorName == null || variantColorName.isEmpty) continue;
              final vNorm = variantColorName.toLowerCase().trim();
              if (vNorm == displayNorm || vNorm.contains(displayNorm) || displayNorm.contains(vNorm)) {
                matchedEnglishName = variantColorName;
                developer.log('✅ Matched display to variant color: "$matchedEnglishName"');
                break;
              }
            }
          }
          // When display is placeholder or no match, use colorId map (same source as ZERO) – never .first
          if (matchedEnglishName == null) {
            matchedEnglishName = colorIdToEnglishName[event.colorId] ?? colorIdToEnglishName[event.colorId.toString().trim()];
          }
          if (matchedEnglishName == null && uniqueEnglishColorNames.length == 1) {
            matchedEnglishName = uniqueEnglishColorNames.first;
          } else if (matchedEnglishName == null) {
            matchedEnglishName = uniqueEnglishColorNames.first;
            developer.log('⚠️ Fallback to first English color (no id match): "$matchedEnglishName"');
          }
          actualColorName = matchedEnglishName;
        }
      }
      
      // Ensure we have a real English name for variant/image matching (never leave as placeholder).
      if (actualColorName == null || actualColorName.isEmpty || actualColorName.startsWith('COLOR_ID_')) {
        final fromMap = colorIdToEnglishName[event.colorId] ?? colorIdToEnglishName[event.colorId.toString().trim()];
        final fallback = selectedColorOption.name.isNotEmpty && !selectedColorOption.name.startsWith('COLOR_ID_')
            ? selectedColorOption.name
            : selectedColorOption.displayNameOrName;
        actualColorName = fromMap ?? fallback;
        if (fromMap != null) {
          developer.log('✅ Using colorId map for final name (no placeholder): "$actualColorName"');
        } else {
          developer.log('⚠️ Fallback name for color ID ${event.colorId}: "$actualColorName"');
        }
      }
      if (actualColorName != null && containsArabic(actualColorName)) {
        // If still Arabic, keep it but log a warning – we still allow selection for UX.
        developer.log(
          '⚠️ actualColorName appears to be Arabic: "$actualColorName". '
          'Proceeding anyway so selection works; matching may be approximate.',
        );
      }
      
      developer.log(
        '✅ Final color name for matching/selection: "$actualColorName" '
        '(ID: ${event.colorId}, Display: "${selectedColorOption.displayNameOrName}")',
      );
      
      final String colorNameForMatching = actualColorName;
      
      // Get the actual SIZE value from variantAttributeOptions
      // CRITICAL: variantAttributeOptions always uses English names for matching
      String? actualSize;
      for (final opt in currentProduct.variantAttributeOptions) {
        final attrNameUpper = opt.attributeName.toUpperCase();
        if ((attrNameUpper == 'SIZE' || 
             attrNameUpper.contains('SIZE') ||
             opt.attributeName.toLowerCase() == currentProduct.primaryVariantLabel.toLowerCase()) && 
            opt.selectedValue.isNotEmpty) {
          // variantAttributeOptions.selectedValue is always English (per model parsing)
          actualSize = opt.selectedValue;
          break;
        }
      }
      // Fallback: check if selectedSize is actually a size (numeric or English name)
      if (actualSize == null && currentProduct.selectedSize.isNotEmpty) {
        final sizeValue = currentProduct.selectedSize;
        // If it's numeric, it's likely English (sizes are usually numbers)
        // If it contains Arabic, try to find English equivalent from sizeOptions
        if (RegExp(r'^\d+').hasMatch(sizeValue)) {
          actualSize = sizeValue;
        } else if (containsArabic(sizeValue)) {
          // Try to find English name from sizeOptions
          for (final sizeOpt in currentProduct.sizeOptions) {
            // SizeOption.name should be English (it's used for matching)
            if (sizeOpt.name == sizeValue || sizeOpt.name.contains(sizeValue) || sizeValue.contains(sizeOpt.name)) {
              actualSize = sizeOpt.name;
              break;
            }
          }
        } else {
          // Already English
          actualSize = sizeValue;
        }
      }
      
      // Check if this color has any in-stock variants using the actual color name
      // Match using multiple possible attribute names (COLOR NAME, color, colour, اللون)
      bool hasInStockVariant = false;
      String normalize(String s) => s.toLowerCase().trim();
      
      if (actualSize != null && actualSize.isNotEmpty) {
        // Size is selected - check if this color has stock with this size
        // CRITICAL: Make size matching flexible - check multiple attribute names and use case-insensitive matching
        for (final v in currentProduct.variantCombinations) {
          // Try multiple ways to match size
          bool sizeMatch = false;
          
          // Check standard SIZE attribute
          sizeMatch = v.hasAttributeValue('SIZE', actualSize) ||
                     v.hasAttributeValue('size', actualSize) ||
                     v.hasAttributeValue('Size', actualSize);
          
          // Check primaryVariantLabel (e.g., "BRAND" for some products)
          if (!sizeMatch && currentProduct.primaryVariantLabel.isNotEmpty) {
            sizeMatch = v.hasAttributeValue(currentProduct.primaryVariantLabel, actualSize);
          }
          
          // Also check BRAND attribute (some products use brand as primary variant, e.g., "BEIRA RIO")
          if (!sizeMatch) {
            sizeMatch = v.hasAttributeValue('BRAND', actualSize) ||
                       v.hasAttributeValue('brand', actualSize) ||
                       v.hasAttributeValue('Brand', actualSize);
          }
          
          // Also try case-insensitive matching by checking all attributes
          if (!sizeMatch) {
            // Get all attribute values and check if any match (case-insensitive)
            for (final attr in v.attributes) {
              final attrName = attr.attributeName.toLowerCase();
              final attrValue = attr.valueName;
              
              // Check if this attribute is a size-related attribute
              final isSizeAttribute = attrName.contains('size') ||
                                     attrName == currentProduct.primaryVariantLabel.toLowerCase() ||
                                     attrName == 'brand' || // Some products use BRAND as primary variant
                                     attrName == 'القياس';
              
              if (isSizeAttribute && normalize(attrValue) == normalize(actualSize)) {
                sizeMatch = true;
                developer.log('🔍 Size match found via flexible matching: attribute="$attrName", value="$attrValue" == "$actualSize"');
                break;
              }
            }
          }
          
          // Try multiple attribute name variations to find color
          final String? variantColorName = getVariantColorValue(v);
          bool colorMatch = false;
          if (variantColorName != null) {
            final normalizedVariant = normalize(variantColorName);
            final normalizedMatching = normalize(colorNameForMatching);
            // Exact match
            colorMatch = normalizedVariant == normalizedMatching;
            // If no exact match, try partial match (for cases like "بحري/بحري" vs "بحري")
            if (!colorMatch) {
              colorMatch = normalizedVariant.contains(normalizedMatching) || 
                          normalizedMatching.contains(normalizedVariant);
            }
          }
          
          if (colorMatch && !sizeMatch) {
            developer.log('🔍 Color matches but size does not: variantColorName="$variantColorName", actualSize="$actualSize"');
            // Log variant attributes for debugging
            final sizeAttrs = v.attributes.where((attr) {
              final attrName = attr.attributeName.toLowerCase();
              return attrName.contains('size') || 
                     attrName == currentProduct.primaryVariantLabel.toLowerCase() ||
                     attrName == 'brand' ||
                     attrName == 'القياس';
            }).map((attr) => '${attr.attributeName}: ${attr.valueName}').toList();
            developer.log('   Variant size attributes: $sizeAttrs');
          }
          
          if (sizeMatch && colorMatch) {
            // Check stock (treat null quantity as available when inStock=true)
            final qty = v.quantityAvailable;
            final isInStock = _isVariantInStock(v);
            developer.log('🔍 Checking variant: sizeMatch=$sizeMatch, colorMatch=$colorMatch, inStock=${v.inStock}, qty=$qty, available=$isInStock');
            if (isInStock) {
              hasInStockVariant = true;
              developer.log('✅ Found in-stock variant for color $colorNameForMatching with size/primary="$actualSize"');
              break;
            } else {
              developer.log('⚠️ Variant found but out of stock: inStock=${v.inStock}, qty=$qty');
            }
          }
        }
        
        // If size is selected but no in-stock variant exists for this color,
        // we still allow selection for better UX (user can see images / details),
        // but we log a warning for diagnostics.
        if (!hasInStockVariant) {
          developer.log(
            '⚠️ No in-stock variants for color $colorNameForMatching (display: ${selectedColorOption.displayNameOrName}) with size $actualSize. '
            'Proceeding with selection but product may be effectively out of stock for this combination.',
          );
        }
      } else {
        // No size selected - check if color has any in-stock variants (will adjust size later)
        for (final v in currentProduct.variantCombinations) {
          final String? variantColorName = getVariantColorValue(v);
          bool colorMatch = false;
          if (variantColorName != null) {
            final normalizedVariant = normalize(variantColorName);
            final normalizedMatching = normalize(colorNameForMatching);
            // Exact match
            colorMatch = normalizedVariant == normalizedMatching;
            // If no exact match, try partial match (for cases like "بحري/بحري" vs "بحري")
            if (!colorMatch) {
              colorMatch = normalizedVariant.contains(normalizedMatching) || 
                          normalizedMatching.contains(normalizedVariant);
            }
          }
          
          if (colorMatch) {
            developer.log('🔍 Found color match (no size): variantColorName="$variantColorName" == colorNameForMatching="$colorNameForMatching"');
            // Check stock: must have quantity_available > 0 AND in_stock = true
            final qty = v.quantityAvailable ?? 0.0;
            final isInStock = v.inStock && qty > 0;
            developer.log('🔍 Checking variant: colorMatch=$colorMatch, inStock=${v.inStock}, qty=$qty, available=$isInStock');
            if (isInStock) {
              hasInStockVariant = true;
              developer.log('✅ Found in-stock variant for color $colorNameForMatching');
              break;
            }
          } else if (variantColorName != null) {
            developer.log('🔍 Color mismatch (no size): variantColorName="$variantColorName" != colorNameForMatching="$colorNameForMatching"');
          }
        }
        
        // If no in-stock variant exists for this color at all, still allow selection
        // so the user can view the color, but log a warning.
        if (!hasInStockVariant) {
          developer.log(
            '⚠️ No in-stock variants for color $colorNameForMatching (display: ${selectedColorOption.displayNameOrName}) with any size. '
            'Proceeding with selection but product may be effectively out of stock for this color.',
          );
        }
      }
      
      // CRITICAL: Recalculate color availability based on currently selected size
      // When color changes, we need to check if each color is available for the selected size
      List<ColorOption> updatedColorOptions = currentProduct.colorOptions.map((color) {
        // Get the English color name for matching
        String? colorNameForMatching;
        for (final opt in currentProduct.variantAttributeOptions) {
          final attrNameLower = opt.attributeName.toLowerCase();
          if (attrNameLower == 'color name' || 
              attrNameLower == 'color' || 
              attrNameLower == 'colour' ||
              attrNameLower == 'اللون') {
            try {
              final matchedValue = opt.values.firstWhere(
                (v) => v.id == color.id,
              );
              if (!containsArabic(matchedValue.name)) {
                colorNameForMatching = matchedValue.name;
                break;
              }
            } catch (e) {
              // ID not found, continue
            }
          }
        }
        if (colorNameForMatching == null || colorNameForMatching.isEmpty) {
          colorNameForMatching = color.name;
        }
        // Fallback for Arabic: use displayName when name is placeholder/empty
        if ((colorNameForMatching == null || colorNameForMatching.isEmpty || colorNameForMatching.startsWith('COLOR_ID_')) &&
            color.displayName != null && color.displayName!.isNotEmpty) {
          colorNameForMatching = color.displayName;
        }
        
        final normalizedColor = normalize(colorNameForMatching ?? '');
        // CRITICAL: Empty string causes "x".contains("") = true, incorrectly matching all variants (Arabic bug)
        final hasValidColorName = normalizedColor.isNotEmpty;
        
        // Check if this color is available for the currently selected size
        bool hasInStockVariant = false;
        if (actualSize != null && actualSize.isNotEmpty) {
          // Size is selected - check if this color has stock with this size
          for (final v in currentProduct.variantCombinations) {
            final bool sizeMatch = v.hasAttributeValue('SIZE', actualSize) ||
                                 v.hasAttributeValue('size', actualSize) ||
                                 v.hasAttributeValue(currentProduct.primaryVariantLabel, actualSize);
            if (!sizeMatch) continue;
            
            final variantColorName = getVariantColorValue(v);
            if (variantColorName == null) continue;
            
            final normalizedVariant = normalize(variantColorName);
            
            final bool colorMatch = hasValidColorName && normalizedVariant.isNotEmpty &&
                (normalizedVariant == normalizedColor ||
                 (normalizedColor.isNotEmpty && normalizedVariant.contains(normalizedColor)) ||
                 (normalizedVariant.isNotEmpty && normalizedColor.contains(normalizedVariant)));
            
            if (colorMatch) {
              final isInStock = _isVariantInStock(v);
              if (isInStock) {
                hasInStockVariant = true;
                break;
              }
            }
          }
        } else {
          // No size selected - check if color has any in-stock variants
          for (final v in currentProduct.variantCombinations) {
            final variantColorName = getVariantColorValue(v);
            if (variantColorName == null) continue;
            
            final normalizedVariant = normalize(variantColorName);
            
            final bool colorMatch = hasValidColorName && normalizedVariant.isNotEmpty &&
                (normalizedVariant == normalizedColor ||
                 (normalizedColor.isNotEmpty && normalizedVariant.contains(normalizedColor)) ||
                 (normalizedVariant.isNotEmpty && normalizedColor.contains(normalizedVariant)));
            
            if (colorMatch) {
              final isInStock = _isVariantInStock(v);
              if (isInStock) {
                hasInStockVariant = true;
                break;
              }
            }
          }
        }
        
        return ColorOption(
          id: color.id,
          name: color.name,
          displayName: color.displayName,
          code: color.code,
          images: color.images,
          isSelected: color.id == event.colorId,
          isAvailable: hasInStockVariant, // Recalculate based on selected size
        );
      }).toList();

      // CRITICAL: Recompute ALL variant attribute options based on selected color
      // This ensures all attributes (size, material, heel height, etc.) are properly
      // enabled/disabled based on what's available for the selected color
      final Map<String, String> selectedByAttribute = {};
      
      // Build current selections map (preserve existing selections except color)
      for (final opt in currentProduct.variantAttributeOptions) {
        if (opt.selectedValue.isNotEmpty) {
          final attrNameLower = opt.attributeName.toLowerCase();
          // Skip color attributes - we'll set the new color below
          if (attrNameLower != 'color name' && 
              attrNameLower != 'color' && 
              attrNameLower != 'colour' &&
              attrNameLower != 'اللون') {
            selectedByAttribute[opt.attributeName] = opt.selectedValue;
          }
        }
      }
      
      // Add selected material and heel height if they exist
      if (currentProduct.selectedMaterial != null && currentProduct.selectedMaterial!.isNotEmpty) {
        selectedByAttribute['MATERIAL NAME'] = currentProduct.selectedMaterial!;
        selectedByAttribute['material name'] = currentProduct.selectedMaterial!;
      }
      if (currentProduct.selectedHeelHeightCm != null) {
        final heightStr = currentProduct.selectedHeelHeightCm!.toStringAsFixed(1);
        selectedByAttribute['HEIGHT'] = heightStr;
        selectedByAttribute['height'] = heightStr;
      }
      
      // Update color selection in the map
      for (final opt in currentProduct.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if (attrNameLower == 'color name' || 
            attrNameLower == 'color' || 
            attrNameLower == 'colour' ||
            attrNameLower == 'اللون') {
          selectedByAttribute[opt.attributeName] = colorNameForMatching;
          // Also add common variations
          selectedByAttribute['COLOR NAME'] = colorNameForMatching;
          selectedByAttribute['color name'] = colorNameForMatching;
          selectedByAttribute['color'] = colorNameForMatching;
          selectedByAttribute['colour'] = colorNameForMatching;
          selectedByAttribute['اللون'] = colorNameForMatching;
          break;
        }
      }
      
      // Recompute availability for ALL variant attribute options
      // CRITICAL: Only require matching on attributes that actually vary (color, size)
      // Don't require matching on attributes that are the same for all variants (material, height, brand)
      final List<VariantAttributeOption> recomputedOptions = [];
      for (final attrOption in currentProduct.variantAttributeOptions) {
        final String attributeName = attrOption.attributeName;
        final attrNameLower = attributeName.toLowerCase();

        List<VariantAttributeValue> newValues = attrOption.values.map((value) {
          bool isAvailable = false;

          // Check if this value is available in any variant combination
          // CRITICAL: Height availability must respect selected color+size - only enable
          // a height option if there exists an in-stock variant for (color, size, height).
          // This prevents incorrectly enabling e.g. "4.5" when selecting a color that has
          // no in-stock variants for that height.
          for (final combo in currentProduct.variantCombinations) {
            bool matchesRequiredAttributes = true;

            // For Height: require variant to match selected color + size AND be in stock
            // Use flexible color matching (Black/BLACK, contains) to avoid false mismatches
            final bool isHeightAttr = attrNameLower == 'height' || attrNameLower == 'heel height';
            if (isHeightAttr && colorNameForMatching.isNotEmpty && currentProduct.selectedSize.isNotEmpty) {
              final variantColor = getVariantColorValue(combo);
              final variantSize = _getComboValueForAttribute(
                currentProduct, combo, currentProduct.primaryVariantLabel,
              ) ?? combo.getAttributeValue('SIZE') ?? combo.getAttributeValue('size');
              final nvc = variantColor != null ? normalize(variantColor) : '';
              final ncm = normalize(colorNameForMatching);
              final colorMatch = variantColor != null && (nvc == ncm || nvc.contains(ncm) || ncm.contains(nvc));
              final sizeMatch = variantSize != null &&
                  normalize(variantSize) == normalize(currentProduct.selectedSize);
              if (!colorMatch || !sizeMatch || !_isVariantInStock(combo)) {
                continue; // Skip - variant doesn't match selection or is out of stock
              }
            }

            // CRITICAL FIX: Size availability should NOT be restricted by selected color.
            // Sizes should be available if they exist in ANY color variant (since stock exists for all colors).
            // Only Material/Height are product-level attributes that should be available regardless of color.
            final bool isSizeOrBrandAttribute = attrNameLower == 'size' ||
                                               attrNameLower == currentProduct.primaryVariantLabel.toLowerCase() ||
                                               attrNameLower == 'brand';
            
            // IMPORTANT: Do NOT require color matching for sizes - allow all sizes to be available
            // regardless of selected color, since stock exists for all color variants.
            // This prevents sizes from being disabled when switching colors.
            if (colorNameForMatching.isNotEmpty && isSizeOrBrandAttribute) {
              // Skip color matching for sizes - sizes should be available for all colors
              // matchesRequiredAttributes stays true, allowing size to be checked without color restriction
            }
            
            if (!matchesRequiredAttributes) continue;

            // 2. Must match the candidate value for the attribute we're checking
            String? comboVal;
            if (attrNameLower == 'color name' || 
                attrNameLower == 'color' || 
                attrNameLower == 'colour' ||
                attrNameLower == 'اللون') {
              comboVal = getVariantColorValue(combo);
            } else {
              // Try exact attribute name first
              comboVal = combo.getAttributeValue(attributeName);
              // Try uppercase version
              if (comboVal == null && attributeName.toUpperCase() != attributeName) {
                comboVal = combo.getAttributeValue(attributeName.toUpperCase());
              }
              // Try lowercase version
              if (comboVal == null && attributeName.toLowerCase() != attributeName) {
                comboVal = combo.getAttributeValue(attributeName.toLowerCase());
              }
              // Try common variations for size
              if (comboVal == null && (attrNameLower == 'size' || attrNameLower == currentProduct.primaryVariantLabel.toLowerCase())) {
                comboVal = combo.getAttributeValue('SIZE') ?? combo.getAttributeValue('size');
              }
              // Try common variations for material
              final bool isMaterialOrHeight = attrNameLower == 'material' ||
                                             attrNameLower == 'material name' ||
                                             attrNameLower == 'height' ||
                                             attrNameLower == 'heel height';
              if (comboVal == null && isMaterialOrHeight) {
                if (attrNameLower.contains('material')) {
                  comboVal = combo.getAttributeValue('MATERIAL NAME') ?? 
                            combo.getAttributeValue('material name') ??
                            combo.getAttributeValue('MATERIAL') ??
                            combo.getAttributeValue('material');
                } else if (attrNameLower.contains('height')) {
                  comboVal = combo.getAttributeValue('HEIGHT') ?? 
                            combo.getAttributeValue('height') ??
                            combo.getAttributeValue('HEEL HEIGHT') ??
                            combo.getAttributeValue('heel height');
                }
              }
            }
            
            if (comboVal == null) {
              matchesRequiredAttributes = false;
            } else {
              final normalizedCombo = normalize(comboVal);
              final normalizedValue = normalize(value.name);
              
              // For color, use flexible matching
              if (attrNameLower == 'color name' || 
                  attrNameLower == 'color' || 
                  attrNameLower == 'colour' ||
                  attrNameLower == 'اللون') {
                matchesRequiredAttributes = normalizedCombo == normalizedValue ||
                                          normalizedCombo.contains(normalizedValue) ||
                                          normalizedValue.contains(normalizedCombo);
              } else if (isHeightAttr) {
                // Height: "2 CM" and "2.0" must match - use numeric comparison to prevent
                // height from being incorrectly marked unavailable and deselected on color change
                final comboNum = double.tryParse(comboVal.replaceAll(RegExp(r'[^0-9.]'), ''));
                final valueNum = double.tryParse(value.name.replaceAll(RegExp(r'[^0-9.]'), ''));
                matchesRequiredAttributes = comboNum != null && valueNum != null && comboNum == valueNum;
              } else {
                matchesRequiredAttributes = normalizedCombo == normalizedValue;
              }
            }
            
            if (!matchesRequiredAttributes) continue;

            // Check if variant is in stock (both inStock flag and quantityAvailable > 0)
            // CRITICAL: Material and Height are product-level attributes - don't require stock check
            // They should be available if they exist in any variant, regardless of stock
            final bool isMaterialOrHeight = attrNameLower == 'material' ||
                                           attrNameLower == 'material name' ||
                                           attrNameLower == 'height' ||
                                           attrNameLower == 'heel height';
            
            if (isMaterialOrHeight) {
              // Material/Height: Available if value matches (no stock check needed)
              if (matchesRequiredAttributes) {
                isAvailable = true;
                break;
              }
            } else {
              // Size/Brand/Color: Require stock check
            final qty = combo.quantityAvailable;
            final isInStock = _isVariantInStock(combo);
            if (matchesRequiredAttributes && isInStock) {
              isAvailable = true;
              break;
            }
            }
          }

          // FALLBACK: For Material/Height, if not found in variants, check if it exists in original options
          // Skip fallback for Height when color+size are selected - availability must be based on
          // actual in-stock variants for that combination (prevents incorrectly enabling e.g. 4.5)
          final bool isMaterialOrHeight = attrNameLower == 'material' ||
                                         attrNameLower == 'material name' ||
                                         attrNameLower == 'height' ||
                                         attrNameLower == 'heel height';
          final bool isHeightWithSelection = (attrNameLower == 'height' || attrNameLower == 'heel height') &&
              colorNameForMatching.isNotEmpty && currentProduct.selectedSize.isNotEmpty;
          
          if (!isAvailable && isMaterialOrHeight && !isHeightWithSelection) {
            // Check if this value exists in the original attribute options
            final originalAttrOption = currentProduct.variantAttributeOptions.firstWhere(
              (opt) => opt.attributeName == attributeName,
              orElse: () => VariantAttributeOption(attributeName: '', values: [], selectedValue: ''),
            );
            if (originalAttrOption.attributeName.isNotEmpty) {
              // Check if this value exists in the original values
              final valueExists = originalAttrOption.values.any(
                (v) => normalize(v.name) == normalize(value.name),
              );
              if (valueExists) {
                isAvailable = true;
                developer.log('✅ Material/Height fallback: "${value.name}" marked as available (exists in original options)');
              }
            }
          }

          // CRITICAL: Mark as selected if it matches the current selected value
          // For size, we should preserve selection even if not available for new color
          // We need to check against the actual current selection, not just selectedByAttribute
          bool isSelected = false;
          
          // Check if this value matches the current selection for this attribute
          if (attrNameLower == 'size' || 
              attrNameLower == currentProduct.primaryVariantLabel.toLowerCase() ||
              attrNameLower == 'brand') {
            // CRITICAL: For size, mark as selected if it matches, regardless of availability
            // This preserves the selected size even when changing colors
            isSelected = normalize(value.name) == normalize(currentProduct.selectedSize);
          } else if (attrNameLower == 'color name' || 
                     attrNameLower == 'color' || 
                     attrNameLower == 'colour' ||
                     attrNameLower == 'اللون') {
            isSelected = isAvailable && normalize(value.name) == normalize(colorNameForMatching);
          } else if (attrNameLower == 'material' || attrNameLower == 'material name') {
            isSelected = isAvailable && 
                        currentProduct.selectedMaterial != null &&
                        normalize(value.name) == normalize(currentProduct.selectedMaterial!);
          } else if (attrNameLower == 'height') {
            final currHeight = currentProduct.selectedHeelHeightCm;
            final valueNum = double.tryParse(value.name.replaceAll(RegExp(r'[^0-9.]'), ''));
            isSelected = isAvailable && currHeight != null && valueNum != null &&
                (valueNum - currHeight).abs() < 0.01;
          } else {
            // For other attributes, check selectedByAttribute
            isSelected = isAvailable && 
                       selectedByAttribute[attributeName]?.toLowerCase() == value.name.toLowerCase();
          }
          
          return VariantAttributeValue(
            id: value.id,
            name: value.name,
            isAvailable: isAvailable,
            isSelected: isSelected,
          );
        }).toList();

        // CRITICAL: For Material/Height/Brand, if only one option exists, ensure it's available and selected
        final bool isMaterialHeightOrBrand = attrNameLower == 'material' ||
                                            attrNameLower == 'material name' ||
                                            attrNameLower == 'height' ||
                                            attrNameLower == 'heel height' ||
                                            attrNameLower == 'brand';
        
        if (isMaterialHeightOrBrand && newValues.length == 1) {
          // Only one option exists - always make it available and selected
          final singleValue = newValues.first;
          if (!singleValue.isAvailable || !singleValue.isSelected) {
            newValues[0] = VariantAttributeValue(
              id: singleValue.id,
              name: singleValue.name,
              isAvailable: true, // Force available for single option
              isSelected: true, // Auto-select single option
            );
            developer.log('✅ Single option for ${attributeName}: "${singleValue.name}" - marked as available and selected');
          }
        }

        // Determine the selected value for this option
        String optionSelectedValue = '';
        
        // If Material/Height/Brand has only one option and it's auto-selected, use that value
        if (isMaterialHeightOrBrand && newValues.length == 1) {
          optionSelectedValue = newValues.first.name;
        } else if (attrNameLower == 'size' || 
            attrNameLower == currentProduct.primaryVariantLabel.toLowerCase() ||
            attrNameLower == 'brand') {
          // CRITICAL: Always preserve the current selected size, even if not available for new color
          // Check if current size exists in newValues (available or not)
          final currentSizeExists = newValues.any((v) => 
            normalize(v.name) == normalize(currentProduct.selectedSize));
          
          if (currentSizeExists || currentProduct.selectedSize.isNotEmpty) {
            // Current size exists OR we have a selected size - preserve it
            // First, try to find exact match
            final matchingValue = newValues.firstWhere(
              (v) => normalize(v.name) == normalize(currentProduct.selectedSize),
              orElse: () => newValues.isNotEmpty ? newValues.first : VariantAttributeValue(
                id: '',
                name: currentProduct.selectedSize,
                isAvailable: false,
                isSelected: false,
              ),
            );
            
            optionSelectedValue = matchingValue.name.isNotEmpty 
                ? matchingValue.name 
                : currentProduct.selectedSize;
            
            // Ensure it's marked as selected in the values list (even if not available)
            newValues = newValues.map((v) {
              final isSelected = normalize(v.name) == normalize(optionSelectedValue);
              return VariantAttributeValue(
                id: v.id,
                name: v.name,
                isAvailable: v.isAvailable,
                isSelected: isSelected, // Mark as selected even if not available
              );
            }).toList();
            developer.log('✅ Size preserved in recomputedOptions: "$optionSelectedValue" (from currentProduct.selectedSize: "${currentProduct.selectedSize}")');
          } else if (newValues.isNotEmpty) {
            // Current size doesn't exist - use first available or first item
            final firstAvailable = newValues.firstWhere(
              (v) => v.isAvailable,
              orElse: () => newValues.first,
            );
            optionSelectedValue = firstAvailable.name;
          }
        } else if (attrNameLower == 'color name' || 
                   attrNameLower == 'color' || 
                   attrNameLower == 'colour' ||
                   attrNameLower == 'اللون') {
          optionSelectedValue = colorNameForMatching;
        } else if (attrNameLower == 'material' || attrNameLower == 'material name') {
          optionSelectedValue = currentProduct.selectedMaterial ?? '';
        } else if (attrNameLower == 'height') {
          if (currentProduct.selectedHeelHeightCm != null) {
            final currH = currentProduct.selectedHeelHeightCm!;
            final matching = newValues.where((v) {
              final vNum = double.tryParse(v.name.replaceAll(RegExp(r'[^0-9.]'), ''));
              return vNum != null && (vNum - currH).abs() < 0.01;
            });
            optionSelectedValue = matching.isNotEmpty ? matching.first.name : currH.toStringAsFixed(1);
          } else {
            optionSelectedValue = '';
          }
        } else {
          optionSelectedValue = selectedByAttribute[attributeName] ?? '';
        }

        recomputedOptions.add(VariantAttributeOption(
          attributeName: attributeName,
          values: newValues,
          selectedValue: optionSelectedValue,
        ));
      }
      
      // Determine next selected values from recomputed options
      // CRITICAL: Preserve current selections if they're still available, otherwise use first available
      String nextSelectedPrimary = currentProduct.selectedSize;
      String? nextSelectedMaterial = currentProduct.selectedMaterial;
      double? nextSelectedHeelHeight = currentProduct.selectedHeelHeightCm;
      
      for (int i = 0; i < recomputedOptions.length; i++) {
        final opt = recomputedOptions[i];
        final attrNameLower = opt.attributeName.toLowerCase();
        
        // Handle size/primary variant
        if (attrNameLower == 'size' || 
            attrNameLower == currentProduct.primaryVariantLabel.toLowerCase() ||
            attrNameLower == 'brand') {
          // CRITICAL: Always preserve the current selected size, even if not available for new color
          // The size should already be preserved in opt.selectedValue when building recomputedOptions
          // But we need to ensure it's marked as selected in the values list
          
          // Use the selectedValue from the option (already set correctly when building recomputedOptions)
          if (opt.selectedValue.isNotEmpty && 
              normalize(opt.selectedValue) == normalize(nextSelectedPrimary)) {
            // Size is already preserved in selectedValue - ensure it's marked as selected in values
            final updatedValues = opt.values.map((v) {
              final isSelected = normalize(v.name) == normalize(opt.selectedValue);
              return VariantAttributeValue(
                id: v.id,
                name: v.name,
                isAvailable: v.isAvailable,
                isSelected: isSelected, // Mark as selected even if not available
              );
            }).toList();
            
              recomputedOptions[i] = VariantAttributeOption(
                attributeName: opt.attributeName,
              values: updatedValues,
              selectedValue: opt.selectedValue, // Keep the preserved size
            );
            nextSelectedPrimary = opt.selectedValue; // Update to match
            developer.log('✅ Size preserved: "$nextSelectedPrimary" (from opt.selectedValue)');
          } else if (opt.selectedValue.isNotEmpty) {
            // Use the preserved selectedValue from the option
            nextSelectedPrimary = opt.selectedValue;
            // Ensure it's marked as selected in values
            final updatedValues = opt.values.map((v) {
              final isSelected = normalize(v.name) == normalize(opt.selectedValue);
              return VariantAttributeValue(
                id: v.id,
                name: v.name,
                isAvailable: v.isAvailable,
                isSelected: isSelected,
              );
            }).toList();
            
            recomputedOptions[i] = VariantAttributeOption(
              attributeName: opt.attributeName,
              values: updatedValues,
              selectedValue: opt.selectedValue,
            );
            developer.log('✅ Size preserved: "$nextSelectedPrimary" (using opt.selectedValue)');
          } else if (opt.values.isNotEmpty) {
            // Fallback: current size doesn't exist in the list at all - find first available
            final firstAvailable = opt.values.firstWhere(
              (v) => v.isAvailable,
              orElse: () => opt.values.first,
            );
            if (firstAvailable.isAvailable) {
              nextSelectedPrimary = firstAvailable.name;
              recomputedOptions[i] = VariantAttributeOption(
                attributeName: opt.attributeName,
                values: opt.values,
                selectedValue: nextSelectedPrimary,
              );
              developer.log('⚠️ Size changed from "${currentProduct.selectedSize}" to "$nextSelectedPrimary" (current size not in list)');
            }
          }
        }
        
        // Handle material
        if (attrNameLower == 'material' || attrNameLower == 'material name') {
          if (nextSelectedMaterial != null && nextSelectedMaterial.isNotEmpty) {
            final currentMaterial = nextSelectedMaterial;
            // Check if current selection is still available
            final materialValue = opt.values.firstWhere(
              (v) => normalize(v.name) == normalize(currentMaterial),
              orElse: () => opt.values.first,
            );
            if (materialValue.isAvailable) {
              // Current selection is still available - keep it
              // Update selectedValue in the option to match
              if (opt.selectedValue != currentMaterial) {
                recomputedOptions[i] = VariantAttributeOption(
                  attributeName: opt.attributeName,
                  values: opt.values,
                  selectedValue: currentMaterial,
                );
              }
            } else {
              // Current selection is not available - find first available
              final firstAvailable = opt.values.firstWhere(
                (v) => v.isAvailable,
                orElse: () => opt.values.first,
              );
              if (firstAvailable.isAvailable) {
                nextSelectedMaterial = firstAvailable.name;
                // Update selectedValue in the option
                recomputedOptions[i] = VariantAttributeOption(
                  attributeName: opt.attributeName,
                  values: opt.values,
                  selectedValue: firstAvailable.name,
                );
              } else {
                nextSelectedMaterial = null;
              }
            }
          } else if (opt.values.isNotEmpty) {
            // No current selection - use first available
            final firstAvailable = opt.values.firstWhere(
              (v) => v.isAvailable,
              orElse: () => opt.values.first,
            );
            if (firstAvailable.isAvailable) {
              nextSelectedMaterial = firstAvailable.name;
              recomputedOptions[i] = VariantAttributeOption(
                attributeName: opt.attributeName,
                values: opt.values,
                selectedValue: firstAvailable.name,
              );
            }
          }
        }
        
        // Handle heel height
        if (attrNameLower == 'height') {
          if (nextSelectedHeelHeight != null) {
            final currentHeight = nextSelectedHeelHeight;
            final heightStr = currentHeight.toStringAsFixed(1);
            // Check if current selection is still available (use numeric match: "2 CM" == 2.0)
            final heightAttrValue = opt.values.firstWhere(
              (v) {
                final vNum = double.tryParse(v.name.replaceAll(RegExp(r'[^0-9.]'), ''));
                return vNum != null && (vNum - currentHeight).abs() < 0.01;
              },
              orElse: () => opt.values.first,
            );
            if (heightAttrValue.isAvailable) {
              // Current selection is still available - keep it
              // Use value's name (e.g. "2 CM") for selectedValue so UI displays correctly
              final valueNameToUse = heightAttrValue.name;
              if (opt.selectedValue != valueNameToUse) {
                recomputedOptions[i] = VariantAttributeOption(
                  attributeName: opt.attributeName,
                  values: opt.values,
                  selectedValue: valueNameToUse,
                );
              }
            } else {
              // Current selection is not available - find first available
              final firstAvailable = opt.values.firstWhere(
                (v) => v.isAvailable,
                orElse: () => opt.values.first,
              );
              if (firstAvailable.isAvailable) {
                final newHeight = double.tryParse(firstAvailable.name);
                if (newHeight != null) {
                  nextSelectedHeelHeight = newHeight;
                  recomputedOptions[i] = VariantAttributeOption(
                    attributeName: opt.attributeName,
                    values: opt.values,
                    selectedValue: firstAvailable.name,
                  );
                } else {
                  nextSelectedHeelHeight = null;
                }
              } else {
                // PRESERVE: No height marked available - keep current selection (heightAttrValue
                // was found via numeric match). Prevents deselecting when availability logic
                // has edge cases (e.g. color/format mismatch).
                final preservedValues = opt.values.map((v) {
                  final matches = double.tryParse(v.name.replaceAll(RegExp(r'[^0-9.]'), '')) != null &&
                      (double.tryParse(v.name.replaceAll(RegExp(r'[^0-9.]'), ''))! - currentHeight).abs() < 0.01;
                  return VariantAttributeValue(
                    id: v.id,
                    name: v.name,
                    isAvailable: v.isAvailable,
                    isSelected: matches,
                  );
                }).toList();
                recomputedOptions[i] = VariantAttributeOption(
                  attributeName: opt.attributeName,
                  values: preservedValues,
                  selectedValue: heightAttrValue.name,
                );
                // nextSelectedHeelHeight stays as currentHeight (already set from currentProduct)
              }
            }
          } else if (opt.values.isNotEmpty) {
            // No current selection - use first available
            final firstAvailable = opt.values.firstWhere(
              (v) => v.isAvailable,
              orElse: () => opt.values.first,
            );
            if (firstAvailable.isAvailable) {
              final newHeight = double.tryParse(firstAvailable.name);
              if (newHeight != null) {
                nextSelectedHeelHeight = newHeight;
                recomputedOptions[i] = VariantAttributeOption(
                  attributeName: opt.attributeName,
                  values: opt.values,
                  selectedValue: firstAvailable.name,
                );
              }
            }
          }
        }
      }
      
      // Update the reference to use the modified recomputedOptions

      final updatedVariantAttributeOptions = recomputedOptions;
      
      // Update size options.
      // IMPORTANT: Size availability should reflect overall stock for that size
      // across all colors, not be over‑restricted by the current color filter.
      // This ensures sizes don't get disabled when switching colors if stock exists.
      final updatedSizeOptions = currentProduct.sizeOptions.map((size) {
        final bool isSelected = normalize(size.name) == normalize(nextSelectedPrimary);

        // Determine availability by scanning all variant combinations
        // and checking if ANY in‑stock variant exists with this size.
        bool isAvailable = false;
        for (final v in currentProduct.variantCombinations) {
          // Try to read size from primary label or SIZE field
          String? comboSize =
              _getComboValueForAttribute(currentProduct, v, currentProduct.primaryVariantLabel);
          comboSize ??= _getComboValueForAttribute(currentProduct, v, 'SIZE');

          if (comboSize != null &&
              normalize(comboSize) == normalize(size.name) &&
              _isVariantInStock(v)) {
            isAvailable = true;
            break;
          }
        }
        
        return SizeOption(
          id: size.id,
          name: size.name,
          isAvailable: isAvailable,
          isRecommended: size.isRecommended,
          isSelected: isSelected,
        );
      }).toList();

      // Don't set images from color option here – set from selected variant below so we never
      // emit wrong/previous images and cause a glitch. Use current images as placeholder until then.
      final placeholderImages = List<String>.from(currentProduct.images);

      var updatedProduct = ProductDetails(
        id: currentProduct.id,
        brand: currentProduct.brand,
        name: currentProduct.name,
        description: currentProduct.description,
        price: currentProduct.price,
        originalPrice: currentProduct.originalPrice,
        rating: currentProduct.rating,
        reviewCount: currentProduct.reviewCount,
        images: placeholderImages,
        colorOptions: updatedColorOptions,
        sizeOptions: updatedSizeOptions,
        variantAttributeOptions: updatedVariantAttributeOptions, /// Zeinab Attributes
        selectedColor: colorNameForMatching,
        selectedSize: nextSelectedPrimary,
        isFavorite: currentProduct.isFavorite,
        hasDiscount: currentProduct.hasDiscount,
        discountPercentage: currentProduct.discountPercentage,
        features: currentProduct.features,
        material: currentProduct.material,
        materialsList: currentProduct.materialsList,
        materialOptions: currentProduct.materialOptions,
        selectedMaterial: nextSelectedMaterial, // Use recomputed material
        careInstructions: currentProduct.careInstructions,
        heelHeightCm: currentProduct.heelHeightCm,
        heelType: currentProduct.heelType,
        heelHeightOptions: currentProduct.heelHeightOptions,
        selectedHeelHeightCm: nextSelectedHeelHeight, // Use recomputed heel height
        isPlusMember: currentProduct.isPlusMember,
        pointsEarned: currentProduct.pointsEarned,
        optionalProducts: currentProduct.optionalProducts,
        accessoryProducts: currentProduct.accessoryProducts,
        alternativeProducts: currentProduct.alternativeProducts,
        variantCombinations: currentProduct.variantCombinations,
        primaryVariantLabel: currentProduct.primaryVariantLabel,
        tags: currentProduct.tags,
        variantImagesMap: currentProduct.variantImagesMap,
      );
      
      // Sync stock & quantity with the newly selected variant
      // IMPORTANT: When color changes, we need to find variant matching size+color only
      // Other attributes (material, heel height) might not match the new color variant
      int nextQuantity = currentState.quantity;
      VariantCombination? selectedVariant;
      
      // First try exact match (all attributes)
      selectedVariant = _findSelectedVariant(updatedProduct);
      
      if (selectedVariant != null) {
        developer.log('🎨 COLOR CHANGED → Found EXACT MATCH variant_id=${selectedVariant.variantId} for color="${updatedProduct.selectedColor}", size="${updatedProduct.selectedSize}"');
        print('🎨🎨🎨 COLOR CHANGED → VARIANT_ID: ${selectedVariant.variantId} 🎨🎨🎨');
      }
      
      // If no exact match found, try flexible match (size + color only)
      if (selectedVariant == null && updatedProduct.selectedSize.isNotEmpty && updatedProduct.selectedColor.isNotEmpty) {
        developer.log('🔍 No exact variant match found, trying flexible match (size + color only)...');
        String normalize(String s) => s.toLowerCase().trim();
        
        // Helper to get color value from variant
        String? getVariantColorValue(VariantCombination v) {
          final colorAttrNames = ['COLOR NAME', 'color name', 'Color Name', 'color', 'Color', 'COLOR', 'colour', 'Colour', 'اللون', 'لون'];
          for (final attrName in colorAttrNames) {
            final value = v.getAttributeValue(attrName);
            if (value != null && value.isNotEmpty) {
              return value;
            }
          }
          return null;
        }
        
        final normalizedSelectedColor = normalize(updatedProduct.selectedColor);
        final flexibleMatch = updatedProduct.variantCombinations.where((combo) {
          // Must match size
          bool sizeMatch = combo.hasAttributeValue('SIZE', updatedProduct.selectedSize) ||
                          combo.hasAttributeValue('size', updatedProduct.selectedSize) ||
                          combo.hasAttributeValue(updatedProduct.primaryVariantLabel, updatedProduct.selectedSize);
          
          if (!sizeMatch) return false;
          
          // Must match color (with normalization for better matching)
          final variantColorName = getVariantColorValue(combo);
          if (variantColorName == null) return false;
          
          final normalizedVariantColor = normalize(variantColorName);
          bool colorMatch = normalizedVariantColor == normalizedSelectedColor ||
                           normalizedVariantColor.contains(normalizedSelectedColor) ||
                           normalizedSelectedColor.contains(normalizedVariantColor);
          
          return colorMatch;
        }).toList();
        
        if (flexibleMatch.isNotEmpty) {
          selectedVariant = flexibleMatch.first;
          developer.log('✅ Found flexible match variant_id=${selectedVariant.variantId} for color=${updatedProduct.selectedColor}, size=${updatedProduct.selectedSize}');
        }
        
        if (flexibleMatch.isNotEmpty) {
          // Sort by highest stock

          flexibleMatch.sort((a, b) {
            final qtyA = a.quantityAvailable ?? 0;
            final qtyB = b.quantityAvailable ?? 0;
            return qtyB.compareTo(qtyA);
          });
          selectedVariant = flexibleMatch.first;
          developer.log('✅ Flexible match found: variantId=${selectedVariant.variantId}, quantityAvailable=${selectedVariant.quantityAvailable}');
          print('🎨🎨🎨 COLOR CHANGED → VARIANT_ID (FLEXIBLE MATCH): ${selectedVariant.variantId} 🎨🎨🎨');
        }
      }
      
      // CRITICAL: When size is selected, use hasInStockVariant as the primary source of truth
      // This ensures we correctly reflect stock status for the exact color+size combination
      bool finalInStock;
      if (selectedVariant != null) {
        // CRITICAL: Use _isVariantInStock to properly check both inStock flag AND quantityAvailable
        // This ensures we correctly identify when a variant is truly out of stock
        bool variantInStock = _isVariantInStock(selectedVariant);
        
        final double? quantityAvailable = selectedVariant.quantityAvailable;

        if (quantityAvailable != null) {
          // Check if there's already an item in cart with this variant ID
          int existingCartQuantity = 0;
          final variantIdToCheck = selectedVariant.variantId;
          // Convert variantId to String for comparison (cart items use String IDs)
          final variantIdStr = variantIdToCheck.toString();
          if (cartBloc.state is CartLoaded) {
            final cartState = cartBloc.state as CartLoaded;
            try {
              final existingItem = cartState.cartItems.firstWhere(
                (item) => item.product.id.toString() == variantIdStr,
              );
              existingCartQuantity = existingItem.quantity;
            } catch (e) {
              // Item not found in cart, existingCartQuantity remains 0
            }
          }
          
          final maxAllowed = quantityAvailable.toInt();
          final available = maxAllowed - existingCartQuantity;
          
          // If no stock available (considering cart), mark as out of stock
          if (maxAllowed <= 0 || available <= 0) {
            variantInStock = false;
            nextQuantity = 1;
          } else {
            // Clamp to available quantity (accounting for cart items)

            ///Zeinab QTY
            if (nextQuantity > available) {
              nextQuantity = available;
            }
            if (nextQuantity <= 0) {
              nextQuantity = 1;
            }
          }
          
          developer.log(
            '📦 _onSelectColor → Found variant: size="${updatedProduct.selectedSize}", '
            'color="$actualColorName", variantId=${selectedVariant.variantId}, '
            'inStock=${selectedVariant.inStock}, qty=$quantityAvailable, '
            'available=$available, finalInStock=$variantInStock',
            name: 'ProductDetails/Stock',
          );
          print('Zeinnaa 2: ${updatedVariantAttributeOptions.length} ,ID ${selectedVariant.variantId} , '
              'List of sizes :: ${ selectedVariant.attributes.length}');
        } else {
          // If quantityAvailable is null, rely on _isVariantInStock result
          developer.log(
            '⚠️ Selected variant has null quantityAvailable, using inStock flag: $variantInStock',
            name: 'ProductDetails/Stock',
          );
        }

        // CRITICAL: If size is selected, prefer hasInStockVariant check over variant match
        // This ensures we correctly reflect stock for the exact color+size combination
        // Use matched variant as single source of truth (same variant used for images)
        finalInStock = variantInStock;
        developer.log(
          '📦 _onSelectColor → variantId=${selectedVariant.variantId}, inStock=$variantInStock, qty=${selectedVariant.quantityAvailable}',
          name: 'ProductDetails/Stock',
        );
      } else {
        // No variant found - use hasInStockVariant check result
        if (actualSize != null && actualSize.isNotEmpty) {
          finalInStock = hasInStockVariant;
          developer.log('📦 No variant match: Using hasInStockVariant=$hasInStockVariant for color="$colorNameForMatching" with size="$actualSize"');
        } else {
          finalInStock = hasInStockVariant;
          developer.log('📦 No variant match: Using hasInStockVariant=$hasInStockVariant for color="$colorNameForMatching" (no size selected)');
        }
        if (!finalInStock) {
          nextQuantity = 1;
        }
      }
      
      final int? qtyForBadge = selectedVariant?.quantityAvailable != null
          ? selectedVariant!.quantityAvailable!.toInt()
          : null;
      updatedProduct = updatedProduct.copyWith(
        inStock: finalInStock,
        selectedVariantQuantityAvailable: qtyForBadge,
      );

      // Update main product images when color changes so the gallery shows the selected color.
      // Use colorNameForMatching (never placeholder) to find variant; fallback to option name/display.
      VariantCombination? variantForImage;
      final namesToTry = <String>[
        if (colorNameForMatching.isNotEmpty && !colorNameForMatching.startsWith('COLOR_ID_')) colorNameForMatching,
        if (selectedColorOption.name.isNotEmpty && !selectedColorOption.name.startsWith('COLOR_ID_')) selectedColorOption.name,
        selectedColorOption.displayNameOrName,
      ].where((s) => s.isNotEmpty).toSet().toList();

      for (final candidateName in namesToTry) {
        final normalizedColor = _norm(candidateName);
        if (normalizedColor.isEmpty) continue;
        for (final v in updatedProduct.variantCombinations) {
          final variantColor = _getVariantColorValue(v);
          if (variantColor == null || v.variantId.isEmpty) continue;
          final nv = _norm(variantColor);
          if (nv == normalizedColor || nv.contains(normalizedColor) || normalizedColor.contains(nv)) {
            variantForImage = v;
            break;
          }
        }
        if (variantForImage != null) break;
      }

      if (selectedColorOption.images.isNotEmpty) {
        updatedProduct = updatedProduct.copyWith(images: List<String>.from(selectedColorOption.images));
        developer.log('🎨 Using ColorOption.images: ${selectedColorOption.images.length} (${selectedColorOption.displayNameOrName})');
      } else if (variantForImage != null) {
        final vid = variantForImage.variantId;
        final variantImages = updatedProduct.variantImagesMap[vid];
        if (variantImages != null && variantImages.isNotEmpty) {
          updatedProduct = updatedProduct.copyWith(images: List<String>.from(variantImages));
        } else {
          final path = '/web/image/product.product/$vid/image_1920';
          final fullUrl = '${AppConstants.baseUrl}${path.startsWith('/') ? path.substring(1) : path}';
          updatedProduct = updatedProduct.copyWith(images: [fullUrl]);
        }
        developer.log('🎨 Using variant image for selected color: variantId=$vid');
      }
      // If still no update (no option images, no matching variant), keep current images to avoid blank.

      emit(ProductDetailsLoaded(updatedProduct, quantity: nextQuantity, isAdding: false));
      
      final result = await selectColor(SelectColorParams(
        productId: event.productId,
        colorId: event.colorId,
      ));
      
      // Don't re-emit on success – we already emitted the correct state above. Re-emitting here
      // overwrites the state that SelectVariantById may have set (which runs while we awaited),
      // causing the "correct image then revert to previous" glitch within ~1 second.
      result.fold(
        (failure) => emit(ProductDetailsError(failure.message)),
        (_) {
          // Success: do nothing; UI already has correct state from first emit + SelectVariantById.
        },
      );
    }
  }

  Future<void> _onSelectSize(
    SelectSizeEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    developer.log('🚀 ========== _onSelectSize CALLED ==========');
    developer.log('🚀 Size ID selected: ${event.sizeId}');
    
    if (state is ProductDetailsLoaded) {
      final currentState = state as ProductDetailsLoaded;
      final currentProduct = currentState.productDetails;
      developer.log('🚀 Product loaded: ${currentProduct.name}');
      
      // Find the selected size.
      // NOTE: Backend sometimes sends sizeOptions as empty, but we still have sizes
      // inside variantAttributeOptions. In that case we synthesize sizeOptions
      // from the size attribute values so that size selection works.
      List<SizeOption> effectiveSizeOptions = currentProduct.sizeOptions;

      if (effectiveSizeOptions.isEmpty) {
        developer.log(
          '⚠️ _onSelectSize: sizeOptions is EMPTY for product ${currentProduct.id}, '
          'synthesizing from variantAttributeOptions...',
        );

        // Try to locate the size attribute in variantAttributeOptions
        VariantAttributeOption? sizeAttr;
        for (final opt in currentProduct.variantAttributeOptions) {
          final n = opt.attributeName.toLowerCase().trim();
          if (n == 'size' ||
              n == currentProduct.primaryVariantLabel.toLowerCase().trim() ||
              n == 'القياس') {
            sizeAttr = opt;
            break;
          }
        }

        if (sizeAttr != null && sizeAttr.values.isNotEmpty) {
          effectiveSizeOptions = sizeAttr.values.map((v) {
            return SizeOption(
              id: v.id,
              name: v.name,
              isAvailable: true, // treat as available for UI selection
              isRecommended: false,
              isSelected: v.id == event.sizeId,
            );
          }).toList();
        } else {
          developer.log(
            '⚠️ _onSelectSize: Could not synthesize sizeOptions (no size attribute values). '
            'Ignoring SelectSizeEvent(sizeId=${event.sizeId}).',
          );
          return;
        }
      }

      // Resolve sizeId → size NAME from the same source as the UI (variantAttributeOptions).
      // Size buttons send sizeId: value.id; we must use the corresponding value.name for variant
      // matching so the correct variant (and image) is found. Using only SizeOption by id can
      // pick the wrong size when backend sizeOptions use different ids.
      String selectedSizeName;
      VariantAttributeOption? sizeAttrForResolve;
      for (final opt in currentProduct.variantAttributeOptions) {
        final n = opt.attributeName.toLowerCase().trim();
        if (n == 'size' ||
            n == currentProduct.primaryVariantLabel.toLowerCase().trim() ||
            n == 'القياس') {
          sizeAttrForResolve = opt;
          break;
        }
      }
      if (sizeAttrForResolve != null) {
        try {
          final matchedValue = sizeAttrForResolve.values.firstWhere(
            (v) => v.id == event.sizeId,
          );
          selectedSizeName = matchedValue.name;
          developer.log('📏 _onSelectSize: resolved sizeId=${event.sizeId} → name="$selectedSizeName" from variantAttributeOptions (same source as size buttons)');
        } catch (_) {
          final selectedSizeOption = effectiveSizeOptions.firstWhere(
            (size) => size.id == event.sizeId,
            orElse: () => effectiveSizeOptions.first,
          );
          selectedSizeName = selectedSizeOption.name;
          developer.log('📏 _onSelectSize: sizeId not in variantAttributeOptions, using SizeOption: name="$selectedSizeName"');
        }
      } else {
        final selectedSizeOption = effectiveSizeOptions.firstWhere(
          (size) => size.id == event.sizeId,
          orElse: () => effectiveSizeOptions.first,
        );
        selectedSizeName = selectedSizeOption.name;
      }

      // Recompute stock for the currently selected combination (size + color + other attrs).
      // If there is no in-stock variant for the current selection, we must mark inStock=false
      // so the UI can show "Out of stock" for that size/color combination.
      bool containsArabic(String text) {
        if (text.isEmpty) return false;
        final arabicRegex = RegExp(r'[\u0600-\u06FF]');
        return arabicRegex.hasMatch(text);
      }

      String normalize(String s) => s.toLowerCase().trim();

      String? getVariantColorValue(VariantCombination v) {
        final colorAttrNames = [
          'COLOR NAME',
          'color name',
          'Color Name',
          'color',
          'Color',
          'COLOR',
          'colour',
          'Colour',
          'اللون',
          'لون',
        ];
        for (final attrName in colorAttrNames) {
          final value = v.getAttributeValue(attrName);
          if (value != null && value.isNotEmpty) {
            return value;
          }
        }
        return null;
      }

      // Determine the effective selected color name for matching.
      String? selectedColorName = currentProduct.selectedColor;
      if (selectedColorName.isEmpty) {
        // Try to get from colorOptions (first selected one)
        try {
          final selectedColorOpt = currentProduct.colorOptions.firstWhere(
            (c) => c.isSelected,
            orElse: () => currentProduct.colorOptions.isNotEmpty
                ? currentProduct.colorOptions.first
                : const ColorOption(
                    id: '',
                    name: '',
                    displayName: null,
                    code: '',
                    images: [],
                    isSelected: false,
                  ),
          );
          selectedColorName = selectedColorOpt.name;
        } catch (_) {
          selectedColorName = '';
        }
      }

      // If the color name is Arabic, try to resolve to an English one from colorOptions.
      if (selectedColorName.isNotEmpty && containsArabic(selectedColorName)) {
        for (final colorOpt in currentProduct.colorOptions) {
          if (colorOpt.displayNameOrName == selectedColorName &&
              !containsArabic(colorOpt.name)) {
            selectedColorName = colorOpt.name;
            break;
          }
        }
      }

      final normalizedSelectedSize = normalize(selectedSizeName);
      final normalizedSelectedColor =
          selectedColorName != null ? normalize(selectedColorName!) : '';

      bool hasAvailableVariantForSelection = false;

      for (final v in currentProduct.variantCombinations) {
        // Match size
        bool sizeMatch = false;
        final sizeVal = v.getAttributeValue('SIZE') ??
            v.getAttributeValue('size') ??
            v.getAttributeValue(currentProduct.primaryVariantLabel);
        if (sizeVal != null && sizeVal.isNotEmpty) {
          sizeMatch = normalize(sizeVal) == normalizedSelectedSize;
        }
        if (!sizeMatch) continue;

        // Match color only when a color is effectively selected
        bool colorMatch = true;
        if (normalizedSelectedColor.isNotEmpty) {
          final variantColorName = getVariantColorValue(v);
          if (variantColorName == null || variantColorName.isEmpty) {
            colorMatch = false;
          } else {
            final normalizedVariantColor = normalize(variantColorName);
            colorMatch = normalizedVariantColor == normalizedSelectedColor ||
                normalizedVariantColor.contains(normalizedSelectedColor) ||
                normalizedSelectedColor.contains(normalizedVariantColor);
          }
        }
        if (!colorMatch) continue;

        // Check stock for this exact combination using the proper stock check function
        if (_isVariantInStock(v)) {
          hasAvailableVariantForSelection = true;
          developer.log(
            '📦 _onSelectSize → Found in-stock variant: size="$selectedSizeName", '
            'color="${selectedColorName ?? 'none'}", variantId=${v.variantId}',
            name: 'ProductDetails/Stock',
          );
          break;
        }
      }

      // CRITICAL: Recalculate color availability based on the newly selected size
      List<ColorOption> updatedColorOptions = currentProduct.colorOptions.map((color) {
        // Get the English color name for matching
        String? colorNameForMatching;
        for (final opt in currentProduct.variantAttributeOptions) {
          final attrNameLower = opt.attributeName.toLowerCase();
          if (attrNameLower == 'color name' || 
              attrNameLower == 'color' || 
              attrNameLower == 'colour' ||
              attrNameLower == 'اللون') {
            try {
              final matchedValue = opt.values.firstWhere(
                (v) => v.id == color.id,
              );
              if (!containsArabic(matchedValue.name)) {
                colorNameForMatching = matchedValue.name;
                break;
              }
            } catch (e) {
              // ID not found, continue
            }
          }
        }
        if (colorNameForMatching == null || colorNameForMatching.isEmpty) {
          colorNameForMatching = color.name;
        }
        // Fallback for Arabic: use displayName when name is placeholder/empty
        if ((colorNameForMatching == null || colorNameForMatching.isEmpty || colorNameForMatching.startsWith('COLOR_ID_')) &&
            color.displayName != null && color.displayName!.isNotEmpty) {
          colorNameForMatching = color.displayName;
        }
        
        // Check if this color is available for the newly selected size
        bool hasInStockVariant = false;
        final normalizedColor = normalize(colorNameForMatching ?? '');
        // CRITICAL: Empty string causes "x".contains("") = true, incorrectly matching all variants (Arabic bug)
        final hasValidColorName = normalizedColor.isNotEmpty;
        
        for (final v in currentProduct.variantCombinations) {
          // Match size
          bool sizeMatch = false;
          final sizeVal = v.getAttributeValue('SIZE') ??
              v.getAttributeValue('size') ??
              v.getAttributeValue(currentProduct.primaryVariantLabel);
          if (sizeVal != null && sizeVal.isNotEmpty) {
            sizeMatch = normalize(sizeVal) == normalizedSelectedSize;
          }
          if (!sizeMatch) continue;
          
          // Match color
          final variantColorName = getVariantColorValue(v);
          if (variantColorName == null) continue;
          
          final normalizedVariantColor = normalize(variantColorName);
          
          final bool colorMatch = hasValidColorName && normalizedVariantColor.isNotEmpty &&
              (normalizedVariantColor == normalizedColor ||
               (normalizedColor.isNotEmpty && normalizedVariantColor.contains(normalizedColor)) ||
               (normalizedVariantColor.isNotEmpty && normalizedColor.contains(normalizedVariantColor)));
          
          if (colorMatch) {
            final isInStock = _isVariantInStock(v);
            if (isInStock) {
              hasInStockVariant = true;
              break;
            }
          }
        }
        
        return ColorOption(
          id: color.id,
          name: color.name,
          displayName: color.displayName,
          code: color.code,
          images: color.images,
          isSelected: color.isSelected,
          isAvailable: hasInStockVariant, // Recalculate based on newly selected size
        );
      }).toList();

      // Sync variantAttributeOptions so size attribute has selectedValue = selectedSizeName.
      // This allows _findSelectedVariant to resolve the exact variant for images + stock.
      final updatedVariantAttributeOptions = currentProduct.variantAttributeOptions.map((opt) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if (attrNameLower == 'size' ||
            attrNameLower == currentProduct.primaryVariantLabel.toLowerCase() ||
            attrNameLower == 'القياس') {
          return VariantAttributeOption(
            attributeName: opt.attributeName,
            values: opt.values,
            selectedValue: selectedSizeName,
          );
        }
        return opt;
      }).toList();

      var productToEmit = currentProduct.copyWith(
        selectedSize: selectedSizeName,
        colorOptions: updatedColorOptions,
        variantAttributeOptions: updatedVariantAttributeOptions,
      );

      final selectedVariant = _findSelectedVariant(productToEmit);
      int nextQuantity = currentState.quantity;
      bool inStock = hasAvailableVariantForSelection;

      if (selectedVariant != null) {
        inStock = _isVariantInStock(selectedVariant);
        final double? quantityAvailable = selectedVariant.quantityAvailable;
        if (quantityAvailable != null) {
          int existingCart = 0;
          if (cartBloc.state is CartLoaded) {
            try {
              final cartState = cartBloc.state as CartLoaded;
              final variantIdStr = selectedVariant.variantId.toString();
              final item = cartState.cartItems.firstWhere(
                (i) => i.product.id.toString() == variantIdStr,
              );
              existingCart = item.quantity;
            } catch (_) {}
          }
          final available = quantityAvailable.toInt() - existingCart;
          if (available <= 0) {
            inStock = false;
            nextQuantity = 1;
          } else {
            if (nextQuantity > available) nextQuantity = available;
            if (nextQuantity <= 0) nextQuantity = 1;
          }
        }
        final int? qtyForBadge = selectedVariant.quantityAvailable != null
            ? selectedVariant.quantityAvailable!.toInt()
            : null;
        productToEmit = productToEmit.copyWith(
          inStock: inStock,
          selectedVariantQuantityAvailable: qtyForBadge,
        );
        // Update images from the variant that matches selected COLOR + SIZE (by name), same as SelectColor.
        // Do not rely on selectedVariant for images; find the variant by color+size so the main image
        // stays on the selected color when only size changes.
        final effectiveColorName = selectedColorName ?? currentProduct.selectedColor;
        if (effectiveColorName.isNotEmpty && selectedSizeName.isNotEmpty) {
          final normalizedColor = _norm(effectiveColorName);
          final normalizedSize = _norm(selectedSizeName);
          VariantCombination? variantForImage;
          for (final v in productToEmit.variantCombinations) {
            final variantColor = _getVariantColorValue(v);
            final sizeVal = v.getAttributeValue('SIZE') ?? v.getAttributeValue('size') ?? v.getAttributeValue(productToEmit.primaryVariantLabel);
            if (variantColor == null || sizeVal == null) continue;
            final nvc = _norm(variantColor);
            final nvs = _norm(sizeVal);
            final colorMatch = nvc == normalizedColor || nvc.contains(normalizedColor) || normalizedColor.contains(nvc);
            final sizeMatch = nvs == normalizedSize;
            if (colorMatch && sizeMatch && v.variantId.isNotEmpty) {
              variantForImage = v;
              break;
            }
          }
          if (variantForImage != null) {
            productToEmit = productToEmit.withImagesForVariant(variantForImage.variantId);
            final variantHasImages = productToEmit.variantImagesMap[variantForImage.variantId]?.isNotEmpty ?? false;
            if (!variantHasImages) {
              final path = '/web/image/product.product/${variantForImage.variantId}/image_1920';
              final fullUrl = '${AppConstants.baseUrl}${path.startsWith('/') ? path.substring(1) : path}';
              productToEmit = productToEmit.copyWith(images: [fullUrl]);
            }
          } else {
            productToEmit = productToEmit.copyWith(images: List<String>.from(currentProduct.images));
          }
        } else {
          productToEmit = productToEmit.copyWith(images: List<String>.from(currentProduct.images));
        }
      } else {
        productToEmit = productToEmit.copyWith(
          inStock: inStock,
          selectedVariantQuantityAvailable: null,
        );
      }

      developer.log(
        '📦 _onSelectSize → size="$selectedSizeName", color="${selectedColorName ?? 'none'}", '
        'variantId=${selectedVariant?.variantId}, inStock=$inStock, qty=${selectedVariant?.quantityAvailable}',
        name: 'ProductDetails/Stock',
      );

      emit(ProductDetailsLoaded(
        productToEmit,
        quantity: nextQuantity,
        isAdding: currentState.isAdding,
      ));
      return;
    }
  }

  /// Helper method to find the currently selected variant based on product details
  VariantCombination? _findSelectedVariant(ProductDetails pd) {
    try {
      // Build selected pairs using attribute names
      final Map<String, String> selectedByAttribute = {};
      String normalize(String s) => s.toLowerCase().trim();
      
      // Add selected size/primary variant from variantAttributeOptions (source of truth)
      String? selectedSizeValue;
      for (final opt in pd.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if ((attrNameLower == 'size' || attrNameLower == pd.primaryVariantLabel.toLowerCase()) && 
            opt.selectedValue.isNotEmpty) {
          selectedSizeValue = opt.selectedValue;
          break;
        }
      }
      // Fallback to selectedSize
      if (selectedSizeValue == null && pd.selectedSize.isNotEmpty) {
        selectedSizeValue = pd.selectedSize;
      }
      
      if (selectedSizeValue != null && selectedSizeValue.isNotEmpty) {
        selectedByAttribute['SIZE'] = selectedSizeValue;
        selectedByAttribute['size'] = selectedSizeValue;
        selectedByAttribute[pd.primaryVariantLabel] = selectedSizeValue;
      }
      
      // Add selected color - prioritize COLOR NAME attribute from variantAttributeOptions
      String? selectedColorValue;
      for (final opt in pd.variantAttributeOptions) {
        final attrNameLower = opt.attributeName.toLowerCase();
        if ((attrNameLower == 'color name' || 
             attrNameLower == 'color' || 
             attrNameLower == 'colour' ||
             attrNameLower == 'اللون') && 
            opt.selectedValue.isNotEmpty) {
          selectedColorValue = opt.selectedValue;
          break;
        }
      }
      // Fallback to selectedColor
      if (selectedColorValue == null && pd.selectedColor.isNotEmpty) {
        selectedColorValue = pd.selectedColor;
      }
      
      if (selectedColorValue != null && selectedColorValue.isNotEmpty) {
        // Use "COLOR NAME" as the primary matching attribute (standard from API)
        selectedByAttribute['COLOR NAME'] = selectedColorValue;
        selectedByAttribute['color name'] = selectedColorValue;
        selectedByAttribute['color'] = selectedColorValue;
        selectedByAttribute['colour'] = selectedColorValue;
        selectedByAttribute['اللون'] = selectedColorValue;
      }
      
      // Add other selected attributes from variantAttributeOptions (material, height, etc.)
      for (final opt in pd.variantAttributeOptions) {
        if (opt.selectedValue.isNotEmpty) {
          final attrNameLower = opt.attributeName.toLowerCase();
          // Skip color and size as we've already handled them
          if (attrNameLower != 'color name' && 
              attrNameLower != 'color' && 
              attrNameLower != 'colour' &&
              attrNameLower != 'اللون' &&
              attrNameLower != 'size' &&
              attrNameLower != pd.primaryVariantLabel.toLowerCase()) {
            selectedByAttribute[opt.attributeName] = opt.selectedValue;
            // Also try uppercase version for common attributes
            if (opt.attributeName.toUpperCase() != opt.attributeName) {
              selectedByAttribute[opt.attributeName.toUpperCase()] = opt.selectedValue;
            }
          }
        }
      }
      
      // Add selectedMaterial if available
      if (pd.selectedMaterial != null && pd.selectedMaterial!.isNotEmpty) {
        selectedByAttribute['MATERIAL NAME'] = pd.selectedMaterial!;
        selectedByAttribute['material name'] = pd.selectedMaterial!;
      }
      
      // Add selectedHeelHeightCm if available
      if (pd.selectedHeelHeightCm != null) {
        final heightStr = pd.selectedHeelHeightCm!.toStringAsFixed(1);
        selectedByAttribute['HEIGHT'] = heightStr;
        selectedByAttribute['height'] = heightStr;
      }
      
      // Find matching variant - must match all selected attributes.
      // Use _getComboValueForAttribute so we match regardless of API attribute names.
      // For color, use bilingual match (Arabic displayName <-> English variant value).
      final matching = pd.variantCombinations.where((combo) {
        for (final entry in selectedByAttribute.entries) {
          final v = _getComboValueForAttribute(pd, combo, entry.key);
          final bool match = _isColorAttributeKey(entry.key)
              ? _colorValuesMatch(pd, v, entry.value)
              : (v != null && normalize(v) == normalize(entry.value));
          if (!match) return false;
        }
        return true;
      }).toList();
      
      if (matching.length == 1) {
        return matching.first;
      } else if (matching.length > 1) {
        // If multiple matches, prefer one with highest available stock
        matching.sort((a, b) {
          final qtyA = a.quantityAvailable ?? 0;
          final qtyB = b.quantityAvailable ?? 0;
          return qtyB.compareTo(qtyA); // Sort descending by stock
        });
        developer.log('🔍 Multiple variants matched, selected one with highest stock: variantId=${matching.first.variantId}, quantityAvailable=${matching.first.quantityAvailable}');
        return matching.first;
      }
      
      // If no exact match, try partial match (at least size and color)
      if (selectedSizeValue != null && selectedColorValue != null) {
        final sizeValue = selectedSizeValue;
        final colorValue = selectedColorValue;
        final partialMatch = pd.variantCombinations.where((combo) {
          final comboSize = _getComboValueForAttribute(pd, combo, 'SIZE');
          final comboColor = _getComboValueForAttribute(pd, combo, 'COLOR NAME');
          final sizeMatch = comboSize != null && normalize(comboSize) == normalize(sizeValue);
          final colorMatch = _colorValuesMatch(pd, comboColor, colorValue);
          return sizeMatch && colorMatch;
        }).toList();
        
        if (partialMatch.isNotEmpty) {
          // Sort by highest stock when multiple partial matches
          partialMatch.sort((a, b) {
            final qtyA = a.quantityAvailable ?? 0;
            final qtyB = b.quantityAvailable ?? 0;
            return qtyB.compareTo(qtyA); // Sort descending by stock
          });
          developer.log('🔍 Partial match found, selected one with highest stock: variantId=${partialMatch.first.variantId}, quantityAvailable=${partialMatch.first.quantityAvailable}');
          return partialMatch.first;
        }
      }
      
      // Last resort: return first variant if available
      if (pd.variantCombinations.isNotEmpty) {
        return pd.variantCombinations.first;
      }
      
      return null;
    } catch (e) {
      developer.log('⚠️ Error finding selected variant: $e');
      return null;
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<ProductDetailsState> emit,
  ) async {
    developer.log('🛒 _onAddToCart called with event: ${event.toString()}');
    
    if (state is ProductDetailsLoaded) {
      final currentState = state as ProductDetailsLoaded;
      developer.log('📱 Current state: ProductDetailsLoaded with quantity: ${currentState.quantity}');
      
      final pd = currentState.productDetails;
      
      // STEP 1: Determine the correct variant ID FIRST (before stock validation)
      developer.log('🔍 Step 1: Determining variant ID to add...');
      String productIdToAdd = event.productId;
      VariantCombination? targetVariant;
      try {
        // Build selected pairs using attribute_id and value_id
        // Helper to resolve attribute_id for an attribute name from variant_combinations
        String? findAttributeIdByName(String attributeName) {
          for (final combo in pd.variantCombinations) {
            for (final a in combo.attributes) {
              if (a.attributeName.toLowerCase() == attributeName.toLowerCase()) {
                return a.attributeId?.toString() ?? '';
              }
            }
          }
          return null;
        }

        // Build a lookup: attribute_id -> (value_name_lower -> value_id_from_combinations)
        final Map<String, Map<String, String>> attrIdNameToId = {};
        for (final combo in pd.variantCombinations) {
          for (final a in combo.attributes) {
            final String attrId = (a.attributeId ?? '').toString();
            final String valueId = (a.valueId ?? '').toString();
            final String valueNameKey = (a.valueName).toLowerCase().trim();
            if (attrId.isEmpty || valueId.isEmpty || valueNameKey.isEmpty) continue;
            attrIdNameToId.putIfAbsent(attrId, () => {});
            attrIdNameToId[attrId]![valueNameKey] = valueId;
          }
        }

        // structure to hold selected attr_id -> value_id (mapped via value name when needed)
        final Map<String, String> selectedByAttrId = {};

        // Add selected size/primary variant
        if (pd.selectedSize.isNotEmpty) {
          final String? attrId = findAttributeIdByName(pd.primaryVariantLabel);
          // find value_id for selected size from options (by name)
          final valName = pd.selectedSize;
          if ((attrId ?? '').isNotEmpty && valName.isNotEmpty) {
            final mapped = attrIdNameToId[attrId!]?[(valName.toLowerCase().trim())] ?? '';
            if (mapped.isNotEmpty) {
              selectedByAttrId[attrId] = mapped;
              developer.log('📏 Added size to matching: attr_id=$attrId, value_id=$mapped, value_name=$valName');
            }
          }
        }

        // Add selected color (CRITICAL: must include color to match correct variant)
        if (pd.selectedColor.isNotEmpty) {
          // Try multiple color attribute name variations
          final List<String> colorAttrNames = ['COLOR NAME', 'COLOR', 'COLOUR', 'اللون', 'color name', 'color'];
          String? colorAttrId;
          String? colorValueId;
          
          for (final colorAttrName in colorAttrNames) {
            colorAttrId = findAttributeIdByName(colorAttrName);
            if (colorAttrId != null && colorAttrId.isNotEmpty) {
              final colorValName = pd.selectedColor;
              final mapped = attrIdNameToId[colorAttrId]?[(colorValName.toLowerCase().trim())] ?? '';
              if (mapped.isNotEmpty) {
                colorValueId = mapped;
                break;
              }
            }
          }
          
          if (colorAttrId != null && colorAttrId.isNotEmpty && colorValueId != null && colorValueId.isNotEmpty) {
            selectedByAttrId[colorAttrId] = colorValueId;
            developer.log('🎨 Added color to matching: attr_id=$colorAttrId, value_id=$colorValueId, value_name=${pd.selectedColor}');
          } else {
            developer.log('⚠️ Could not find color attribute_id or value_id for color: ${pd.selectedColor}');
          }
        }

        // Add selected material if available
        if (pd.selectedMaterial != null && pd.selectedMaterial!.isNotEmpty) {
          final List<String> materialAttrNames = ['MATERIAL NAME', 'MATERIAL', 'material name', 'material'];
          String? materialAttrId;
          String? materialValueId;
          
          for (final materialAttrName in materialAttrNames) {
            materialAttrId = findAttributeIdByName(materialAttrName);
            if (materialAttrId != null && materialAttrId.isNotEmpty) {
              final materialValName = pd.selectedMaterial!;
              final mapped = attrIdNameToId[materialAttrId]?[(materialValName.toLowerCase().trim())] ?? '';
              if (mapped.isNotEmpty) {
                materialValueId = mapped;
                break;
              }
            }
          }
          
          if (materialAttrId != null && materialAttrId.isNotEmpty && materialValueId != null && materialValueId.isNotEmpty) {
            selectedByAttrId[materialAttrId] = materialValueId;
            developer.log('🧵 Added material to matching: attr_id=$materialAttrId, value_id=$materialValueId, value_name=${pd.selectedMaterial}');
          }
        }

        // Add selected heel height if available
        if (pd.selectedHeelHeightCm != null) {
          final List<String> heightAttrNames = ['HEIGHT', 'HEEL HEIGHT', 'heel height', 'height'];
          String? heightAttrId;
          String? heightValueId;
          
          for (final heightAttrName in heightAttrNames) {
            heightAttrId = findAttributeIdByName(heightAttrName);
            if (heightAttrId != null && heightAttrId.isNotEmpty) {
              // Convert heel height to string (e.g., 4.5 -> "4.5")
              final heightValName = pd.selectedHeelHeightCm!.toStringAsFixed(1);
              final mapped = attrIdNameToId[heightAttrId]?[(heightValName.toLowerCase().trim())] ?? '';
              if (mapped.isNotEmpty) {
                heightValueId = mapped;
                break;
              }
            }
          }
          
          if (heightAttrId != null && heightAttrId.isNotEmpty && heightValueId != null && heightValueId.isNotEmpty) {
            selectedByAttrId[heightAttrId] = heightValueId;
            developer.log('👠 Added heel height to matching: attr_id=$heightAttrId, value_id=$heightValueId, value_name=${pd.selectedHeelHeightCm}');
          }
        }

        // Add other dynamic attributes from variantAttributeOptions
        for (final opt in pd.variantAttributeOptions) {
          if (opt.selectedValue.isEmpty) continue;
          final String? attrId = findAttributeIdByName(opt.attributeName);
          final valName = opt.selectedValue;
          if ((attrId ?? '').isNotEmpty && valName.isNotEmpty) {
            final mapped = attrIdNameToId[attrId!]?[(valName.toLowerCase().trim())] ?? '';
            if (mapped.isNotEmpty) {
              selectedByAttrId[attrId] = mapped;
              developer.log('🔧 Added ${opt.attributeName} to matching: attr_id=$attrId, value_id=$mapped, value_name=$valName');
            }
          }
        }

        developer.log('🎯 Variant resolution (by ids) — ' + selectedByAttrId.entries.map((e) => 'attr_id=${e.key}:value_id=${e.value}').join(', '));

        bool matchesAll(VariantCombination v) {
          // For each selected pair attr_id -> value_id there must be an attribute in the variant with same ids
          for (final entry in selectedByAttrId.entries) {
            final String attrId = entry.key;
            final String valId = entry.value;
            final bool hasPair = v.attributes.any((a) =>
              (a.attributeId?.toString() ?? '') == attrId && (a.valueId?.toString() ?? '') == valId
            );
            if (!hasPair) return false;
          }
          return true;
        }

        // Try to find exact match by attribute IDs
        final matchingVariants = pd.variantCombinations.where((v) => matchesAll(v)).toList();
        
        if (matchingVariants.length == 1) {
          final matched = matchingVariants.first;
          developer.log('✅ Matched variantId=${matched.variantId} with attributes: '+
            matched.attributes.map((a) => '${a.attributeName}:${a.valueName}').join(', '));
          productIdToAdd = matched.variantId;
          targetVariant = matched;
        } else if (matchingVariants.length > 1) {
          developer.log('⚠️ Multiple variants matched (${matchingVariants.length}). Using first match.');
          final matched = matchingVariants.first;
          productIdToAdd = matched.variantId;
          targetVariant = matched;
        } else {
          // No exact match by IDs - try matching by attribute names as fallback
          developer.log('⚠️ No exact match by IDs. Trying fallback matching by attribute names...');
          final Map<String, String> selectedByAttributeName = {};
          
          if (pd.selectedSize.isNotEmpty) {
            selectedByAttributeName[pd.primaryVariantLabel] = pd.selectedSize;
            selectedByAttributeName['size'] = pd.selectedSize;
            selectedByAttributeName['SIZE'] = pd.selectedSize;
          }
          
          if (pd.selectedColor.isNotEmpty) {
            selectedByAttributeName['color'] = pd.selectedColor;
            selectedByAttributeName['colour'] = pd.selectedColor;
            selectedByAttributeName['COLOR NAME'] = pd.selectedColor;
            selectedByAttributeName['اللون'] = pd.selectedColor;
          }
          
          if (pd.selectedMaterial != null && pd.selectedMaterial!.isNotEmpty) {
            selectedByAttributeName['MATERIAL NAME'] = pd.selectedMaterial!;
            selectedByAttributeName['material name'] = pd.selectedMaterial!;
          }
          
          if (pd.selectedHeelHeightCm != null) {
            final heightStr = pd.selectedHeelHeightCm!.toStringAsFixed(1);
            selectedByAttributeName['HEIGHT'] = heightStr;
            selectedByAttributeName['height'] = heightStr;
          }
          
          for (final opt in pd.variantAttributeOptions) {
            if (opt.selectedValue.isNotEmpty) {
              selectedByAttributeName[opt.attributeName] = opt.selectedValue;
            }
          }
          
          final nameMatchedVariants = pd.variantCombinations.where((v) {
            for (final entry in selectedByAttributeName.entries) {
              final vVal = v.getAttributeValue(entry.key);
              if (vVal == null || vVal.toLowerCase() != entry.value.toLowerCase()) {
                return false;
              }
            }
            return true;
          }).toList();
          
          if (nameMatchedVariants.length == 1) {
            final matched = nameMatchedVariants.first;
            developer.log('✅ Matched by attribute names: variantId=${matched.variantId}');
            productIdToAdd = matched.variantId;
            targetVariant = matched;
          } else if (nameMatchedVariants.length > 1) {
            developer.log('⚠️ Multiple variants matched by names (${nameMatchedVariants.length}). Using first match.');
            final matched = nameMatchedVariants.first;
            productIdToAdd = matched.variantId;
            targetVariant = matched;
          } else {
            // Final fallback: use selected size option's variant id if available
            final SizeOption selectedSize = pd.sizeOptions.firstWhere(
              (s) => s.isSelected,
              orElse: () => pd.sizeOptions.isNotEmpty ? pd.sizeOptions.first : const SizeOption(id: '', name: '', isAvailable: false, isRecommended: false, isSelected: false),
            );
            if (selectedSize.id.isNotEmpty) {
              productIdToAdd = selectedSize.id;
              developer.log('⚠️ No match found. Falling back to sizeOption.variantId=${selectedSize.id} for size="${selectedSize.name}"');
              // Try to find variant by this ID
              try {
                targetVariant = pd.variantCombinations.firstWhere(
                  (v) => v.variantId == productIdToAdd,
                );
              } catch (_) {
                developer.log('❌ Could not find variant with variantId=$productIdToAdd');
              }
            } else {
              developer.log('❌ No matching variant found and no size variantId available, using productId=${productIdToAdd}');
              // Try to find variant by productId
              try {
                targetVariant = pd.variantCombinations.firstWhere(
                  (v) => v.variantId == productIdToAdd,
                );
              } catch (_) {
                developer.log('❌ Could not find variant with variantId=$productIdToAdd');
              }
            }
          }
        }
      } catch (e) {
        developer.log('⚠️ Error resolving variant ID: $e');
      }
      
      // If we still don't have a target variant, try to find it by the resolved productIdToAdd
      if (targetVariant == null && productIdToAdd.isNotEmpty) {
        try {
          targetVariant = pd.variantCombinations.firstWhere(
            (v) => v.variantId == productIdToAdd,
          );
          developer.log('✅ Found target variant by productIdToAdd: ${targetVariant.variantId}');
        } catch (_) {
          developer.log('⚠️ Could not find variant with variantId=$productIdToAdd');
        }
      }
      
      // STEP 2: Validate stock on the TARGET variant (the one we're actually adding)
      developer.log('🔍 Step 2: Validating stock for variantId=$productIdToAdd');
      int quantityToAdd = currentState.quantity;
      bool quantityWasClamped = false;
      
      if (targetVariant != null) {
        developer.log('📦 Target variant: variantId=${targetVariant.variantId}, inStock=${targetVariant.inStock}, quantityAvailable=${targetVariant.quantityAvailable}');
        
        // Check inStock first
        if (!targetVariant.inStock) {
          developer.log('❌ Variant is marked as out of stock');
          final isArabic = AppLocalizationService().currentLocale.languageCode == 'ar';
          final msg = isArabic
              ? 'هذا المنتج غير متوفر حالياً في المخزون.'
              : 'This product is currently out of stock.';
          emit(ProductDetailsError(msg));
          return;
        }
        
        // Check quantityAvailable
        final quantityAvailable = targetVariant.quantityAvailable;
        if (quantityAvailable != null) {
          if (quantityAvailable <= 0) {
            developer.log('❌ Variant quantityAvailable is 0 or negative');
            final isArabic = AppLocalizationService().currentLocale.languageCode == 'ar';
            final msg = isArabic
                ? 'هذا المنتج غير متوفر حالياً في المخزون.'
                : 'This product is currently out of stock.';
            emit(ProductDetailsError(msg));
            return;
          }
          
          // Check if there's already an item in cart with this variant ID
          int existingCartQuantity = 0;
          final variantIdToCheck = targetVariant.variantId;
          if (cartBloc.state is CartLoaded) {
            final cartState = cartBloc.state as CartLoaded;
            try {
              final existingItem = cartState.cartItems.firstWhere(
                (item) => item.product.id == variantIdToCheck,
              );
              existingCartQuantity = existingItem.quantity;
              developer.log('📋 Found existing cart item: quantity=$existingCartQuantity');
            } catch (e) {
              developer.log('ℹ️ Item not found in cart, using 0 for existing quantity');
            }
          }
          
          // Calculate available quantity (total available - already in cart)
          final maxAllowed = quantityAvailable.toInt();
          final available = maxAllowed - existingCartQuantity;
          
          developer.log('🔢 Stock check: quantity=${currentState.quantity}, existingCart=$existingCartQuantity, maxAllowed=$maxAllowed, available=$available');
          
          // If user tries to add more than available, clamp to available quantity
          if (currentState.quantity > available && available > 0) {
            quantityToAdd = available;
            quantityWasClamped = true;
            developer.log('⚠️ Quantity clamped from ${currentState.quantity} to $quantityToAdd (available: $available)');
          }
        } else {
          developer.log('⚠️ quantityAvailable is null, but inStock=true. Proceeding with stock check...');
        }
      } else {
        developer.log('⚠️ Could not find target variant for stock validation. Proceeding anyway...');
      }
      
      emit(currentState.copyWith(isAdding: true));
      developer.log('⏳ Emitting loading state...');
      
      developer.log('🚀 Calling addToCart use case...');

      developer.log('📤 addToCart payload — productIdToAdd=$productIdToAdd, colorId=${event.colorId}, sizeId=${event.sizeId}, qty=$quantityToAdd');
      final result = await addToCart(AddToCartParams(
        productId: productIdToAdd,
        colorId: event.colorId,
        sizeId: event.sizeId,
        quantity: quantityToAdd,
      ));
      
      developer.log('📦 addToCart result received: ${result.toString()}');
      
      result.fold(
        (failure) {
          developer.log('❌ Add to cart failed: ${failure.message}');
          
          // Check if this is a stock-related error - if so, don't show error since we already clamped
          final lowerMessage = failure.message.toLowerCase();
          final isStockError = lowerMessage.contains('available') || 
                              lowerMessage.contains('stock') ||
                              lowerMessage.contains('quantity') ||
                              lowerMessage.contains('exceed');
          
          if (isStockError) {
            // For stock errors, we've already clamped, so just refresh cart and show success
            developer.log('⚠️ Stock error from API (should not happen after clamping), refreshing cart state');
            cartBloc.add(const RefreshCart());
            
            // If quantity was clamped, show the clamped dialog, otherwise just close
            if (quantityWasClamped) {
              final isArabic = AppLocalizationService().currentLocale.languageCode == 'ar';
              final message = isArabic
                  ? 'تم إضافة جميع الكمية المتاحة ($quantityToAdd قطعة) إلى السلة.'
                  : 'We added all available quantity ($quantityToAdd item(s)) to your cart.';
              emit(ProductDetailsQuantityClamped(message, quantityToAdd));
            } else {
              emit(currentState.copyWith(isAdding: false));
            }
          } else {
            // For non-stock errors, show the error
            emit(ProductDetailsError(failure.message));
          }
        },
        (cartItem) {
          developer.log('✅ Cart item added successfully via API: ${cartItem.toString()}');
          
          // The item has already been added to the cart via the API in the repository
          // Just refresh the cart to get the updated state
          developer.log('🔄 Refreshing cart to get updated state...');
          cartBloc.add(const RefreshCart());
          
          // If quantity was clamped, emit a special state to show dialog
          if (quantityWasClamped) {
            final isArabic = AppLocalizationService().currentLocale.languageCode == 'ar';
            final message = isArabic
                ? 'تم إضافة جميع الكمية المتاحة ($quantityToAdd قطعة) إلى السلة.'
                : 'We added all available quantity ($quantityToAdd item(s)) to your cart.';
            emit(ProductDetailsQuantityClamped(message, quantityToAdd));
          } else {
            emit(currentState.copyWith(isAdding: false));
          }
          developer.log('✅ Final state emitted: isAdding = false');
        },
      );
    } else {
      developer.log('⚠️ State is not ProductDetailsLoaded: ${state.runtimeType}');
    }
  }

  void _onIncrementQty(
    IncrementQuantityEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is ProductDetailsLoaded) {
      final s = state as ProductDetailsLoaded;
      final pd = s.productDetails;
      
      // Find the currently selected variant
      final selectedVariant = _findSelectedVariant(pd);
      if (selectedVariant == null) {
        developer.log('⚠️ Cannot find selected variant, allowing increment');
        final newQuantity = s.quantity + 1;
        emit(s.copyWith(quantity: newQuantity));
        return;
      }
      
      // Get available quantity for this variant
      final quantityAvailable = selectedVariant.quantityAvailable ?? double.infinity;
      if (quantityAvailable == 0) {
        developer.log('⚠️ Product is out of stock, cannot increment');
        return;
      }
      
      // Check if there's already an item in cart with this variant ID
      int existingCartQuantity = 0;
      if (cartBloc.state is CartLoaded) {
        final cartState = cartBloc.state as CartLoaded;
        try {
          final existingItem = cartState.cartItems.firstWhere(
            (item) => item.product.id == selectedVariant.variantId,
          );
          existingCartQuantity = existingItem.quantity;
        } catch (e) {
          // Item not found in cart, existingCartQuantity remains 0
          developer.log('ℹ️ Item not found in cart, using 0 for existing quantity');
        }
      }
      
      // Calculate total quantity (current selection + already in cart)
      final totalQuantity = s.quantity + existingCartQuantity;
      final maxAllowed = quantityAvailable.toInt();
      
      // Always prevent incrementing if it would exceed available stock
      if (totalQuantity >= maxAllowed) {
        developer.log('⚠️ Cannot increment: total quantity ($totalQuantity) would exceed available stock ($maxAllowed)');
        // Don't emit error, just silently prevent the increment
        return;
      }
      
      final newQuantity = s.quantity + 1;
      developer.log('➕ Incrementing quantity from ${s.quantity} to $newQuantity (available: $maxAllowed, in cart: $existingCartQuantity)');
      emit(s.copyWith(quantity: newQuantity));
    }
  }

  void _onDecrementQty(
    DecrementQuantityEvent event,
    Emitter<ProductDetailsState> emit,
  ) {
    if (state is ProductDetailsLoaded) {
      final s = state as ProductDetailsLoaded;
      if (s.quantity > 1) {
        final newQuantity = s.quantity - 1;
        developer.log('➖ Decrementing quantity from ${s.quantity} to $newQuantity');
        emit(s.copyWith(quantity: newQuantity));
      } else {
        developer.log('⚠️ Cannot decrement quantity below 1 (current: ${s.quantity})');
      }
    }
  }
}
