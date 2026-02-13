# Dynamic Variant Selection System - Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DYNAMIC VARIANT SYSTEM                          │
└─────────────────────────────────────────────────────────────────────────┘

                                    ▼
                                    
┌─────────────────────────────────────────────────────────────────────────┐
│                              API LAYER                                  │
├─────────────────────────────────────────────────────────────────────────┤
│  GET /api/products/{id}                                                 │
│  Returns:                                                               │
│  - variant_attributes (unlimited)                                       │
│  - variant_combinations (unlimited)                                     │
│  - selected_variant                                                     │
│  - images                                                               │
└─────────────────────────────────────────────────────────────────────────┘

                                    ▼
                                    
┌─────────────────────────────────────────────────────────────────────────┐
│                          DOMAIN LAYER                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  ProductDetails Entity                                                  │
│  - variantAttributeOptions: List<VariantAttributeOption>                │
│  - variantCombinations: List<VariantCombination>                        │
│  - variantImagesMap: Map<String, List<String>>                          │
└─────────────────────────────────────────────────────────────────────────┘

                                    ▼
                                    
┌─────────────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐    │
│  │         DynamicVariantController (State Management)           │    │
│  ├───────────────────────────────────────────────────────────────┤    │
│  │  State:                                                       │    │
│  │  - selectedAttributes: Map<int, int>                          │    │
│  │  - selectedVariant: VariantCombination?                       │    │
│  │  - currentPrice: double                                       │    │
│  │  - inStock: bool                                              │    │
│  │  - quantityAvailable: int                                     │    │
│  │  - variantId: String                                          │    │
│  │  - currentImages: List<String>                                │    │
│  │                                                               │    │
│  │  Methods:                                                     │    │
│  │  - initialize(ProductDetails)                                 │    │
│  │  - selectAttributeValue(attrId, valueId)                      │    │
│  │  - getAvailableValuesForAttribute(attrId)                     │    │
│  │  - isValueAvailable(attrId, valueId)                          │    │
│  └───────────────────────────────────────────────────────────────┘    │
│                                                                         │
│                              ▼                                          │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐    │
│  │         DynamicVariantSelector (UI Widget)                    │    │
│  ├───────────────────────────────────────────────────────────────┤    │
│  │  Renders:                                                     │    │
│  │  - All attributes dynamically                                 │    │
│  │  - Value buttons with states:                                 │    │
│  │    • Selected (primary color, white text)                     │    │
│  │    • Available (white bg, primary border)                     │    │
│  │    • Unavailable (grey, disabled)                             │    │
│  │  - Variant info display                                       │    │
│  │  - Price, stock, variant_id                                   │    │
│  └───────────────────────────────────────────────────────────────┘    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

                                    ▼
                                    
┌─────────────────────────────────────────────────────────────────────────┐
│                            USER INTERFACE                               │
├─────────────────────────────────────────────────────────────────────────┤
│  Product Details Page                                                   │
│  - Image Gallery (variant-specific)                                     │
│  - Product Info (name, brand, price)                                    │
│  - Dynamic Variant Selector                                             │
│  - Add to Cart Button (enabled/disabled)                                │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagram

### 1. Initialization Flow

```
┌──────────────┐
│  API Response│
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Parse variant_attributes                                     │
│ - Extract attribute_id, name, values                         │
│ - Build VariantAttributeOption list                          │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Parse variant_combinations                                   │
│ - Extract variant_id, price, stock, attributes               │
│ - Build VariantCombination list                              │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Parse selected_variant                                       │
│ - Extract attributes: [{attribute_id, value_id}, ...]        │
│ - Build initial selectedAttributes map                       │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Initialize DynamicVariantController                          │
│ - selectedAttributes = {8: 101, 7: 201, 9: 301}              │
│ - Find matching variant from variant_combinations            │
│ - Update price, stock, variant_id, images                    │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Render UI                                                    │
│ - Show all attributes dynamically                            │
│ - Mark selected values                                       │
│ - Enable/disable values based on availability                │
└──────────────────────────────────────────────────────────────┘
```

### 2. Selection Flow

