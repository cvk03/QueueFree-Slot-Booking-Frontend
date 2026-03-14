import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Machine.dart';

class ApiService {
  static const String baseUrl = 'https://queuefree-slot-booking-backend.onrender.com';
  static const Duration timeoutDuration = Duration(seconds: 90);

  static final http.Client _httpClient = http.Client();

  static Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }
      return await user.getIdToken(true);
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  static Future<Map<String, String>> _getHeaders({String? customToken}) async {
    final token = customToken ?? await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Machine>> getMachines() async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/machines'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Machine.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error fetching machines: $e';
    }
  }

  static Future<List<Map<String, dynamic>>> getAvailableSlots(
      String machineId,
      DateTime date,
      ) async {
    try {
      final headers = await _getHeaders();
      
      // ✅ Normalize to UTC Midnight to match standard backend expectations
      final utcDate = DateTime.utc(date.year, date.month, date.day);
      final int timestamp = utcDate.millisecondsSinceEpoch;

      final url = '$baseUrl/machines/$machineId/available-slots?date=$timestamp';
      print('🔄 API Request: GET $url');

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(timeoutDuration);

      print('✅ API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else if (response.statusCode == 400) {
        throw 'Bad Request: The server rejected the parameters. URL: $url';
      } else {
        throw 'Failed to fetch slots: ${response.statusCode}';
      }
    } on TimeoutException {
      throw 'Server timeout. The backend might still be waking up.';
    } catch (e) {
      print('❌ Error fetching slots: $e');
      rethrow;
    }
  }

  static Future<Machine> getMachineById(String machineId) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/machines/$machineId'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Machine.fromJson(json as Map<String, dynamic>);
      } else {
        throw 'Failed to fetch machine: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error fetching machine: $e';
    }
  }

  // ✅ Updated to match the new endpoint and body format
  static Future<Map<String, dynamic>> createBooking({
    required String machineId,
    required DateTime slotDate,
    required String userId,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Ensure date is in UTC and ISO format with .000Z
      final String formattedDate = slotDate.toUtc().toIso8601String();

      final body = jsonEncode({
        'date': formattedDate,
        'student_uid': userId,
      });

      final url = '$baseUrl/machines/$machineId/bookings';
      print('🔄 Creating booking at: $url');
      print('📦 Body: $body');

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(timeoutDuration);

      print('✅ API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // ✅ Handle cases where response body might not be JSON (e.g. "Booking successful")
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          return {'message': response.body};
        }
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          throw errorData['error'] ?? errorData['message'] ?? 'Bad Request';
        } catch (_) {
          throw response.body.isNotEmpty ? response.body : 'Bad Request';
        }
      } else if (response.statusCode == 401) {
        throw 'Unauthorized: Please sign in again';
      } else if (response.statusCode == 409) {
        throw 'Slot already booked';
      } else {
        throw 'Failed to create booking: ${response.statusCode}';
      }
    } on TimeoutException {
      throw 'Server timeout. Please try again.';
    } catch (e) {
      print('❌ Error creating booking: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/bookings/user/$userId'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw 'Failed to fetch bookings: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error fetching bookings: $e';
    }
  }

  static Future<void> cancelBooking(String bookingId) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw 'Failed to cancel booking: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error cancelling booking: $e';
    }
  }

  static Future<Map<String, dynamic>> updateBooking(
      String bookingId,
      Map<String, dynamic> updateData,
      ) async {
    try {
      final headers = await _getHeaders();
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: headers,
        body: jsonEncode(updateData),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw 'Failed to update booking: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error updating booking: $e';
    }
  }

  static String handleError(dynamic error) {
    if (error is String) return error;
    return error.toString();
  }
}