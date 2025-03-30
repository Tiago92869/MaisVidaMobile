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
    // _accessToken = await _storage.read(key: 'accessToken');
    // _userId = await _storage.read(key: 'userId');
    _accessToken = "testeste";
    _userId = "asdasd";

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
    final String subjectsQuery = emotions
        .map((emotion) =>
            'goalSubjects=${emotion.toString().split('.').last.toUpperCase()}')
        .join('&');
    final String url =
        '$_baseUrl?userId=$_userId&emotion=$subjectsQuery&startDate=${_formatDate(startDate)}&endDate=${_formatDate(endDate)}';
    print('Request URL for fetchDiaries: $url'); // Log the request URL

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          print('Request to $url timed out.');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Successfully fetched ${data.length} diaries.');
        return data.map((json) => DiaryDay.fromJson(json)).toList();
      } else {
        print('Failed to load diaries. Status Code: ${response.statusCode}');
        throw Exception('Failed to load diaries');
      }
    } catch (e) {
      print('Error fetching diaries: $e');
      rethrow;
    }
  }

  Future<Diary> createDiary(Diary diary) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl';
    final requestBody = jsonEncode(diary.toJson());
    print('Request URL for createDiary: $url'); // Log the request URL
    print('Request Body for createDiary: $requestBody'); // Log the request body

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          print('Request to $url timed out.');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Diary created successfully.');
        return Diary.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to create diary. Status Code: ${response.statusCode}');
        throw Exception('Failed to create diary');
      }
    } catch (e) {
      print('Error creating diary: $e');
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
    final String url = '$_baseUrl/$id';
    print('Request URL for deleteDiary: $url'); // Log the request URL

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          print('Request to $url timed out.');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Diary deleted successfully.');
      } else {
        print('Failed to delete diary. Status Code: ${response.statusCode}');
        throw Exception('Failed to delete diary');
      }
    } catch (e) {
      print('Error deleting diary: $e');
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
