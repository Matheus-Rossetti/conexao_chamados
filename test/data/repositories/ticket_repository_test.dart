import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:avaliacao_final_sctec/data/models/service_model.dart';
import 'package:avaliacao_final_sctec/data/repositories/ticket_repository.dart';
import 'package:avaliacao_final_sctec/data/services/local_db_service.dart';
import 'package:avaliacao_final_sctec/data/services/ticket_service.dart';

class MockTicketService extends Mock implements TicketService {}

class MockLocalDbService extends Mock implements LocalDbService {}

void main() {
  late MockTicketService mockTicketService;
  late MockLocalDbService mockLocalDbService;
  late TicketRepository ticketRepository;
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    mockTicketService = MockTicketService();
    mockLocalDbService = MockLocalDbService();

    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await LocalDbService().createTable(db);

    when(() => mockLocalDbService.database).thenAnswer((_) async => db);

    ticketRepository = TicketRepository(mockTicketService, mockLocalDbService);
  });

  tearDown(() async {
    await db.close();
  });

  group('TicketRepository', () {
    test(
      'fetchAndSaveTickets saves fetched tickets and returns active ones',
      () async {
        final mockApiResponse = {
          'dados': [
            {
              'id': 101,
              'codigo_cliente': 'CLI001',
              'nome_cliente': 'Cliente Um',
              'categoria_informada': 'Fibra',
              'descricao_problema': 'Sem sinal',
              'endereco_cliente': 'Rua A',
              'bairro': 'Centro',
              'cidade': 'Florianópolis',
              'latitude': -27.5,
              'longitude': -48.5,
              'status': 'ativo',
              'criado_em': '2026-01-01',
            },
            {
              'id': 102,
              'codigo_cliente': 'CLI002',
              'nome_cliente': 'Cliente Dois',
              'categoria_informada': 'Roteador',
              'descricao_problema': 'Lento',
              'endereco_cliente': 'Rua B',
              'bairro': 'Trindade',
              'cidade': 'Florianópolis',
              'latitude': -27.6,
              'longitude': -48.6,
              'status': 'atendido',
              'criado_em': '2026-01-02',
            },
          ],
        };

        when(() => mockTicketService.fetchTickets())
            .thenAnswer((_) async => mockApiResponse);

        final result = await ticketRepository.fetchAndSaveTickets();

        expect(result.length, equals(1));
        expect(result.first.id, equals(101));
        expect(result.first.clientName, equals('Cliente Um'));
        expect(result.first.status, equals('ativo'));

        verify(() => mockTicketService.fetchTickets()).called(1);
      },
    );

    test('getStoredTickets returns only active tickets', () async {
      await db.insert('tickets', {
        'id': 1,
        'codigo_cliente': 'C1',
        'nome_cliente': 'Ativo 1',
        'categoria_informada': 'Cat',
        'descricao_problema': 'Desc',
        'endereco_cliente': 'End',
        'bairro': 'Bairro',
        'cidade': 'Cidade',
        'latitude': 0.0,
        'longitude': 0.0,
        'status': 'ativo',
        'criado_em': '2026-01-01',
      });

      await db.insert('tickets', {
        'id': 2,
        'codigo_cliente': 'C2',
        'nome_cliente': 'Atendido 1',
        'categoria_informada': 'Cat',
        'descricao_problema': 'Desc',
        'endereco_cliente': 'End',
        'bairro': 'Bairro',
        'cidade': 'Cidade',
        'latitude': 0.0,
        'longitude': 0.0,
        'status': 'atendido',
        'criado_em': '2026-01-01',
      });

      final storedTickets = await ticketRepository.getStoredTickets();

      expect(storedTickets.length, equals(1));
      expect(storedTickets.first.id, equals(1));
      expect(storedTickets.first.clientName, equals('Ativo 1'));
    });

    test(
      'getStoredServices returns stored services with ticket details joined',
      () async {
        await db.insert('tickets', {
          'id': 10,
          'codigo_cliente': 'C10',
          'nome_cliente': 'Cliente Dez',
          'categoria_informada': 'Cabo',
          'status': 'atendido',
        });

        await db.insert('services', {
          'id': 1,
          'ticket_fk': 10,
          'sincronizado': 1,
          'conclusao': 'Concluído',
          'descricao': 'Troca de cabo',
          'data': '2026-02-01',
        });

        final storedServices = await ticketRepository.getStoredServices();

        expect(storedServices.length, equals(1));
        expect(storedServices.first.id, equals(1));
        expect(storedServices.first.ticketFk, equals(10));
        expect(storedServices.first.clientName, equals('Cliente Dez'));
        expect(storedServices.first.clientCode, equals('C10'));
        expect(storedServices.first.category, equals('Cabo'));
      },
    );

    test('saveService inserts service, updates ticket status to atendido and returns ID', () async {
      await db.insert('tickets', {
        'id': 20,
        'codigo_cliente': 'C20',
        'nome_cliente': 'Cliente Vinte',
        'status': 'ativo',
      });

      when(
        () => mockTicketService.sendService(
          ticketId: 20,
          conclusion: 'Resolvido',
          description: 'Troca de conector',
          date: '2026-02-10',
          imagePath: null,
        ),
      ).thenAnswer((_) async => 'http://example.com/foto.jpg');

      final serviceId = await ticketRepository.saveService(
        ticketId: 20,
        conclusion: 'Resolvido',
        description: 'Troca de conector',
        date: '2026-02-10',
      );

      expect(serviceId, greaterThan(0));

      // Verify ticket status was updated to 'atendido'
      final tickets = await db.query(
        'tickets',
        where: 'id = ?',
        whereArgs: [20],
      );
      expect(tickets.first['status'], equals('atendido'));

      // Verify service was inserted
      final services = await db.query(
        'services',
        where: 'id = ?',
        whereArgs: [serviceId],
      );
      expect(services.length, equals(1));
      expect(services.first['conclusao'], equals('Resolvido'));
      expect(services.first['sincronizado'], equals(1));
      expect(services.first['foto_url'], equals('http://example.com/foto.jpg'));
    });

    group('uploadServices', () {
      test('synchronizes pending services and updates foto_url and sincronizado flag', () async {
        await db.insert('services', {
          'id': 5,
          'ticket_fk': 30,
          'sincronizado': 0,
          'conclusao': 'Ok',
          'descricao': 'Procedimento',
          'data': '2026-02-15',
          'imagem': '/path/to/img.png',
        });

        final pendingService = ServiceModel(
          id: 5,
          ticketFk: 30,
          synchronized: 0,
          conclusion: 'Ok',
          description: 'Procedimento',
          date: '2026-02-15',
          imagePath: '/path/to/img.png',
        );

        when(
          () => mockTicketService.sendService(
            ticketId: 30,
            conclusion: 'Ok',
            description: 'Procedimento',
            date: '2026-02-15',
            imagePath: '/path/to/img.png',
          ),
        ).thenAnswer((_) async => 'http://example.com/img5.png');

        await ticketRepository.uploadServices([pendingService]);

        final updated = await db.query(
          'services',
          where: 'id = ?',
          whereArgs: [5],
        );
        expect(updated.first['sincronizado'], equals(1));
        expect(
          updated.first['foto_url'],
          equals('http://example.com/img5.png'),
        );
      });

      test('skips services that are already synchronized', () async {
        final syncedService = ServiceModel(
          id: 6,
          ticketFk: 31,
          synchronized: 1,
          conclusion: 'Ok',
          description: 'Já sincronizado',
          date: '2026-02-15',
        );

        await ticketRepository.uploadServices([syncedService]);

        verifyNever(
          () => mockTicketService.sendService(
            ticketId: any(named: 'ticketId'),
            conclusion: any(named: 'conclusion'),
            description: any(named: 'description'),
            date: any(named: 'date'),
            imagePath: any(named: 'imagePath'),
          ),
        );
      });

      test('throws Exception when internet connection fails for all unsynchronized services', () async {
        final pendingService = ServiceModel(
          id: 7,
          ticketFk: 32,
          synchronized: 0,
          conclusion: 'Ok',
          description: 'Falha de rede',
          date: '2026-02-15',
        );

        when(
          () => mockTicketService.sendService(
            ticketId: 32,
            conclusion: 'Ok',
            description: 'Falha de rede',
            date: '2026-02-15',
            imagePath: null,
          ),
        ).thenThrow(Exception('Network error'));

        expect(
          () => ticketRepository.uploadServices([pendingService]),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Falha na sincronização: sem conexão com a internet.'),
            ),
          ),
        );
      });
    });
  });
}
