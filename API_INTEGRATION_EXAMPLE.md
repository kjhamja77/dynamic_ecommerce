# API Integration Example for Dynamic Variant System

## Complete API Response Example

Here's a complete example of the API response structure that the Dynamic Variant System expects:

```json
{
  "status": "success",
  "data": {
    "id": 12345,
    "name": "Premium Leather Shoes",
    "brand": "LuxeFootwear",
    "description": "High-quality leather shoes with exceptional comfort",
    "price": 99.99,
    "original_price": 129.99,
    
    "variant_attributes": [
      {
        "id": 8,
        "name": "Color",
        "values": [
          {
            "id": 101,
            "name": "Black"
          },
          {
            "id": 102,
            "name": "White"
          },
          {
            "id": 103,
            "name": "Brown"
          },
          {
            "id": 104,
            "name": "Red"
          }
        ]
      },
      {
        "id": 7,
        "name": "Size",
        "values": [
          {
            "id": 201,
            "name": "36"
          },
          {
            "id": 202,
            "name": "37"
          },
          {
            "id": 203,
            "name": "38"
          },
          {
            "id": 204,
            "name": "39"
          },
          {
            "id": 205,
            "name": "40"
          }
        ]
      },
      {
        "id": 9,
        "name": "Material",
        "values": [
          {
            "id": 301,
            "name": "Genuine Leather"
          },
          {
            "id": 302,
            "name": "Synthetic Leather"
          },
          {
            "id": 303,
            "name": "Suede"
          }
        ]
      },
      {
        "id": 10,
        "name": "Heel Height",
        "values": [
          {
            "id": 401,
            "name": "2.5 cm"
          },
          {
            "id": 402,
            "name": "4.0 cm"
          },
          {
            "id": 403,
            "name": "5.5 cm"
          }
        ]
      }
    ],
    
    "variant_combinations": [
      {
        "variant_id": "12345-1",
        "price": 99.99,
        "quantity_available": 10,
        "in_stock": true,
        "attributes": [
          {
            "attribute_id": 8,
            "value_id": 101,
            "attribute_name": "Color",
            "value_name": "Black"
          },
          {
            "attribute_id": 7,
            "value_id": 201,
            "attribute_name": "Size",
            "value_name": "36"
          },
          {
            "attribute_id": 9,
            "value_id": 301,
            "attribute_name": "Material",
            "value_name": "Genuine Leather"
          },
          {
            "attribute_id": 10,
            "value_id": 401,
            "attribute_name": "Heel Height",
            "value_name": "2.5 cm"
          }
        ]
      },
      {
        "variant_id": "12345-2",
        "price": 99.99,
        "quantity_available": 5,
        "in_stock": true,
        "attributes": [
          {
            "attribute_id": 8,
            "value_id": 101,
            "attribute_name": "Color",
            "value_name": "Black"
          },
          {
            "attribute_id": 7,
            "value_id": 202,
            "attribute_name": "Size",
            "value_name": "37"
          },
          {
            "attribute_id": 9,
            "value_id": 301,
            "attribute_name": "Material",
            "value_name": "Genuine Leather"
          },
          {
            "attribute_id": 10,
            "value_id": 401,
            "attribute_name": "Heel Height",
            "value_name": "2.5 cm"
          }
        ]
      },
      {
        "variant_id": "12345-3",
        "price": 89.99,
        "quantity_available": 15,
        "in_stock": true,
        "attributes": [
          {
            "attribute_id": 8,
            "value_id": 102,
            "attribute_name": "Color",
            "value_name": "White"
          },
          {
            "attribute_id": 7,
            "value_id": 201,
            "attribute_name": "Size",
            "value_name": "36"
          },
          {
            "attribute_id": 9,
            "value_id": 302,
            "attribute_name": "Material",
            "value_name": "Synthetic Leather"
          },
          {
            "attribute_id": 10,
            "value_id": 402,
            "attribute_name": "Heel Height",
            "value_name": "4.0 cm"
          }
        ]
      },
      {
        "variant_id": "12345-4",
        "price": 99.99,
        "quantity_available": 0,
        "in_stock": false,
        "attributes": [
          {
            "attribute_id": 8,
            "value_id": 103,
            "attribute_name": "Color",
            "value_name": "Brown"
          },
          {
            "attribute_id": 7,
            "value_id": 203,
            "attribute_name": "Size",
            "value_name": "38"
          },
          {
            "attribute_id": 9,
            "value_id": 301,
            "attribute_name": "Material",
            "value_name": "Genuine Leather"
          },
          {
            "attribute_id": 10,
            "value_id": 403,
            "attribute_name": "Heel Height",
            "value_name": "5.5 cm"
          }
        ]
      }
    ],
    
    "selected_variant": {
      "variant_id": "12345-1",
      "attributes": [
        {
          "attribute_id": 8,
          "value_id": 101
        },
        {
          "attribute_id": 7,
          "value_id": 201
        },
        {
          "attribute_id": 9,
          "value_id": 301
        },
        {
          "attribute_id": 10,
          "value_id": 401
        }
      ]
    },
    
    "images": [
      {
        "type": "template",
        "url": "https://cdn.example.com/products/12345/template-1.jpg"
      },
      {
        "type": "template",
        "url": "https://cdn.example.com/products/12345/template-2.jpg"
      },
      {
        "type": "variant",
        "variant_id": "12345-1",
        "url": "https://cdn.example.com/products/12345/variants/12345-1-main.jpg"
      },
      {
        "type": "variant",
        "variant_id": "12345-1",
        "url": "https://cdn.example.com/products/12345/variants/12345-1-side.jpg"
      },
      {
        "type": "variant",
        "variant_id": "12345-1",
        "url": "https://cdn.example.com/products/12345/variants/12345-1-back.jpg"
      },
      {
        "type": "variant",
        "variant_id": "12345-2",
        "url": "https://cdn.example.com/products/12345/variants/12345-2-main.jpg"
      },
      {
        "type": "variant",
        "variant_id": "12345-3",
        "url": "https://cdn.example.com/products/12345/variants/12345-3-main.jpg"
      }
    ]
  }
}
```

