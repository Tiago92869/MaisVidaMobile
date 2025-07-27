import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:mentara/config/config.dart';
import 'package:mentara/services/journey/journey_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class JourneyService {
  final String _baseUrl = Config.journeyUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  // Fetch all journeys for the current user
  Future<List<JourneySimpleUser>> getAllJourneys() async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/mine/simple';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => JourneySimpleUser.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch user journeys');
    }
  }

  // Fetch journey details for a specific journey
  Future<UserJourneyProgress> getJourneyDetails(String journeyId) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/mine/progress/$journeyId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return UserJourneyProgress.fromJson(jsonDecode(decodedBody));
    } else {
      throw Exception('Failed to fetch journey details');
    }
  }

  // Update user journey progress
  Future<UserJourneyProgress> editUserJourneyProgress(
      String userJourneyResourceProgressId,
      UpdateUserJourneyResourceProgress progress) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/progress/user/$userJourneyResourceProgressId';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(progress.toJson()),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return UserJourneyProgress.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update user journey progress');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Start a journey for the current user
  Future<UserJourneyProgress> startJourneyForUser(String journeyId) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/start/$journeyId';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      return UserJourneyProgress.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to start journey');
    }
  }
}

