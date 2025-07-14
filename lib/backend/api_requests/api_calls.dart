import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'package:n_f_c_app/backend/api_requests/_/api_manager.dart';

export 'package:n_f_c_app/backend/api_requests/_/api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start UDLAP Group Code

class UdlapGroup {
  static String getBaseUrl() => 'https://ws-guards.ever-track.com/v1';
  static Map<String, String> headers = {};
  static LoginCall loginCall = LoginCall();
}

class LoginCall {
  Future<ApiCallResponse> call({
    String? username = '',
    String? password = '',
  }) async {
    final baseUrl = UdlapGroup.getBaseUrl();

    final ffApiRequestBody = '''
{
  "username": "${escapeStringForJson(username)}",
  "passwordHash": "${escapeStringForJson(password)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Login',
      apiUrl: '${baseUrl}/Login',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  int? userId(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.userId''',
      ));
  String? firstName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.firstName''',
      ));
  String? lastName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.lastName''',
      ));
  String? username(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.username''',
      ));
  String? passwordHash(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.passwordHash''',
      ));
  String? email(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.email''',
      ));
  String? phoneNumber(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.phoneNumber''',
      ));
  String? role(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.role''',
      ));
  bool? active(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.active''',
      ));
  String? lastLogin(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.lastLogin''',
      ));
  String? createdAt(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.createdAt''',
      ));
  String? updatedAt(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.updatedAt''',
      ));
}

/// End UDLAP Group Code

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
