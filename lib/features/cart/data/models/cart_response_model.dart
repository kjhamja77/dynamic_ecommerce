import 'cart_item_model.dart';
import '../../../home/data/models/product_model.dart';
import '../../../../core/constants/app_constants.dart';

class CartResponseModel {
  final int orderId;
  final String state;
  final String currency;
  final double amountUntaxed;
  final double amountTax;
  final double amountTotal;
  final List<TaxSummaryModel> taxSummary;
  final List<CartLineModel> lines;
  final PaginationModel pagination;

  const CartResponseModel({
    required this.orderId,
    required this.state,
    required this.currency,
    required this.amountUntaxed,
    required this.amountTax,
    required this.amountTotal,
    required this.taxSummary,
    required this.lines,
    required this.pagination,
  });

  factory CartResponseModel.fromApiJson(Map<String, dynamic> json) {
    return CartResponseModel(
      orderId: json['order_id'] ?? 0,
      state: json['state'] ?? '',
      currency: json['currency'] ?? '',
      amountUntaxed: (json['amount_untaxed'] ?? 0.0).toDouble(),
      amountTax: (json['amount_tax'] ?? 0.0).toDouble(),
      amountTotal: (json['amount_total'] ?? 0.0).toDouble(),
      taxSummary: (json['tax_summary'] as List?)
          ?.map((tax) => TaxSummaryModel.fromApiJson(tax as Map<String, dynamic>))
          .toList() ?? [],
      lines: (json['lines'] as List?)
          ?.map((line) => CartLineModel.fromApiJson(line as Map<String, dynamic>))
          .toList() ?? [],
      pagination: PaginationModel.fromApiJson(json['pagination'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'state': state,
      'currency': currency,
      'amount_untaxed': amountUntaxed,
      'amount_tax': amountTax,
      'amount_total': amountTotal,
      'tax_summary': taxSummary.map((tax) => tax.toJson()).toList(),
      'lines': lines.map((line) => line.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class TaxSummaryModel {
  final int taxId;
  final String taxName;
  final double taxRate;
  final String taxType;
  final double totalTaxAmount;
  final double totalTaxableAmount;

  const TaxSummaryModel({
    required this.taxId,
    required this.taxName,
    required this.taxRate,
    required this.taxType,
    required this.totalTaxAmount,
    required this.totalTaxableAmount,
  });

  factory TaxSummaryModel.fromApiJson(Map<String, dynamic> json) {
    return TaxSummaryModel(
      taxId: json['tax_id'] ?? 0,
      taxName: json['tax_name'] ?? '',
      taxRate: (json['tax_rate'] ?? 0.0).toDouble(),
      taxType: json['tax_type'] ?? '',
      totalTaxAmount: (json['total_tax_amount'] ?? 0.0).toDouble(),
      totalTaxableAmount: (json['total_taxable_amount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tax_id': taxId,
      'tax_name': taxName,
      'tax_rate': taxRate,
      'tax_type': taxType,
      'total_tax_amount': totalTaxAmount,
      'total_taxable_amount': totalTaxableAmount,
    };
  }
}

class CartLineModel {
  final int lineId;
  final int productId;
  final String productName;
  final String productImage;
  final double quantity;
  /// Max quantity allowed for this line (stock available). From API when cart is loaded.
  final int? quantityAvailable;
  final double priceUnit;
  final double priceSubtotal;
  final double priceTotal;
  final double taxAmount;
  final List<int> taxes;
  final List<TaxDetailModel> taxDetails;

  const CartLineModel({
    required this.lineId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    this.quantityAvailable,
    required this.priceUnit,
    required this.priceSubtotal,
    required this.priceTotal,
    required this.taxAmount,
    required this.taxes,
    required this.taxDetails,
  });

  factory CartLineModel.fromApiJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] ?? 0.0).toDouble();
    final available = json['quantity_available'] ?? json['max_quantity'] ?? json['stock_available'];
    final quantityAvailable = available != null ? (available is int ? available : (available is num ? available.toInt() : int.tryParse(available.toString()))) : null;
    return CartLineModel(
      lineId: json['line_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      quantity: qty,
      quantityAvailable: quantityAvailable,
      priceUnit: (json['price_unit'] ?? 0.0).toDouble(),
      priceSubtotal: (json['price_subtotal'] ?? 0.0).toDouble(),
      priceTotal: (json['price_total'] ?? 0.0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0.0).toDouble(),
      taxes: (json['taxes'] as List?)?.map((tax) => tax as int).toList() ?? [],
      taxDetails: (json['tax_details'] as List?)
          ?.map((detail) => TaxDetailModel.fromApiJson(detail as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line_id': lineId,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'quantity': quantity,
      if (quantityAvailable != null) 'quantity_available': quantityAvailable,
      'price_unit': priceUnit,
      'price_subtotal': priceSubtotal,
      'price_total': priceTotal,
      'tax_amount': taxAmount,
      'taxes': taxes,
      'tax_details': taxDetails.map((detail) => detail.toJson()).toList(),
    };
  }

  // Convert to CartItemModel for compatibility with existing UI
  CartItemModel toCartItemModel() {
    // Construct full image URL if productImage is available
    final List<String> images = [];
    if (productImage.isNotEmpty) {
      // If productImage is already a full URL, use it as is
      if (productImage.startsWith('http')) {
        images.add(productImage);
      } else {
        // Otherwise, construct full URL with base URL
        images.add('${AppConstants.baseUrl}${productImage.startsWith('/') ? productImage.substring(1) : productImage}');
      }
    }

    return CartItemModel(
      id: lineId.toString(),
      product: ProductModel(
        id: productId.toString(),
        name: productName,
        description: '', // Not provided in cart response
        price: priceUnit,
        originalPrice: null,
        images: images,
        category: '', // Not provided in cart response
        brand: '', // Not provided in cart response
        type: 'variant', // Default for cart items
        rating: 0.0, // Not provided in cart response
        reviewCount: 0, // Not provided in cart response
        isAvailable: true,
        sizes: [], // Not provided in cart response
        colors: [], // Not provided in cart response
        createdAt: DateTime.now(),
      ),
      quantity: quantity.toInt(),
      selectedColor: '', // Not provided in cart response
      selectedSize: '', // Not provided in cart response
      price: priceUnit,
      addedAt: DateTime.now(),
    );
  }
}

class TaxDetailModel {
  final int taxId;
  final String taxName;
  final double taxAmount;
  final double taxRate;
  final String taxType;

  const TaxDetailModel({
    required this.taxId,
    required this.taxName,
    required this.taxAmount,
    required this.taxRate,
    required this.taxType,
  });

  factory TaxDetailModel.fromApiJson(Map<String, dynamic> json) {
    return TaxDetailModel(
      taxId: json['tax_id'] ?? 0,
      taxName: json['tax_name'] ?? '',
      taxAmount: (json['tax_amount'] ?? 0.0).toDouble(),
      taxRate: (json['tax_rate'] ?? 0.0).toDouble(),
      taxType: json['tax_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tax_id': taxId,
      'tax_name': taxName,
      'tax_amount': taxAmount,
      'tax_rate': taxRate,
      'tax_type': taxType,
    };
  }
}

class PaginationModel {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationModel({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationModel.fromApiJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      totalItems: json['total_items'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
      hasPrevious: json['has_previous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'page_size': pageSize,
      'total_items': totalItems,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }
}
