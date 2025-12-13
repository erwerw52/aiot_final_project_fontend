import 'package:aiot_final_project_fontend/api/tts_api/request_data/generate_pcm_request.dart';
import 'package:aiot_final_project_fontend/api/tts_api/response_data/generate_pcm_response.dart';
import 'package:aiot_final_project_fontend/api/tts_api/tts_api_service.dart';
import 'package:aiot_final_project_fontend/utils/debug/log.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_repository.g.dart';

@riverpod
TtsRepository ttsRepository(Ref ref) {
  return TtsRepository();
}

class TtsRepository {
  TtsRepository._internal();

  factory TtsRepository() => _instance ?? TtsRepository._internal();

  static TtsRepository? _instance;

  Future<GeneratePcmResponse> generatePcm({required String text}) async {
    return TtsApiService.instance.generatePcm
        .data(data: GeneratePcmRequest(
          text: text,
          voice: 'zh-TW-HsiaoChenNeural',
        ).toJson())
        .onError((response) => _parseError(response))
        .callAndTransform();
  }

  /// [私有函式] 統一處理 Gov API 的錯誤。
  void _parseError(Response<dynamic> response) {
    try {
      Log.get().shout(
        'Gov API Error: ${response.statusCode} ${response.statusMessage}',
      );
      Log.get().shout('Response data: ${response.data}');
      throw Exception(
        'Gov API Error: ${response.statusCode} ${response.statusMessage}',
      );
    } catch (e) {
      Log.get().shout(e.toString());
      rethrow;
    }
  }
}