```
┌──────────────┐
│ User taps    │
│ value button │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ selectAttributeValue(attributeId, valueId)                   │
│ - Update selectedAttributes[attributeId] = valueId           │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Find matching variant                                        │
│ - Loop through variant_combinations                          │
│ - Match ALL {attribute_id, value_id} pairs                   │
│ - Return matching variant or null                            │
└──────┬───────────────────────────────────────────────────────┘
       │
       ├─── Match found ───────────────┐
       │                               │
       ▼                               ▼
┌──────────────────────┐    ┌──────────────────────┐
│ Update state:        │    │ Set out of stock:    │
│ - selectedVariant    │    │ - selectedVariant=null│
│ - currentPrice       │    │ - inStock=false      │
│ - inStock=true       │    │ - quantityAvailable=0│
│ - quantityAvailable  │    │ - variantId=''       │
│ - variantId          │    └──────┬───────────────┘
│ - currentImages      │           │
└──────┬───────────────┘           │
       │                           │
       └───────────┬───────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────────────────┐
│ notifyListeners()                                            │
│ - Trigger UI rebuild                                         │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ UI updates automatically                                     │
│ - Selected value highlighted                                 │
│ - Other values enabled/disabled                              │
│ - Price updated                                              │
│ - Stock status updated                                       │
│ - Images updated                                             │
│ - Add to Cart button enabled/disabled                        │
└──────────────────────────────────────────────────────────────┘
```

### 3. Availability Calculation Flow

```
┌──────────────────────────────────────────────────────────────┐
│ getAvailableValuesForAttribute(attributeId)                  │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Build temporary selection                                    │
│ - Copy selectedAttributes                                    │
│ - Remove attributeId from copy                               │
│ - tempSelection = {8: 101, 9: 301} (without size)            │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Filter variant_combinations                                  │
│ - Keep only variants matching tempSelection                  │
│ - Keep only variants with inStock=true                       │
│ - Keep only variants with quantityAvailable > 0              │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Collect available value_ids                                  │
│ - Loop through filtered variants                             │
│ - Extract value_id for attributeId                           │
│ - Add to availableValueIds set                               │
└──────┬───────────────────────────────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────────────────────────────┐
│ Return availableValueIds                                     │
│ - Example: {201, 202, 203} (sizes 36, 37, 38)                │
└──────────────────────────────────────────────────────────────┘
```

---

## Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Product Details Page                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐    │
│  │                    Image Gallery                              │    │
│  │  - Displays currentImages from controller                     │    │
│  │  - Updates when variant changes                               │    │
│  └───────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐    │
│  │                  Product Info                                 │    │
│  │  - Brand, Name, Description                                   │    │
│  │  - Price from controller.currentPrice                         │    │
│  └───────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐    │
│  │              DynamicVariantSelector                           │    │
│  │  ┌─────────────────────────────────────────────────────┐     │    │
│  │  │  ChangeNotifierProvider<DynamicVariantController>   │     │    │
│  │  │  ┌───────────────────────────────────────────────┐  │     │    │
│  │  │  │  Consumer<DynamicVariantController>           │  │     │    │
│  │  │  │  ┌─────────────────────────────────────────┐  │  │     │    │
│  │  │  │  │  For each attribute:                    │  │  │     │    │
│  │  │  │  │  ┌───────────────────────────────────┐  │  │  │     │    │
│  │  │  │  │  │  _AttributeSection                │  │  │  │     │    │
│  │  │  │  │  │  - Attribute name                 │  │  │  │     │    │
│  │  │  │  │  │  - Value buttons                  │  │  │  │     │    │
│  │  │  │  │  │    ┌─────────────────────────┐   │  │  │  │     │    │
│  │  │  │  │  │    │  _ValueButton           │   │  │  │  │     │    │
│  │  │  │  │  │    │  - Value name           │   │  │  │  │     │    │
│  │  │  │  │  │    │  - Selected state       │   │  │  │  │     │    │
│  │  │  │  │  │    │  - Available state      │   │  │  │  │     │    │
│  │  │  │  │  │    │  - onTap callback       │   │  │  │  │     │    │
│  │  │  │  │  │    └─────────────────────────┘   │  │  │  │     │    │
│  │  │  │  │  └───────────────────────────────────┘  │  │  │     │    │
│  │  │  │  │  ┌─────────────────────────────────┐  │  │  │     │    │
│  │  │  │  │  │  _VariantInfoDisplay            │  │  │  │     │    │
│  │  │  │  │  │  - Price                        │  │  │  │     │    │
│  │  │  │  │  │  - Stock status                 │  │  │  │     │    │
│  │  │  │  │  │  - Variant ID                   │  │  │  │     │    │
│  │  │  │  │  │  - Selected attributes          │  │  │  │     │    │
│  │  │  │  │  └─────────────────────────────────┘  │  │  │     │    │
│  │  │  │  └─────────────────────────────────────────┘  │  │     │    │
│  │  │  └───────────────────────────────────────────────┘  │     │    │
│  │  └─────────────────────────────────────────────────────┘     │    │
│  └───────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐    │
│  │                  Add to Cart Button                           │    │
│  │  - Enabled when controller.inStock == true                    │    │
│  │  - Disabled when controller.inStock == false                  │    │
│  └───────────────────────────────────────────────────────────────┘    │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## State Management Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DynamicVariantController                             │
│                    (extends ChangeNotifier)                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  State Variables:                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ selectedAttributes: Map<int, int>                               │  │
│  │ - Key: attribute_id (e.g., 8 for Color)                         │  │
│  │ - Value: value_id (e.g., 101 for Black)                         │  │
│  │ - Example: {8: 101, 7: 201, 9: 301}                             │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ selectedVariant: VariantCombination?                            │  │
│  │ - The matching variant from variant_combinations                │  │
│  │ - null if no match found                                        │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ Derived State:                                                  │  │
│  │ - currentPrice: double                                          │  │
│  │ - inStock: bool                                                 │  │
│  │ - quantityAvailable: int                                        │  │
│  │ - variantId: String                                             │  │
│  │ - currentImages: List<String>                                   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  State Changes:                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ 1. User selects value                                           │  │
│  │    ↓                                                            │  │
│  │ 2. selectAttributeValue(attrId, valueId)                        │  │
│  │    ↓                                                            │  │
│  │ 3. Update selectedAttributes                                    │  │
│  │    ↓                                                            │  │
│  │ 4. Find matching variant                                        │  │
│  │    ↓                                                            │  │
│  │ 5. Update derived state                                         │  │
│  │    ↓                                                            │  │
│  │ 6. notifyListeners()                                            │  │
│  │    ↓                                                            │  │
│  │ 7. UI rebuilds automatically                                    │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

                                    ▼

┌─────────────────────────────────────────────────────────────────────────┐
│                    UI Layer (Widgets)                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Consumer<DynamicVariantController>                                     │
│  - Listens to controller changes                                        │
│  - Rebuilds when notifyListeners() is called                            │
│  - Accesses controller state via context.watch()                        │
│                                                                         │
│  Widget Tree:                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ DynamicVariantSelector                                          │  │
│  │   ├─ ChangeNotifierProvider (provides controller)               │  │
│  │   └─ Consumer (listens to controller)                           │  │
│  │       ├─ _AttributeSection (for each attribute)                 │  │
│  │       │   └─ _ValueButton (for each value)                      │  │
│  │       │       └─ GestureDetector                                │  │
│  │       │           └─ onTap: controller.selectAttributeValue()   │  │
│  │       └─ _VariantInfoDisplay                                    │  │
│  │           ├─ Price (controller.currentPrice)                    │  │
│  │           ├─ Stock (controller.inStock)                         │  │
│  │           └─ Variant ID (controller.variantId)                  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Matching Algorithm Visualization

```
Given:
  selectedAttributes = {8: 101, 7: 201, 9: 301}
  (Color=Black, Size=36, Material=Leather)

Variant Combinations:
┌────────────┬─────────────────────────────────────────┬────────┐
│ Variant ID │ Attributes                              │ Match? │
├────────────┼─────────────────────────────────────────┼────────┤
│ 12345      │ {8:101, 7:201, 9:301}                   │   ✅   │
│            │ (Black, 36, Leather)                    │        │
├────────────┼─────────────────────────────────────────┼────────┤
│ 12346      │ {8:101, 7:202, 9:301}                   │   ❌   │
│            │ (Black, 37, Leather)                    │ Size   │
│            │                                         │ differs│
├────────────┼─────────────────────────────────────────┼────────┤
│ 12347      │ {8:102, 7:201, 9:301}                   │   ❌   │
│            │ (White, 36, Leather)                    │ Color  │
│            │                                         │ differs│
├────────────┼─────────────────────────────────────────┼────────┤
│ 12348      │ {8:101, 7:201, 9:302}                   │   ❌   │
│            │ (Black, 36, Synthetic)                  │Material│
│            │                                         │ differs│
└────────────┴─────────────────────────────────────────┴────────┘

Result: Variant 12345 matches!
```

