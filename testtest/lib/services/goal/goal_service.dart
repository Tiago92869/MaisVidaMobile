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
    bool isCompleted,
    DateTime startDate,
    DateTime endDate,
    List<GoalSubject> goalSubjects,
  ) async {
    await _loadStoredCredentials();
    try {
      print("GET ALL 1");

      // Construct query parameters
      final String subjectsQuery = goalSubjects
          .map((subject) =>
              'goalSubjects=${subject.toString().split('.').last.toUpperCase()}')
          .join('&');
      final String url =
          '$_baseUrl?&userId=$_userId&isCompleted=$isCompleted&$subjectsQuery'
          '&startDate=${_formatDate(startDate)}&endDate=${_formatDate(endDate)}';

      print('URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${_accessToken}',
          'Content-Type': 'application/json',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('STATUS CODE: ${response.statusCode}');
      print('STATUS CODE: ${response.body}');
      if (response.statusCode == 200) {
        print('STATUS CODE11111: ${response.statusCode}');
        final List<dynamic> jsonList = jsonDecode(response.body);
        print('STATUS CODE2222: ${response.statusCode}');
        final List<GoalDay> goalDays =
            jsonList.map((json) => GoalDay.fromJson(json)).toList();
        print('RESPONSE SIZE: ${goalDays.length}');
        return goalDays;
      } else {
        throw Exception('Failed to load goals');
      }
    } on http.ClientException {
      throw Exception('Failed to connect to the server');
    } catch (e) {
      throw Exception('Failed to fetch goals');
    }
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$year-$month-$day';
  }

  Future<GoalInfoCard> createGoal(GoalInfoCard goal) async {
    await _loadStoredCredentials();
    try {
      final response = await http
          .post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(goal.toJson()),
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      if (response.statusCode == 200) {
        return GoalInfoCard.fromJson(jsonDecode(response.body));
      } else {
        throw HttpException('Failed to create goal: ${response.reasonPhrase}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error: ${e.message}');
      rethrow;
    } on http.ClientException catch (e) {
      print('Client exception: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<GoalInfoCard> updateGoal(String id, GoalInfoCard goal) async {
    await _loadStoredCredentials();
    try {
      print("SAVED BODY!! ${goal.completed}");
      final response = await http
          .patch(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(goal.toJson()),
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      if (response.statusCode == 200) {
        print("SAVED WITH SUCCESS!!");
        return GoalInfoCard.fromJson(jsonDecode(response.body));
      } else {
        print("SAVED WITH FAIL!!");
        throw HttpException('Failed to update goal: ${response.reasonPhrase}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error: ${e.message}');
      rethrow;
    } on http.ClientException catch (e) {
      print('Client exception: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> deleteGoal(String id) async {
    await _loadStoredCredentials();
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      if (response.statusCode != 200) {
        throw HttpException('Failed to delete goal: ${response.reasonPhrase}');
      }
    } on TimeoutException catch (e) {
      print('Timeout error: ${e.message}');
      rethrow;
    } on http.ClientException catch (e) {
      print('Client exception: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }
}
