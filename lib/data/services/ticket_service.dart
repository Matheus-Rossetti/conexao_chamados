import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TicketService {
  Future<Map<String, dynamic>> fetchTickets();
  Future<String?> sendService({
    required int ticketId,
    required String conclusion,
    required String description,
    String? date,
    String? imagePath,
  });
}

class TicketServiceDioImpl implements TicketService {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  TicketServiceDioImpl({required this.dio, required this.secureStorage});

  @override
  Future<Map<String, dynamic>> fetchTickets() async {
    try {
      final token = await secureStorage.read(key: 'token');

      final response = await dio.get(
        '/chamados',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
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
        throw Exception('Erro ao buscar chamados');
      }
    } on DioException catch (e) {
      String errorMessage = 'Erro ao buscar chamados';
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

  @override
  Future<String?> sendService({
    required int ticketId,
    required String conclusion,
    required String description,
    String? date,
    String? imagePath,
  }) async {
    try {
      final token = await secureStorage.read(key: 'token');

      final formDataMap = <String, dynamic>{
        'chamado_id': ticketId,
        'categoria_tecnico': conclusion,
        'descricao_procedimento': description,
      };

      if (date != null && date.isNotEmpty) {
        formDataMap['data_resolucao'] = date;
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        formDataMap['foto'] = await MultipartFile.fromFile(imagePath);
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await dio.post(
        '/atendimento',
        data: formData,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is Map) {
          final dados = data['dados'];
          if (dados is Map) {
            return dados['foto_url']?.toString();
          }
        }
      }
      return null;
    } on DioException catch (e) {
      String errorMessage = 'Erro ao enviar atendimento';
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
