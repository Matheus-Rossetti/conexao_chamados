import 'package:avaliacao_final_sctec/views/auth/auth_view.dart';
import 'package:avaliacao_final_sctec/views/splash/splash_view.dart';
import 'package:flutter/material.dart';

import '../views/home/home_view.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  '/': (context) => SplashView(),
  'auth': (context) => AuthView(),
  'home': (context) => HomeView(),
};