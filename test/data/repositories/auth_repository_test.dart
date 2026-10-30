import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:avaliacao_final_sctec/data/repositories/auth_repository.dart';
import 'package:avaliacao_final_sctec/data/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockAuthService mockAuthService;
  late MockFlutterSecureStorage mockSecureStorage;
  late AuthRepository authRepository;

  setUp(() {
    mockAuthService = MockAuthService();
    mockSecureStorage = MockFlutterSecureStorage();
    authRepository = AuthRepository(mockAuthService, mockSecureStorage);

    registerFallbackValue('');
  });

  group('AuthRepository', () {
    test('computeHmac generates correct HMAC-SHA256 string', () {
      final hmac = authRepository.computeHmac('123456');
      expect(hmac, isNotEmpty);
      expect(hmac, isA<String>());
      // Verify determinism
      expect(authRepository.computeHmac('123456'), equals(hmac));
      // Verify different password yields different hash
      expect(authRepository.computeHmac('654321'), isNot(equals(hmac)));
    });

    group('login', () {
      test(
        'stores token and technician_name on successful login with dados map',
        () async {
          final senhaHmac = authRepository.computeHmac('password123');
          when(
            () => mockAuthService.login(
              email: 'test@example.com',
              senhaHmac: senhaHmac,
            ),
          ).thenAnswer(
            (_) async => {
              'sucesso': true,
              'dados': {
                'token': 'jwt_token_123',
                'usuario': {'nome': 'Técnico Silva'},
              },
            },
          );

          when(
            () => mockSecureStorage.write(
              key: any(named: 'key'),
              value: any(named: 'value'),
            ),
          ).thenAnswer((_) async {});

          await authRepository.login(
            email: 'test@example.com',
            password: 'password123',
          );

          verify(
            () => mockSecureStorage.write(key: 'token', value: 'jwt_token_123'),
          ).called(1);

          verify(
            () => mockSecureStorage.write(
              key: 'technician_name',
              value: 'Técnico Silva',
            ),
          ).called(1);
        },
      );

      test('stores token when token is at root level of response', () async {
        final senhaHmac = authRepository.computeHmac('password123');
        when(
          () => mockAuthService.login(
            email: 'test@example.com',
            senhaHmac: senhaHmac,
          ),
        ).thenAnswer((_) async => {'sucesso': true, 'token': 'root_jwt_token'});

        when(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        await authRepository.login(
          email: 'test@example.com',
          password: 'password123',
        );

        verify(
          () => mockSecureStorage.write(key: 'token', value: 'root_jwt_token'),
        ).called(1);

        verifyNever(
          () => mockSecureStorage.write(
            key: 'technician_name',
            value: any(named: 'value'),
          ),
        );
      });

      test('throws Exception when login response sucesso is false', () async {
        final senhaHmac = authRepository.computeHmac('password123');
        when(
          () => mockAuthService.login(
            email: 'test@example.com',
            senhaHmac: senhaHmac,
          ),
        ).thenAnswer(
          (_) async => {'sucesso': false, 'mensagem': 'Credenciais inválidas'},
        );

        expect(
          () => authRepository.login(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Credenciais inválidas'),
            ),
          ),
        );
      });

      test('throws Exception when token is missing in response', () async {
        final senhaHmac = authRepository.computeHmac('password123');
        when(
          () => mockAuthService.login(
            email: 'test@example.com',
            senhaHmac: senhaHmac,
          ),
        ).thenAnswer((_) async => {'sucesso': true, 'dados': {}});

        expect(
          () => authRepository.login(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Token não encontrado na resposta do servidor'),
            ),
          ),
        );
      });
    });
  });
}