---

## Data Transformation (Backend → Flutter)

### Step 1: Parse API Response

```dart
class ProductDetailsRemoteDataSource {
  Future<ProductDetails> getProductDetails(String productId) async {
    final response = await apiClient.get('/products/$productId');
    final data = response.data['data'];
    
    return _transformApiResponse(data);
  }
  
  ProductDetails _transformApiResponse(Map<String, dynamic> data) {
    // Parse variant_attributes
    final variantAttributes = (data['variant_attributes'] as List?)
        ?.map((attr) => _parseVariantAttribute(attr))
        .toList() ?? [];
    
    // Parse variant_combinations
    final variantCombinations = (data['variant_combinations'] as List?)
        ?.map((combo) => _parseVariantCombination(combo))
        .toList() ?? [];
    
    // Parse images and build variantImagesMap
    final images = <String>[];
    final variantImagesMap = <String, List<String>>{};
    
    for (final img in (data['images'] as List? ?? [])) {
      final type = img['type'] as String?;
      final url = img['url'] as String?;
      
      if (url == null || url.isEmpty) continue;
      
      if (type == 'template') {
        images.add(url);
      } else if (type == 'variant') {
        final variantId = img['variant_id'] as String?;
        if (variantId != null) {
          variantImagesMap.putIfAbsent(variantId, () => []);
          variantImagesMap[variantId]!.add(url);
        }
      }
    }
    
    // Parse selected_variant
    final selectedVariant = data['selected_variant'] as Map<String, dynamic>?;
    String selectedColor = '';
    String selectedSize = '';
    
    if (selectedVariant != null) {
      final attrs = selectedVariant['attributes'] as List?;
      if (attrs != null) {
        for (final attr in attrs) {
          final attrId = attr['attribute_id'] as int?;
          final valueId = attr['value_id'] as int?;
          
          // Find attribute name and value name
          final attrOption = variantAttributes.firstWhere(
            (opt) => int.tryParse(opt.attributeId ?? '') == attrId,
            orElse: () => VariantAttributeOption(
              attributeName: '',
              values: [],
              selectedValue: '',
            ),
          );
          
          if (attrOption.attributeName.isNotEmpty) {
            final value = attrOption.values.firstWhere(
              (v) => int.tryParse(v.id) == valueId,
              orElse: () => VariantAttributeValue(
                id: '',
                name: '',
                isAvailable: false,
                isSelected: false,
              ),
            );
            
            if (value.name.isNotEmpty) {
              // Set selectedColor and selectedSize for backward compatibility
              if (attrOption.attributeName.toLowerCase() == 'color') {
                selectedColor = value.name;
              } else if (attrOption.attributeName.toLowerCase() == 'size') {
                selectedSize = value.name;
              }
            }
          }
        }
      }
    }
    
    return ProductDetails(
      id: data['id'].toString(),
      brand: data['brand'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (data['original_price'] as num?)?.toDouble(),
      rating: (data['rating'] as int?) ?? 0,
      reviewCount: (data['review_count'] as int?) ?? 0,
      images: images,
      colorOptions: [], // Legacy field
      sizeOptions: [], // Legacy field
      variantAttributeOptions: variantAttributes,
      selectedColor: selectedColor,
      selectedSize: selectedSize,
      isFavorite: data['is_favorite'] as bool? ?? false,
      hasDiscount: (data['original_price'] as num?)?.toDouble() != null,
      discountPercentage: _calculateDiscountPercentage(
        data['price'] as num?,
        data['original_price'] as num?,
      ),
      features: (data['features'] as List?)?.cast<String>() ?? [],
      material: data['material'] as String? ?? '',
      careInstructions: data['care_instructions'] as String? ?? '',
      isPlusMember: data['is_plus_member'] as bool? ?? false,
      pointsEarned: (data['points_earned'] as int?) ?? 0,
      variantCombinations: variantCombinations,
      variantImagesMap: variantImagesMap,
    );
  }
  
  VariantAttributeOption _parseVariantAttribute(Map<String, dynamic> attr) {
    final values = (attr['values'] as List?)
        ?.map((v) => VariantAttributeValue(
              id: v['id'].toString(),
              name: v['name'] as String? ?? '',
              isAvailable: true,
              isSelected: false,
            ))
        .toList() ?? [];
    
    return VariantAttributeOption(
      attributeName: attr['name'] as String? ?? '',
      values: values,
      selectedValue: values.isNotEmpty ? values.first.name : '',
      attributeId: attr['id'].toString(),
    );
  }
  
  VariantCombination _parseVariantCombination(Map<String, dynamic> combo) {
    final attributes = (combo['attributes'] as List?)
        ?.map((attr) => VariantAttribute(
              attributeName: attr['attribute_name'] as String? ?? '',
              valueName: attr['value_name'] as String? ?? '',
              attributeId: attr['attribute_id'].toString(),
              valueId: attr['value_id'].toString(),
            ))
        .toList() ?? [];
    
    return VariantCombination(
      variantId: combo['variant_id'] as String? ?? '',
      inStock: combo['in_stock'] as bool? ?? false,
      quantityAvailable: (combo['quantity_available'] as num?)?.toDouble(),
      attributes: attributes,
    );
  }
  
  int? _calculateDiscountPercentage(num? price, num? originalPrice) {
    if (price == null || originalPrice == null || originalPrice <= 0) {
      return null;
    }
    
    final discount = ((originalPrice - price) / originalPrice * 100).round();
    return discount > 0 ? discount : null;
  }
}
```