---

## Availability Algorithm Visualization

```
Scenario: User selected Color=Black (8:101)
Question: Which sizes are available?

Step 1: Build temp selection (without size)
  tempSelection = {8: 101}

Step 2: Filter variants
  ┌────────────┬─────────────────┬────────┬──────┬────────┐
  │ Variant ID │ Attributes      │ Stock  │ Qty  │ Keep?  │
  ├────────────┼─────────────────┼────────┼──────┼────────┤
  │ 12345      │ Black, 36, ...  │ true   │ 10   │   ✅   │
  │ 12346      │ Black, 37, ...  │ false  │ 0    │   ❌   │
  │ 12347      │ Black, 38, ...  │ true   │ 5    │   ✅   │
  │ 12348      │ White, 36, ...  │ true   │ 10   │   ❌   │
  └────────────┴─────────────────┴────────┴──────┴────────┘

Step 3: Collect size value_ids from kept variants
  Variant 12345 → size value_id = 201 (36)
  Variant 12347 → size value_id = 203 (38)

Result: Available sizes = {201, 203} (36, 38)
```

---

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Error Scenarios                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Scenario 1: No matching variant found                                  │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ User selects: Color=Red, Size=40                                │  │
│  │ No variant exists with this combination                         │  │
│  │                                                                  │  │
│  │ Controller action:                                              │  │
│  │ - selectedVariant = null                                        │  │
│  │ - inStock = false                                               │  │
│  │ - quantityAvailable = 0                                         │  │
│  │ - variantId = ''                                                │  │
│  │                                                                  │  │
│  │ UI displays:                                                    │  │
│  │ - "Out of Stock" message                                        │  │
│  │ - Add to Cart button disabled                                   │  │
│  │ - All values remain enabled (user can try other combinations)   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  Scenario 2: Invalid attribute_id or value_id                           │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ API returns invalid IDs (null, string, negative)                │  │
│  │                                                                  │  │
│  │ Controller action:                                              │  │
│  │ - Skip invalid attributes/values                                │  │
│  │ - Log warning message                                           │  │
│  │ - Continue with valid attributes                                │  │
│  │                                                                  │  │
│  │ UI displays:                                                    │  │
│  │ - Only valid attributes                                         │  │
│  │ - System continues to function                                  │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  Scenario 3: Empty variant_combinations                                 │
│  ┌─────────────────────────────────────────────────────────────────┐  │
│  │ API returns no variant combinations                             │  │
│  │                                                                  │  │
│  │ Controller action:                                              │  │
│  │ - selectedVariant = null                                        │  │
│  │ - inStock = false                                               │  │
│  │                                                                  │  │
│  │ UI displays:                                                    │  │
│  │ - Attributes rendered but all values disabled                   │  │
│  │ - "Out of Stock" message                                        │  │
│  │ - Add to Cart button disabled                                   │  │
│  └─────────────────────────────────────────────────────────────────┘  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Performance Optimization Points

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      Performance Optimizations                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. Lazy Calculation                                                    │
│     - Availability calculated only when needed                          │
│     - Results not cached (recalculated on each selection)               │
│     - Trade-off: Accuracy vs Memory                                     │
│                                                                         │
│  2. Early Exit in Matching                                              │
│     - Stop checking as soon as mismatch found                           │
│     - Reduces unnecessary comparisons                                   │
│                                                                         │
│  3. Minimal Rebuilds                                                    │
│     - Only affected widgets rebuild                                     │
│     - Consumer pattern ensures targeted updates                         │
│                                                                         │
│  4. Efficient Data Structures                                           │
│     - Map for O(1) attribute lookup                                     │
│     - Set for O(1) availability check                                   │
│                                                                         │
│  5. Image Caching                                                       │
│     - CachedNetworkImage for automatic caching                          │
│     - Reduces network requests                                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

**Last Updated**: February 11, 2026  
**Version**: 1.0.0
