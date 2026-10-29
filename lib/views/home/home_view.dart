import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/ticket_card.dart';
import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final vm = HomeViewmodel();
  bool _isLoading = true;
  String _technicianName = "Técnico";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final name = await vm.getTechnicianName();
    await vm.loadTickets();

    if (!mounted) return;
    setState(() {
      _technicianName = name;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final technicianName = _technicianName;
    final tickets = vm.tickets;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Técnico',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            technicianName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Active count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkSlateBlue,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.accentSky.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.assignment_rounded,
                            size: 16,
                            color: AppColors.accentSky,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${tickets.length} Ativos',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentSky,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Tickets Ativos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),

            // List of Tickets
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentSky,
                      ),
                    ),
                  )
                : tickets.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Nenhum ticket ativo no momento.',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final ticket = tickets[index];
                      return TicketCard(ticket: ticket);
                    }, childCount: tickets.length),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
