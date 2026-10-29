import '../../core/dependecies.dart';
import '../../data/models/ticket_model.dart';
import '../../data/repositories/ticket_repository.dart';

class HomeViewmodel {
  final TicketRepository _ticketRepository = dependencies<TicketRepository>();

  final String technicianName = "Joao Ilson Thum Garcia";

  List<TicketModel> tickets = [];

  Future<void> loadTickets() async {
    try {
      tickets = await _ticketRepository.fetchAndSaveTickets();
    } catch (e) {
      tickets = await _ticketRepository.getStoredTickets();
    }
  }
}
