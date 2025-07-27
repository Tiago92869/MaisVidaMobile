import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:mentara/config/config.dart';
import 'package:mentara/services/goal/goal_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class GoalService {
  final String _baseUrl = Config.goalUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _userId;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _userId = await _storage.read(key: 'userId');
  }

  Future<PagezGoalsDTO> fetchGoals(
    bool? isCompleted,
    DateTime startDate,
    DateTime endDate,
    List<GoalSubject> goalSubjects, {
    int page = 0,
    int size = 10,
  }) async {
    await _loadStoredCredentials();
    try {
      final String subjectsQuery = goalSubjects
          .map(
            (subject) =>
                'goalSubjects=${subject.toString().split('.').last.toUpperCase()}',
          )
          .join('&');
      final String isCompletedQuery =
          isCompleted != null ? '&isCompleted=$isCompleted' : '';
      final String url =
          '$_baseUrl?&userId=$_userId$isCompletedQuery&$subjectsQuery'
          '&startDate=${_formatDate(startDate)}&endDate=${_formatDate(endDate)}'
          '&page=$page&size=$size';

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
        return PagezGoalsDTO.fromJson(jsonDecode(decodedBody));
      } else {
        throw Exception('Failed to load goals');
      }
    } catch (e) {
      throw Exception('Failed to fetch goals');
    }
  }

  Future<GoalInfoCard> createGoal(GoalInfoCard goal) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(goal.toJson());

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
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
        return GoalInfoCard.fromJson(jsonDecode(response.body));
      } else {
        throw HttpException('Failed to create goal: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to create goal');
    }
  }

  Future<GoalInfoCard> updateGoal(String id, GoalInfoCard goal) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(goal.toJson());
      final String requestUrl = '$_baseUrl/$id';

      final response = await http
          .patch(
            Uri.parse(requestUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
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
        return GoalInfoCard.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update goal');
      }
    } catch (e) {
      throw Exception('Failed to update goal');
    }
  }

  Future<void> deleteGoal(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/$id';

      final response = await http
          .delete(
            Uri.parse(requestUrl),
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
        throw HttpException('Failed to delete goal: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to delete goal');
    }
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$year-$month-$day';
  }
}

