abstract class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String senhaHmac,
  });
}
