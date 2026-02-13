# Material Issue - Root Cause and Solution

## 🔍 What's Happening (Based on Your Logs)

### Your Console Log:

```
📌 Found selectedValue for "MATERIAL NAME" (matched with "MATERIALS"): "Leather Finish"
⚠️ Using existing selection "Leather Finish" for "MATERIAL NAME" 
   (no enabled values computed yet)
```

### What This Means:

1. ✅ System found "Leather Finish" as the selected material
2. ❌ But `enabledValues` is **empty** for materials
3. ❌ So it shows as **disabled/grey**

---

## 🐛 The Bug in Your Current Code

### Problem 1: Mixed Enabled Values

Your log shows:
```
✅ Matched attribute "height" with UI attribute "HEIGHT" 
   → enabled values: [35, leather finish, 10.5]
```

**This is wrong!** Enabled values should be:
- For HEIGHT: `[10.5, 4.5, 4, 2.8]` ← Only height values
- For MATERIAL: `[Leather Finish, Synthetic Leather]` ← Only material values  
- For SIZE: `[35, 36, 37, 38]` ← Only size values

But your code is returning: `[35, leather finish, 10.5]` ← **Mixed!**

### Problem 2: Case Sensitivity

```dart
// Your current code:
enabledValues = ["35", "leather finish", "10.5"]  // ← lowercase

// When checking:
if (enabledValues.contains("Leather Finish")) {  // ← Capital L
  // FALSE! Because "Leather Finish" != "leather finish"
}
```

### Problem 3: Empty Set for Materials

```dart
// Your current code returns:
enabledAttributesForSelection = {
  "height": {"35", "leather finish", "10.5"},  // ← Mixed values
  "material": {},  // ← EMPTY! This is why material is disabled
  "size": {"35"}
}
```

---

## 🎯 Visual Explanation

### Current Flow (Broken):

```
User selects: SIZE=35, HEIGHT=10.5, COLOR=BEIGE
                    ↓
getEnabledValuesForCurrentSelection()
                    ↓
Loop through 433 variants
                    ↓
For each variant, collect ALL attribute values
                    ↓
Result: {
  "height": ["35", "leather finish", "10.5"],  ← MIXED!
  "material": [],  ← EMPTY!
  "size": ["35"]
}
                    ↓
UI checks: Is "Leather Finish" in material enabled values?
                    ↓
Result: NO (empty set)
                    ↓
Material shows as DISABLED (grey)
```

### Correct Flow (With DynamicVariantController):

```
User selects: SIZE=35, HEIGHT=10.5, COLOR=BEIGE
                    ↓
controller.selectAttributeValue(sizeAttrId, 35)
                    ↓
selectedAttributes = {7: 35, 10: 10.5, 8: 306}
                    ↓
Calculate material availability:
  tempSelection = {7: 35, 10: 10.5, 8: 306}  ← Without material
                    ↓
Find variants matching SIZE=35 + HEIGHT=10.5 + COLOR=BEIGE
                    ↓
Variant 6200: SIZE=35 + HEIGHT=10.5 + COLOR=BEIGE + MATERIAL=Leather Finish
              inStock=true, qty=5 ✅
                    ↓
Variant 6201: SIZE=35 + HEIGHT=10.5 + COLOR=BEIGE + MATERIAL=Synthetic Leather
              inStock=false, qty=0 ❌
                    ↓
Result: availableValueIds = {301}  ← Only Leather Finish
                    ↓
UI checks: Is valueId 301 in available values?
                    ↓
Result: YES
                    ↓
Material shows as ENABLED (blue/orange)
```

---

## 🔧 The Fix Code

### Replace This Section in product_info_section.dart:

#### FIND (around line 760-870):

```dart
// ❌ DELETE ALL THIS
final Map<String, Set<String>> enabledAttributesForSelection =
    productDetails.getEnabledValuesForCurrentSelection();

final Map<String, Set<String>> enabledAttributesForColor =
    (enabledAttributesForSelection.isEmpty &&
            productDetails.variantCombinations.isNotEmpty &&
            productDetails.selectedColor.isNotEmpty)
        ? productDetails
            .getEnabledAttributeValuesForColor(productDetails.selectedColor)
        : const <String, Set<String>>{};

Set<String> enabledValuesForThisAttribute = {};
String norm(String s) => s.toLowerCase().trim();
final normalizedAttrName = norm(attributeName);

for (final entry in enabledAttributesForSelection.entries) {
  final normalizedEntryName = norm(entry.key);
  if (normalizedEntryName == normalizedAttrName) {
    enabledValuesForThisAttribute =
        entry.value.map((v) => norm(v)).toSet();
    debugPrint(
        '✅ Matched attribute "${entry.key}" with UI attribute "$attributeName" from full selection → enabled values: ${enabledValuesForThisAttribute.toList()}');
    break;
  }
}

if (enabledValuesForThisAttribute.isEmpty &&
    enabledAttributesForColor.isNotEmpty) {
  for (final entry in enabledAttributesForColor.entries) {
    final normalizedEntryName = norm(entry.key);
    final bool nameMatches = normalizedEntryName == normalizedAttrName ||
        normalizedEntryName.contains(normalizedAttrName) ||
        normalizedAttrName.contains(normalizedEntryName);
    
    final bool isMaterialMatch = 
        (normalizedEntryName.contains('material') && normalizedAttrName.contains('material')) ||
        (normalizedEntryName == 'materials' && normalizedAttrName == 'material name') ||
        (normalizedEntryName == 'material name' && normalizedAttrName == 'materials');
    
    if (nameMatches || isMaterialMatch) {
      enabledValuesForThisAttribute = entry.value.map((v) => norm(v)).toSet();
      debugPrint(
          '✅ Matched attribute "${entry.key}" with UI attribute "$attributeName" from color map → enabled values: ${enabledValuesForThisAttribute.toList()}');
      break;
    }
  }
}

// ... more complex logic for auto-select ...
```

