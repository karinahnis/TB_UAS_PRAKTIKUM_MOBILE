import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/exceptions.dart';
import '../models/category.dart';
import '../models/event.dart';
import '../models/pagination_meta.dart';

class EventService {
  final Dio _dio;

  EventService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/api/v1/categories');
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<MapEntry<List<EventSummary>, PaginationMeta>> getEvents({
    int page = 1,
    int perPage = 10,
    String? search,
    int? categoryId,
    String? city,
    String? sort,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (categoryId != null) params['category_id'] = categoryId;
      if (city != null && city.isNotEmpty) params['city'] = city;
      if (sort != null) params['sort'] = sort;

      final response = await _dio.get('/api/v1/events', queryParameters: params);
      final data = (response.data['data'] as List<dynamic>)
          .map((e) => EventSummary.fromJson(e as Map<String, dynamic>))
          .toList();
      final meta =
          PaginationMeta.fromJson(response.data['meta'] as Map<String, dynamic>);
      return MapEntry(data, meta);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<EventDetail> getEventDetail(int id) async {
    try {
      final response = await _dio.get('/api/v1/events/$id');
      return EventDetail.fromJson(
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
