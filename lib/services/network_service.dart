import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/env.dart';

class NetworkService {
  Future<String?> getAuthToken(String username, String password) async {
    const url = '${ApiConstants.baseUrl}${ApiConstants.tokenEndpoint}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'client_id': ApiConstants.clientId,
          'client_secret': ApiConstants.clientSecret,
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      print('Auth error: $e');
      return null;
    }
  }

  Future<dynamic> makeAuthorizedRequest(String endpoint, {String method = 'GET', Map<String, dynamic>? body}) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(StorageKeys.accessToken);

    if (accessToken == null) return null;

    try {
      final url = Uri.parse('${ApiConstants.papiUrl}/$endpoint');
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      http.Response response;
      if (method == 'POST') {
        response = await http.post(url, headers: headers, body: json.encode(body));
      } else if (method == 'PUT') {
        response = await http.put(url, headers: headers, body: json.encode(body));
      } else {
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return true;
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return [];
      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Request error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getSubjects({int? year, int? semester}) async {
    String endpoint = '${ApiConstants.semesterEndpoint}?selector=current';

    if (year != null && semester != null) {
      String formattedYear = '$year - ${year + 1}';
      String encodedYear = Uri.encodeComponent(formattedYear);
      endpoint = '${ApiConstants.semesterEndpoint}?year=$encodedYear&period=$semester';
    }

    final data = await makeAuthorizedRequest(endpoint);
    if (data == null) return [];

    List<Map<String, dynamic>> subjects = [];
    try {
      if (data is Map && data.containsKey('RecordBooks')) {
        final recordBooks = data['RecordBooks'] as List? ?? [];
        for (var book in recordBooks) {
          final disciplines = book['Disciplines'] as List? ?? [];
          for (var discipline in disciplines) {
            subjects.add({
              'id': int.tryParse(discipline['Id'].toString()) ?? 0,
              'title': discipline['Title'] ?? 'Без названия'
            });
          }
        }
      } else if (data is List) {
        for (var item in data) {
          if (item is Map) {
            if (item.containsKey('Disciplines')) {
              final disciplines = item['Disciplines'] as List? ?? [];
              for (var discipline in disciplines) {
                subjects.add({
                  'id': int.tryParse(discipline['Id'].toString()) ?? 0,
                  'title': discipline['Title'] ?? 'Без названия'
                });
              }
            } else if (item.containsKey('Id') && item.containsKey('Title')) {
              subjects.add({
                'id': int.tryParse(item['Id'].toString()) ?? 0,
                'title': item['Title'] ?? 'Без названия'
              });
            }
          }
        }
      }
    } catch (e) {
      print('Parsing error: $e');
    }
    return subjects;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.accessToken, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.accessToken);
  }
}
