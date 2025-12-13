import 'package:aiot_final_project_fontend/api/base/i_api_method.dart';
import 'package:dio/dio.dart';

abstract class IApiTypedMethod<T> extends IApiMethod {
  Function(Response response)? _errorCallback;

  T transformer(Response<dynamic> response);

  T interceptor(T oldData) {
    return oldData;
  }

  Future<T> callAndTransform() async {
    var response = await call();
    var statusCode = response.statusCode ?? -1;
    if (statusCode > 299 || statusCode < 200) {
      if (_errorCallback != null) {
        _errorCallback!(response);
      } else {
        throw Exception("call api error: $statusCode ${response.data}");
      }
    }
    return interceptor(transformer(response));
  }

  IApiTypedMethod<T> onError(Function(Response response)? f) {
    _errorCallback = f;
    return this;
  }

  @override
  IApiTypedMethod<T> data(
      {Map<String, dynamic>? data, Map<String, dynamic>? params}) {
    super.data(data: data, params: params);
    return this;
  }

  @override
  IApiTypedMethod<T> objectData({Object? data, Map<String, dynamic>? params}) {
    super.objectData(data: data, params: params);
    return this;
  }
}

