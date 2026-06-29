import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/exceptions.dart';
import '../models/ticket.dart';

class TicketService {
  final _dio = ApiClient.instance.dio;

  Future<List<TicketListItem>> getTickets() async {
    try {
      final response = await _dio.get('/api/v1/tickets');
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => TicketListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TicketDetail> getTicketDetail(int id) async {
    try {
      final response = await _dio.get('/api/v1/tickets/$id');
      return TicketDetail.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.error is AppException) return e.error as Exception;

    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 422:
        return ValidationException(
          message: message,
          errors: e.response?.data?['errors'] as Map<String, dynamic>?,
        );
      case null:
        return NetworkException(message: e.message);
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }
}
