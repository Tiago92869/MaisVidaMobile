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

  Future<ResourcePage> fetchResources(List<ResourceType> resourceTypes,
      int page, int size, String search) async {
    await _loadStoredCredentials();
    try {
      print('Fetching resources...');
      final String url = '$_baseUrl?userId=$_userId&page=$page&size=$size&search=$search';
      print('Request URL for fetchResources: $url'); // Log the request URL

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
        print('Resources fetched successfully.');
        return ResourcePage.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load resources. Status Code: ${response.statusCode}');
        throw Exception('Failed to load resources');
      }
    } catch (e) {
      print('Error fetching resources: $e');
      rethrow;
    }
  }

  Future<Resource> fetchResourceById(String id) async {
    await _loadStoredCredentials();
    try {
      print('Fetching resource with ID: $id');
      final String requestUrl = '$_baseUrl/$id';
      print('Request URL for fetchResourceById: $requestUrl'); // Log the request URL

      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          print('Request to $requestUrl timed out.');
          throw TimeoutException(
              'The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Resource fetched successfully.');
        return Resource.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load resource. Status Code: ${response.statusCode}');
        throw Exception('Failed to load resource');
      }
    } catch (e) {
      print('Error fetching resource by ID: $e');
      throw Exception('Failed to fetch resource');
    }
  }
}
