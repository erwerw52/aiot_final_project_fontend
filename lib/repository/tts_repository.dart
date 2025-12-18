import 'package:aiot_final_project_fontend/api/tts_api/request_data/tts_request.dart';
import 'package:aiot_final_project_fontend/api/tts_api/response_data/tts_response.dart';
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


  Future<TtsResponse> getTtsWav({required String text}) async {
    return TtsApiService.instance.getTtsWav
        .data(params: TtsRequest(text: text, voice: VoiceType.female).toJson())
        .onError((response) => _parseError(response))
        .callAndTransform();
  }

  /// [私有函式] 統一處理 TTS API 的錯誤。
  void _parseError(Response<dynamic> response) {
    try {
      String errorMessage = '';

      // 處理不同類型的響應數據
      if (response.data is List<int>) {
        // Binary 數據，轉換為字符串
        errorMessage = String.fromCharCodes(response.data as List<int>);
      } else if (response.data is Map) {
        // JSON 數據，檢查是否包含結構化錯誤信息
        Map<String, dynamic> errorData = response.data as Map<String, dynamic>;

        // 檢查是否是 TTS 相關的錯誤
        if (errorData.containsKey('detail')) {
          String detail = errorData['detail']?.toString() ?? '';
          if (detail.contains('TTS generation failed')) {
            // 提取嵌套的錯誤信息
            if (detail.contains('403')) {
              errorMessage = 'TTS 服務驗證失敗，請檢查 API 金鑰設定';
            } else if (detail.contains('Invalid response status')) {
              errorMessage = 'TTS 服務回應異常，請稍後再試';
            } else if (detail.contains('Invalid voice')) {
              errorMessage = 'TTS 語音參數錯誤，請檢查 voice 設定';
            } else {
              errorMessage = 'TTS 生成失敗：$detail';
            }
          } else {
            errorMessage = detail;
          }
        } else if (errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        } else {
          errorMessage = errorData.toString();
        }
      } else {
        // 其他類型
        errorMessage = response.data?.toString() ?? 'Unknown error';
      }

      // 檢查是否是 ngrok 離線錯誤
      if (errorMessage.contains('ERR_NGROK_3200') || errorMessage.contains('is offline')) {
        Log.get().shout('TTS API Error: Server is currently offline (ngrok tunnel expired)');
        throw Exception('TTS 服務目前離線，請重新啟動服務器');
      }

      Log.get().shout(
        'TTS API Error: ${response.statusCode} ${response.statusMessage}',
      );
      Log.get().shout('Response data: $errorMessage');

      throw Exception(
        'TTS API Error: ${response.statusCode} ${response.statusMessage}',
      );
    } catch (e) {
      Log.get().shout('Error parsing response: ${e.toString()}');
      rethrow;
    }
  }
}
