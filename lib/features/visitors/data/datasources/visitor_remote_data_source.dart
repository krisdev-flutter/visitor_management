import 'package:dio/dio.dart';
import 'package:visitor_management_task/core/config/api_config.dart';
import 'package:visitor_management_task/features/visitors/domain/entities/visitor.dart';

import '../models/visitor_model.dart';

class VisitorRemoteDataSource {
  VisitorRemoteDataSource()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.visitorsBaseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          sendTimeout: ApiConfig.receiveTimeout,
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: ResponseType.json,
        ),
      );

  final Dio _dio;

  void _checkConfigured() {
    final baseUrl = ApiConfig.visitorsBaseUrl.trim();

    if (baseUrl.isEmpty ||
        baseUrl.contains('YOUR_PROJECT') ||
        !baseUrl.startsWith('https://')) {
      throw Exception('Invalid MockAPI visitors URL configuration.');
    }
  }

  String _visitorUrl(String id) =>
      '${ApiConfig.visitorsBaseUrl}/${Uri.encodeComponent(id)}';

  String _validateId(String id) {
    final value = id.trim();

    if (value.isEmpty) {
      throw Exception('Visitor ID is missing.');
    }

    return value;
  }

  Exception _friendlyError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 400) {
        return Exception(
          'Invalid visitor data. Please check the request fields.',
        );
      }

      if (statusCode == 404) {
        return Exception(
          'Visitor not found. Refresh the visitor list and try again.',
        );
      }

      if (statusCode == 408 ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return Exception('Request timed out. Check your internet connection.');
      }

      if (statusCode == 429) {
        return Exception('Too many requests. Please try again shortly.');
      }

      if (statusCode != null && statusCode >= 500) {
        return Exception('The visitor API is temporarily unavailable.');
      }

      if (error.type == DioExceptionType.connectionError) {
        return Exception(
          'Could not connect to the visitor API. Check your internet connection and API URL.',
        );
      }

      return Exception(
        'API request failed${statusCode != null ? ' ($statusCode)' : ''}.',
      );
    }

    return Exception(error.toString().replaceFirst('Exception: ', ''));
  }

  Future<List<Visitor>> getVisitors() async {
    _checkConfigured();

    try {
      final response = await _dio.get('');

      if (response.data is! List) {
        throw Exception('Unexpected visitor list response from API.');
      }

      return (response.data as List).map((item) {
        if (item is! Map) {
          throw Exception('Invalid visitor record received from API.');
        }

        return VisitorModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> getVisitor(String id) async {
    _checkConfigured();
    final visitorId = _validateId(id);

    try {
      final response = await _dio.get(_visitorUrl(visitorId));

      if (response.data is! Map) {
        throw Exception('Invalid visitor response from API.');
      }

      return VisitorModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> createVisitor(Visitor visitor) async {
    _checkConfigured();

    try {
      final response = await _dio.post(
        '',
        data: VisitorModel.fromEntity(visitor).toJson(),
      );

      if (response.data is! Map) {
        throw Exception('Invalid response after creating visitor.');
      }

      return VisitorModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> updateVisitor(Visitor visitor) async {
    _checkConfigured();
    final visitorId = _validateId(visitor.id);

    try {
      final response = await _dio.put(
        _visitorUrl(visitorId),
        data: VisitorModel.fromEntity(visitor).toJson(),
      );

      if (response.data is! Map) {
        throw Exception('Invalid response after updating visitor.');
      }

      return VisitorModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> checkInVisitor(String id) async {
    _checkConfigured();
    final visitorId = _validateId(id);

    try {
      final currentVisitor = await getVisitor(visitorId);

      if (currentVisitor.status != VisitorStatusValue.registered) {
        throw Exception('Only registered visitors can check in.');
      }

      final response = await _dio.patch(
        _visitorUrl(visitorId),
        data: {
          'status': VisitorStatusValue.checkedIn,
          'check_in_time': DateTime.now().toIso8601String(),
        },
      );

      if (response.data is! Map) {
        throw Exception('Invalid response after checking in visitor.');
      }

      return VisitorModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> checkOutVisitor(String id) async {
    _checkConfigured();
    final visitorId = _validateId(id);

    try {
      final currentVisitor = await getVisitor(visitorId);

      if (currentVisitor.status != VisitorStatusValue.checkedIn) {
        throw Exception('Only checked-in visitors can check out.');
      }

      final response = await _dio.patch(
        _visitorUrl(visitorId),
        data: {
          'status': VisitorStatusValue.checkedOut,
          'check_out_time': DateTime.now().toIso8601String(),
        },
      );

      if (response.data is! Map) {
        throw Exception('Invalid response after checking out visitor.');
      }

      return VisitorModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<void> deleteVisitor(String id) async {
    _checkConfigured();
    final visitorId = _validateId(id);

    try {
      await _dio.delete(_visitorUrl(visitorId));
    } catch (error) {
      throw _friendlyError(error);
    }
  }
}
