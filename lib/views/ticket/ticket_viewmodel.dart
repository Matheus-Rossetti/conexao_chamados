import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/dependecies.dart';
import '../../data/models/ticket_model.dart';
import '../../data/repositories/ticket_repository.dart';

class TicketViewModel {
  final TicketModel ticket;
  final TicketRepository _ticketRepository;

  TicketViewModel({required this.ticket, TicketRepository? ticketRepository})
    : _ticketRepository = ticketRepository ?? dependencies<TicketRepository>();

  final ImagePicker _imagePicker = ImagePicker();

  String? selectedConclusion;
  final List<String> conclusionOptions = [
    "Serviço concluído",
    "Requer troca de peça",
    "Requer nova visita",
    "Equipamento sem conserto",
    "Fora de garantia",
  ];

  final descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  XFile? pickedImage;

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        pickedImage = image;
      }
    } catch (_) {}
  }

  Future<void> saveAttendance() async {
    final dateStr =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';

    await _ticketRepository.saveService(
      ticketId: ticket.id,
      conclusion: selectedConclusion ?? "Serviço concluído",
      description: descriptionController.text.trim(),
      date: dateStr,
      imagePath: pickedImage?.path,
    );
  }

  void dispose() {
    descriptionController.dispose();
  }
}
