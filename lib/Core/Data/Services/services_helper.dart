import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../Constants/config.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

class ServicesHelper {
  final String baseURL = AppConfig().baseURL;
  final int pageSize = 50;
  final int timeout = 5;

  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppRepo().jwtToken}'
      };

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

      final durationTimeOut = Duration(seconds: timeout);

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
        case ServiceType.put:
          response = await client
              .put(uri, body: encodedBody, headers: headers ?? newHeaders)
              .timeout(durationTimeOut);
      }

      if (!AppRepo().networkConnectivity) {
        AppRepo().networkConnectivity = true;
      }

      return _responseHandler(
          response,
          () => request(url,
              serviceType: serviceType,
              body: body,
              headers: headers,
              requiredDefaultHeader: requiredDefaultHeader));
    } on TimeoutException catch (_) {
      debugPrint('Connection timeout');
      return null;
    } on SocketException catch (socketError) {
      debugPrint('socketError: $socketError');
      AppRepo().networkConnectivity = false;
      AppRepo().networkConnectivityStream.add(1);

      return null;
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<dynamic> uploadRequest(
    String url, {
    required String filePath,
    required http_parser.MediaType mediaType,
    Map<String, String>? body,
    Map<String, String>? headers,
    bool requiredDefaultHeader = false,
  }) async {
    print('jwtToken ${AppRepo().jwtToken}');
    final uri = Uri.parse(url);

    try {
      http.Response? response;
      final durationTimeOut = Duration(seconds: timeout);
      final client = http.MultipartRequest('POST', uri);

      if (body != null) {
        client.fields.addAll(body);
      }
      if (headers != null) {
        client.headers.addAll(headers);
      } else {
        if (requiredDefaultHeader) {
          client.headers.addAll(defaultHeaders);
        }
      }

      client.files.add(await http.MultipartFile.fromPath('file', filePath,
          contentType: mediaType));

      response = await http.Response.fromStream(
          await client.send().timeout(durationTimeOut));

      return _responseHandler(
        response,
        () => uploadRequest(
          url,
          filePath: filePath,
          mediaType: mediaType,
          body: body,
          headers: headers,
          requiredDefaultHeader: requiredDefaultHeader,
        ),
      );
    } on TimeoutException catch (_) {
      debugPrint('Connection timeout');
      return null;
    } on SocketException catch (socketError) {
      debugPrint('socketError: $socketError');
      AppRepo().networkConnectivity = false;
      AppRepo().networkConnectivityStream.add(1);

      return null;
    } catch (error) {
      debugPrint(error.toString());
      return null;
    }
  }

  Future<dynamic> _responseHandler(
      http.Response response, Function? originalRequest) async {
    debugPrint('statusCode : ${response.statusCode}');
    debugPrint('body : ${response.body}');
    AppRepo().hideLoading();

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
      // Success
    } else if (response.statusCode == 401) {
      final message = jsonDecode(response.body);
      if (message['message'] is String &&
          message['message'].contains('invalid csrf token')) {
        return null;
      }

      return await originalRequest!();
    } else if (response.statusCode == 429) {
      AppRepo().showSnackbar(
          label: 'Server',
          text: 'Too many requests exception, please try again later!');
      return null;
    } else {
      AppRepo().hideLoading();

      final message = jsonDecode(response.body);

      if (message['message'] is List<dynamic>) {
        Get.snackbar(
            message['error'] ?? '', (message['message'].join('\n')) ?? '');
      } else {
        Get.snackbar(message['error'] ?? '', message['message'] ?? '');
      }

      debugPrint('Error: $message');
      return message;
    }
  }
}
