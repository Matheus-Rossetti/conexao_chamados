import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avaliacao_final_sctec/data/services/auth_service_impl.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AuthServiceImpl authService;

  setUp(() {
    mockDio = MockDio();
    authService = AuthServiceImpl(dio: mockDio);
  });

  group('AuthServiceImpl', () {
    test('login returns map on status code 200 with Map data', () async {
      final expectedData = {
        'sucesso': true,
        'token': 'jwt_token_456',
        'dados': {'nome': 'Técnico'},
      };

      when(
        () => mockDio.post(
          '/login',
          data: {'email': 'user@test.com', 'senha_hmac': 'hmac456'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 200,
          data: expectedData,
        ),
      );

      final result = await authService.login(
        email: 'user@test.com',
        senhaHmac: 'hmac456',
      );

      expect(result, equals(expectedData));
    });

    test('login throws Exception on error status code', () async {
      when(
        () => mockDio.post(
          '/login',
          data: {'email': 'user@test.com', 'senha_hmac': 'hmac456'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/login'),
          statusCode: 500,
          data: {},
        ),
      );

      expect(
        () => authService.login(email: 'user@test.com', senhaHmac: 'hmac456'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro ao realizar login'),
          ),
        ),
      );
    });

    test('login handles DioException with message field', () async {
      when(
        () => mockDio.post(
          '/login',
          data: {'email': 'user@test.com', 'senha_hmac': 'hmac456'},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 400,
            data: {'message': 'Credenciais incorretas'},
          ),
        ),
      );

      expect(
        () => authService.login(email: 'user@test.com', senhaHmac: 'hmac456'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Credenciais incorretas'),
          ),
        ),
      );
    });

    test('initializes default Dio with base URL if not provided', () {
      final defaultService = AuthServiceImpl();
      expect(
        defaultService.dio.options.baseUrl,
        equals('https://oquetemnomeucosmetico.com.br/api'),
      );
    });
  });
}
