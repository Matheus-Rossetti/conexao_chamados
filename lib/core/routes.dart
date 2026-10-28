import 'package:avaliacao_final_sctec/views/auth/auth_view.dart';
import 'package:avaliacao_final_sctec/views/splash/splash_view.dart';
import 'package:flutter/material.dart';

import '../views/home/home_view.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const home = '/home';
}

final Map<String, Widget Function(BuildContext)> appRoutes = {
  AppRoutes.splash: (context) => SplashView(),
  AppRoutes.auth: (context) => AuthView(),
  AppRoutes.home: (context) => HomeView(),
};