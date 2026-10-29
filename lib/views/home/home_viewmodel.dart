import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/dependecies.dart';
import '../../data/models/ticket_model.dart';
import '../../data/repositories/ticket_repository.dart';
import '../../data/repositories/location_repository.dart';

class HomeViewmodel {
  final TicketRepository _ticketRepository = dependencies<TicketRepository>();
  final LocationRepository _locationRepository =
      dependencies<LocationRepository>();
  final FlutterSecureStorage _secureStorage =
      dependencies<FlutterSecureStorage>();

  final ValueNotifier<List<TicketModel>> tickets = ValueNotifier([]);
  Timer? _timer;

  Future<String> getTechnicianName() async {
    final name = await _secureStorage.read(key: 'technician_name');
    return (name != null && name.isNotEmpty) ? name : "Técnico";
  }

  Future<void> loadTickets() async {
    List<TicketModel> loadedTickets = [];
    try {
      loadedTickets = await _ticketRepository.fetchAndSaveTickets();
    } catch (e) {
      loadedTickets = await _ticketRepository.getStoredTickets();
    }

    tickets.value = loadedTickets;
    await calculateDistancesAndSort();
    _startPeriodicSorting();
  }

  void _startPeriodicSorting() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      await calculateDistancesAndSort();
    });
  }

  Future<void> calculateDistancesAndSort() async {
    final position = await _locationRepository.getCurrentPosition();
    if (position == null) return;

    final currentList = List<TicketModel>.from(tickets.value);

    for (final ticket in currentList) {
      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        ticket.latitude,
        ticket.longitude,
      );
      ticket.distanceMeters = distanceMeters;
      ticket.distanceFormatted = _formatDistance(distanceMeters);
    }

    currentList.sort(
      (a, b) => (a.distanceMeters ?? double.infinity).compareTo(
        b.distanceMeters ?? double.infinity,
      ),
    );

    tickets.value = currentList;
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  void dispose() {
    _timer?.cancel();
    tickets.dispose();
  }
}
