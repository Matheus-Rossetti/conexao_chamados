import 'package:avaliacao_final_sctec/core/app_colors.dart';
import 'package:avaliacao_final_sctec/core/routes.dart';
import 'package:avaliacao_final_sctec/views/splash/splash_viewmodel.dart';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final vm = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final signedIn = await vm.isUserSignedIn();

    if (!mounted) return;
    signedIn
        ? Navigator.of(context).pushReplacementNamed(AppRoutes.home)
        : Navigator.of(context).pushReplacementNamed(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bolt_rounded, size: 64, color: AppColors.accentSky),
            SizedBox(height: 16),
            Text(
              "Conexão Chamados",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
