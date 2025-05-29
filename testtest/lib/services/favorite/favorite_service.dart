import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:testtest/config/config.dart';
import 'package:testtest/services/activity/activity_model.dart';
import 'package:testtest/services/favorite/favorite_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:testtest/services/resource/resource_model.dart';

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
    print('Request URL for fetchFavoriteByUserId: $url'); // Log the request URL

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
              print('Request to $url timed out.');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Successfully fetched favorite.');
        return Favorite.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to fetch favorite. Status Code: ${response.statusCode}');
        throw HttpException(
          'Failed to load favorite: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error fetching favorite: $e');
      rethrow;
    }
  }

  Future<void> modifyFavorite(FavoriteInput favoriteInput, bool add) async {
    await _loadStoredCredentials();
    final String url = '$_baseUrl?add=$add';
    final requestBody = jsonEncode(favoriteInput.toJson());
    print('Request URL for modifyFavorite: $url'); // Log the request URL
    print(
      'Request Body for modifyFavorite: $requestBody',
    ); // Log the request body

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
              print('Request to $url timed out.');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Successfully modified favorite.');
      } else {
        print('Failed to modify favorite. Status Code: ${response.statusCode}');
        throw HttpException(
          'Failed to update favorite: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error modifying favorite: $e');
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
    print('Request URL for isFavorite: $uri'); // Log the request URL

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
              print('Request to $uri timed out.');
              throw TimeoutException(
                'The connection has timed out, please try again later.',
              );
            },
          );

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Resource is favorite.');
        return true;
      } else if (response.statusCode == 404) {
        print('Resource is not favorite.');
        return false;
      } else {
        print(
          'Failed to check favorite status. Status Code: ${response.statusCode}',
        );
        throw HttpException(
          'Failed to check favorite: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      rethrow;
    }
  }

  Future<List<Resource>> fetchFavoriteResources() async {
  await _loadStoredCredentials();
  final String url = '$_baseUrl/resources';
  print('Request URL for fetchFavoriteResources: $url'); // Log the request URL

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
      return jsonList.map((json) => Resource.fromJson(json)).toList();
    } else {
      print('Failed to fetch favorite resources. Status Code: ${response.statusCode}');
      throw Exception('Failed to fetch favorite resources');
    }
  } catch (e) {
    print('Error fetching favorite resources: $e');
    rethrow;
  }
}

Future<List<Activity>> fetchFavoriteActivities() async {
  await _loadStoredCredentials();
  final String url = '$_baseUrl/activities';
  print('Request URL for fetchFavoriteActivities: $url'); // Log the request URL

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
      return jsonList.map((json) => Activity.fromJson(json)).toList();
    } else {
      print('Failed to fetch favorite activities. Status Code: ${response.statusCode}');
      throw Exception('Failed to fetch favorite activities');
    }
  } catch (e) {
    print('Error fetching favorite activities: $e');
    rethrow;
  }
}
}



class BadRequestException extends HttpException {
  BadRequestException(String message) : super(message);
}
