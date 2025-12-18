import 'package:aiot_final_project_fontend/api/base/http_methods.dart';
import 'package:aiot_final_project_fontend/api/base/i_api_typed_method.dart';
import 'package:aiot_final_project_fontend/api/tts_api/response_data/tts_response.dart';
import 'package:aiot_final_project_fontend/api/tts_api/tts_api_connector.dart';
import 'package:dio/dio.dart';

class GetTtsWav extends IApiTypedMethod<TtsResponse> {
  @override
  IHttpMethod getMethod() {
    return HttpMethodGet(TtsApiConnector());
  }

  @override
  String name() {
    return "/queries/get-tts-wav";
  }

  @override
  TtsResponse transformer(Response<dynamic> response) {
    return TtsResponse.fromJson(response.data);
  }

  @override
  bool isNeedToPrintLog() {
    return false;
  }
}