import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentara/config/config.dart';
import 'package:mentara/services/medicine/medicine_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Duration _timeoutDuration = Duration(seconds: 10);

class MedicineService {
  final String _baseUrl = Config.medicineUrl;
  final _storage = const FlutterSecureStorage();

  String? _accessToken;

  Future<void> _loadStoredCredentials() async {
    _accessToken = await _storage.read(key: 'accessToken');
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

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return MedicinePage.fromJson(jsonDecode(decodedBody));
      } else {
        throw Exception('Failed to fetch medicines');
      }
    } catch (e) {
      throw Exception('Failed to fetch medicines');
    }
  }

  Future<Medicine> fetchMedicineById(String id) async {
    await _loadStoredCredentials();
    try {
      final String url = '$_baseUrl/$id';

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
        final decodedBody = utf8.decode(response.bodyBytes);
        return Medicine.fromJson(jsonDecode(decodedBody));
      } else {
        throw Exception('Failed to load medicine');
      }
    } catch (e) {
      throw Exception('Failed to fetch medicine');
    }
  }

  Future<void> createMedicine(MedicineCreate medicineCreate) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(medicineCreate.toJson());

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

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to create medicine');
      }
    } catch (e) {
      throw Exception('Failed to create medicine');
    }
  }

  Future<void> modifyMedicine(String id, Medicine medicine) async {
    await _loadStoredCredentials();
    try {
      final requestBody = jsonEncode(medicine.toJson());
      final String requestUrl = '$_baseUrl/$id';

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

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to update medicine');
      }
    } catch (e) {
      throw Exception('Failed to update medicine');
    }
  }

  Future<void> deleteMedicine(String id) async {
    await _loadStoredCredentials();
    try {
      final String requestUrl = '$_baseUrl/$id';

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

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to delete medicine');
      }
    } catch (e) {
      throw Exception('Failed to delete medicine');
    }
  }

  // Updated to exclude time from the date format
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
