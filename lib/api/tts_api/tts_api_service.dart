import 'package:aiot_final_project_fontend/api/tts_api/method/get_tts_wav.dart';

class TtsApiService {
  factory TtsApiService() => _instance ?? TtsApiService._internal();

  static TtsApiService get instance => _getInstance();
  static TtsApiService? _instance;

  TtsApiService._internal(){
    _instance = this;
  }

  static TtsApiService _getInstance(){
    _instance ??= TtsApiService._internal();
    return _instance!;
  }

  GetTtsWav get getTtsWav => GetTtsWav();
}