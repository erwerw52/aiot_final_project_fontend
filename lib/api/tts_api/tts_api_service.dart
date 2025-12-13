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

  //TODO 以下實作 API 方法

}