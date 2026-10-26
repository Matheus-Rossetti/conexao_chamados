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
      backgroundColor: Colors.amber,
    );
  }
}
