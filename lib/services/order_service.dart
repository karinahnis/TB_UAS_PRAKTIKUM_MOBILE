import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/exceptions.dart';
import '../models/order.dart';
import '../models/pagination_meta.dart';

class PayOrderResult {
  final int orderId;
  final String orderCode;
  final String paymentStatus;
  final String orderStatus;
  final String paymentMethod;
  final String paymentCode;
  final double amount;
  final String paidAt;
  final int generatedTicketCount;

  PayOrderResult({
    required this.orderId,
    required this.orderCode,
    required this.paymentStatus,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentCode,
    required this.amount,
    required this.paidAt,
    required this.generatedTicketCount,
  });

  factory PayOrderResult.fromJson(Map<String, dynamic> json) {
    return PayOrderResult(
      orderId: json['order_id'] as int,
      orderCode: json['order_code'] as String,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentCode: json['payment_code'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidAt: json['paid_at'] as String,
      generatedTicketCount: json['generated_ticket_count'] as int,
    );
  }
}

class OrderService {
  final _dio = ApiClient.instance.dio;

  Future<Order> createOrder(int ticketTypeId, int quantity) async {
    try {
      final response = await _dio.post('/api/v1/orders', data: {
        'ticket_type_id': ticketTypeId,
        'quantity': quantity,
      });
      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<MapEntry<List<Order>, PaginationMeta>> getOrders({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get('/api/v1/orders', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      final data = (response.data['data'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta =
          PaginationMeta.fromJson(response.data['meta'] as Map<String, dynamic>);
      return MapEntry(data, meta);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> getOrderDetail(int id) async {
    try {
      final response = await _dio.get('/api/v1/orders/$id');
      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Order> cancelOrder(int id) async {
    try {
      final response = await _dio.post('/api/v1/orders/$id/cancel');
      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PayOrderResult> payOrder(int id, String paymentMethod) async {
    try {
      final response = await _dio.post('/api/v1/orders/$id/pay', data: {
        'payment_method': paymentMethod,
      });
      return PayOrderResult.fromJson(
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
