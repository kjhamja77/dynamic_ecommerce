# Product Filtering Flow - Step by Step Explanation

## Overview
The filtering system uses two different API endpoints depending on whether advanced filters are applied:
1. **Regular Catalog API** (`/ecom/get/product/catalog`) - for basic browsing
2. **Filter-Search API** (`/ecom/get/product/filter-search`) - for filtered searches

---

## Step-by-Step Flow

### **STEP 1: User Opens Catalog/Filter Page**
- User navigates to catalog page or opens filter page
- Initial filters may be set (e.g., category from previous navigation)

**Location**: `CatalogBloc` → `LoadCatalog` event

---

### **STEP 2: Determine Which API to Use**
**Location**: `CatalogRepositoryImpl.fetchProducts()`

The system checks if **any advanced filters** are applied:

```dart
final hasAdvancedFilters = 
    (brand != null && brand != 'All') ||
    minPrice != null || maxPrice != null || 
    minRating != null ||
    onSale || inStock || 
    sizes.isNotEmpty || colors.isNotEmpty ||
    materials.isNotEmpty || seasons.isNotEmpty || 
    genders.isNotEmpty || extraAttributes.isNotEmpty;
```

**Decision**:
- ✅ **hasAdvancedFilters = true** → Use **Filter-Search API**
- ❌ **hasAdvancedFilters = false** → Use **Regular Catalog API**

---

### **STEP 3A: Regular Catalog API Path** (No Advanced Filters)
**Location**: `CatalogRepositoryImpl.fetchProducts()`

1. Check cache for previous results
2. If not cached, call `/ecom/get/product/catalog` with:
   - `category` (string)
   - `page`, `pageSize`
   - `sort_by` (optional)
   - `query` (search text, optional)
   - `featured` (boolean)
3. Parse response and return products
4. Cache results for faster subsequent requests

---

### **STEP 3B: Filter-Search API Path** (Advanced Filters Applied)
**Location**: `CatalogRepositoryImpl.fetchProductsWithFilterSearch()`

#### **Sub-step 3B.1: Convert Parameters to FilterCriteria**
**Location**: `FilterCriteria.fromCatalogParamsAsync()`

This converts UI filter parameters into API-compatible format:

1. **Category IDs**: 
   - If `categoryIds` provided → use directly
   - If `categoryId` (string) provided → parse to int
   - Result: `categoryIds: [1, 2, 3]`

2. **Brand IDs**:
   - Convert brand **name** → brand **ID**
   - Uses `BrandMappingService` to dynamically fetch brand ID
   - If not found, uses static mapping fallback:
     ```dart
     'Nike': 1, 'Adidas': 2, 'Zara': 4, etc.
     ```
   - Result: `brandIds: [1]`

3. **Attribute Values (Colors, Sizes, etc.)**:
   - Convert attribute **value names** → attribute **value IDs**
   - Example: `["Red", "Blue"]` → `[6, 5]`
   - Example: `["M", "L"]` → `[22, 23]`
   - Uses dynamic attribute mapping from `BrandMappingService`
   - Result: `attributeIds: [5, 6, 22, 23]`

4. **Sort Options**:
   - Convert sort option name (e.g., `"price_low_high"`) → `sortByField` + `sortOrder`
   - Example: `"price_low_high"` → `{field: "list_price", order: "asc"}`
   - Example: `"newest"` → `{field: "create_date", order: "desc"}`

5. **Price Range**:
   - `minPrice` and `maxPrice` passed directly as doubles

6. **Search Query**:
   - `query` passed directly as string

#### **Sub-step 3B.2: Build API Request**
**Location**: `FilterCriteria.toJson()`

Converts `FilterCriteria` object to JSON payload:

```json
{
  "page": 1,
  "limit": 20,
  "category_ids": [1, 2],
  "brand_ids": [4],
  "attribute_values": [5, 6, 22, 23],  // All attribute value IDs
  "min_price": 1000.0,
  "max_price": 50000.0,
  "sort_by": "list_price",
  "sort_order": "asc",
  "search_query": "shoes"
}
```

**Important Notes**:
- `attribute_values` contains ALL attribute value IDs (colors, sizes, materials, etc.)
- `category_ids` is an array (can filter by multiple categories)
- `brand_ids` is an array (can filter by multiple brands)

#### **Sub-step 3B.3: Call Filter-Search API**
**Location**: `FilterRemoteDataSourceImpl.filterProducts()`

Makes POST request to: `/ecom/get/product/filter-search`

**Request**: JSON body with FilterCriteria
**Response**: 
```json
{
  "result": {
    "data": {
      "items": [...products...],
      "total_count": 150,
      "current_page": 1,
      "has_next": true
    }
  }
}
```

#### **Sub-step 3B.4: Parse API Response**
**Location**: `CatalogRepositoryImpl.fetchProductsWithFilterSearch()`

1. Extract products from `result.data.items`
2. Convert each product JSON → `Product` entity
3. Extract pagination info: `total_count`, `current_page`, `has_next`

#### **Sub-step 3B.5: Post-Processing Filters**
**Location**: `CatalogRepositoryImpl.fetchProductsWithFilterSearch()`

