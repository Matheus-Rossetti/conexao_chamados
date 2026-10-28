import '../../core/dependecies.dart';
import '../../data/repositories/auth_repository.dart';

class AuthViewmodel {
  final AuthRepository _authRepository;

  AuthViewmodel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? dependencies<AuthRepository>();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  Future<void> login({required String email, required String password}) async {
    await _authRepository.login(email: email, password: password);
  }
}
