import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/ticket_model.dart';

class TicketViewModel {
  final TicketModel ticket;

  TicketViewModel({required this.ticket});

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

  void dispose() {
    descriptionController.dispose();
  }
}
