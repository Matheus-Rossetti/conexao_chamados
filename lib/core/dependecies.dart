import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../data/services/auth_service.dart';
import '../data/services/auth_service_impl.dart';
import '../data/repositories/auth_repository.dart';

final dependencies = GetIt.instance;

void initDependencies() {
  dependencies.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  dependencies.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: 'https://oquetemnomeucosmetico.com.br/api')),
  );
  dependencies.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(dio: dependencies()),
  );
  dependencies.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dependencies(), dependencies()),
  );
}
