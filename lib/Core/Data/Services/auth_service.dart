import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../Core/Data/Services/services_helper.dart';

class AuthenticationService extends ServicesHelper {
  String get apiURL => '$baseURL/users';

  Future<Map<String, dynamic>?> createUser({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> data = {
      "email": email,
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

  String get _adminURL => '$baseURL/admin';

  String _adminTemplateUrl(String name) =>
      '$_adminURL/templates/${Uri.encodeComponent(name)}';

  Uri _adminSqlUri({String? table, String? column}) {
    return Uri.parse('$_adminURL/sql').replace(
      queryParameters: <String, String>{
        if (table != null) 'table': table,
        if (column != null) 'column': column,
      },
    );
  }

  List<String> _stringList(dynamic response) {
    if (response is List) {
      return response.map((item) => item?.toString() ?? '').toList();
    }
    return <String>[];
  }

  bool _adminOk(dynamic response) {
    if (response == null) return false;
    if (response is Map && response.containsKey('detail')) return false;
    return true;
  }

  bool _httpOk(int statusCode) =>
      statusCode == 200 || statusCode == 201 || statusCode == 204;

  Future<bool> _adminHttpFailed(int statusCode, String body) async {
    if (statusCode == 401) {
      await AppRepo().redirectToAuth();
      return true;
    }
    if (statusCode == 403) {
      Get.offAllNamed(AppConfig().routes.admin);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> adminLogin(Map<String, dynamic> input) async {
    final response = await request(
      '$_adminURL/login',
      serviceType: ServiceType.post,
      body: {
        "username": input["username"],
        "password": input["password"],
      },
      requiredDefaultHeader: false,
    );
    if (response is Map<String, dynamic> &&
        (response['access_token'] != null || response['token'] != null)) {
      return response;
    }
    return null;
  }

  Future<List<String>> getAdminMailingListPages() async {
    final response = await request(
      '$_adminURL/templates',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );
    return _stringList(response)
        .where((name) => name.endsWith('.html'))
        .toList();
  }

  Future<List<String>> getAdminSqlTables() async {
    final response = await request(
      _adminSqlUri().toString(),
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );
    return _stringList(response);
  }

  Future<List<String>> getAdminSqlColumns(String tableName) async {
    final response = await request(
      _adminSqlUri(table: tableName).toString(),
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );
    return _stringList(response);
  }

  Future<List<String>> getAdminSqlColumnData({
    required String tableName,
    required String columnName,
  }) async {
    final response = await request(
      _adminSqlUri(table: tableName, column: columnName).toString(),
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );
    return _stringList(response);
  }

  Future<String?> getAdminMailingPageHtml(String pageName) async {
    final uri = Uri.parse(_adminTemplateUrl(pageName));
    try {
      final response = await http.get(uri, headers: defaultHeaders);
      if (await _adminHttpFailed(response.statusCode, response.body)) {
        return null;
      }
      if (response.statusCode != 200) return null;
      return response.body;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveAdminMailingPage({
    required String htmlName,
    required String htmlContent,
  }) async {
    final response = await request(
      _adminTemplateUrl(htmlName),
      serviceType: ServiceType.put,
      requiredDefaultHeader: true,
      body: {'text': htmlContent},
    );
    return _adminOk(response);
  }

  Future<bool> removeAdminMailingPage(String htmlName) async {
    final response = await request(
      _adminTemplateUrl(htmlName),
      serviceType: ServiceType.delete,
      requiredDefaultHeader: true,
    );
    return _adminOk(response);
  }

  Future<bool> sendAdminMailingPageNow({
    required String htmlName,
    required List<String> groups,
  }) async {
    final uri = Uri.parse('${_adminTemplateUrl(htmlName)}/send');
    try {
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(<String, dynamic>{'groups': groups}),
      );
      if (await _adminHttpFailed(response.statusCode, response.body)) {
        return false;
      }
      return _httpOk(response.statusCode);
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAdminMailingPageSchedule(
      String htmlName) async {
    final uri = Uri.parse('${_adminTemplateUrl(htmlName)}/schedule');
    try {
      final response = await http.get(uri, headers: defaultHeaders);
      if (await _adminHttpFailed(response.statusCode, response.body)) {
        return null;
      }
      if (response.statusCode != 200) return null;
      final body = response.body;
      if (body.isEmpty) return null;
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
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
    final response = await request(
      '${_adminTemplateUrl(htmlName)}/schedule',
      serviceType: ServiceType.put,
      requiredDefaultHeader: true,
      body: {
        'groups': groups,
        'date': date.toIso8601String(),
        'repeat': repeat,
      },
    );
    return _adminOk(response);
  }

  Future<String?> getAdminRestrictionsText() async {
    final response = await request(
      '$_adminURL/restrictions',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );
    if (response is Map<String, dynamic> && !response.containsKey('detail')) {
      return response['text']?.toString() ?? '';
    }
    return null;
  }

  Future<bool> saveAdminRestrictionsText(String text) async {
    final response = await request(
      '$_adminURL/restrictions',
      serviceType: ServiceType.put,
      requiredDefaultHeader: true,
      body: {'text': text},
    );
    return _adminOk(response);
  }

  Future<List<Map<String, dynamic>>> searchAffliation(String value) async {
    final query = Uri.encodeQueryComponent(value);
    final response = await request(
      '$baseURL/profile/affiliations?q=$query',
      serviceType: ServiceType.get,
      requiredDefaultHeader: false,
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
      '$baseURL/profile/llm',
      serviceType: ServiceType.post,
      requiredDefaultHeader: true,
      timeoutSeconds: timeoutLlm,
      body: {
        'keywords': keywords,
      },
    );

    if (response is Map<String, dynamic>) {
      final draft1 = response['draft_1']?.toString();
      final draft2 = response['draft_2']?.toString();
      if (draft1 != null && draft2 != null) {
        return {
          'draft_1': draft1,
          'draft_2': draft2,
          // Existing LLM choice screen still reads these keys.
          'string1': draft1,
          'string2': draft2,
        };
      }
    }

    return null;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final response = await request(
      '$baseURL/profile/me',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );

    if (response is! Map<String, dynamic> || response.containsKey('detail')) {
      return null;
    }
    return response;
  }

  Future<Map<String, dynamic>?> updateProfile({
    String? name,
    String? affiliation,
    String? affliation,
    String? position,
    String? description,
    String? location,
    bool? onboardingComplete,
  }) async {
    final Map<String, dynamic> data = {};
    // Send provided fields even when empty so later profile save can clear them.
    if (name != null) {
      data['name'] = name;
    }
    final affiliationValue = affiliation ?? affliation;
    if (affiliationValue != null) {
      data['affiliation'] = affiliationValue;
    }
    if (position != null) {
      data['position'] = position;
    }
    if (description != null) {
      data['description'] = description;
    }
    if (location != null) {
      data['location'] = location;
    }
    if (onboardingComplete != null) {
      data['onboarding_complete'] = onboardingComplete;
    }

    if (data.isEmpty) return null;

    final response = await request(
      '$baseURL/profile/me',
      serviceType: ServiceType.patch,
      requiredDefaultHeader: true,
      body: data,
    );

    if (response is! Map<String, dynamic> || response.containsKey('detail')) {
      return null;
    }
    return response;
  }

  Future<Map<String, dynamic>?> verifyEmailToken(String token) async {
    final response = await request(
      '$baseURL/verify',
      serviceType: ServiceType.post,
      requiredDefaultHeader: false,
      body: {
        "token": token,
      },
    );

    return response;
  }

  Future<Map<String, dynamic>?> resendVerificationEmail(String email) async {
    final response = await request(
      '$baseURL/verify/resend',
      serviceType: ServiceType.post,
      requiredDefaultHeader: false,
      body: {
        "email": email,
      },
    );

    return response;
  }

  Future<Map<String, dynamic>?> validateResetToken(String token) async {
    // v2 has no token-check endpoint; later reset UI only needs a URL token.
    if (token.isEmpty) return null;
    return {'token': token};
  }

  Future<Map<String, dynamic>?> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await request(
      '$baseURL/recover/reset',
      serviceType: ServiceType.post,
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

  Future<Map<String, dynamic>?> deleteMe() async {
    final response = await request(
      '$apiURL/me',
      serviceType: ServiceType.delete,
      requiredDefaultHeader: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }
}