#### REPLACE WITH:

```dart
// ✅ ADD THIS - SIMPLE AND FAST
// Get attribute option
final attrOption = productDetails.variantAttributeOptions.firstWhere(
  (opt) => opt.attributeName == attributeName,
  orElse: () => VariantAttributeOption(
    attributeName: '',
    values: [],
    selectedValue: '',
  ),
);

if (attrOption.attributeName.isEmpty) return const SizedBox.shrink();

// Get attribute ID
final attributeId = int.tryParse(attrOption.attributeId ?? '');
if (attributeId == null) {
  debugPrint('⚠️ No valid attribute_id for $attributeName');
  return const SizedBox.shrink();
}

// Get available values (FAST - uses ID-based matching)
final availableValueIds = variantController?.getAvailableValuesForAttribute(attributeId) ?? <int>{};

// Get selected value (FAST - O(1) lookup)
final selectedValueId = variantController?.selectedAttributes[attributeId];

debugPrint('🎯 $attributeName: attributeId=$attributeId, available=${availableValueIds.length}, selected=$selectedValueId');
```

#### FIND (around line 880-980):

```dart
// ❌ DELETE THIS
final val = value as VariantAttributeValue;

// ... 50+ lines of complex selection logic ...

bool effectiveIsAvailable = false;
if (productDetails.selectedColor.isNotEmpty &&
    enabledValuesForThisAttribute.isNotEmpty) {
  effectiveIsAvailable =
      enabledValuesForThisAttribute.contains(norm(val.name));
} else if (productDetails.selectedColor.isEmpty) {
  effectiveIsAvailable = val.isAvailable;
}

bool isSelected = false;
final normalizedValName = norm(val.name);

if (valueToAutoSelect != null) {
  final normalizedAutoSelect = norm(valueToAutoSelect!);
  if (normalizedValName == normalizedAutoSelect &&
      enabledValuesForThisAttribute.contains(normalizedAutoSelect)) {
    isSelected = true;
    debugPrint('✅ Auto-selecting "$normalizedValName" for attribute "$attributeName" (from loop)');
  }
}

// ... more complex logic ...
```

#### REPLACE WITH:

```dart
// ✅ ADD THIS - SIMPLE
final val = value as VariantAttributeValue;
final valueId = int.tryParse(val.id);

if (valueId == null) {
  debugPrint('⚠️ No valid value_id for ${val.name}');
  return const SizedBox.shrink();
}

// Simple, fast checks
final isSelected = selectedValueId == valueId;
final isAvailable = availableValueIds.contains(valueId);
final isEnabled = !isSelected && isAvailable;
final showDisabled = !isAvailable;

debugPrint('   ${val.name}: selected=$isSelected, available=$isAvailable, enabled=$isEnabled');
```

---

## 🧪 Expected Results

### Console Output After Fix:

```
🎯 MATERIAL NAME: attributeId=9, available=2, selected=301
   Leather Finish: selected=true, available=true, enabled=false
   Synthetic Leather: selected=false, available=true, enabled=true
   PRINTED COVER: selected=false, available=false, enabled=false
```

### UI After Fix:

```
MATERIAL NAME
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Leather Finish   │  │Synthetic Leather │  │ PRINTED COVER    │
│                  │  │  Only 3 left     │  │                  │
└──────────────────┘  └──────────────────┘  └──────────────────┘
  ↑ SELECTED (BLUE)     ↑ ENABLED (ORANGE)    ↑ DISABLED (GREY)
     Qty: 5                Qty: 3                Qty: 0
```

---

## ✅ Verification Checklist

After applying the fix:

- [ ] Material "Leather Finish" shows as enabled (blue when selected)
- [ ] Other materials show correct availability
- [ ] Low stock items show "Only X left" warning
- [ ] Out of stock items show as disabled (grey)
- [ ] Selection is instant (<50ms, no freeze)
- [ ] Console shows clean logs (not 433+ lines)
- [ ] All attributes work dynamically
- [ ] No "no enabled values computed yet" warning

---

## 🚀 Quick Start

1. **Copy** `dynamic_variant_controller.dart` to your project
2. **Follow** the code replacement above
3. **Test** - material should work!
4. **Verify** - check console logs

**Time**: 15 minutes  
**Result**: Material works correctly with stock checking! 🎉

---

**Last Updated**: February 11, 2026  
**Status**: ✅ Complete Solution Ready
