import 'package:sqflite/sqflite.dart';

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
}
