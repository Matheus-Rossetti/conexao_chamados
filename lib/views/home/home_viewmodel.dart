import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/dependecies.dart';
import '../../data/models/ticket_model.dart';
import '../../data/repositories/ticket_repository.dart';

class HomeViewmodel {
  final TicketRepository _ticketRepository = dependencies<TicketRepository>();
  final FlutterSecureStorage _secureStorage =
      dependencies<FlutterSecureStorage>();

  Future<String> getTechnicianName() async {
    final name = await _secureStorage.read(key: 'technician_name');
    return (name != null && name.isNotEmpty) ? name : "Técnico";
  }

  List<TicketModel> tickets = [];

  Future<void> loadTickets() async {
    try {
      tickets = await _ticketRepository.fetchAndSaveTickets();
    } catch (e) {
      tickets = await _ticketRepository.getStoredTickets();
    }
  }
}
