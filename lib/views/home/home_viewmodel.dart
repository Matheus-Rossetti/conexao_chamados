import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/dependecies.dart';
import '../../data/models/service_model.dart';
import '../../data/models/ticket_model.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/ticket_repository.dart';

class HomeViewmodel {
  final TicketRepository _ticketRepository = dependencies<TicketRepository>();
  final LocationRepository _locationRepository =
      dependencies<LocationRepository>();
  final FlutterSecureStorage _secureStorage =
      dependencies<FlutterSecureStorage>();

  final ValueNotifier<List<TicketModel>> tickets = ValueNotifier([]);
  final ValueNotifier<List<ServiceModel>> services = ValueNotifier([]);
  final ValueNotifier<String> selectedTab = ValueNotifier('chamados');

  List<ServiceModel> _allServices = [];
  bool isOfflineMode = false;

  Future<String> getTechnicianName() async {
    final name = await _secureStorage.read(key: 'technician_name');
    return (name != null && name.isNotEmpty) ? name : "Técnico";
  }

  Future<void> loadTickets() async {
    isOfflineMode = false;
    List<TicketModel> loadedTickets = [];
    try {
      loadedTickets = await _ticketRepository.fetchAndSaveTickets();
    } catch (e) {
      isOfflineMode = true;
      loadedTickets = await _ticketRepository.getStoredTickets();
    }

    await _processAndSortTickets(loadedTickets);
    await loadServices();
  }

  Future<void> refreshLocalTickets() async {
    final storedTickets = await _ticketRepository.getStoredTickets();
    await _processAndSortTickets(storedTickets);
    await loadServices();
  }

  Future<void> loadServices() async {
    _allServices = await _ticketRepository.getStoredServices();
    services.value = _allServices;
  }

  Future<void> syncServices() async {
    final servicesList = await _ticketRepository.getStoredServices();
    await _ticketRepository.uploadServices(servicesList);
    await loadServices();
  }

  void setTab(String tab) {
    selectedTab.value = tab;
  }

  void searchServices(String query) {
    if (query.trim().isEmpty) {
      services.value = _allServices;
      return;
    }

    final lowerQuery = query.toLowerCase().trim();
    services.value = _allServices.where((service) {
      final idMatch = service.ticketFk.toString().toLowerCase().contains(
        lowerQuery,
      );
      final codeMatch = (service.clientCode ?? '').toLowerCase().contains(
        lowerQuery,
      );
      final nameMatch = (service.clientName ?? '').toLowerCase().contains(
        lowerQuery,
      );
      final dateMatch = service.date.toLowerCase().contains(lowerQuery);

      return idMatch || codeMatch || nameMatch || dateMatch;
    }).toList();
  }

  Future<void> _processAndSortTickets(List<TicketModel> list) async {
    final position = await _locationRepository.getCurrentPosition();

    if (position != null) {
      for (final ticket in list) {
        final distanceMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          ticket.latitude,
          ticket.longitude,
        );
        ticket.distanceMeters = distanceMeters;
        ticket.distanceFormatted = _formatDistance(distanceMeters);
      }

      list.sort(
        (a, b) => (a.distanceMeters ?? double.infinity).compareTo(
          b.distanceMeters ?? double.infinity,
        ),
      );
    }

    tickets.value = list;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  void dispose() {
    tickets.dispose();
    services.dispose();
    selectedTab.dispose();
  }
}
