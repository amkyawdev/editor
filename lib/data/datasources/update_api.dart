import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_constants.dart';

class UpdateApi {
  static Future<Map<String, dynamic>?> checkForUpdates(String currentVersion) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.updateApiBaseUrl}/updates/check?version=$currentVersion'),
      ).timeout(AppConstants.apiTimeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Network error or timeout
    }
    return null;
  }

  static Future<String?> getLatestVersion() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.updateApiBaseUrl}/updates/latest'),
      ).timeout(AppConstants.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['version'];
      }
    } catch (e) {
      // Network error or timeout
    }
    return null;
  }
}