import 'package:aiot_final_project_fontend/api/base/i_api_connector.dart';
import 'package:aiot_final_project_fontend/api/base/i_api_method.dart';
import 'package:aiot_final_project_fontend/api/tts_api/method/get_tts_pcm.dart';
import 'package:aiot_final_project_fontend/api/tts_api/method/get_tts_wav.dart';
import 'package:dio/dio.dart';

class TtsApiConnector extends IApiConnector {
  factory TtsApiConnector() => _instance ?? TtsApiConnector._internal();

  static TtsApiConnector? _instance;

  TtsApiConnector._internal(){
    _instance = this;
  }

  @override
  Duration getConnectTimeout() => Duration(milliseconds: 5555);

  @override
  String getDomain() => "";

  @override
  String getHost() => "https://aiot-backend.zeabur.app";

  @override
  Duration getReceiveTimeout() => Duration(milliseconds: 5555);

  @override
  Future<void> setDio(Dio dio, IApiMethod apiMethod) async {
    // 對於返回 binary 數據的 API，需要設置 responseType
    if (apiMethod is GetTtsPcm || apiMethod is GetTtsWav) {
      dio.options.responseType = ResponseType.bytes;
    }
  }

}