---

## Backend Implementation Example (Python/Flask)

```python
from flask import Flask, jsonify
from dataclasses import dataclass
from typing import List, Optional

@dataclass
class AttributeValue:
    id: int
    name: str

@dataclass
class VariantAttribute:
    id: int
    name: str
    values: List[AttributeValue]

@dataclass
class VariantCombination:
    variant_id: str
    price: float
    quantity_available: int
    in_stock: bool
    attributes: List[dict]

@dataclass
class ProductImage:
    type: str  # 'template' or 'variant'
    url: str
    variant_id: Optional[str] = None

class ProductService:
    def get_product_details(self, product_id: int):
        # Fetch from database
        product = db.query(Product).filter_by(id=product_id).first()
        
        # Get all variant attributes
        variant_attributes = self._get_variant_attributes(product)
        
        # Get all variant combinations
        variant_combinations = self._get_variant_combinations(product)
        
        # Get selected variant (default or from user preference)
        selected_variant = self._get_selected_variant(product, variant_combinations)
        
        # Get images
        images = self._get_images(product, variant_combinations)
        
        return {
            'status': 'success',
            'data': {
                'id': product.id,
                'name': product.name,
                'brand': product.brand.name,
                'description': product.description,
                'price': float(product.price),
                'original_price': float(product.original_price) if product.original_price else None,
                'variant_attributes': [
                    {
                        'id': attr.id,
                        'name': attr.name,
                        'values': [
                            {
                                'id': val.id,
                                'name': val.name
                            }
                            for val in attr.values
                        ]
                    }
                    for attr in variant_attributes
                ],
                'variant_combinations': [
                    {
                        'variant_id': combo.variant_id,
                        'price': float(combo.price),
                        'quantity_available': combo.quantity_available,
                        'in_stock': combo.in_stock,
                        'attributes': [
                            {
                                'attribute_id': attr['attribute_id'],
                                'value_id': attr['value_id'],
                                'attribute_name': attr['attribute_name'],
                                'value_name': attr['value_name']
                            }
                            for attr in combo.attributes
                        ]
                    }
                    for combo in variant_combinations
                ],
                'selected_variant': {
                    'variant_id': selected_variant.variant_id,
                    'attributes': [
                        {
                            'attribute_id': attr['attribute_id'],
                            'value_id': attr['value_id']
                        }
                        for attr in selected_variant.attributes
                    ]
                },
                'images': [
                    {
                        'type': img.type,
                        'url': img.url,
                        'variant_id': img.variant_id
                    }
                    for img in images
                ]
            }
        }
    
    def _get_variant_attributes(self, product):
        # Query all attributes for this product
        return db.query(ProductAttribute).filter_by(product_id=product.id).all()
    
    def _get_variant_combinations(self, product):
        # Query all variant combinations
        variants = db.query(ProductVariant).filter_by(product_id=product.id).all()
        
        combinations = []
        for variant in variants:
            # Get attributes for this variant
            variant_attrs = db.query(VariantAttributeValue).filter_by(
                variant_id=variant.id
            ).all()
            
            combinations.append({
                'variant_id': str(variant.id),
                'price': float(variant.price),
                'quantity_available': variant.quantity_available,
                'in_stock': variant.in_stock,
                'attributes': [
                    {
                        'attribute_id': attr.attribute_id,
                        'value_id': attr.value_id,
                        'attribute_name': attr.attribute.name,
                        'value_name': attr.value.name
                    }
                    for attr in variant_attrs
                ]
            })
        
        return combinations
    
    def _get_selected_variant(self, product, combinations):
        # Return first in-stock variant or first variant
        for combo in combinations:
            if combo['in_stock'] and combo['quantity_available'] > 0:
                return combo
        
        return combinations[0] if combinations else None
    
    def _get_images(self, product, combinations):
        images = []
        
        # Add template images
        for img in product.template_images:
            images.append({
                'type': 'template',
                'url': img.url
            })
        
        # Add variant-specific images
        for combo in combinations:
            variant = db.query(ProductVariant).filter_by(
                id=combo['variant_id']
            ).first()
            
            for img in variant.images:
                images.append({
                    'type': 'variant',
                    'variant_id': combo['variant_id'],
                    'url': img.url
                })
        
        return images

# Flask route
@app.route('/api/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    service = ProductService()
    result = service.get_product_details(product_id)
    return jsonify(result)
```

