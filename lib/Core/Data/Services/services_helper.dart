import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../Constants/config.dart';

class ServicesHelper {
  final String baseURL = AppConfig().baseURL;
  final int pageSize = 50;
  final int timeout = 5;
  final int timeoutLlm = 30;

  Map<String, String> get defaultHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final token = AppRepo().jwtToken?.trim();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String queryMaker(Map<String, dynamic> parameters) {
    String query = '';
    parameters.forEach((key, value) {
      if (query.isEmpty) {
        query = '?$key=$value';
      } else {
        query = '$query&$key=$value';
      }
    });

    return query;
  }

  Future<dynamic> request(
    String url, {
    required ServiceType serviceType,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiredDefaultHeader = false,
    bool formUrlEncoded = false,
    int? timeoutSeconds,
  }) async {
    final uri = Uri.parse(url);

    Map<String, String> newHeaders = defaultHeaders;
    if (!requiredDefaultHeader) {
      newHeaders = {
        'Content-Type': formUrlEncoded
            ? 'application/x-www-form-urlencoded'
            : 'application/json',
      };
    }

    final dynamic encodedBody = formUrlEncoded
        ? (body ?? {}).map((k, v) => MapEntry(k, v?.toString() ?? ''))
        : jsonEncode(body);

    try {
      http.Response? response;

      final client = http.Client();

      final durationTimeOut = Duration(seconds: timeoutSeconds ?? timeout);

      switch (serviceType) {
        case ServiceType.post:
          response = await client
              .post(uri, body: encodedBody, headers: headers ?? newHeaders)
              .timeout(durationTimeOut);
        case ServiceType.get:
          response = await client
              .get(uri, headers: headers ?? newHeaders)
              .timeout(durationTimeOut);
        case ServiceType.delete:
          response = await client
              .delete(uri,
                  body: body != null ? encodedBody : null,
                  headers: headers ?? newHeaders)
              .timeout(durationTimeOut);
        case ServiceType.patch:
          response = await client
              .patch(uri, body: encodedBody, headers: headers ?? newHeaders)
              .timeout(durationTimeOut);
        case ServiceType.put:
          response = await client
              .put(uri, body: encodedBody, headers: headers ?? newHeaders)
              .timeout(durationTimeOut);
      }

      if (!AppRepo().networkConnectivity) {
        AppRepo().networkConnectivity = true;
      }

      return await _responseHandler(
          response,
          () => request(url,
              serviceType: serviceType,
              body: body,
              headers: headers,
              requiredDefaultHeader: requiredDefaultHeader,
              formUrlEncoded: formUrlEncoded,
              timeoutSeconds: timeoutSeconds));
    } on TimeoutException catch (_) {
      debugPrint('Connection timeout');
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Could not reach the server. Please try again.',
        position: SnackPosition.TOP,
      );
      return null;
    } on SocketException catch (socketError) {
      debugPrint('socketError: $socketError');
      AppRepo().networkConnectivity = false;
      AppRepo().networkConnectivityStream.add(1);
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Could not reach the server. Please try again.',
        position: SnackPosition.TOP,
      );

      return null;
    } catch (error) {
      debugPrint(error.toString());
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Could not reach the server. Please try again.',
        position: SnackPosition.TOP,
      );
      return null;
    }
  }

  Future<dynamic> _responseHandler(
      http.Response response, Function? originalRequest) async {
    debugPrint('statusCode : ${response.statusCode}');
    AppRepo().hideLoading();

    if (response.statusCode == 204) {
      return <String, dynamic>{};
    } else if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return decoded;
    } else if (response.statusCode == 409) {
      final message = _decodeErrorBody(
        response.body,
        fallback: 'Request failed with status 409',
      );
      final errorText =
          _detailText(message) ?? 'The request could not be completed.';
      AppRepo().showSnackbar(
        label: 'Error',
        text: errorText,
        position: SnackPosition.TOP,
      );
      debugPrint('Error: $message');
      return message;
    } else if (_isAuthFailure(response.statusCode, response.body)) {
      final message = _decodeErrorBody(
        response.body,
        fallback: 'Could not validate credentials',
      );
      final errorText = _detailText(message) ?? 'Could not validate credentials';

      if (errorText == 'Email not verified') {
        return message;
      }

      if (errorText == 'Invalid email or password' ||
          errorText == 'Invalid username or password') {
        AppRepo().showSnackbar(
          label: 'Login failed',
          text: errorText,
          position: SnackPosition.TOP,
        );
        return null;
      }

      if (errorText == 'Not an admin token') {
        Get.offAllNamed(AppConfig().routes.admin);
        return null;
      }

      await AppRepo().redirectToAuth();
      return null;
    } else if (response.statusCode == 429) {
      AppRepo().showSnackbar(
          label: 'Server',
          text: 'Too many requests exception, please try again later!');
      return null;
    } else {
      AppRepo().hideLoading();

      final message = _decodeErrorBody(
        response.body,
        fallback: 'Request failed with status ${response.statusCode}',
      );
      final errorText =
          _detailText(message) ?? 'The request could not be completed.';

      AppRepo().showSnackbar(
        label: 'Error',
        text: errorText,
        position: SnackPosition.TOP,
      );

      debugPrint('Error: $message');
      return message;
    }
  }

  Map<String, dynamic> _decodeErrorBody(String body,
      {required String fallback}) {
    try {
      return Map<String, dynamic>.from(jsonDecode(body));
    } catch (_) {
      return {
        'detail': fallback,
      };
    }
  }

  String? _detailText(Map<String, dynamic> message) {
    final detail = message['detail'];
    if (detail is List) {
      return detail.map((item) {
        if (item is Map && item['msg'] != null) {
          return item['msg'].toString();
        }
        return item.toString();
      }).join('\n');
    }
    return detail?.toString() ?? message['message']?.toString();
  }

  bool _isAuthFailure(int statusCode, String body) {
    if (statusCode == 401) {
      return true;
    }
    if (statusCode != 403) {
      return false;
    }
    final detail = _credentialErrorDetail(body);
    return detail == 'Could not validate credentials' ||
        detail == 'Not authenticated';
  }

  String? _credentialErrorDetail(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return decoded['detail']?.toString();
      }
    } catch (_) {
      // Body is not JSON.
    }
    return null;
  }
}
