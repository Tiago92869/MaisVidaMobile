import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:testtest/services/resource/resource_model.dart';
import 'package:testtest/config/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class ResourceService {
  final String _baseUrl = Config.resourceUrl;
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

  Future<ResourcePage> fetchResources(List<ResourceType> resourceTypes,
      int page, int size, String search) async {
    await _loadStoredCredentials();
    try {
      print('Fetching resources...');

      // Construct the types query part
      final String typesQuery = resourceTypes != null &&
              resourceTypes.isNotEmpty
          ? resourceTypes
              .map((type) =>
                  'resourceType=${type.toString().split('.').last.toUpperCase()}')
              .join('&')
          : '';

      // Construct the search query part
      final String searchQuery =
          search != null && search.isNotEmpty ? 'search=$search' : '';

      // Combine the base URL with the parameters
      final String url =
          '$_baseUrl?&userId=$_userId&$typesQuery&$searchQuery&page=$page&size=$size';

      print('Request URL: $url');

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

      if (response.statusCode == 200) {
        print('Resources fetched successfully.');
        return ResourcePage.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load resources. Status Code: ${response.statusCode}');
        throw Exception('Failed to load resources');
      }
    } on http.ClientException catch (e) {
      print('ClientException: Failed to connect to the server. Error: $e');
      throw Exception('Failed to connect to the server');
    } catch (e) {
      print('Exception: Failed to fetch resources. Error: $e');
      throw Exception('Failed to fetch resources');
    }
  }

  Future<Resource> fetchResourceById(String id) async {
    await _loadStoredCredentials();
    try {
      print('Fetching resource with ID: $id');
      final String url = '$_baseUrl/$id';

      print('Request URL: $url');

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

      if (response.statusCode == 200) {
        print('Resource fetched successfully.');
        return Resource.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load resource. Status Code: ${response.statusCode}');
        throw Exception('Failed to load resource');
      }
    } on http.ClientException catch (e) {
      print('ClientException: Failed to connect to the server. Error: $e');
      throw Exception('Failed to connect to the server');
    } catch (e) {
      print('Exception: Failed to fetch resource. Error: $e');
      throw Exception('Failed to fetch resource');
    }
  }
}
