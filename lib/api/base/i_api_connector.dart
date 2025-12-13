import 'dart:convert';
import 'dart:io';

import 'package:aiot_final_project_fontend/api/base/i_api_method.dart';
import 'package:aiot_final_project_fontend/utils/debug/log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

/// Mark: 使用 Isolate.run()，在 iOS 會產生 "Too many open files" 的錯誤，
/// Android 尚未發現，有可能是時間因素，不同平台的 open files limit 不同。
/// [post] 以及 [get] 暫時移除 Isolate.run() 用法，
/// 之後再思考比較好的 Isolate 使用方式。 (一個 connector 一個 Isolate)
abstract class IApiConnector {
  final String eventStreamAcceptType = "text/event-stream";
  Dio? _apiDio;
  Dio? _apiPrintDio;

  String getHost();

  String getDomain();

  Duration getConnectTimeout();

  Duration getReceiveTimeout();

  static final InterceptorsWrapper _handleErrorIntercept =
      InterceptorsWrapper(onError: _handleError);

  static final InterceptorsWrapper _printLogIntercept =
      InterceptorsWrapper(onRequest: _printRequest, onResponse: _printResponse);

  static String _tryToParseMap(dynamic input) {
    if (input is Map) {
      return jsonEncode(input);
    } else {
      return input.toString();
    }
  }

  Future<Response> post(IApiMethod apiMethod) async {
    String api = _fixApiUrl(apiMethod.getUrl());
    Dio dio = await _getDio(apiMethod);
    return dio.post(api,
        data: apiMethod.getData(), queryParameters: apiMethod.getParams());
  }

  Future<Response> get(IApiMethod apiMethod, {Dio? dio}) async {
    String api = _fixApiUrl(apiMethod.getUrl());
    Dio dio = await _getDio(apiMethod);
    return dio.get(api,
        data: apiMethod.getData(), queryParameters: apiMethod.getParams());
  }

  void printRequest(IApiMethod apiMethod) {
    if (apiMethod.isNeedToPrintLog()) {}
  }

  void printResponse(IApiMethod apiMethod) {}

  String _fixApiUrl(String api) {
    if (api.startsWith("/")) {
      api = api.substring(1);
    }
    return api;
  }

  Future<Dio> _getDio(IApiMethod apiMethod) async {
    Dio dio;
    if ((!apiMethod.isNeedToPrintLog() && _apiDio == null) ||
        (apiMethod.isNeedToPrintLog() && _apiPrintDio == null)) {
      BaseOptions options = BaseOptions(
          baseUrl: getHost() + getDomain(),
          headers: {},
          connectTimeout: getConnectTimeout(),
          receiveTimeout: getReceiveTimeout(),
          contentType: Headers.jsonContentType);

      dio = Dio(options);
      dio.interceptors.add(_handleErrorIntercept);
      dio.options.headers[HttpHeaders.contentTypeHeader] =
          Headers.jsonContentType;
      if (apiMethod.isNeedToPrintLog()) {
        dio.interceptors.add(_printLogIntercept);
        _apiPrintDio = dio;
      } else {
        _apiDio = dio;
      }
    } else {
      if (apiMethod.isNeedToPrintLog()) {
        dio = _apiPrintDio!;
      } else {
        dio = _apiDio!;
      }
    }
    await setDio(dio, apiMethod);
    return dio;
  }

  Future<void> setDio(Dio dio, IApiMethod apiMethod);

  static void _printRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    // Do something before request is sent
    Log.get().info("onRequest\n"
        "url: ${options.uri}\n"
        "headers: ${_tryToParseMap(options.headers)}\n"
        "body: ${_tryToParseMap(options.data)}");
    handler.next(options);
  }

  static void _printResponse(
      Response response, ResponseInterceptorHandler handler) async {
    Log.get().info("onResponse\n"
        "url: ${response.realUri}\n"
        "response: ${_tryToParseMap(response.data)}");
    // Do something with response data
    handler.next(response);
  }

  static void _handleError(
      DioException e, ErrorInterceptorHandler handler) async {
    String errorMsg = '';
    if (e.response != null) {
      errorMsg = '${e.response!.data}';
    } else {
      errorMsg = '${e.message}';
    }
    String errInfo = '''
    onError
    url: ${e.requestOptions.baseUrl}${e.requestOptions.path}
    type: ${e.type}
    error: $errorMsg
    ''';
    debugPrintStack(stackTrace: e.stackTrace, label: errInfo);

    bool isSolveError = false;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        Map<String, dynamic> data = {};
        data['statusCode'] = -1;
        data['errorCode'] = '';
        data['message'] = e.type.toString();
        var handledResponse = Response(
            requestOptions: RequestOptions(), data: data, statusCode: -1);
        e.response?.data = data;
        Log.get().severe('Timeout');

        handler.resolve(handledResponse);
        isSolveError = true;
        break;
      case DioExceptionType.badResponse:
        if (e.response != null) {
          // memo: error message will in there.
          if (e.response?.data is! Map) {
            Map<String, dynamic> data = {};
            data['statusCode'] = e.response?.statusCode;
            data['errorCode'] = '';
            data['message'] = e.response?.data;
            e.response?.data = data;
          }
          handler.resolve(e.response!);
          isSolveError = true;
        }
        break;
      case DioExceptionType.cancel:
        // memo: 主動取消，不做處理
        isSolveError = true;
        break;
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        Map<String, dynamic> data = {};
        data['statusCode'] = -1;
        data['errorCode'] = '';
        data['message'] = e.type.toString();
        var handledResponse = Response(
            requestOptions: RequestOptions(), data: data, statusCode: -1);
        e.response?.data = data;
        Log.get().severe('Access Restricted');
        handler.resolve(handledResponse);
        isSolveError = true;
        break;
    }

    if (!isSolveError) {
      handler.next(e);
      // Do something with response error
    }
  }
}

