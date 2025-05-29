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

  Future<Journey> getJourneyById(String id) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/$id';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      return Journey.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch journey');
    }
  }

  Future<List<Journey>> getAllJourneys(int page, int size) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl?page=$page&size=$size';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
    ).timeout(_timeoutDuration);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body)['content'];
      return jsonList.map((json) => Journey.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch journeys');
    }
  }

  Future<Journey> createJourney(Journey journey) async {
    await _loadStoredCredentials();
    final String url = _baseUrl;

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(journey.toJson()),
    ).timeout(_timeoutDuration);

    if (response.statusCode == 201) {
      return Journey.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create journey');
    }
  }

  Future<void> deleteJourney(String id) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/$id';

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    ).timeout(_timeoutDuration);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete journey');
    }
  }
}