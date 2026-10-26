import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dependencies = GetIt.instance;

void initDependencies() {
  dependencies.registerSingleton<FlutterSecureStorage>(FlutterSecureStorage());

}