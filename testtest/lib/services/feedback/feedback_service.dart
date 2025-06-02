import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testtest/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:testtest/services/feedback/feedback_model.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class FeedbackService {
  final String _baseUrl = Config.feedbackUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  Future<Feedback> createFeedback(Feedback feedback) async {
    await _loadStoredCredentials();
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(feedback.toJson()),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 201) {
        return Feedback.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create feedback');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Feedback> updateFeedback(Feedback feedback) async {
    await _loadStoredCredentials();
    try {
      final response = await http
          .patch(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(feedback.toJson()),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        return Feedback.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update feedback');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Feedback> getFeedbackByResource(String resourceId) async {
    await _loadStoredCredentials();
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/resource/$resourceId'),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeoutDuration);

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}'); // Log para verificar o Content-Type

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
        print('Response Body: $decodedBody');
        return Feedback.fromJson(jsonDecode(decodedBody));
      } else {
        throw Exception('Failed to fetch feedback');
      }
    } catch (e) {
      print('Error fetching feedback: $e');
      rethrow;
    }
  }
}
