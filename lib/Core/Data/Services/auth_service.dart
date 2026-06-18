import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../Core/Data/Services/services_helper.dart';

class AuthenticationService extends ServicesHelper {
  String get apiURL => '$baseURL/users/';

  Future<Map<String, dynamic>?> createUser({
    required String email,
    required String name,
    required String password,
  }) async {
    final Map<String, dynamic> data = {
      "email": email,
      "name": name,
      "password": password,
    };

    final response = await request(
      apiURL,
      body: data,
      serviceType: ServiceType.post,
      requiredDefaultHeader: false,
    );
    return response;
  }

  Future<Map<String, dynamic>?> login(Map<String, dynamic> input) async {
    final response = await request(
      '$baseURL/login',
      serviceType: ServiceType.post,
      body: {
        "username": input["email"] ?? input["username"],
        "password": input["password"],
      },
      requiredDefaultHeader: false,
      formUrlEncoded: true,
    );
    return response;
  }

  Future<Map<String, dynamic>?> adminLogin(Map<String, dynamic> input) async {
    final response = await request(
      '$baseURL/adminlogin',
      serviceType: ServiceType.post,
      body: {
        "username": input["username"],
        "password": input["password"],
      },
      requiredDefaultHeader: false,
    );
    return response;
  }

  Future<List<String>> getAdminMailingListPages() async {
    final response = await request(
      '$baseURL/adminlogin/listofpages',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );

    if (response is List) {
      return response.map((item) => item.toString()).toList();
    }

    if (response is Map<String, dynamic>) {
      final pages = response['pages'] ?? response['data'] ?? response['items'];
      if (pages is List) {
        return pages.map((item) => item.toString()).toList();
      }
    }

    return <String>[];
  }

  Future<List<String>> getAdminSqlTables() async {
    final response = await request(
      '$baseURL/adminlogin/read-SQL-tables',
      serviceType: ServiceType.post,
      requiredDefaultHeader: true,
      body: {},
    );

    if (response is List) {
      return response.map((item) => item.toString()).toList();
    }

    if (response is Map<String, dynamic>) {
      final tables =
          response['tables'] ?? response['data'] ?? response['items'];
      if (tables is List) {
        return tables.map((item) => item.toString()).toList();
      }
    }

    return <String>[];
  }

  Future<List<String>> getAdminSqlColumns(String tableName) async {
    final response = await request(
      '$baseURL/adminlogin/read-SQL-columns',
      serviceType: ServiceType.post,
      requiredDefaultHeader: true,
      body: {
        'table_name': tableName,
      },
    );

    if (response is List) {
      return response.map((item) => item.toString()).toList();
    }

    if (response is Map<String, dynamic>) {
      final columns =
          response['columns'] ?? response['data'] ?? response['items'];
      if (columns is List) {
        return columns.map((item) => item.toString()).toList();
      }
    }

    return <String>[];
  }

  Future<List<String>> getAdminSqlColumnData({
    required String tableName,
    required String columnName,
  }) async {
    final response = await request(
      '$baseURL/adminlogin/read-SQL-data',
      serviceType: ServiceType.post,
      requiredDefaultHeader: true,
      body: {
        'table_name': tableName,
        'column_name': columnName,
      },
    );

    if (response is List) {
      return response.map((item) => item?.toString() ?? '').toList();
    }

    if (response is Map<String, dynamic>) {
      final values =
          response['values'] ?? response['data'] ?? response['items'];
      if (values is List) {
        return values.map((item) => item?.toString() ?? '').toList();
      }
    }

    return <String>[];
  }

