import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../data/services/auth_service.dart';
import '../data/services/ticket_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/ticket_repository.dart';
import '../data/services/local_db_service.dart';

final dependencies = GetIt.instance;

Future<void> initDependencies() async {
  dependencies.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(),
  );
  dependencies.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: 'https://oquetemnomeucosmetico.com.br/api')),
  );
  dependencies.registerLazySingleton<AuthService>(
    () => AuthServiceDioImpl(dio: dependencies<Dio>()),
  );
  dependencies.registerLazySingleton<TicketService>(
    () => TicketServiceDioImpl(
      dio: dependencies<Dio>(),
      secureStorage: dependencies<FlutterSecureStorage>(),
    ),
  );
  dependencies.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      dependencies<AuthService>(),
      dependencies<FlutterSecureStorage>(),
    ),
  );
  dependencies.registerLazySingleton<TicketRepository>(
    () => TicketRepository(
      dependencies<TicketService>(),
      dependencies<LocalDbService>(),
    ),
  );

  final localDbService = LocalDbService();
  await localDbService.database;
  dependencies.registerSingleton<LocalDbService>(localDbService);
}
