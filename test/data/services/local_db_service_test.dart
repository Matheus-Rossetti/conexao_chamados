import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:avaliacao_final_sctec/data/services/local_db_service.dart';

void main() {
  late LocalDbService localDbService;
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    localDbService = LocalDbService();
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
  });

  tearDown(() async {
    await db.close();
  });

  group('LocalDbService', () {
    test('createTable creates tickets and services tables in database', () async {
      await localDbService.createTable(db);

      // Verify tickets table exists
      final ticketsTableInfo = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='tickets'",
      );
      expect(ticketsTableInfo.length, equals(1));

      // Verify services table exists
      final servicesTableInfo = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='services'",
      );
      expect(servicesTableInfo.length, equals(1));

      // Verify tickets columns
      final ticketsColumns = await db.rawQuery("PRAGMA table_info(tickets)");
      final ticketColNames = ticketsColumns.map((col) => col['name']).toList();
      expect(
        ticketColNames,
        containsAll([
          'id',
          'codigo_cliente',
          'nome_cliente',
          'categoria_informada',
          'descricao_problema',
          'endereco_cliente',
          'bairro',
          'cidade',
          'latitude',
          'longitude',
          'status',
          'criado_em',
        ]),
      );

      // Verify services columns
      final servicesColumns = await db.rawQuery("PRAGMA table_info(services)");
      final serviceColNames = servicesColumns
          .map((col) => col['name'])
          .toList();
      expect(
        serviceColNames,
        containsAll([
          'id',
          'ticket_fk',
          'sincronizado',
          'conclusao',
          'descricao',
          'data',
          'imagem',
          'foto_url',
        ]),
      );
    });
  });
}
