import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:testtest/config/config.dart';
import 'package:testtest/services/goal/goal_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class GoalService {
  final String _baseUrl = Config.goalUrl;
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

  Future<List<GoalDay>> fetchGoals(
    bool? isCompleted,
    DateTime startDate,
    DateTime endDate,
    List<GoalSubject> goalSubjects,
    int currentPage,
    int pageSize, {
    int page = 0, // Add page parameter
    int size = 5, // Add size parameter
  }) async {
    await _loadStoredCredentials();
    try {
      print('Fetching goals...');
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
          '&page=$page&size=$size'; // Add page and size to the query

      print('Request URL for fetchGoals: $url'); // Log the request URL

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
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<GoalDay> goalDays =
            jsonList.map((json) => GoalDay.fromJson(json)).toList();
        print('Goals fetched successfully. Total goals: ${goalDays.length}');
        return goalDays;
      } else {
        print('Failed to load goals. Status Code: ${response.statusCode}');
        throw Exception('Failed to load goals');
      }
    } catch (e) {
      print('Error fetching goals: $e');
      throw Exception('Failed to fetch goals');
    }
  }

  Future<GoalInfoCard> createGoal(GoalInfoCard goal) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(goal.toJson());
      print(
        'Request Body for createGoal: $requestBody',
      ); // Log the request body

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

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Goal created successfully.');
        return GoalInfoCard.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to create goal. Status Code: ${response.statusCode}');
        throw HttpException('Failed to create goal: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error creating goal: $e');
      throw Exception('Failed to create goal');
    }
  }

  Future<GoalInfoCard> updateGoal(String id, GoalInfoCard goal) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(goal.toJson());
      final String requestUrl = '$_baseUrl/$id';
      print('Request URL for updateGoal: $requestUrl'); // Log the request URL
      print(
        'Request Body for updateGoal: $requestBody',
      ); // Log the request body

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

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Goal updated successfully.');
        return GoalInfoCard.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to update goal. Status Code: ${response.statusCode}');
        throw Exception('Failed to update goal');
      }
    } catch (e) {
      print('Error updating goal: $e');
      throw Exception('Failed to update goal');
    }
  }

  Future<void> deleteGoal(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/$id';
      print('Request URL for deleteGoal: $requestUrl'); // Log the request URL

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

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Goal deleted successfully.');
      } else {
        print('Failed to delete goal. Status Code: ${response.statusCode}');
        throw HttpException('Failed to delete goal: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error deleting goal: $e');
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
