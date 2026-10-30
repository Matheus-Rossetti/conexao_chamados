import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/models/service_model.dart';
import '../../data/models/ticket_model.dart';
import '../widgets/service_card.dart';
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
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  Widget _buildTabButton(String tabKey, String label, String currentTab) {
    final isSelected = currentTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setTab(tabKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentSky : AppColors.darkSlateBlue,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentSky
                  : AppColors.accentSky.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.deepNavy : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final technicianName = _technicianName;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentSky,
          backgroundColor: AppColors.darkSlateBlue,
          onRefresh: () => vm.refreshLocalTickets(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      ValueListenableBuilder<List<TicketModel>>(
                        valueListenable: vm.tickets,
                        builder: (context, tickets, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkSlateBlue,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.accentSky.withValues(
                                  alpha: 0.3,
                                ),
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Tabs: "chamados" and "atendimentos" replacing "Chamados Ativos"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: ValueListenableBuilder<String>(
                    valueListenable: vm.selectedTab,
                    builder: (context, currentTab, child) {
                      return Row(
                        children: [
                          _buildTabButton('chamados', 'Chamados', currentTab),
                          const SizedBox(width: 12),
                          _buildTabButton(
                            'atendimentos',
                            'Atendimentos',
                            currentTab,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // List based on selected tab
              ValueListenableBuilder<String>(
                valueListenable: vm.selectedTab,
                builder: (context, currentTab, child) {
                  if (currentTab == 'chamados') {
                    return _isLoading
                        ? const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentSky,
                              ),
                            ),
                          )
                        : ValueListenableBuilder<List<TicketModel>>(
                            valueListenable: vm.tickets,
                            builder: (context, tickets, child) {
                              if (tickets.isEmpty) {
                                return const SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      'Nenhum chamado ativo no momento.',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final ticket = tickets[index];
                                  return TicketCard(
                                    ticket: ticket,
                                    callback: () => vm.refreshLocalTickets(),
                                  );
                                }, childCount: tickets.length),
                              );
                            },
                          );
                  } else {
                    return ValueListenableBuilder<List<ServiceModel>>(
                      valueListenable: vm.services,
                      builder: (context, servicesList, child) {
                        if (servicesList.isEmpty) {
                          return const SliverFillRemaining(
                            child: Center(
                              child: Text(
                                'Nenhum atendimento realizado.',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final service = servicesList[index];
                            return ServiceCard(service: service);
                          }, childCount: servicesList.length),
                        );
                      },
                    );
                  }
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
