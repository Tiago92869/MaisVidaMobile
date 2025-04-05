import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testtest/config/config.dart';
import 'package:testtest/services/medicine/medicine_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class MedicineService {
  final String _baseUrl = Config.medicineUrl;
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

  Future<List<MedicineDay>> fetchMedicines(
    bool archived,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _loadStoredCredentials();
    try {
      final String url =
          '$_baseUrl?archived=$archived&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}';
      print('Request URL for fetchMedicines: $url'); // Log the request URL

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
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Medicines fetched successfully.');
        var jsonList = jsonDecode(response.body) as List;
        return jsonList.map((json) => MedicineDay.fromJson(json)).toList();
      } else {
        print('Failed to load medicines. Status Code: ${response.statusCode}');
        throw Exception('Failed to load medicines');
      }
    } catch (e) {
      print('Error fetching medicines: $e');
      throw Exception('Failed to fetch medicines');
    }
  }

  Future<Medicine> fetchMedicineById(String id) async {
    await _loadStoredCredentials();
    try {
      final String url = '$_baseUrl/$id';
      print('Request URL for fetchMedicineById: $url'); // Log the request URL

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
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Medicine fetched successfully.');
        return Medicine.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load medicine. Status Code: ${response.statusCode}');
        throw Exception('Failed to load medicine');
      }
    } catch (e) {
      print('Error fetching medicine by ID: $e');
      throw Exception('Failed to fetch medicine');
    }
  }

  Future<Medicine> createMedicine(Medicine medicine) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(medicine.toJson());
      print('Request Body for createMedicine: $requestBody'); // Log the request body

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Medicine created successfully.');
        return Medicine.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to create medicine. Status Code: ${response.statusCode}');
        throw Exception('Failed to create medicine');
      }
    } catch (e) {
      print('Error creating medicine: $e');
      throw Exception('Failed to create medicine');
    }
  }

  Future<Medicine> modifyMedicine(String id, Medicine medicine) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(medicine.toJson());
      final String requestUrl = '$_baseUrl/$id';
      print('Request URL for modifyMedicine: $requestUrl'); // Log the request URL
      print('Request Body for modifyMedicine: $requestBody'); // Log the request body

      final response = await http.patch(
        Uri.parse(requestUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('Medicine updated successfully.');
        return Medicine.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to update medicine. Status Code: ${response.statusCode}');
        throw Exception('Failed to update medicine');
      }
    } catch (e) {
      print('Error updating medicine: $e');
      throw Exception('Failed to update medicine');
    }
  }

  Future<void> deleteMedicine(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/$id';
      print('Request URL for deleteMedicine: $requestUrl'); // Log the request URL

      final response = await http.delete(
        Uri.parse(requestUrl),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(
        _timeoutDuration,
        onTimeout: () {
          throw TimeoutException('The connection has timed out, please try again later.');
        },
      );

      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Medicine deleted successfully.');
      } else {
        print('Failed to delete medicine. Status Code: ${response.statusCode}');
        throw Exception('Failed to delete medicine');
      }
    } catch (e) {
      print('Error deleting medicine: $e');
      throw Exception('Failed to delete medicine');
    }
  }
}
