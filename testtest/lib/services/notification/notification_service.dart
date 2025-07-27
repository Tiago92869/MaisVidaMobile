// notification_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notification_model.dart';
import 'package:mentara/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class NotificationService {
  final String _baseUrl = Config.notificationUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _userId;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _userId = await _storage.read(key: 'userId');
  }

  Future<List<NotificationModel>> fetchNotifications({
    int page = 0,
    int size = 10,
  }) async {
    await _loadStoredCredentials();
    try {
      final requestUrl =
          '$_baseUrl?userId=$_userId&page=$page&size=$size&sort=read,ASC';

      final response = await http
          .get(
            Uri.parse(requestUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);

        final Map<String, dynamic> json = jsonDecode(decodedBody);

        if (json.containsKey('content')) {
          final List<dynamic> notificationsJson = json['content'];
          return notificationsJson
              .map((e) => NotificationModel.fromJson(e))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> deleteNotification(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/$id';

      final response = await http
          .delete(
            Uri.parse(requestUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      throw Exception('Failed to delete notification');
    }
  }

  Future<NotificationModel> markAsRead(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/read/$id';

      final response = await http
          .patch(
            Uri.parse(requestUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return NotificationModel.fromJson(json);
      } else {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read');
    }
  }
}