---

## Database Schema Example

```sql
-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    brand_id INTEGER REFERENCES brands(id),
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product attributes (Color, Size, Material, etc.)
CREATE TABLE product_attributes (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    name VARCHAR(100) NOT NULL,  -- 'Color', 'Size', etc.
    display_order INTEGER DEFAULT 0
);

-- Attribute values (Black, White, 36, 37, etc.)
CREATE TABLE attribute_values (
    id SERIAL PRIMARY KEY,
    attribute_id INTEGER REFERENCES product_attributes(id),
    name VARCHAR(100) NOT NULL,  -- 'Black', '36', etc.
    display_order INTEGER DEFAULT 0
);

-- Product variants (specific combinations)
CREATE TABLE product_variants (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    variant_id VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity_available INTEGER DEFAULT 0,
    in_stock BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Variant attribute values (links variants to specific attribute values)
CREATE TABLE variant_attribute_values (
    id SERIAL PRIMARY KEY,
    variant_id INTEGER REFERENCES product_variants(id),
    attribute_id INTEGER REFERENCES product_attributes(id),
    value_id INTEGER REFERENCES attribute_values(id),
    UNIQUE(variant_id, attribute_id)
);

-- Product images
CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    variant_id INTEGER REFERENCES product_variants(id) NULL,
    type VARCHAR(20) NOT NULL,  -- 'template' or 'variant'
    url TEXT NOT NULL,
    display_order INTEGER DEFAULT 0
);
```

