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
    print('Loading stored credentials...');
    _accessToken = await _storage.read(key: 'accessToken');
    _userId = await _storage.read(key: 'userId');

    if (_accessToken != null) {
      print('Access token loaded: $_accessToken');
    } else {
      print('No access token found');
    }

    if (_userId != null) {
      print('User ID loaded: $_userId');
    } else {
      print('No User ID found');
    }
  }

  Future<List<NotificationModel>> fetchNotifications({
    int page = 0,
    int size = 10,
  }) async {
    await _loadStoredCredentials();
    try {
      final requestUrl =
          '$_baseUrl?userId=$_userId&page=$page&size=$size&sort=read,ASC'; // Alterado para ASC para mostrar não lidas primeiro
      print('Request URL for fetchNotifications: $requestUrl'); // Log the request URL

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
              print('Request to $requestUrl timed out.');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('Response status code: ${response.statusCode}');
      print('Response Headers: ${response.headers}'); // Log para verificar o Content-Type

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
        print('Response body: $decodedBody');

        final Map<String, dynamic> json = jsonDecode(decodedBody);

        // Check the structure of the response
        if (json.containsKey('content')) {
          final List<dynamic> notificationsJson = json['content'];
          print('Notifications fetched successfully.');
          return notificationsJson
              .map((e) => NotificationModel.fromJson(e))
              .toList();
        } else {
          print('Unexpected response format: $decodedBody');
          throw Exception('Unexpected response format');
        }
      } else {
        print(
          'Failed to load notifications. Status Code: ${response.statusCode}',
        );
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> deleteNotification(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/$id';
      print(
        'Request URL for deleteNotification: $requestUrl',
      ); // Log the request URL

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
              print('Request to $requestUrl timed out.');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Notification deleted successfully.');
      } else {
        print(
          'Failed to delete notification. Status Code: ${response.statusCode}',
        );
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print('Error deleting notification: $e');
      throw Exception('Failed to delete notification');
    }
  }

  Future<NotificationModel> markAsRead(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/read/$id';
      print('Request URL for markAsRead: $requestUrl');

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
              print('Request to $requestUrl timed out.');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        print('Notification marked as read successfully.');
        return NotificationModel.fromJson(json);
      } else {
        print(
          'Failed to mark notification as read. Status Code: ${response.statusCode}',
        );
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      throw Exception('Failed to mark notification as read');
    }
  }
}
