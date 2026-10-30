import 'package:sqflite/sqflite.dart';

import '../models/service_model.dart';
import '../models/ticket_model.dart';
import '../services/local_db_service.dart';
import '../services/ticket_service.dart';

class TicketRepository {
  final TicketService _ticketService;
  final LocalDbService _localDbService;

  TicketRepository(this._ticketService, this._localDbService);

  Future<List<TicketModel>> fetchAndSaveTickets() async {
    try {
      final response = await _ticketService.fetchTickets();
      final dados = response['dados'];

      if (dados is List) {
        final tickets = dados
            .map((item) => TicketModel.fromJson(item as Map<String, dynamic>))
            .toList();

        final db = await _localDbService.database;
        await db.transaction((txn) async {
          for (final ticket in tickets) {
            await txn.insert(
              'tickets',
              ticket.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        });

        return tickets;
      }
      return await getStoredTickets();
    } catch (e) {
      return await getStoredTickets();
    }
  }

  Future<List<TicketModel>> getStoredTickets() async {
    final db = await _localDbService.database;
    final maps = await db.query('tickets');
    return maps.map((map) => TicketModel.fromMap(map)).toList();
  }

  Future<int> saveService({
    required int ticketId,
    required String conclusion,
    required String description,
    required String date,
    String? imagePath,
  }) async {
    final service = ServiceModel(
      ticketFk: ticketId,
      synchronized: 0,
      conclusion: conclusion,
      description: description,
      date: date,
      imagePath: imagePath,
    );

    final db = await _localDbService.database;
    return await db.transaction((txn) async {
      final serviceId = await txn.insert(
        'services',
        service.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.update(
        'tickets',
        {'status': 'atendido'},
        where: 'id = ?',
        whereArgs: [ticketId],
      );

      return serviceId;
    });
  }
}
