import 'dart:async';

import 'package:aiot_final_project_fontend/api/base/http_methods.dart';
import 'package:dio/dio.dart';

abstract class IApiMethod {
  Object? _data;
  late IHttpMethod method;
  Map<String, dynamic>? _params;

  IApiMethod() {
    method = getMethod();
  }

  String name();

  IHttpMethod getMethod();

  bool isNeedToPrintLog() => false;

  bool get isNeedToken => true;

  /// request 的參數
  ///
  /// data - body 的內容
  ///
  /// params - url 串的資料
  IApiMethod data({Map<String, dynamic>? data, Map<String, dynamic>? params}) {
    _data = data;
    _params = params;
    return this;
  }

  /// request 的參數
  ///
  /// data - body 的內容
  ///
  /// params - url 串的資料
  IApiMethod objectData({Object? data, Map<String, dynamic>? params}) {
    _data = data;
    _params = params;
    return this;
  }

  Object? getData() {
    return _data;
  }

  Map<String, dynamic>? getParams() {
    return _params;
  }

  String getUrl() {
    return "/${name()}";
  }

  String getMethodName(IApiMethod apiMethod) {
    return method.methodName;
  }

  Future<Response> call({bool isRecall = false}) async {
    if (method is DioHttpMethod) {
      Response<dynamic> response =
          await (method as DioHttpMethod).getResponse(this);
      return response;
    } else {
      throw Exception("This is not Dio Http Method!!!");
    }
  }
}

