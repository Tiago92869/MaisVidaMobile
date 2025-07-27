import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:testtest/config/config.dart';
import 'package:testtest/services/activity/activity_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class ActivityService {
  final String _baseUrl = Config.activityUrl;
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

  Future<ActivityPage> fetchActivities({
    int page = 0,
    int size = 10,
    String searchQuery = "",
  }) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl?page=$page&size=$size&search=$searchQuery';
    print('Request URL for fetchActivities: $url'); // Log the request URL

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              print('Request to $url timed out.');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Use utf8.decode para garantir o encoding correto
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final activityPage = ActivityPage.fromJson(jsonResponse);
        print(
          'Successfully fetched ${activityPage.content.length} activities.',
        );
        return activityPage;
      } else {
        print('Failed to load activities. Status Code: ${response.statusCode}');
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      print('Error fetching activities: $e');
      rethrow;
    }
  }

  Future<Activity> fetchActivityById(String id) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/$id';
    print('Request URL for fetchActivityById: $url'); // Log the request URL

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            _timeoutDuration,
            onTimeout: () {
              print('Request to $url timed out.');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Use utf8.decode para garantir o encoding correto
        final activity = Activity.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        print('Successfully fetched activity: ${activity.toJson()}');
        return activity;
      } else {
        print('Failed to load activity. Status Code: ${response.statusCode}');
        throw Exception('Failed to load activity');
      }
    } catch (e) {
      print('Error fetching activity: $e');
      rethrow;
    }
  }
}
