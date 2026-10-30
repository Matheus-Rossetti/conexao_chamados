import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avaliacao_final_sctec/data/services/auth_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AuthServiceDioImpl authService;

  setUp(() {
    mockDio = MockDio();
    authService = AuthServiceDioImpl(dio: mockDio);
  });

  group('AuthServiceDioImpl', () {
    test(
      'login returns map on status code 200 with Map<String, dynamic> data',
      () async {
        final expectedData = {
          'sucesso': true,
          'token': 'jwt_123',
          'dados': {'nome': 'Test User'},
        };

        when(
          () => mockDio.post(
            '/login',
            data: {'email': 'test@test.com', 'senha_hmac': 'hmac123'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 200,
            data: expectedData,
          ),
        );

        final result = await authService.login(
          email: 'test@test.com',
          senhaHmac: 'hmac123',
        );

        expect(result, equals(expectedData));
      },
    );

    test(
      'login returns empty map on status code 200 with non-map data',
      () async {
        when(
          () => mockDio.post(
            '/login',
            data: {'email': 'test@test.com', 'senha_hmac': 'hmac123'},
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 200,
            data: 'unexpected_string',
          ),
        );

        final result = await authService.login(
          email: 'test@test.com',
          senhaHmac: 'hmac123',
        );

        expect(result, equals({}));
      },
    );

    test('login throws Exception on status code outside 200..299', () async {
      when(
        () => mockDio.post(
          '/login',
          data: {'email': 'test@test.com', 'senha_hmac': 'hmac123'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 400,
          data: {},
        ),
      );

      expect(
        () => authService.login(email: 'test@test.com', senhaHmac: 'hmac123'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro ao realizar login'),
          ),
        ),
      );
    });

    test(
      'login extracts message field from response data on DioException',
      () async {
        when(
          () => mockDio.post(
            '/login',
            data: {'email': 'test@test.com', 'senha_hmac': 'hmac123'},
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/login'),
              statusCode: 401,
              data: {'message': 'Usuário ou senha inválidos'},
            ),
          ),
        );

        expect(
          () => authService.login(email: 'test@test.com', senhaHmac: 'hmac123'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Usuário ou senha inválidos'),
            ),
          ),
        );
      },
    );

    test('login extracts string response data on DioException', () async {
      when(
        () => mockDio.post(
          '/login',
          data: {'email': 'test@test.com', 'senha_hmac': 'hmac123'},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 500,
            data: 'Internal Server Error Detail',
          ),
        ),
      );

      expect(
        () => authService.login(email: 'test@test.com', senhaHmac: 'hmac123'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Internal Server Error Detail'),
          ),
        ),
      );
    });

    test(
      'login uses Exception message on DioException without response',
      () async {
        when(
          () => mockDio.post(
            '/login',
            data: {'email': 'test@test.com', 'senha_hmac': 'hmac123'},
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/login'),
            message: 'Connection Timeout',
          ),
        );

        expect(
          () => authService.login(email: 'test@test.com', senhaHmac: 'hmac123'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Connection Timeout'),
            ),
          ),
        );
      },
    );
  });
}
