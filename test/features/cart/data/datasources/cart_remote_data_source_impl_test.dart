import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:zalando_clone_app/features/cart/data/datasources/cart_remote_data_source_impl.dart';
import 'package:zalando_clone_app/features/cart/data/models/cart_item_model.dart';
import 'package:zalando_clone_app/features/cart/data/models/cart_response_model.dart';
import 'package:zalando_clone_app/features/home/data/models/product_model.dart';

import 'cart_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late CartRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = CartRemoteDataSourceImpl(mockApiClient);
  });

  group('getCartItems', () {
    test('should return cart response successfully', () async {
      // Arrange
      final mockResponse = Response(
        data: {
          'result': {
            'status': 'success',
            'message': 'Cart retrieved successfully',
            'data': {
              'order_id': 52,
              'state': 'draft',
              'currency': 'IQD',
              'amount_untaxed': 750.0,
              'amount_tax': 2250.0,
              'amount_total': 3000.0,
              'tax_summary': [
                {
                  'tax_id': 6,
                  'tax_name': '300%',
                  'tax_rate': 300.0,
                  'tax_type': 'percent',
                  'total_tax_amount': 2250.0,
                  'total_taxable_amount': 750.0
                }
              ],
              'lines': [
                {
                  'line_id': 80,
                  'product_id': 36,
                  'product_name': '[DESK0005] Customizable Desk (Custom, White)',
                  'quantity': 1.0,
                  'price_unit': 750.0,
                  'price_subtotal': 750.0,
                  'price_total': 3000.0,
                  'tax_amount': 2250.0,
                  'taxes': [6],
                  'tax_details': [
                    {
                      'tax_id': 6,
                      'tax_name': '300%',
                      'tax_amount': 2250.0,
                      'tax_rate': 300.0,
                      'tax_type': 'percent'
                    }
                  ]
                }
              ],
              'pagination': {
                'current_page': 1,
                'page_size': 10,
                'total_items': 1,
                'total_pages': 1,
                'has_next': false,
                'has_previous': false
              }
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/product/cart'),
      );

      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
        (
          status: 'success',
          message: 'Cart retrieved successfully',
          data: {
            'order_id': 52,
            'state': 'draft',
            'currency': 'IQD',
            'amount_untaxed': 750.0,
            'amount_tax': 2250.0,
            'amount_total': 3000.0,
            'tax_summary': [
              {
                'tax_id': 6,
                'tax_name': '300%',
                'tax_rate': 300.0,
                'tax_type': 'percent',
                'total_tax_amount': 2250.0,
                'total_taxable_amount': 750.0
              }
            ],
            'lines': [
              {
                'line_id': 80,
                'product_id': 36,
                'product_name': '[DESK0005] Customizable Desk (Custom, White)',
                'quantity': 1.0,
                'price_unit': 750.0,
                'price_subtotal': 750.0,
                'price_total': 3000.0,
                'tax_amount': 2250.0,
                'taxes': [6],
                'tax_details': [
                  {
                    'tax_id': 6,
                    'tax_name': '300%',
                    'tax_amount': 2250.0,
                    'tax_rate': 300.0,
                    'tax_type': 'percent'
                  }
                ]
              }
            ],
            'pagination': {
              'current_page': 1,
              'page_size': 10,
              'total_items': 1,
              'total_pages': 1,
              'has_next': false,
              'has_previous': false
            }
          },
        ),
      );

      // Act
      final result = await dataSource.getCartItems();

      // Assert
      expect(result, isA<CartResponseModel>());
      expect(result.orderId, equals(52));
      expect(result.state, equals('draft'));
      expect(result.currency, equals('IQD'));
      expect(result.amountTotal, equals(3000.0));
      expect(result.lines.length, equals(1));
      expect(result.lines.first.productId, equals(36));
      expect(result.lines.first.productName, equals('[DESK0005] Customizable Desk (Custom, White)'));
      expect(result.lines.first.quantity, equals(1.0));

      verify(mockApiClient.requestRpc(
        '/ecom/product/cart',
        method: 'POST',
        params: {
          'action': 'get',
          'page': 1,
          'page_size': 10,
        },
      )).called(1);
    });

    test('should throw exception when API returns error', () async {
      // Arrange
      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/ecom/product/cart'),
        message: 'Network error',
      ));

      // Act & Assert
      expect(
        () => dataSource.getCartItems(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('addToCart', () {
    test('should add item to cart successfully', () async {
      // Arrange
      final productId = 36;
      final quantity = 2;

      final mockResponse = Response(
        data: {
          'result': {
            'status': 'success',
            'message': 'Cart processed successfully',
            'data': {
              'order_id': 52,
              'state': 'draft',
              'currency': 'IQD',
              'amount_untaxed': 1500.0,
              'amount_tax': 4500.0,
              'amount_total': 6000.0,
              'tax_summary': [
                {
                  'tax_id': 6,
                  'tax_name': '300%',
                  'tax_rate': 300.0,
                  'tax_type': 'percent',
                  'total_tax_amount': 4500.0,
                  'total_taxable_amount': 1500.0
                }
              ],
              'lines': [
                {
                  'line_id': 80,
                  'product_id': 36,
                  'product_name': '[DESK0005] Customizable Desk (Custom, White)',
                  'quantity': 2.0,
                  'price_unit': 750.0,
                  'price_subtotal': 1500.0,
                  'price_total': 6000.0,
                  'tax_amount': 4500.0,
                  'taxes': [6],
                  'tax_details': [
                    {
                      'tax_id': 6,
                      'tax_name': '300%',
                      'tax_amount': 4500.0,
                      'tax_rate': 300.0,
                      'tax_type': 'percent'
                    }
                  ]
                }
              ],
              'pagination': {
                'current_page': 1,
                'page_size': 10,
                'total_items': 1,
                'total_pages': 1,
                'has_next': false,
                'has_previous': false
              }
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/product/cart'),
      );

      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
        (
          status: 'success',
          message: 'Cart processed successfully',
          data: {
            'order_id': 52,
            'state': 'draft',
            'currency': 'IQD',
            'amount_untaxed': 1500.0,
            'amount_tax': 4500.0,
            'amount_total': 6000.0,
            'tax_summary': [
              {
                'tax_id': 6,
                'tax_name': '300%',
                'tax_rate': 300.0,
                'tax_type': 'percent',
                'total_tax_amount': 4500.0,
                'total_taxable_amount': 1500.0
              }
            ],
            'lines': [
              {
                'line_id': 80,
                'product_id': 36,
                'product_name': '[DESK0005] Customizable Desk (Custom, White)',
                'quantity': 2.0,
                'price_unit': 750.0,
                'price_subtotal': 1500.0,
                'price_total': 6000.0,
                'tax_amount': 4500.0,
                'taxes': [6],
                'tax_details': [
                  {
                    'tax_id': 6,
                    'tax_name': '300%',
                    'tax_amount': 4500.0,
                    'tax_rate': 300.0,
                    'tax_type': 'percent'
                  }
                ]
              }
            ],
            'pagination': {
              'current_page': 1,
              'page_size': 10,
              'total_items': 1,
              'total_pages': 1,
              'has_next': false,
              'has_previous': false
            }
          },
        ),
      );

      // Act
      final result = await dataSource.addToCart(productId, quantity);

      // Assert
      expect(result, isA<CartResponseModel>());
      expect(result.orderId, equals(52));
      expect(result.amountTotal, equals(6000.0));
      expect(result.lines.length, equals(1));
      expect(result.lines.first.productId, equals(36));
      expect(result.lines.first.quantity, equals(2.0));

      verify(mockApiClient.requestRpc(
        '/ecom/product/cart',
        method: 'POST',
        params: {
          'action': 'add',
          'product_id': productId,
          'quantity': quantity,
        },
      )).called(1);
    });
  });

  group('updateCartItemQuantity', () {
    test('should update cart item quantity successfully', () async {
      // Arrange
      final productId = 36;
      final quantity = 3;

      final mockResponse = Response(
        data: {
          'result': {
            'status': 'success',
            'message': 'Cart processed successfully',
            'data': {
              'order_id': 52,
              'state': 'draft',
              'currency': 'IQD',
              'amount_untaxed': 2250.0,
              'amount_tax': 6750.0,
              'amount_total': 9000.0,
              'lines': [
                {
                  'line_id': 80,
                  'product_id': 36,
                  'product_name': '[DESK0005] Customizable Desk (Custom, White)',
                  'quantity': 3.0,
                  'price_unit': 750.0,
                  'price_subtotal': 2250.0,
                  'price_total': 9000.0,
                  'tax_amount': 6750.0,
                  'taxes': [6],
                  'tax_details': [
                    {
                      'tax_id': 6,
                      'tax_name': '300%',
                      'tax_amount': 6750.0,
                      'tax_rate': 300.0,
                      'tax_type': 'percent'
                    }
                  ]
                }
              ],
              'pagination': {
                'current_page': 1,
                'page_size': 10,
                'total_items': 1,
                'total_pages': 1,
                'has_next': false,
                'has_previous': false
              }
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/product/cart'),
      );

      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
        (
          status: 'success',
          message: 'Cart processed successfully',
          data: {
            'order_id': 52,
            'state': 'draft',
            'currency': 'IQD',
            'amount_untaxed': 2250.0,
            'amount_tax': 6750.0,
            'amount_total': 9000.0,
            'lines': [
              {
                'line_id': 80,
                'product_id': 36,
                'product_name': '[DESK0005] Customizable Desk (Custom, White)',
                'quantity': 3.0,
                'price_unit': 750.0,
                'price_subtotal': 2250.0,
                'price_total': 9000.0,
                'tax_amount': 6750.0,
                'taxes': [6],
                'tax_details': [
                  {
                    'tax_id': 6,
                    'tax_name': '300%',
                    'tax_amount': 6750.0,
                    'tax_rate': 300.0,
                    'tax_type': 'percent'
                  }
                ]
              }
            ],
            'pagination': {
              'current_page': 1,
              'page_size': 10,
              'total_items': 1,
              'total_pages': 1,
              'has_next': false,
              'has_previous': false
            }
          },
        ),
      );

      // Act
      final result = await dataSource.updateCartItemQuantity(productId, quantity);

      // Assert
      expect(result, isA<CartResponseModel>());
      expect(result.lines.first.quantity, equals(3.0));

      verify(mockApiClient.requestRpc(
        '/ecom/product/cart',
        method: 'POST',
        params: {
          'action': 'update',
          'product_id': productId,
          'quantity': quantity,
        },
      )).called(1);
    });
  });

  group('removeFromCart', () {
    test('should remove item from cart successfully', () async {
      // Arrange
      final productId = 36;

      final mockResponse = Response(
        data: {
          'result': {
            'status': 'success',
            'message': 'Cart processed successfully',
            'data': {
              'order_id': 52,
              'state': 'draft',
              'currency': 'IQD',
              'amount_untaxed': 0.0,
              'amount_tax': 0.0,
              'amount_total': 0.0,
              'lines': [],
              'pagination': {
                'current_page': 1,
                'page_size': 10,
                'total_items': 0,
                'total_pages': 1,
                'has_next': false,
                'has_previous': false
              }
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/product/cart'),
      );

      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
        (
          status: 'success',
          message: 'Cart processed successfully',
          data: {
            'order_id': 52,
            'state': 'draft',
            'currency': 'IQD',
            'amount_untaxed': 0.0,
            'amount_tax': 0.0,
            'amount_total': 0.0,
            'lines': [],
            'pagination': {
              'current_page': 1,
              'page_size': 10,
              'total_items': 0,
              'total_pages': 1,
              'has_next': false,
              'has_previous': false
            }
          },
        ),
      );

      // Act
      final result = await dataSource.removeFromCart(productId);

      // Assert
      expect(result, isA<CartResponseModel>());
      expect(result.lines.length, equals(0));

      verify(mockApiClient.requestRpc(
        '/ecom/product/cart',
        method: 'POST',
        params: {
          'action': 'remove',
          'product_id': productId,
        },
      )).called(1);
    });
  });

  group('removeFromCartByQuantity', () {
    test('should remove item from cart by quantity successfully', () async {
      // Arrange
      final productId = 36;
      final quantity = 1;

      final mockResponse = Response(
        data: {
          'result': {
            'status': 'success',
            'message': 'Cart processed successfully',
            'data': {
              'order_id': 52,
              'state': 'draft',
              'currency': 'IQD',
              'amount_untaxed': 0.0,
              'amount_tax': 0.0,
              'amount_total': 0.0,
              'lines': [],
              'pagination': {
                'current_page': 1,
                'page_size': 10,
                'total_items': 0,
                'total_pages': 1,
                'has_next': false,
                'has_previous': false
              }
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/product/cart'),
      );

      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
        (
          status: 'success',
          message: 'Cart processed successfully',
          data: {
            'order_id': 52,
            'state': 'draft',
            'currency': 'IQD',
            'amount_untaxed': 0.0,
            'amount_tax': 0.0,
            'amount_total': 0.0,
            'lines': [],
            'pagination': {
              'current_page': 1,
              'page_size': 10,
              'total_items': 0,
              'total_pages': 1,
              'has_next': false,
              'has_previous': false
            }
          },
        ),
      );

      // Act
      final result = await dataSource.removeFromCartByQuantity(productId, quantity);

      // Assert
      expect(result, isA<CartResponseModel>());
      expect(result.lines.length, equals(0));

      verify(mockApiClient.requestRpc(
        '/ecom/product/cart',
        method: 'POST',
        params: {
          'action': 'remove',
          'product_id': productId,
          'quantity': quantity,
        },
      )).called(1);
    });
  });
}