---

## Testing the Integration

### 1. Test API Response

```bash
curl -X GET "https://api.example.com/products/12345" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

### 2. Validate Response Structure

```dart
void validateApiResponse(Map<String, dynamic> response) {
  assert(response['status'] == 'success');
  assert(response['data'] != null);
  
  final data = response['data'];
  
  // Validate variant_attributes
  assert(data['variant_attributes'] is List);
  for (final attr in data['variant_attributes']) {
    assert(attr['id'] is int);
    assert(attr['name'] is String);
    assert(attr['values'] is List);
    
    for (final value in attr['values']) {
      assert(value['id'] is int);
      assert(value['name'] is String);
    }
  }
  
  // Validate variant_combinations
  assert(data['variant_combinations'] is List);
  for (final combo in data['variant_combinations']) {
    assert(combo['variant_id'] is String);
    assert(combo['price'] is num);
    assert(combo['quantity_available'] is int);
    assert(combo['in_stock'] is bool);
    assert(combo['attributes'] is List);
    
    for (final attr in combo['attributes']) {
      assert(attr['attribute_id'] is int);
      assert(attr['value_id'] is int);
    }
  }
  
  print('✅ API response validation passed!');
}
```

### 3. Test with Flutter

```dart
void main() async {
  final dataSource = ProductDetailsRemoteDataSourceImpl(apiClient);
  
  try {
    final productDetails = await dataSource.getProductDetails('12345');
    
    print('Product: ${productDetails.name}');
    print('Attributes: ${productDetails.variantAttributeOptions.length}');
    print('Combinations: ${productDetails.variantCombinations.length}');
    print('Images: ${productDetails.images.length}');
    
    // Test with DynamicVariantController
    final controller = DynamicVariantController();
    controller.initialize(productDetails);
    
    print('Selected variant: ${controller.variantId}');
    print('Price: ${controller.currentPrice}');
    print('In stock: ${controller.inStock}');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## Common Issues and Solutions

### Issue 1: IDs are strings instead of integers

**Problem**: API returns `"attribute_id": "8"` instead of `"attribute_id": 8`

**Solution**: Update backend to return integers:

```python
# ❌ Wrong
'attribute_id': str(attr.id)

# ✅ Correct
'attribute_id': attr.id
```

### Issue 2: Missing variant combinations

**Problem**: Not all combinations are returned

**Solution**: Generate all possible combinations:

```python
from itertools import product

def generate_all_combinations(attributes):
    # Get all attribute values
    attr_values = [attr.values for attr in attributes]
    
    # Generate all combinations
    combinations = list(product(*attr_values))
    
    return combinations
```

### Issue 3: Images not loading

**Problem**: Image URLs are relative paths

**Solution**: Convert to absolute URLs:

```python
def get_absolute_url(relative_url):
    base_url = 'https://cdn.example.com'
    return f'{base_url}/{relative_url.lstrip("/")}'
```

---

## Performance Optimization

### 1. Cache Variant Combinations

```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def get_variant_combinations(product_id):
    # Cache for 1 hour
    return db.query(ProductVariant).filter_by(product_id=product_id).all()
```

### 2. Paginate Large Responses

```python
def get_variant_combinations(product_id, page=1, per_page=50):
    offset = (page - 1) * per_page
    return db.query(ProductVariant)\
        .filter_by(product_id=product_id)\
        .limit(per_page)\
        .offset(offset)\
        .all()
```

### 3. Optimize Images

```python
def get_optimized_image_url(image_url, size='medium'):
    # Use CDN with image optimization
    sizes = {
        'thumbnail': '150x150',
        'medium': '600x600',
        'large': '1200x1200'
    }
    
    return f'{image_url}?size={sizes[size]}&format=webp'
```

---

**Last Updated**: February 11, 2026
