/*

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import '../services_class/data_helper.dart';

class NetworkResponse {
  final int statusCode;
  final Map<String, dynamic>? responseData;
  final String? errorMessage;
  final bool isSuccess;

  NetworkResponse({
    required this.statusCode,
    this.responseData,
    this.errorMessage = "Request failed !",
    required this.isSuccess,
  });
}

class NetworkCall {
  static final Logger _logger = Logger();

  /// POST Multipart request
  static Future<NetworkResponse> multipartRequest({
    required String url,
    Map<String, String>? fields,
    Map<String, dynamic>? body,
    File? imageFile,
    File? videoFile,
    required String methodType,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      var request = http.MultipartRequest(methodType, uri);

      // Add Authorization header
      if (AuthController.accessToken != null &&
          AuthController.accessToken!.isNotEmpty) {
        request.headers['Authorization'] = AuthController.accessToken!;
      }

      // Add fields (e.g. name, email)
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Attach image if present
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      // Attach video if present
      if (videoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'video',
          videoFile.path,
          contentType: MediaType('video', 'mp4'),
        ));
      }

      // Send request
      _logRequest(url, request.headers, requestBody: fields, );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseDecode = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseDecode,
        );
      } else if (response.statusCode == 401) {
        await _logOut();
        return NetworkResponse(statusCode: response.statusCode, isSuccess: false);
      } else {
        return NetworkResponse(statusCode: response.statusCode, isSuccess: false);
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// POST request
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };

      // Only add token if it exists
      if (AuthController.accessToken != null &&
          AuthController.accessToken!.isNotEmpty) {
        headers['Authorization'] = AuthController.accessToken!;
      }

      _logRequest(url, headers, requestBody: body);

      Response response = await post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseDecode = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseDecode,
        );
      } else if (response.statusCode == 401) {
        await _logOut();
        return NetworkResponse(statusCode: response.statusCode, isSuccess: false);
      } else {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: jsonDecode(response.body),
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// PATCH request
  static Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };

      if (AuthController.accessToken != null &&
          AuthController.accessToken!.isNotEmpty) {
        headers['Authorization'] = AuthController.accessToken!;
      }

      _logRequest(url, headers, requestBody: body);
      Response response = await patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseDecode = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseDecode,
        );
      } else if (response.statusCode == 401) {
        await _logOut();
        return NetworkResponse(statusCode: response.statusCode, isSuccess: false);
      } else {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: jsonDecode(response.body),
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// GET request
  static Future<NetworkResponse> getRequest({
    required String url,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      String fullUrl = url;
      if (queryParams != null && queryParams.isNotEmpty) {
        fullUrl += '?';
        queryParams.forEach((key, value) {
          fullUrl += '$key=$value&';
        });
        fullUrl = fullUrl.substring(0, fullUrl.length - 1);
      }

      final Uri uri = Uri.parse(fullUrl);
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };
      if (AuthController.accessToken != null &&
          AuthController.accessToken!.isNotEmpty) {
        headers['Authorization'] = AuthController.accessToken!;
      }

      _logRequest(fullUrl, headers);
      Response response = await get(uri, headers: headers);
      _logResponse(fullUrl, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseDecode = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseDecode,
        );
      } else if (response.statusCode == 401) {
        await _logOut();
        return NetworkResponse(statusCode: response.statusCode, isSuccess: false);
      } else {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: jsonDecode(response.body),
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// PUT request
  static Future<NetworkResponse> putRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };
      if (AuthController.accessToken != null &&
          AuthController.accessToken!.isNotEmpty) {
        headers['Authorization'] = AuthController.accessToken!;
      }

      _logRequest(url, headers, requestBody: body);
      Response response = await put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseDecode = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseDecode,
        );
      } else if (response.statusCode == 401) {
        await _logOut();
        return NetworkResponse(statusCode: response.statusCode, isSuccess: false);
      } else {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: jsonDecode(response.body),
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// DELETE request
  static Future<NetworkResponse> deleteRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      Map<String, String> headers = {
        "Content-Type": "application/json",
      };
      if (AuthController.accessToken != null &&
          AuthController.accessToken!.isNotEmpty) {
        headers['Authorization'] = AuthController.accessToken!;
      }

      _logRequest(url, headers, requestBody: body);
      Response response = await delete(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseDecode = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseDecode,
        );
      } else if (response.statusCode == 401) {
        await _logOut();
        return NetworkResponse(statusCode: response.statusCode, isSuccess: false);
      } else {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: jsonDecode(response.body),
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// PUT Multipart request
  static Future<NetworkResponse> putMultipartRequest({
    required String url,
    required File file,
    String? fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final request = http.MultipartRequest('PUT', uri);

      // Token header
      request.headers['Accept'] = 'application/json';
      if (AuthController.accessToken != null &&
          AuthController.accessToken!.isNotEmpty) {
        request.headers['Authorization'] = AuthController.accessToken!;
      }

      // Attach image file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName!, file.path),
      );

      // Add optional fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      _logRequest(url, request.headers, requestBody: fields);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseDecode = jsonDecode(response.body);
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: responseDecode,
        );
      } else if (response.statusCode == 401) {
        await _logOut();
        return NetworkResponse(statusCode: response.statusCode, isSuccess: false);
      } else {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          responseData: jsonDecode(response.body),
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Logging request
  static void _logRequest(String url, Map<String, dynamic> headers,
      {Map<String, dynamic>? requestBody}) {
    _logger.i(
        "🌐 REQUEST\nURL: $url\nHeaders: $headers\nBody: ${jsonEncode(requestBody)}");
  }

  /// Logging response
  static void _logResponse(String url, Response response) {
    _logger.i(
        "📥 RESPONSE\nURL: $url\nStatus Code: ${response.statusCode}\nBody: ${response.body}");
  }

  /// Logout and navigate to login
  static Future<void> _logOut() async {
    *//*await AuthController.dataClear();
    Get.offAll( LoginView());*//*

  }
}*/

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

