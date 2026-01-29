import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_data.dart';

class GoogleSheetsService {
  static const String _deploymentUrl =
      "https://script.google.com/macros/s/AKfycbzWAnfZQ0mnpjLQbpS4lgI4LoYVfEwvaTXqbwgImzg-sdhErf3GbO0cVsBk918xLjRx/exec";

  static Future<bool> submitUserData(UserData userData) async {
    try {
      print('\n📝 Submitting data to Google Sheet...');
      print('Deployment URL: $_deploymentUrl');

      // Prepare clean data
      final dataToSubmit = {
        'firstName': userData.firstName ?? '',
        'lastName': userData.lastName ?? '',
        'mobileNumber': userData.mobileNumber ?? '',
        'landline': userData.landline ?? '',
        'email': userData.email ?? '',
        'apartment': userData.apartment ?? '',
        'floor': userData.floor ?? '',
        'building': userData.building ?? '',
        'streetName': userData.streetName ?? '',
        'area': userData.area ?? '',
        'city': userData.city ?? '',
        'landmark': userData.landmark ?? '',
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('📤 Sending: ${jsonEncode(dataToSubmit)}');

      // Send to Apps Script
      final response = await http.post(
        Uri.parse(_deploymentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dataToSubmit),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Apps Script returns 302 on success
      if (response.statusCode == 302 || response.statusCode == 200) {
        print('✓ Data submitted successfully!');
        return true;
      }

      // Try parsing JSON response
      try {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          print('✓ Success confirmed by server');
          return true;
        }
        print('✗ Server returned: ${json['message']}');
        return false;
      } catch (e) {
        print('✗ Could not parse response');
        return false;
      }
    } catch (e) {
      print('✗ Error: $e');
      return false;
    }
  }
}
