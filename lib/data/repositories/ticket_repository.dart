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
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      });
    }

    return await getStoredTickets();
  }

  Future<List<TicketModel>> getStoredTickets() async {
    final db = await _localDbService.database;
    final maps = await db.query(
      'tickets',
      where: 'status = ?',
      whereArgs: ['ativo'],
    );
    return maps.map((map) => TicketModel.fromMap(map)).toList();
  }

  Future<List<ServiceModel>> getStoredServices() async {
    final db = await _localDbService.database;
    final maps = await db.rawQuery('''
      SELECT s.*, t.nome_cliente, t.codigo_cliente, t.categoria_informada 
      FROM services s
      LEFT JOIN tickets t ON s.ticket_fk = t.id
    ''');
    return maps.map((map) => ServiceModel.fromMap(map)).toList();
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
    final serviceId = await db.transaction((txn) async {
      final id = await txn.insert(
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

      return id;
    });

    try {
      final savedService = ServiceModel(
        id: serviceId,
        ticketFk: ticketId,
        synchronized: 0,
        conclusion: conclusion,
        description: description,
        date: date,
        imagePath: imagePath,
      );
      await uploadServices([savedService]);
    } catch (_) {}

    return serviceId;
  }

  Future<void> uploadServices(List<ServiceModel> services) async {
    final db = await _localDbService.database;

    for (final service in services) {
      if (service.synchronized == 1) continue;

      try {
        final fotoUrl = await _ticketService.sendService(
          ticketId: service.ticketFk,
          conclusion: service.conclusion,
          description: service.description,
          date: service.date,
          imagePath: service.imagePath,
        );

        if (service.id != null) {
          await db.update(
            'services',
            {
              'sincronizado': 1,
              if (fotoUrl != null && fotoUrl.isNotEmpty) 'foto_url': fotoUrl,
            },
            where: 'id = ?',
            whereArgs: [service.id],
          );
        }
      } catch (_) {
        // Continue uploading remaining services even if one fails
      }
    }
  }
}
