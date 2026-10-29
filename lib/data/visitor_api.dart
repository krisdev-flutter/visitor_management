import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:visitor_management_task/core/api_config.dart';
import 'package:visitor_management_task/models/visitor.dart';

class VisitorApi {
  VisitorApi()
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
      final responseData = error.response?.data;

      debugPrint('API URL: ${error.requestOptions.uri}');
      debugPrint('API method: ${error.requestOptions.method}');
      debugPrint('API status: $statusCode');
      debugPrint('API response: $responseData');
      debugPrint('API request body: ${error.requestOptions.data}');

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

        return Visitor.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> getVisitor(String id) async {
    _checkConfigured();
    final visitorId = _validateId(id);

    try {
      final response = await _dio.get('/${Uri.encodeComponent(visitorId)}');

      if (response.data is! Map) {
        throw Exception('Invalid visitor response from API.');
      }

      return Visitor.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> createVisitor(Visitor visitor) async {
    _checkConfigured();

    try {
      final response = await _dio.post('', data: visitor.toJson());

      if (response.data is! Map) {
        throw Exception('Invalid response after creating visitor.');
      }

      return Visitor.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> updateVisitor(Visitor visitor) async {
    _checkConfigured();
    final visitorId = _validateId(visitor.id);

    try {
      final response = await _dio.put(
        '/${Uri.encodeComponent(visitorId)}',
        data: visitor.toJson(),
      );

      if (response.data is! Map) {
        throw Exception('Invalid response after updating visitor.');
      }

      return Visitor.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> checkInVisitor(String id) async {
    _checkConfigured();
    final visitorId = _validateId(id);

    try {
      final currentVisitor = await getVisitor(visitorId);

      if (currentVisitor.status != 'Registered') {
        throw Exception('Only registered visitors can check in.');
      }

      final response = await _dio.patch(
        '/${Uri.encodeComponent(visitorId)}',
        data: {
          'status': 'Checked In',
          'check_in_time': DateTime.now().toIso8601String(),
        },
      );

      if (response.data is! Map) {
        throw Exception('Invalid response after checking in visitor.');
      }

      return Visitor.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<Visitor> checkOutVisitor(String id) async {
    _checkConfigured();
    final visitorId = _validateId(id);

    try {
      final currentVisitor = await getVisitor(visitorId);

      if (currentVisitor.status != 'Checked In') {
        throw Exception('Only checked-in visitors can check out.');
      }

      final response = await _dio.patch(
        '/${Uri.encodeComponent(visitorId)}',
        data: {
          'status': 'Checked Out',
          'check_out_time': DateTime.now().toIso8601String(),
        },
      );

      if (response.data is! Map) {
        throw Exception('Invalid response after checking out visitor.');
      }

      return Visitor.fromJson(Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _friendlyError(error);
    }
  }

  Future<void> deleteVisitor(String id) async {
    _checkConfigured();
    final visitorId = _validateId(id);

    try {
      await _dio.delete('/${Uri.encodeComponent(visitorId)}');
    } catch (error) {
      throw _friendlyError(error);
    }
  }
}
