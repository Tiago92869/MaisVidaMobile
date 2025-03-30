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

  Future<MedicinePage> fetchMedicines(bool archived, int page, int size) async {
    await _loadStoredCredentials();
    try {
      final String url = '$_baseUrl?archived=$archived&page=$page&size=$size';
      print('Fetching medicines from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Successfully fetched medicines');
        return MedicinePage.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to load medicines. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Request timed out while fetching medicines');
      throw Exception('Request timed out');
    } catch (e) {
      print('Error fetching medicines: $e');
      throw Exception('Failed to fetch medicines: $e');
    }
  }

  Future<Medicine> fetchMedicineById(String id) async {
    await _loadStoredCredentials();
    try {
      final String url = '$_baseUrl/$id';
      print('Fetching medicine by ID from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        print('Successfully fetched medicine with ID: $id');
        return Medicine.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load medicine. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Request timed out while fetching medicine with ID: $id');
      throw Exception('Request timed out');
    } catch (e) {
      print('Error fetching medicine by ID: $e');
      throw Exception('Failed to fetch medicine: $e');
    }
  }

  Future<Medicine> createMedicine(Medicine medicine) async {
    await _loadStoredCredentials();
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(medicine.toJson()),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        print('Successfully created medicine: ${medicine.name}');
        return Medicine.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to create medicine. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Request timed out while creating medicine');
      throw Exception('Request timed out');
    } catch (e) {
      print('Error creating medicine: $e');
      throw Exception('Failed to create medicine: $e');
    }
  }

  Future<Medicine> modifyMedicine(String id, Medicine medicine) async {
    await _loadStoredCredentials();
    try {
      final String url = '$_baseUrl/$id';
      print('Update medicine from URL: $url');

      final response = await http
          .patch(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(medicine.toJson()),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        print('Successfully updated medicine ID: $id');
        return Medicine.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to update medicine. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Request timed out while updating medicine ID: $id');
      throw Exception('Request timed out');
    } catch (e) {
      print('Error updating medicine: $e');
      throw Exception('Failed to update medicine: $e');
    }
  }

  Future<void> deleteMedicine(String id) async {
    await _loadStoredCredentials();
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        print('Successfully deleted medicine ID: $id');
      } else {
        throw Exception(
            'Failed to delete medicine. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Request timed out while deleting medicine ID: $id');
      throw Exception('Request timed out');
    } catch (e) {
      print('Error deleting medicine: $e');
      throw Exception('Failed to delete medicine: $e');
    }
  }
}
