import 'package:aiot_final_project_fontend/api/base/http_methods.dart';
import 'package:aiot_final_project_fontend/api/base/i_api_typed_method.dart';
import 'package:aiot_final_project_fontend/api/tts_api/response_data/generate_pcm_response.dart';
import 'package:aiot_final_project_fontend/api/tts_api/tts_api_connector.dart';
import 'package:dio/dio.dart';

class GeneratePcm extends IApiTypedMethod<GeneratePcmResponse>{
  @override
  IHttpMethod getMethod() {
   return HttpMethodPost(TtsApiConnector());
  }

  @override
  String name() {
    return "/commands/generate-tts";
  }

  @override
  GeneratePcmResponse transformer(Response<dynamic> response) {
    return GeneratePcmResponse.fromJson(response.data);
  }

  @override
  bool isNeedToPrintLog() {
    return true;
  }
}