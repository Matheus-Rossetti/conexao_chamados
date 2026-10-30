import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/models/service_model.dart';

class ServiceView extends StatefulWidget {
  const ServiceView({super.key});

  @override
  State<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends State<ServiceView> {
  late ServiceModel service;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      service = ModalRoute.of(context)!.settings.arguments as ServiceModel;
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: Text(
          'Detalhes do Atendimento (${service.clientCode ?? 'N/A'})',
          style: const TextStyle(color: AppColors.textLight, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.conclusion,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepNavy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: service.synchronized == 1
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          service.synchronized == 1
                              ? 'Sincronizado'
                              : 'Pendente',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: service.synchronized == 1
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (service.clientName != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.clientName!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mediumSlateGray,
                            ),
                          ),
                        ),
                        if (service.clientCode != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.deepNavy.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              service.clientCode!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (service.category != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            service.category!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Text(
                    'Descrição:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mediumSlateGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.mediumSlateGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Data: ${service.date}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mediumSlateGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image Section
            if ((service.imagePath != null && service.imagePath!.isNotEmpty) ||
                (service.fotoUrl != null && service.fotoUrl!.isNotEmpty)) ...[
              const Text(
                'Foto do Atendimento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accentSky.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:
                      service.synchronized == 0 &&
                          service.imagePath != null &&
                          File(service.imagePath!).existsSync()
                      ? Image.file(
                          File(service.imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : service.fotoUrl != null && service.fotoUrl!.isNotEmpty
                      ? Image.network(
                          service.fotoUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentSky,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 48,
                                    color: AppColors.mediumSlateGray,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Imagem indisponível',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'Nenhuma foto anexada',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
