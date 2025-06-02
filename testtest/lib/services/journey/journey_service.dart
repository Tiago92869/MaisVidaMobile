import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:testtest/config/config.dart';
import 'package:testtest/services/journey/journey_model.dart';
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

    print('Fetching user journeys from API: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeoutDuration);

    print('Response Headers: ${response.headers}'); // Log para verificar o Content-Type

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
      print('API response: $decodedBody');
      final List<dynamic> jsonList = jsonDecode(decodedBody);
      return jsonList.map((json) => JourneySimpleUser.fromJson(json)).toList();
    } else {
      print('Failed to fetch user journeys, status code: ${response.statusCode}');
      throw Exception('Failed to fetch user journeys');
    }
  }

  // Fetch journey details for a specific journey
  Future<UserJourneyProgress> getJourneyDetails(String journeyId) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/mine/progress/$journeyId';

    print('Fetching journey details from API: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeoutDuration);

    print('Response Headers: ${response.headers}'); // Log para verificar o Content-Type

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
      print('API response: $decodedBody');
      return UserJourneyProgress.fromJson(jsonDecode(decodedBody));
    } else {
      print('Failed to fetch journey details, status code: ${response.statusCode}');
      throw Exception('Failed to fetch journey details');
    }
  }

  // Update user journey progress
  Future<UserJourneyProgress> editUserJourneyProgress(
      String userJourneyResourceProgressId,
      UpdateUserJourneyResourceProgress progress) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/progress/user/$userJourneyResourceProgressId';

    print('--- editUserJourneyProgress START ---');
    print('API URL: $url');
    print('Access Token: $_accessToken');
    print('Request Payload: ${jsonEncode(progress.toJson())}');

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(progress.toJson()),
      ).timeout(_timeoutDuration);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('Successfully updated user journey progress.');
        return UserJourneyProgress.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to update user journey progress. Status Code: ${response.statusCode}');
        print('Error Response Body: ${response.body}');
        throw Exception('Failed to update user journey progress');
      }
    } catch (e) {
      print('Exception occurred in editUserJourneyProgress: $e');
      rethrow;
    } finally {
      print('--- editUserJourneyProgress END ---');
    }
  }

  // Start a journey for the current user
  Future<UserJourneyProgress> startJourneyForUser(String journeyId) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/start/$journeyId';

    print('Starting journey for user at API: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      print('API response: ${response.body}');
      return UserJourneyProgress.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to start journey, status code: ${response.statusCode}');
      throw Exception('Failed to start journey');
    }
  }
}
