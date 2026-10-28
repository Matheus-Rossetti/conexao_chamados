import 'package:avaliacao_final_sctec/core/app_colors.dart';
import 'package:avaliacao_final_sctec/views/home/home_viewmodel.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  final vm = HomeViewmodel();

  HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkSlateBlue,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        title: const Text(
          'Início',
          style: TextStyle(color: AppColors.textLight),
        ),
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      body: const Center(
        child: Text(
          'Bem-vindo à tela inicial',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