  Future<String?> getAdminMailingPageHtml(String pageName) async {
    final uri = Uri.parse('$baseURL/adminlogin/send-page');
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({
          'page_name': pageName,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      final body = response.body;
      if (body.isEmpty) return null;

      try {
        final decoded = jsonDecode(body);
        if (decoded is String) return decoded;
        if (decoded is Map<String, dynamic>) {
          final html = decoded['html'] ??
              decoded['content'] ??
              decoded['page'] ??
              decoded['data'];
          if (html != null) return html.toString();
        }
      } catch (_) {
        // Body is likely raw HTML text.
      }

      return body;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveAdminMailingPage({
    required String htmlName,
    required String htmlContent,
  }) async {
    final uri = Uri.parse('$baseURL/adminlogin/save-page');
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({
          'HTMLname': htmlName,
          'HTMLContent': htmlContent,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeAdminMailingPage(String htmlName) async {
    final uri = Uri.parse('$baseURL/adminlogin/remove-page');
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({
          'HTMLname': htmlName,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendAdminMailingPageNow({
    required String htmlName,
    required List<String> groups,
  }) async {
    final uri = Uri.parse('$baseURL/adminlogin/send-page-now');
    final body = jsonEncode(<String, dynamic>{
      'HTMLname': htmlName,
      'groups': groups,
    });
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: body,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAdminMailingPageSchedule(
      String htmlName) async {
    final uri = Uri.parse('$baseURL/adminlogin/schedule-later-load');
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({
          'HTMLname': htmlName,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      final body = response.body;
      if (body.isEmpty) return null;

      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        // Body is not JSON — treat as no schedule.
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> scheduleAdminMailingPage({
    required String htmlName,
    required List<String> groups,
    required DateTime date,
    required String repeat,
  }) async {
    final uri = Uri.parse('$baseURL/adminlogin/schedule-page');
    final body = jsonEncode(<String, dynamic>{
      'HTMLname': htmlName,
      'groups': groups,
      'date': date.toIso8601String(),
      'repeat': repeat,
    });
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: body,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getAdminRestrictionsText() async {
    final uri = Uri.parse('$baseURL/adminlogin/restrictions');
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      final body = response.body;
      if (body.isEmpty) return '';

      try {
        final decoded = jsonDecode(body);
        if (decoded is String) return decoded;
        if (decoded is Map<String, dynamic>) {
          final text = decoded['text'] ?? decoded['content'] ?? decoded['data'];
          if (text != null) return text.toString();
        }
      } catch (_) {
        // Body is likely plain text.
      }

      return body;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveAdminRestrictionsText(String text) async {
    final uri = Uri.parse('$baseURL/adminlogin/save-restrictions');
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode({
          'text': text,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchAffliation(String value) async {
    final response = await request(
      '$baseURL/affliation',
      serviceType: ServiceType.post,
      requiredDefaultHeader: false,
      body: {
        'affliation': value,
      },
    );

    if (response is List) {
      return response
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (response is Map<String, dynamic>) {
      final items =
          response['data'] ?? response['items'] ?? response['results'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, String>?> getLlmKeywordSuggestions(
      List<String> keywords) async {
    final response = await request(
      '$baseURL/llm',
      serviceType: ServiceType.post,
      requiredDefaultHeader: true,
      body: {
        'keywords': keywords,
      },
    );

    if (response is Map<String, dynamic>) {
      final string1 = response['string1']?.toString();
      final string2 = response['string2']?.toString();
      if (string1 != null && string2 != null) {
        return {
          'string1': string1,
          'string2': string2,
        };
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> verifyEmailToken(String token) async {
    final response = await request(
      '$baseURL/verify',
      serviceType: ServiceType.put,
      requiredDefaultHeader: false,
      body: {
        "token": token,
      },
    );

    return response;
  }

  Future<Map<String, dynamic>?> validateResetToken(String token) async {
    final response = await request(
      '$baseURL/verifytoken',
      serviceType: ServiceType.put,
      requiredDefaultHeader: false,
      body: {
        "token": token,
      },
    );

    return response;
  }

  Future<Map<String, dynamic>?> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await request(
      '$baseURL/recover',
      serviceType: ServiceType.put,
      requiredDefaultHeader: false,
      body: {
        "token": token,
        "password": password,
      },
    );

    return response;
  }

  Future<Map<String, dynamic>?> sendResetPasswordEmail(String email) async {
    final response = await request(
      '$baseURL/recover',
      serviceType: ServiceType.post,
      requiredDefaultHeader: false,
      body: {
        "email": email,
      },
    );

    return response;
  }
}
