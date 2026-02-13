# 🐞 Variant Selection Issue – Unintended Auto Switching & State Reset

## Problem Description

Currently, when the user changes a single attribute (e.g., **Size**), the system automatically switches to a full matching variant returned from the backend.

This causes:

- Other selected attributes (Color, Material, Height, etc.) to change automatically
- Previously selected options to be reset
- UI state inconsistency
- Unexpected navigation behavior
- Poor user experience

### Example Scenario

1. **Default selection:**
   - Size: 40
   - Color: White
   - Material: Suede Leather

2. **User changes Size from 40 to 38** (single click only)

   **Expected:**
   - Only Size should change to 38
   - Color and Material should remain unchanged (White, Suede Leather)

   **Actual:**
   - The system auto-selects a different full variant
   - Other attributes change automatically (e.g., Color changes to Black, Material changes to Leather)

3. **When switching back from 38 to 40:**
   - Other attributes get cleared or mismatched
   - UI loses the previous selection state

---

## 🎯 Expected Behavior

The UI must be **selection-driven, not variant-driven**.

### Requirements:

1. ✅ **Changing one attribute must NOT auto-change other attributes**
   - When user selects Size: 38, only Size should update
   - All other selected attributes (Color, Material, Height, Width, etc.) must remain unchanged

2. ✅ **Preserve all existing user selections**
   - Maintain a `selectedAttributes` state object: `Map<int attributeId, int valueId>`
   - Update only the changed attribute in this map
   - Never clear or reset other selections unless explicitly invalid

3. ✅ **Validate availability after attribute change**
   - After any attribute change:
     - Validate the current combination against `variant_combinations` or `attribute_value_combinations`
     - If unavailable → show "Out of stock" message
     - Disable "Add to Cart" button if combination is invalid
     - Do NOT auto-switch to another variant

4. ✅ **No full variant override**
   - No full variant should be fetched and applied when a single attribute changes
   - The system should work with the existing `variant_combinations` data
   - No backend API call should be triggered for variant selection

5. ✅ **State consistency**
   - State must remain consistent when switching back and forth between values
   - Previous selections should be remembered and restored when valid

---

## 🔧 Technical Implementation

### Current Problem

The system currently:
- Fetches and applies a full variant on every attribute change
- Overwrites `selectedAttributes` with all attributes from the matched variant
- Causes unintended side effects on other attributes

### Required Solution

Instead of:
```dart
// ❌ WRONG: Fetching full variant and applying all attributes
final variant = await fetchVariantFromBackend(selectedSize);
productDetails.selectedColor = variant.color;  // Auto-changes color!
productDetails.selectedMaterial = variant.material;  // Auto-changes material!
```

We should:
```dart
// ✅ CORRECT: Update only the changed attribute
selectedAttributes[attributeId] = valueId;  // Only update Size

// Then validate availability
final isValid = validateCombination(selectedAttributes);
if (!isValid) {
  showOutOfStock();
  disableAddToCart();
} else {
  updatePriceAndStock(selectedAttributes);
}
```

### Implementation Steps

1. **Maintain `selectedAttributes` state**
   - Use `Map<int attributeId, int valueId>` to track user selections
   - Update only the changed attribute: `selectedAttributes[changedAttributeId] = newValueId`
   - Preserve all other entries in the map

2. **Validate combination without auto-switching**
   - After updating `selectedAttributes`, find matching variants:
     ```dart
     final matchingVariants = variantCombinations.where((variant) {
       return variantMatchesSelection(variant, selectedAttributes);
     }).toList();
     ```
   - If `matchingVariants.isEmpty`:
     - Set `inStock = false`
     - Show "Out of stock" message
     - Disable "Add to Cart" button
     - Do NOT auto-select a different variant

3. **Update UI state**
   - Update price from first matching variant (if exists)
   - Update stock quantity (sum from all matching variants)
   - Update variant images (if variant-specific images exist)
   - Keep all selected attributes visible in UI

4. **Handle invalid combinations gracefully**
   - When a combination becomes invalid (e.g., Size 38 + Color White doesn't exist):
     - Keep both selections visible
     - Show "Out of stock" indicator
     - Disable "Add to Cart"
     - Allow user to change either attribute to make it valid again

---

## 📋 Files to Modify

### Primary Files:
- `lib/features/product_details/presentation/bloc/product_details_bloc.dart`
  - Modify event handlers (`SelectSizeEvent`, `SelectColorEvent`, `FilterVariantsByAttributeEvent`)
  - Ensure they update only the changed attribute
  - Remove any logic that auto-selects full variants

- `lib/features/product_details/presentation/controllers/dynamic_variant_controller.dart`
  - The `selectAttributeValue()` method already follows the correct pattern
  - Verify `_clearConflictingAttributes()` doesn't clear too aggressively
  - Ensure `_updateMatchingVariant()` doesn't auto-select different attributes

### Secondary Files (if needed):
- `lib/features/product_details/presentation/widgets/dynamic_variant_selector.dart`
- `lib/features/product_details/presentation/widgets/color_selection_widget.dart`
- `lib/features/product_details/presentation/widgets/add_to_cart_bottom_sheet.dart`

---

## ✅ Acceptance Criteria

- [ ] Changing Size from 40 to 38 does NOT change Color or Material
- [ ] Changing any single attribute preserves all other selected attributes
- [ ] Invalid combinations show "Out of stock" without auto-switching
- [ ] "Add to Cart" button is disabled for invalid combinations
- [ ] Switching back and forth between values maintains previous selections
- [ ] No backend API calls are triggered for variant selection (use existing `variant_combinations`)
- [ ] UI state remains consistent throughout user interactions

---

## 🧪 Testing Scenarios

1. **Test Case 1: Single Attribute Change**
   - Select Size: 40, Color: White, Material: Suede
   - Change Size to 38
   - **Expected:** Only Size changes to 38, Color and Material remain White and Suede

2. **Test Case 2: Invalid Combination**
   - Select Size: 38, Color: White
   - If this combination doesn't exist:
     - **Expected:** "Out of stock" message appears, Add to Cart disabled
     - **Expected:** Both Size 38 and Color White remain selected
     - **Expected:** User can change either Size or Color to make it valid

3. **Test Case 3: Switching Back**
   - Select Size: 40, Color: White
   - Change Size to 38
   - Change Size back to 40
   - **Expected:** Color White is still selected (not reset)

4. **Test Case 4: Multiple Attributes**
   - Select Size: 40, Height: 2.8, Material: Suede, Width: 16
   - Change only Size to 38
   - **Expected:** Only Size changes, all other attributes remain unchanged

---

## 📝 Notes

- The `DynamicVariantController` already implements selection-driven logic correctly
- The issue might be in the BLoC event handlers that override the controller's behavior
- Ensure no code path fetches full variants from backend on attribute change
- Use `attribute_value_combinations` or `variant_combinations` for validation (already available in `ProductDetails`)

---

**Priority:** 🔴 High  
**Estimated Effort:** 4-6 hours  
**Assigned To:** [To be assigned]  
**Status:** 🟡 In Progress
