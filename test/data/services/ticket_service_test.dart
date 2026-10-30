import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avaliacao_final_sctec/data/services/ticket_service.dart';

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockDio mockDio;
  late MockFlutterSecureStorage mockSecureStorage;
  late TicketServiceDioImpl ticketService;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    mockSecureStorage = MockFlutterSecureStorage();
    ticketService = TicketServiceDioImpl(
      dio: mockDio,
      secureStorage: mockSecureStorage,
    );
  });

  group('TicketServiceDioImpl', () {
    group('fetchTickets', () {
      test(
        'returns data map on status code 200 with Bearer token header',
        () async {
          when(() => mockSecureStorage.read(key: 'token'))
              .thenAnswer((_) async => 'saved_jwt_token');

          final expectedData = {
            'dados': [
              {'id': 1, 'nome_cliente': 'Cliente A'},
            ],
          };

          when(() => mockDio.get('/chamados', options: any(named: 'options')))
              .thenAnswer(
                (_) async => Response(
                  requestOptions: RequestOptions(path: '/chamados'),
                  statusCode: 200,
                  data: expectedData,
                ),
              );

          final result = await ticketService.fetchTickets();

          expect(result, equals(expectedData));
          verify(() => mockSecureStorage.read(key: 'token')).called(1);
        },
      );

      test('throws Exception on non-200 status code', () async {
        when(() => mockSecureStorage.read(key: 'token'))
            .thenAnswer((_) async => null);

        when(() => mockDio.get('/chamados', options: any(named: 'options')))
            .thenAnswer(
              (_) async => Response(
                requestOptions: RequestOptions(path: '/chamados'),
                statusCode: 500,
                data: {},
              ),
            );

        expect(
          () => ticketService.fetchTickets(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Erro ao buscar chamados'),
            ),
          ),
        );
      });

      test('extracts error message from DioException response data', () async {
        when(() => mockSecureStorage.read(key: 'token'))
            .thenAnswer((_) async => 'token');

        when(() => mockDio.get('/chamados', options: any(named: 'options')))
            .thenThrow(
              DioException(
                requestOptions: RequestOptions(path: '/chamados'),
                response: Response(
                  requestOptions: RequestOptions(path: '/chamados'),
                  statusCode: 401,
                  data: {'message': 'Token expirado'},
                ),
              ),
            );

        expect(
          () => ticketService.fetchTickets(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Token expirado'),
            ),
          ),
        );
      });
    });

    group('sendService', () {
      test('returns foto_url on status code 201', () async {
        when(() => mockSecureStorage.read(key: 'token'))
            .thenAnswer((_) async => 'saved_token');

        when(
          () => mockDio.post(
            '/atendimento',
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/atendimento'),
            statusCode: 201,
            data: {
              'dados': {
                'foto_url': 'https://s3.amazonaws.com/bucket/foto123.jpg',
              },
            },
          ),
        );

        final fotoUrl = await ticketService.sendService(
          ticketId: 10,
          conclusion: 'Resolvido',
          description: 'Troca de modem',
          date: '2026-02-20',
        );

        expect(fotoUrl, equals('https://s3.amazonaws.com/bucket/foto123.jpg'));
      });

      test(
        'sends service with image file when imagePath is provided',
        () async {
          final tempDir = await Directory.systemTemp.createTemp();
          final tempFile = File('${tempDir.path}/test_image.jpg');
          await tempFile.writeAsBytes([0, 1, 2, 3]);

          when(() => mockSecureStorage.read(key: 'token'))
              .thenAnswer((_) async => 'saved_token');

          when(
            () => mockDio.post(
              '/atendimento',
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).thenAnswer(
            (_) async => Response(
              requestOptions: RequestOptions(path: '/atendimento'),
              statusCode: 201,
              data: {
                'dados': {
                  'foto_url': 'https://s3.amazonaws.com/bucket/foto456.jpg',
                },
              },
            ),
          );

          final fotoUrl = await ticketService.sendService(
            ticketId: 11,
            conclusion: 'Resolvido',
            description: 'Foto enviada',
            date: '2026-02-20',
            imagePath: tempFile.path,
          );

          expect(
            fotoUrl,
            equals('https://s3.amazonaws.com/bucket/foto456.jpg'),
          );

          await tempDir.delete(recursive: true);
        },
      );

      test('returns null when status code is not 201', () async {
        when(() => mockSecureStorage.read(key: 'token'))
            .thenAnswer((_) async => 'saved_token');

        when(
          () => mockDio.post(
            '/atendimento',
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/atendimento'),
            statusCode: 200,
            data: {'message': 'Recebido com avisos'},
          ),
        );

        final fotoUrl = await ticketService.sendService(
          ticketId: 10,
          conclusion: 'Parcial',
          description: 'Desc',
        );

        expect(fotoUrl, isNull);
      });

      test('throws Exception on DioException', () async {
        when(() => mockSecureStorage.read(key: 'token'))
            .thenAnswer((_) async => 'saved_token');

        when(
          () => mockDio.post(
            '/atendimento',
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/atendimento'),
            response: Response(
              requestOptions: RequestOptions(path: '/atendimento'),
              statusCode: 422,
              data: {'message': 'Dados do chamado inválidos'},
            ),
          ),
        );

        expect(
          () => ticketService.sendService(
            ticketId: 10,
            conclusion: 'Incompleto',
            description: 'Desc',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Dados do chamado inválidos'),
            ),
          ),
        );
      });
    });
  });
}