Some filters are applied **client-side** after API response (API doesn't support them):

```dart
List<Product> filtered = products.where((p) {
  final ratingOk = (minRating == null || p.rating >= minRating);
  final saleOk = !onSale || p.hasDiscount;
  final sizesOk = sizes.isEmpty || p.sizes.any((s) => sizes.contains(s));
  final colorsOk = colors.isEmpty || p.colors.any((c) => colors.contains(c));
  
  return ratingOk && saleOk && sizesOk && colorsOk;
}).toList();
```

**Why?** Some filters need to match product variant details that might not be in the API response.

---

### **STEP 4: Update UI State**
**Location**: `CatalogBloc._onUpdateFilters()`

1. Update `CatalogState` with new filter values
2. Emit interim state (shows loading shimmer)
3. Call `fetchCatalogPage()` with updated filters
4. Update products list in state
5. Emit final `CatalogLoaded` state

---

## Filter Application Flow

### **When User Applies Filters from Filter Page**

1. **User selects filters** in `FiltersPage`
2. **Clicks "Apply"** → `FilterBloc` → `ApplyFilters` event
3. **Navigates back** to catalog with `FilterCriteria`
4. **CatalogPage receives** `initialFilters` in constructor
5. **On first load**, catalog detects `initialFilters`:
   ```dart
   if (state is CatalogLoaded && !_filtersApplied) {
     _filtersApplied = true;
     bloc.add(UpdateCatalogFilters(...));
   }
   ```
6. **CatalogBloc** processes filters and fetches products

---

## Filter Options Loading Flow

### **Loading Available Filter Options**

1. **User opens Filter Page**
2. **FilterBloc** loads:
   - **Categories**: `GET /ecom/get/product/categories`
   - **Brands**: `GET /ecom/get/product/brands`
   - **Attributes**: `GET /ecom/get/product/attributes?category_id=X`
   - **Filter Options**: `GET /ecom/get/product/filter-options`

3. **Attributes are filtered by category**:
   - If category selected → only attributes applicable to that category
   - If no category → all attributes

4. **Filter options include**:
   - Price range (min/max from all products)
   - Available attribute values per attribute
   - Sort options

---

## Key Components

### **1. FilterCriteria**
**Location**: `lib/features/filters/domain/entities/filter_criteria.dart`

Encapsulates all filter parameters:
- Category IDs, Brand IDs, Attribute Value IDs
- Price range, Rating, On Sale, In Stock
- Search query, Sort options
- Pagination (page, limit)

**Methods**:
- `fromCatalogParamsAsync()` - Builds from UI params
- `toJson()` - Converts to API format

### **2. BrandMappingService**
**Location**: `lib/core/services/brand_mapping_service.dart`

Dynamically maps:
- Brand **names** → Brand **IDs**
- Attribute **value names** → Attribute **value IDs**

Uses API to fetch mappings at runtime.

### **3. CatalogRepository**
**Location**: `lib/features/catalog/data/repositories/catalog_repository_impl.dart`

**Methods**:
- `fetchProducts()` - Main entry point, decides which API to use
- `fetchProductsWithFilterSearch()` - Handles filtered searches
- Handles caching and fallbacks

### **4. FilterRemoteDataSource**
**Location**: `lib/features/filters/data/datasources/filter_remote_data_source.dart`

**Methods**:
- `filterProducts()` - Calls filter-search API
- `getCategories()` - Loads categories
- `getBrands()` - Loads brands
- `getAttributes()` - Loads attributes
- `getFilterOptions()` - Loads filter metadata

---

## Important Notes

### **Attribute Value Mapping**
- Colors, sizes, materials, etc. are all sent as **attribute value IDs** in `attribute_values` array
- The system uses `BrandMappingService` to dynamically map names → IDs
- If mapping fails, it falls back to static mappings

### **Category Filtering**
- `categoryIds` is an array - supports multiple categories
- If user navigates to catalog from a category, that category ID is passed
- Filter page can add/remove additional categories

### **Client-Side vs Server-Side Filtering**
**Server-Side** (via API):
- Category, Brand, Price, Search Query, Sort
- Most attribute filters

**Client-Side** (post-processing):
- Rating (if API doesn't return rating)
- Sale status (if API doesn't return discount info)
- Size/Color matching (if product variants not in API response)

### **Sorting**
- Sorting is handled **server-side** via `sort_by` and `sort_order`
- Sort options mapped:
  - `"price_low_high"` → `{field: "list_price", order: "asc"}`
  - `"price_high_low"` → `{field: "list_price", order: "desc"}`
  - `"newest"` → `{field: "create_date", order: "desc"}`
  - etc.

---

## Example Flow

**Scenario**: User filters "Red Nike Shoes, Size M, Price 10K-50K"

1. User selects filters in Filter Page
2. Filters converted to `FilterCriteria`:
   - `brandIds: [1]` (Nike)
   - `attributeIds: [6, 22]` (Red=6, M=22)
   - `minPrice: 10000, maxPrice: 50000`
   - `categoryIds: [1]` (Shoes category)
3. API call to `/ecom/get/product/filter-search` with JSON payload
4. API returns filtered products
5. Client-side post-processing applies any remaining filters
6. UI displays filtered results

---

## Troubleshooting

### **Filters not working?**
1. Check if `hasAdvancedFilters` is true (should trigger filter-search API)
2. Check if brand/attribute IDs are correctly mapped
3. Check API request payload (logs show full JSON)
4. Check if post-processing filters are too strict

### **Filter options showing all attributes?**
- Attributes should be filtered by `category_id` when category is selected
- Check if `category_id` is being passed to `/ecom/get/product/attributes`

### **Pagination not working with filters?**
- Ensure `page` and `limit` are passed correctly
- Check if `hasNext` is being parsed from API response





