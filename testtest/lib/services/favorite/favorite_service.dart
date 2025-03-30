import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:testtest/config/config.dart';
import 'package:testtest/services/favorite/favorite_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class FavoriteService {
  final String _baseUrl = Config.favoriteUrl;
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

  Future<Favorite> fetchFavoriteByUserId() async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl';

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
          print('Timeout while fetching favorite');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      if (response.statusCode == 200) {
        print('Successfully fetched favorite: ${response.body}');
        return Favorite.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to fetch favorite: ${response.reasonPhrase}');
        throw HttpException(
            'Failed to load favorite: ${response.reasonPhrase}');
      }
    } on TimeoutException catch (e) {
      print('TimeoutException: ${e.message}');
      rethrow;
    } on http.ClientException catch (e) {
      print('http.ClientException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> modifyFavorite(FavoriteInput favoriteInput, bool add) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl?add=$add';
    print('Modifying favorite with input: $favoriteInput, add: $add');

    try {
      final response = await http
          .patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(favoriteInput.toJson()),
      )
          .timeout(
        _timeoutDuration,
        onTimeout: () {
          print(
              'Timeout while modifying favorite with input: $favoriteInput, add: $add');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      if (response.statusCode == 200) {
        print('Successfully modified favorite.');
      } else {
        print('Failed to modify favorite: ${response.reasonPhrase}');
        throw HttpException(
            'Failed to update favorite: ${response.reasonPhrase}');
      }
    } on TimeoutException catch (e) {
      print('TimeoutException: ${e.message}');
      rethrow;
    } on http.ClientException catch (e) {
      print('http.ClientException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }

  Future<bool> isFavorite({
    String? resourceId,
    String? activityId,
  }) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl/check';
    final queryParameters = <String, String?>{
      if (resourceId != null) 'resourceId': resourceId,
      if (activityId != null) 'activityId': activityId,
    };

    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    print(
        'Checking favorite status with resourceId: $resourceId, activityId: $activityId');

    print(uri);
    try {
      final response = await http.head(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          print(
              'Timeout while checking favorite status with resourceId: $resourceId, activityId: $activityId');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      if (response.statusCode == 200) {
        print('Resource is favorite');
        return true;
      } else if (response.statusCode == 404) {
        print('Resource is not favorite');
        return false;
      } else if (response.statusCode == 400) {
        print('Bad request while checking favorite status');
        throw BadRequestException('Bad request: ${response.reasonPhrase}');
      } else {
        print('Failed to check favorite status: ${response.reasonPhrase}');
        throw HttpException(
            'Failed to check favorite: ${response.reasonPhrase}');
      }
    } on TimeoutException catch (e) {
      print('TimeoutException: ${e.message}');
      rethrow;
    } on http.ClientException catch (e) {
      print('http.ClientException: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      rethrow;
    }
  }
}

class BadRequestException extends HttpException {
  BadRequestException(String message) : super(message);
}
