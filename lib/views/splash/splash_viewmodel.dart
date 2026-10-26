import 'package:avaliacao_final_sctec/core/dependecies.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashViewModel {

  const SplashViewModel();

  Future<bool> isUserSignedIn() async {
    final token = await dependencies<FlutterSecureStorage>().read(key: 'token');
    return token != null && token.isNotEmpty;
  }
}