import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:maisvida/config/config.dart';
import 'package:maisvida/services/activity/activity_model.dart';
import 'package:maisvida/services/favorite/favorite_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maisvida/services/resource/resource_model.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class FavoriteService {
  final String _baseUrl = Config.favoriteUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
  }

  Future<Favorite> fetchFavoriteByUserId() async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl';

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
        return Favorite.fromJson(jsonDecode(response.body));
      } else {
        throw HttpException(
          'Failed to load favorite: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> modifyFavorite(FavoriteInput favoriteInput, bool add) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl?add=$add';
    final requestBody = jsonEncode(favoriteInput.toJson());

    try {
      final response = await http
          .patch(
            Uri.parse(url),
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
      } else {
        throw HttpException(
          'Failed to update favorite: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isFavorite({String? resourceId, String? activityId}) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/check';
    final queryParameters = <String, String?>{
      if (resourceId != null) 'resourceId': resourceId,
      if (activityId != null) 'activityId': activityId,
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParameters);

    try {
      final response = await http
          .head(
            uri,
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
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw HttpException(
          'Failed to check favorite: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Resource>> fetchFavoriteResources() async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/resources';

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
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Resource.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch favorite resources');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Activity>> fetchFavoriteActivities() async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/activities';

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
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Activity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch favorite activities');
      }
    } catch (e) {
      rethrow;
    }
  }
}
