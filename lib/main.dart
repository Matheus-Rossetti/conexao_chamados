import 'package:avaliacao_final_sctec/core/dependecies.dart';
import 'package:flutter/material.dart';

import 'core/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: appRoutes);
  }
}
