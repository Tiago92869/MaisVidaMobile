import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'diary_model.dart';
import 'package:mentara/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class DiaryService {
  final String _baseUrl = Config.diaryUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _userId;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _userId = await _storage.read(key: 'userId');
  }

  Future<List<DiaryDay>> fetchDiaries(
    List<DiaryType> emotions,
    DateTime startDate,
    DateTime endDate, {
    int page = 0,
    int size = 10,
  }) async {
    await _loadStoredCredentials();

    final String emotionsQuery = emotions
        .map(
          (emotion) =>
              'Diary%20Emotion=${emotion.toString().split('.').last.toUpperCase()}',
        )
        .join('&');

    final String url =
        '$_baseUrl?userId=$_userId&$emotionsQuery&startDate=${_formatDate(startDate)}&endDate=${_formatDate(endDate)}&page=$page&size=$size';

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
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);
        return data.map((json) => DiaryDay.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load diaries');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Diary> createDiary(Diary diary) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl';
    final requestBody = jsonEncode(diary.toJson());

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: requestBody,
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
        final decodedBody = utf8.decode(response.bodyBytes);
        return Diary.fromJson(jsonDecode(decodedBody));
      } else {
        throw Exception('Failed to create diary');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Diary> updateDiary(String id, Diary diary) async {
    await _loadStoredCredentials();

    final String url = '$_baseUrl/$id';

    try {
      final response = await http
          .patch(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(diary.toJson()),
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
        final decodedBody = utf8.decode(response.bodyBytes);
        return Diary.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to update diary');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDiary(String id) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/$id';

    try {
      final response = await http
          .delete(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $_accessToken'},
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
      } else {
        throw Exception('Failed to delete diary');
      }
    } catch (e) {
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

