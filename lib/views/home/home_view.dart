import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../data/models/service_model.dart';
import '../../data/models/ticket_model.dart';
import '../widgets/service_card.dart';
import '../widgets/tab_button.dart';
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

  Future<void> _handleUpdate() async {
    try {
      await vm.loadTickets();
      if (!mounted) return;

      final message = vm.isOfflineMode
          ? 'Você está offline. Exibindo chamados salvos localmente.'
          : 'Chamados atualizados com sucesso!';
      final bgColor = vm.isOfflineMode
          ? Colors.orange.shade800
          : AppColors.success;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: bgColor),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar chamados: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleSync() async {
    try {
      await vm.syncServices();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atendimentos sincronizados com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sincronizar atendimentos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
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
          onRefresh: () async {
            if (vm.selectedTab.value == 'chamados') {
              await _handleUpdate();
            } else {
              await _handleSync();
            }
          },
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

              // Tabs: "chamados" and "atendimentos"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: vm.selectedTab,
                        builder: (context, currentTab, child) {
                          return Row(
                            children: [
                              TabButton(
                                tabKey: 'chamados',
                                label: 'Chamados',
                                currentTab: currentTab,
                                onTap: (key) {
                                  vm.setTab(key);
                                  vm.searchServices('');
                                },
                              ),
                              const SizedBox(width: 12),
                              TabButton(
                                tabKey: 'atendimentos',
                                label: 'Atendimentos',
                                currentTab: currentTab,
                                onTap: (key) => vm.setTab(key),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      ValueListenableBuilder<String>(
                        valueListenable: vm.selectedTab,
                        builder: (context, currentTab, child) {
                          final labelText = currentTab == 'chamados'
                              ? 'Puxe para atualizar'
                              : 'Puxe para sincronizar';
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.arrow_downward,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                labelText,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar (Only appears on "atendimentos" tab)
              ValueListenableBuilder<String>(
                valueListenable: vm.selectedTab,
                builder: (context, currentTab, child) {
                  if (currentTab != 'atendimentos') {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: TextField(
                        onChanged: (val) => vm.searchServices(val),
                        style: const TextStyle(color: AppColors.textLight),
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Buscar atendimentos...',
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.darkSlateBlue,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.accentSky,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
