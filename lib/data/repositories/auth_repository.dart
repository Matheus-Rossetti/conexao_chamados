import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;

  static const String _secretKey = r'ISP_TECH_SENAI_2026_xK9#mQ2$vL8!zP4';

  AuthRepository(this._authService, this._secureStorage);

  String computeHmac(String password) {
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(password);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  Future<void> login({required String email, required String password}) async {
    final senhaHmac = computeHmac(password);
    final result = await _authService.login(email: email, senhaHmac: senhaHmac);

    if (result['sucesso'] == false) {
      throw Exception(result['mensagem'] ?? 'Falha no login');
    }

    final dados = result['dados'];
    final token = (dados is Map ? dados['token'] : null) ?? result['token'];

    if (token != null && token.toString().isNotEmpty) {
      await _secureStorage.write(key: 'token', value: token.toString());
    } else {
      throw Exception('Token não encontrado na resposta do servidor');
    }
  }
}
