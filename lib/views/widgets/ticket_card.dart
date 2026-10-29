import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/models/ticket_model.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          // Top Row: Client Name & Code
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ticket.clientName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.deepNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ticket.clientCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Colors.amber.shade800,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  ticket.category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description (No ellipsis)
          Text(
            ticket.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.mediumSlateGray,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${ticket.address}, ${ticket.neighborhood} - ${ticket.city}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mediumSlateGray,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Map Placeholder Space
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightIcyBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mediumSlateGray.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.map_outlined,
                  size: 36,
                  color: AppColors.mediumSlateGray,
                ),
                SizedBox(height: 6),
                Text(
                  'Mapa (Em breve)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mediumSlateGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bottom Info Row: Sync Status & Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sync status
              Row(
                children: [
                  Icon(
                    Icons.cloud_done_rounded,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sincronizado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              // Distance
              Row(
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 16,
                    color: AppColors.darkSlateBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ticket.distanceFormatted,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkSlateBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
