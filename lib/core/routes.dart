import 'package:avaliacao_final_sctec/views/auth/auth_view.dart';
import 'package:avaliacao_final_sctec/views/splash/splash_view.dart';
import 'package:avaliacao_final_sctec/views/service/service_view.dart';
import 'package:avaliacao_final_sctec/views/ticket/ticket_view.dart';
import 'package:flutter/material.dart';

import '../views/home/home_view.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const home = '/home';
  static const ticket = '/ticket';
  static const serviceDetail = '/service-detail';
}

final Map<String, Widget Function(BuildContext)> appRoutes = {
  AppRoutes.splash: (context) => SplashView(),
  AppRoutes.auth: (context) => AuthView(),
  AppRoutes.home: (context) => HomeView(),
  AppRoutes.ticket: (context) => TicketView(),
  AppRoutes.serviceDetail: (context) => ServiceView(),
};
