import 'package:dio/dio.dart';

abstract class AuthService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String senhaHmac,
  });
}

class AuthServiceDioImpl implements AuthService {
  final Dio dio;

  AuthServiceDioImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String senhaHmac,
  }) async {
    try {
      final response = await dio.post(
        '/login',
        data: {'email': email, 'senha_hmac': senhaHmac},
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else if (response.data is Map) {
          return Map<String, dynamic>.from(response.data);
        }
        return {};
      } else {
        throw Exception('Erro ao realizar login');
      }
    } on DioException catch (e) {
      String errorMessage = 'Erro ao realizar login';
      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'].toString();
        } else if (data is String) {
          errorMessage = data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    }
  }
}
