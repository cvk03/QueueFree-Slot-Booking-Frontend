import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Machine.dart';

class ApiService {
  static const String baseUrl = 'https://queuefree-slot-booking-backend.onrender.com';
  // ✅ Increased timeout to 90s because Render free tier needs time to spin up
  static const Duration timeoutDuration = Duration(seconds: 90);

  // ✅ Create a custom HTTP client
  static final http.Client _httpClient = http.Client();

  // ✅ Get current user's ID token from Firebase
  static Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }
      // Get Firebase ID token and force refresh
      final idToken = await user.getIdToken(true);
      return idToken;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // ✅ Helper method to get headers with Authorization token
  static Future<Map<String, String>> _getHeaders({String? customToken}) async {
    final token = customToken ?? await _getAuthToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ✅ Get all machines - Updated with better error handling for cold starts
  static Future<List<Machine>> getMachines() async {
    try {
      final headers = await _getHeaders();

      print('🔄 Fetching machines from: $baseUrl/machines');
      
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/machines'),
        headers: headers,
      ).timeout(timeoutDuration);

      print('✅ GET /machines - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final machines = data
            .map((json) => Machine.fromJson(json as Map<String, dynamic>))
            .toList();

        return machines;
      } else if (response.statusCode == 401) {
        throw 'Unauthorized: Please sign in again';
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } on TimeoutException {
      throw 'The server is taking too long to respond. This often happens on the first request as the backend wakes up. Please try again in a few seconds.';
    } on SocketException catch (e) {
      throw 'Network Error: ${e.message}. Check your internet connection.';
    } catch (e) {
      throw 'Error fetching machines: $e';
    }
  }

  // ✅ Get machine details by ID
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

  // ✅ Get available slots for a machine
  static Future<List<Map<String, dynamic>>> getAvailableSlots(
      String machineId,
      DateTime date,
      ) async {
    try {
      final headers = await _getHeaders();
      final formattedDate = date.toIso8601String().split('T')[0];

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/machines/$machineId/slots?date=$formattedDate'),
        headers: headers,
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw 'Failed to fetch slots: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error fetching slots: $e';
    }
  }

  // ✅ Create a booking
  static Future<Map<String, dynamic>> createBooking({
    required String machineId,
    required DateTime slotDate,
    required String userId,
    required String userName,
  }) async {
    try {
      final headers = await _getHeaders();

      final body = jsonEncode({
        'machineId': machineId,
        'slotDate': slotDate.toIso8601String(),
        'userId': userId,
        'userName': userName,
      });

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/bookings'),
        headers: headers,
        body: body,
      ).timeout(timeoutDuration);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw 'Failed to create booking: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Error creating booking: $e';
    }
  }

  // ✅ Get user bookings
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

  // ✅ Cancel a booking
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

  // ✅ Update booking
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

  // ✅ Handle API errors
  static String handleError(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString();
    }
    return 'An unexpected error occurred';
  }
}