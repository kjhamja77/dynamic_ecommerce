import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:zalando_clone_app/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:zalando_clone_app/features/profile/data/models/user_profile_model.dart';

import 'profile_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ProfileRemoteDataSourceImpl(mockApiClient);
  });

  group('updateUserProfile', () {
    test('should update user profile successfully', () async {
      // Arrange
      final profile = UserProfileModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+1 555 123 4567',
        address: '123 Main St, Los Angeles, 90001',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockResponse = Response(
        data: {
          'result': {
            'status': 'success',
            'message': 'Profile updated successfully',
            'data': {
              'user_profile': [
                {
                  'user_id': '1',
                  'name': 'John Doe',
                  'email': 'john@example.com',
                  'phone': '+1 555 123 4567',
                  'image': 'https://example.com/avatar.jpg',
                }
              ]
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/user/profile'),
      );

      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
        (
          status: 'success',
          message: 'Profile updated successfully',
          data: {
            'user_profile': [
              {
                'user_id': '1',
                'name': 'John Doe',
                'email': 'john@example.com',
                'phone': '+1 555 123 4567',
                'image': 'https://example.com/avatar.jpg',
              }
            ]
          },
        ),
      );

      // Act
      final result = await dataSource.updateUserProfile(profile);

      // Assert
      expect(result, isA<UserProfileModel>());
      expect(result.name, equals('John Doe'));
      expect(result.email, equals('john@example.com'));
      expect(result.phoneNumber, equals('+1 555 123 4567'));

      verify(mockApiClient.requestRpc(
        '/ecom/user/profile',
        method: 'POST',
        params: {
          'action': 'update',
          'name': 'John Doe',
          'phone': '+1 555 123 4567',
          'street': '123 Main St',
          'city': 'Los Angeles',
          'zip': '90001',
          'image': 'https://example.com/avatar.jpg',
        },
      )).called(1);
    });

    test('should handle profile update with minimal data', () async {
      // Arrange
      final profile = UserProfileModel(
        id: '1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mockResponse = Response(
        data: {
          'result': {
            'status': 'success',
            'message': 'Profile updated successfully',
            'data': {
              'user_profile': [
                {
                  'user_id': '1',
                  'name': 'Jane Doe',
                  'email': 'jane@example.com',
                }
              ]
            }
          }
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/ecom/user/profile'),
      );

      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenAnswer((_) async => mockResponse);

      when(mockApiClient.parseRpcEnvelope(any)).thenReturn(
        (
          status: 'success',
          message: 'Profile updated successfully',
          data: {
            'user_profile': [
              {
                'user_id': '1',
                'name': 'Jane Doe',
                'email': 'jane@example.com',
              }
            ]
          },
        ),
      );

      // Act
      final result = await dataSource.updateUserProfile(profile);

      // Assert
      expect(result, isA<UserProfileModel>());
      expect(result.name, equals('Jane Doe'));
      expect(result.email, equals('jane@example.com'));

      verify(mockApiClient.requestRpc(
        '/ecom/user/profile',
        method: 'POST',
        params: {
          'action': 'update',
          'name': 'Jane Doe',
          'image': '',
        },
      )).called(1);
    });

    test('should throw exception when API returns error', () async {
      // Arrange
      final profile = UserProfileModel(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockApiClient.requestRpc(
        any,
        method: anyNamed('method'),
        params: anyNamed('params'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/ecom/user/profile'),
        message: 'Network error',
      ));

      // Act & Assert
      expect(
        () => dataSource.updateUserProfile(profile),
        throwsA(isA<Exception>()),
      );
    });
  });
}

