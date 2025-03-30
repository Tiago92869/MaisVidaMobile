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

  Future<List<Activity>> fetchActivities(
      int page, int size, String searchQuery) async {
    await _loadStoredCredentials();
    try {
      final String url = '$_baseUrl?page=$page&size=$size&search=$searchQuery';
      print('Fetching activities from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutDuration);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final activityPage = ActivityPage.fromJson(jsonResponse);
        print(
            'Received ${activityPage.content.length} activities from the response.');
        return activityPage.content;
      } else {
        print('Failed to load activities. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to load activities. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Request timed out.');
      throw Exception('Request timed out');
    } catch (e) {
      print('Error fetching activities: $e');
      throw Exception('Failed to fetch activities: $e');
    }
  }

  Future<Activity> fetchActivityById(String id) async {
    await _loadStoredCredentials();
    try {
      final String url = '$_baseUrl/$id';
      print('Fetching activity from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutDuration);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final activity = Activity.fromJson(jsonDecode(response.body));
        print('Received activity: ${activity.toJson()}');
        return activity;
      } else {
        print('Failed to load activity. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to load activity. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Request timed out.');
      throw Exception('Request timed out');
    } catch (e) {
      print('Error fetching activity: $e');
      throw Exception('Failed to fetch activity: $e');
    }
  }
}
