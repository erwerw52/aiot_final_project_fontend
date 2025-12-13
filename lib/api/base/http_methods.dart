import 'package:aiot_final_project_fontend/api/base/i_api_connector.dart';
import 'package:aiot_final_project_fontend/api/base/i_api_method.dart';
import 'package:dio/dio.dart';

abstract class IHttpMethod {
  String get methodName;
}

abstract class DioHttpMethod extends IHttpMethod {
  late IApiConnector _apiConnector;

  DioHttpMethod(IApiConnector apiConnector) {
    _apiConnector = apiConnector;
  }

  Future<Response<dynamic>> getResponse(IApiMethod apiMethod);
}

class HttpMethodPost extends DioHttpMethod {
  HttpMethodPost(super.apiConnector);

  @override
  Future<Response<dynamic>> getResponse(IApiMethod apiMethod) async {
    return await _apiConnector.post(apiMethod);
  }

  @override
  String get methodName => "POST";
}

class HttpMethodGet extends DioHttpMethod {
  HttpMethodGet(super.apiConnector);

  @override
  Future<Response<dynamic>> getResponse(IApiMethod apiMethod) async {
    return await _apiConnector.get(apiMethod);
  }

  @override
  String get methodName => "GET";
}

