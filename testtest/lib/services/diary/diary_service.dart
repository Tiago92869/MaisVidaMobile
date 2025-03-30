import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'diary_model.dart';
import 'package:testtest/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class DiaryService {
  final String _baseUrl = Config.diaryUrl;
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

  Future<List<DiaryDay>> fetchDiaries(
    List<DiaryType> emotions,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _loadStoredCredentials();
    print('fetchDiaries called with parameters:');
    print('emotion: $emotions, startDate: $startDate, endDate: $endDate');

    final String subjectsQuery = emotions
        .map((emotion) =>
            'goalSubjects=${emotion.toString().split('.').last.toUpperCase()}')
        .join('&');

    final queryParameters = {
      'userId': _userId,
      'emotion': subjectsQuery, // Convert enum to string
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
    };

    print('Query parameters: $queryParameters');

    final uri =
        Uri.parse('$_baseUrl').replace(queryParameters: queryParameters);

    print('Requesting URI: $uri');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          print('fetchDiaries request timed out.');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('fetchDiaries response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('fetchDiaries response data: $data');
        return data.map((json) => DiaryDay.fromJson(json)).toList();
      } else {
        print(
            'Failed to load diaries with status code: ${response.statusCode}');
        throw Exception('Failed to load diaries');
      }
    } catch (e) {
      print('Exception in fetchDiaries: $e');
      rethrow;
    }
  }

  Future<Diary> createDiary(Diary diary) async {
    await _loadStoredCredentials();
    print('createDiary called with diary: ${diary.toJson()}');

    try {
      final response = await http
          .post(
        Uri.parse('$_baseUrl'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(diary.toJson()),
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          print('createDiary request timed out.');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('createDiary response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Diary created successfully.');
        return Diary.fromJson(json.decode(response.body));
      } else {
        print(
            'Failed to create diary with status code: ${response.statusCode}');
        throw Exception('Failed to create diary');
      }
    } catch (e) {
      print('Exception in createDiary: $e');
      rethrow;
    }
  }

  Future<Diary> updateDiary(String id, Diary diary) async {
    await _loadStoredCredentials();
    print('updateDiary called with id: $id, diary: ${diary.toJson()}');

    try {
      final response = await http
          .patch(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(diary.toJson()),
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          print('updateDiary request timed out.');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('updateDiary response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Diary updated successfully.');
        return Diary.fromJson(json.decode(response.body));
      } else {
        print(
            'Failed to update diary with status code: ${response.statusCode}');
        throw Exception('Failed to update diary');
      }
    } catch (e) {
      print('Exception in updateDiary: $e');
      rethrow;
    }
  }

  Future<void> deleteDiary(String id) async {
    await _loadStoredCredentials();
    print('deleteDiary called with id: $id');

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          print('deleteDiary request timed out.');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('deleteDiary response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Diary deleted successfully.');
      } else {
        print(
            'Failed to delete diary with status code: ${response.statusCode}');
        throw Exception('Failed to delete diary');
      }
    } catch (e) {
      print('Exception in deleteDiary: $e');
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$year-$month-$day';
  }
}
