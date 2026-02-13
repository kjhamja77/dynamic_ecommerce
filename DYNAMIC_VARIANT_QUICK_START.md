# Dynamic Variant Selection - Quick Start Guide

## 🚀 Quick Start (5 Minutes)

### Step 1: Copy Files

Copy these 3 files to your project:

```
lib/features/product_details/presentation/
├── controllers/
│   └── dynamic_variant_controller.dart
└── widgets/
    └── dynamic_variant_selector.dart
└── pages/
    └── dynamic_variant_example_page.dart (optional - for reference)
```

### Step 2: Basic Usage

```dart
import 'package:your_app/features/product_details/presentation/widgets/dynamic_variant_selector.dart';

class YourProductPage extends StatelessWidget {
  final ProductDetails productDetails;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DynamicVariantSelector(
        productDetails: productDetails,
        onVariantChanged: (controller) {
          print('Selected variant: ${controller.variantId}');
          print('Price: ${controller.currentPrice}');
          print('In stock: ${controller.inStock}');
        },
      ),
    );
  }
}
```

### Step 3: Done! 🎉

That's it! The widget will:
- ✅ Render all attributes dynamically
- ✅ Handle selection automatically
- ✅ Update price, stock, and images
- ✅ Disable unavailable combinations

---

## 📋 API Requirements

Your API must return:

```json
{
  "variant_attributes": [
    {
      "id": 8,
      "name": "Color",
      "values": [
        { "id": 101, "name": "Black" },
        { "id": 102, "name": "White" }
      ]
    }
  ],
  "variant_combinations": [
    {
      "variant_id": "12345",
      "price": 99.99,
      "quantity_available": 10,
      "in_stock": true,
      "attributes": [
        { "attribute_id": 8, "value_id": 101 }
      ]
    }
  ],
  "selected_variant": {
    "variant_id": "12345",
    "attributes": [
      { "attribute_id": 8, "value_id": 101 }
    ]
  },
  "images": [
    {
      "type": "variant",
      "variant_id": "12345",
      "url": "https://example.com/image.jpg"
    }
  ]
}
```

**Critical**: All IDs must be integers, not strings!

---

## 🎯 Common Use Cases

### 1. Get Current Selection

```dart
DynamicVariantSelector(
  productDetails: productDetails,
  onVariantChanged: (controller) {
    final selection = controller.selectedAttributes;
    // selection = { 8: 101, 7: 201 } (attribute_id → value_id)
  },
)
```

### 2. Check Stock Status

```dart
onVariantChanged: (controller) {
  if (controller.inStock) {
    print('Available: ${controller.quantityAvailable} units');
  } else {
    print('Out of stock');
  }
}
```

### 3. Update Images

```dart
onVariantChanged: (controller) {
  setState(() {
    currentImages = controller.currentImages;
  });
}
```

### 4. Disable Add to Cart

```dart
ElevatedButton(
  onPressed: controller?.inStock == true ? _addToCart : null,
  child: Text(
    controller?.inStock == true ? 'Add to Cart' : 'Out of Stock',
  ),
)
```

---

## 🔧 Advanced Usage

### Access Controller Directly

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  DynamicVariantController? _controller;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DynamicVariantSelector(
          productDetails: productDetails,
          onVariantChanged: (controller) {
            setState(() {
              _controller = controller;
            });
          },
        ),
        
        // Use controller anywhere
        Text('Price: \$${_controller?.currentPrice ?? 0}'),
        Text('Variant: ${_controller?.variantId ?? "None"}'),
      ],
    );
  }
}
```

### Manual Selection

```dart
final controller = DynamicVariantController();
controller.initialize(productDetails);

// Select values programmatically
controller.selectAttributeValue(8, 101); // Color: Black
controller.selectAttributeValue(7, 201); // Size: 36

print('Matched variant: ${controller.variantId}');
```

### Check Availability

```dart
// Get all available values for an attribute
final availableValues = controller.getAvailableValuesForAttribute(8);
print('Available colors: $availableValues'); // [101, 102, 103]

// Check if specific value is available
final isAvailable = controller.isValueAvailable(8, 101);
print('Black is available: $isAvailable'); // true/false
```

---

## 🐛 Troubleshooting

### Problem: "No matching variant found"

**Cause**: Selected combination doesn't exist in `variant_combinations`

**Solution**: Ensure your API returns ALL possible combinations, including out-of-stock ones:

```json
{
  "variant_combinations": [
    {
      "variant_id": "12345",
      "in_stock": true,
      "quantity_available": 10,
      "attributes": [...]
    },
    {
      "variant_id": "12346",
      "in_stock": false,  // ← Include out-of-stock variants!
      "quantity_available": 0,
      "attributes": [...]
    }
  ]
}
```

### Problem: "Values not updating"

**Cause**: IDs are strings instead of integers

**Solution**: Convert IDs to integers in your API:

```dart
// ❌ Wrong
"attribute_id": "8"

// ✅ Correct
"attribute_id": 8
```

### Problem: "Images not changing"

**Cause**: `variantImagesMap` not properly structured

**Solution**: Ensure map uses variant_id as key:

```dart
"variantImagesMap": {
  "12345": ["url1.jpg", "url2.jpg"],
  "12346": ["url3.jpg"]
}
```

---

## 📊 Performance Tips

1. **Limit Combinations**: Keep combinations under 1000 for best performance
2. **Cache Images**: Use `CachedNetworkImage` for image caching
3. **Lazy Load**: Load product details only when needed
4. **Optimize API**: Return only necessary fields

---

## 🎨 Customization

### Change Colors

Edit the widget's color scheme:

```dart
// In _ValueButton widget
color: isSelected
    ? Colors.blue  // ← Change selected color
    : Colors.grey  // ← Change default color
```

### Change Layout

Modify spacing and padding:

```dart
// In _AttributeSection widget
padding: EdgeInsets.all(16.0),  // ← Adjust padding
spacing: 8.0,                   // ← Adjust spacing
```

### Add Custom UI

Extend the widget with custom elements:

```dart
Column(
  children: [
    DynamicVariantSelector(...),
    
    // Add your custom UI
    MyCustomPriceDisplay(),
    MyCustomStockBadge(),
  ],
)
```

---

## 📚 Next Steps

1. ✅ Read the full documentation: `DYNAMIC_VARIANT_SYSTEM_DOCUMENTATION.md`
2. ✅ Check the example page: `dynamic_variant_example_page.dart`
3. ✅ Test with your API response
4. ✅ Customize the UI to match your design

---

## 💡 Pro Tips

- **Always validate API response** before passing to the widget
- **Handle loading states** while fetching product details
- **Show error messages** when API fails
- **Track analytics** on variant selections
- **Test edge cases** (0 attributes, 1 attribute, 10+ attributes)

---

## 🤝 Need Help?

- Check the full documentation
- Review the example page
- Contact your development team

---

**Happy Coding! 🚀**
