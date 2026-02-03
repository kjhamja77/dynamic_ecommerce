import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:zalando_clone_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zalando_clone_app/core/constants/endpoints.dart';
import 'package:zalando_clone_app/core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecordingInterceptor extends Interceptor {
  late RequestOptions lastRequest;
  late Response lastResponse;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    lastRequest = options;
    // Short-circuit the call with a fake 200 response
    handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: {
        'user': {
          'id': '1',
          'email': 'john@example.com',
          'first_name': 'John',
          'last_name': 'Doe',
          'created_at': DateTime(2024, 1, 1).toIso8601String(),
          'updated_at': DateTime(2024, 1, 1).toIso8601String(),
        }
      },
    ));
  }
}

class FakeSecureStorage extends FlutterSecureStorage {}

void main() {
  group('AuthRemoteDataSource (Postman alignment)', () {
    late Dio dio;
    late RecordingInterceptor recorder;
    late AuthRemoteDataSourceImpl ds;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      recorder = RecordingInterceptor();
      dio.interceptors.add(recorder);
      final api = ApiClient(FakeSecureStorage());
      // Inject our test dio into ApiClient
      api.dio.interceptors.clear();
      api.dio.interceptors.add(recorder);
      // overwrite base url to match test dio
      api.dio.options.baseUrl = dio.options.baseUrl;
      ds = AuthRemoteDataSourceImpl(api);
    });

    test('login hits /ecom/portal/login with params wrapper', () async {
      await ds.login('john@example.com', '123', 'device123', 'token123');
      expect(recorder.lastRequest.path, Endpoints.login);
      expect(recorder.lastRequest.data, {
        'params': {
          'email': 'john@example.com',
          'password': '123',
          'device_id': 'device123',
          'device_token': 'token123',
        }
      });
    });

    test('register hits /ecom/portal/register with params wrapper', () async {
      await ds.register('john@example.com', '123', 'John', 'Doe');
      expect(recorder.lastRequest.path, Endpoints.register);
      expect(recorder.lastRequest.data, {
        'params': {
          'first_name': 'John',
          'last_name': 'Doe',
          'email': 'john@example.com',
          'password': '123',
        }
      });
    });

    test('logout hits /ecom/portal/logout with params wrapper', () async {
      await ds.logout();
      expect(recorder.lastRequest.path, Endpoints.logout);
      expect(recorder.lastRequest.data, {'params': {}});
    });

    test('forgotPassword hits reset password endpoint with params wrapper', () async {
      await ds.forgotPassword('john@example.com');
      expect(recorder.lastRequest.path, Endpoints.resetPassword);
      expect(recorder.lastRequest.data, {
        'params': {'email': 'john@example.com'}
      });
    });
  });
}


