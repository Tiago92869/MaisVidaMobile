// notification_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'notification_model.dart';
import 'package:testtest/config/config.dart';
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

  Future<List<NotificationModel>> fetchNotifications() async {
    await _loadStoredCredentials();
    final response = await http.get(
      Uri.parse('$_baseUrl?userId=$_userId'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(
      _timeoutDuration,
      onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, please try again later.');
      },
    );

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);

      // Check the structure of the response
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
  }

  Future<void> deleteNotification(String id) async {
    await _loadStoredCredentials();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(
      _timeoutDuration,
      onTimeout: () {
        throw TimeoutException(
            'The connection has timed out, please try again later.');
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }
}
