import 'package:aiot_final_project_fontend/api/base/i_api_connector.dart';
import 'package:aiot_final_project_fontend/api/base/i_api_method.dart';
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
  String getHost() => "";

  @override
  Duration getReceiveTimeout() => Duration(milliseconds: 5555);

  @override
  Future<void> setDio(Dio dio, IApiMethod apiMethod) async {
  }

}