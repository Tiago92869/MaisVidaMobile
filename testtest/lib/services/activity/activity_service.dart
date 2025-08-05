import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maisvida/config/config.dart';
import 'package:maisvida/services/activity/activity_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class ActivityService {
  final String _baseUrl = Config.activityUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  Future<ActivityPage> fetchActivities({
    int page = 0,
    int size = 10,
    String searchQuery = "",
  }) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl?page=$page&size=$size&search=$searchQuery';

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
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final activityPage = ActivityPage.fromJson(jsonResponse);
        return activityPage;
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Activity> fetchActivityById(String id) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/$id';

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
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      if (response.statusCode == 200) {
        final activity = Activity.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
        return activity;
      } else {
        throw Exception('Failed to load activity');
      }
    } catch (e) {
      rethrow;
    }
  }
}