import '../services_class/data_helper.dart'; // Assuming AuthController is here

class NetworkResponse {
  final int statusCode;
  final Map<String, dynamic>? responseData;
  final String? errorMessage;
  final bool isSuccess;

  NetworkResponse({
    required this.statusCode,
    this.responseData,
    this.errorMessage = "Request failed!",
    required this.isSuccess,
  });
}

class NetworkCall {
  static final Logger _logger = Logger();

  // Singleton Dio instance for reuse and configuration
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));

  // Initialize Dio with interceptor for logging and token
  static void _setupInterceptors() {
    _dio.interceptors.clear(); // Avoid duplicates if called multiple times
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add Authorization header if token exists
        if (AuthController.accessToken != null &&
            AuthController.accessToken!.isNotEmpty) {
          options.headers['Authorization'] = AuthController.accessToken!;
        }

        // Log request
        _logger.i(
          "🌐 REQUEST\n"
              "Method: ${options.method}\n"
              "URL: ${options.uri}\n"
              "Headers: ${options.headers}\n"
              "Body/Data: ${options.data}",
        );

        handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response
        _logger.i(
          "📥 RESPONSE\n"
              "URL: ${response.realUri}\n"
              "Status Code: ${response.statusCode}\n"
              "Body: ${response.data}",
        );

        handler.next(response);
      },
      onError: (DioException err, handler) {
        _logger.e(
          "❌ ERROR\n"
              "URL: ${err.requestOptions.uri}\n"
              "Status: ${err.response?.statusCode}\n"
              "Message: ${err.message}\n"
              "Response: ${err.response?.data}",
        );

        handler.next(err);
      },
    ));
  }

  // Call this once in your app startup (e.g., main.dart)
  static void initialize() {
    _setupInterceptors();
  }

  // Generic request handler
  static Future<NetworkResponse> _handleRequest(Future<Response> request) async {
    try {
      final response = await request;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          statusCode: response.statusCode!,
          isSuccess: true,
          responseData: response.data is String
              ? jsonDecode(response.data)
              : response.data,
        );
      } else if (response.statusCode == 401) {
        await _logOut();
        return NetworkResponse(statusCode: 401, isSuccess: false);
      } else {
        return NetworkResponse(
          statusCode: response.statusCode!,
          isSuccess: false,
          responseData: response.data is String
              ? jsonDecode(response.data)
              : response.data,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _logOut();
      }

      return NetworkResponse(
        statusCode: e.response?.statusCode ?? -1,
        isSuccess: false,
        errorMessage: e.message ?? e.toString(),
        responseData: e.response?.data,
      );
    } catch (e) {
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // POST request
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _handleRequest(
      _dio.post(url, data: body),
    );
  }

  // PATCH request
  static Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _handleRequest(
      _dio.patch(url, data: body),
    );
  }

  // GET request
  static Future<NetworkResponse> getRequest({
    required String url,
    Map<String, dynamic>? queryParams,
  }) async {
    return _handleRequest(
      _dio.get(url, queryParameters: queryParams),
    );
  }

  // PUT request
  static Future<NetworkResponse> putRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _handleRequest(
      _dio.put(url, data: body),
    );
  }

  // DELETE request
  static Future<NetworkResponse> deleteRequest({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _handleRequest(
      _dio.delete(url, data: body),
    );
  }

  // Multipart POST/PUT/PATCH (supports image, video, fields)
  static Future<NetworkResponse> multipartRequest({
    required String url,
    Map<String, String>? fields,
    Map<String, dynamic>? body,
    File? imageFile,
    File? videoFile,
    required String methodType, // 'POST', 'PUT', 'PATCH'
  }) async {
    final formData = FormData();

    // Add regular fields
    if (fields != null) {
      formData.fields.addAll(fields.entries.map((e) => MapEntry(e.key, e.value)));
    }

    // Add JSON body fields if needed
    if (body != null) {
      body.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    // Attach image
    if (imageFile != null) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      ));
    }

    // Attach video
    if (videoFile != null) {
      formData.files.add(MapEntry(
        'video',
        await MultipartFile.fromFile(
          videoFile.path,
          filename: videoFile.path.split('/').last,
          contentType: MediaType('video', 'mp4'),
        ),
      ));
    }

    return _handleRequest(
      _dio.request(
        url,
        data: formData,
        options: Options(method: methodType),
      ),
    );
  }

  // Dedicated PUT Multipart (e.g., for file upload only)
  static Future<NetworkResponse> putMultipartRequest({
    required String url,
    required File file,
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    final formData = FormData();

    if (fields != null) {
      formData.fields.addAll(fields.entries.map((e) => MapEntry(e.key, e.value)));
    }

    formData.files.add(MapEntry(
      fieldName,
      await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    ));

    return _handleRequest(
      _dio.put(url, data: formData),
    );
  }

  /// Logout logic
  static Future<void> _logOut() async {
    /*await AuthController.dataClear();
    Get.offAll(const LoginView());*/
  }
}
