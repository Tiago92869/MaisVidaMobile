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

  Future<MedicinePage> fetchMedicines(
    bool archived,
    DateTime startDate,
    DateTime endDate, {
    int page = 0,
    int size = 10,
  }) async {
    await _loadStoredCredentials();
    try {
      // Format the dates to yyyy-MM-dd
      final String formattedStartDate = _formatDate(startDate);
      final String formattedEndDate = _formatDate(endDate);

      final String url =
          '$_baseUrl?archived=$archived&startDate=$formattedStartDate&endDate=$formattedEndDate&page=$page&size=$size';

      // Log the request details
      print('Request URL: $url');
      print(
        'Request Headers: {Authorization: Bearer $_accessToken, Content-Type: application/json}',
      );
      print(
        'Request Parameters: archived=$archived, startDate=$formattedStartDate, endDate=$formattedEndDate, page=$page, size=$size',
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      // Log the response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}'); // Log para verificar o Content-Type

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
        print('Response Body: $decodedBody');
        return MedicinePage.fromJson(jsonDecode(decodedBody));
      } else {
        print('Failed to fetch medicines. Status Code: ${response.statusCode}');
        throw Exception('Failed to fetch medicines');
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
      print('Response Headers: ${response.headers}'); // Log para verificar o Content-Type

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes); // Decodifica explicitamente em UTF-8
        print('Response Body: $decodedBody');
        return Medicine.fromJson(jsonDecode(decodedBody));
      } else {
        print('Failed to load medicine. Status Code: ${response.statusCode}');
        throw Exception('Failed to load medicine');
      }
    } catch (e) {
      print('Error fetching medicine by ID: $e');
      throw Exception('Failed to fetch medicine');
    }
  }

  Future<void> createMedicine(MedicineCreate medicineCreate) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(medicineCreate.toJson());
      print(
        'Request Body for createMedicine: $requestBody',
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
        print('Medicine created successfully.');
      } else {
        print('Failed to create medicine. Status Code: ${response.statusCode}');
        throw Exception('Failed to create medicine');
      }
    } catch (e) {
      print('Error creating medicine: $e');
      throw Exception('Failed to create medicine');
    }
  }

  Future<void> modifyMedicine(String id, Medicine medicine) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(medicine.toJson());
      final String requestUrl = '$_baseUrl/$id';
      print('Request URL for modifyMedicine: $requestUrl');
      print('Request Body for modifyMedicine: $requestBody');

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
        print('Medicine updated successfully.');
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
      print(
        'Request URL for deleteMedicine: $requestUrl',
      ); // Log the request URL

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

  // Updated to exclude time from the date format
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
