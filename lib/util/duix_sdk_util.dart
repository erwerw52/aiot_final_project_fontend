import 'package:flutter/services.dart';

class DuixSdkUtil {
  // 單例實例
  static final DuixSdkUtil _instance = DuixSdkUtil._internal();

  // MethodChannel
  static const MethodChannel _channel = MethodChannel('com.example.duix_sdk');

  // 回調函數
  Function(String event, String message, dynamic info)? _eventCallback;
  Function(String url, int current, int total, bool isUnzip)? _downloadProgressCallback;

  // 私有構造函數
  DuixSdkUtil._internal() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  // 獲取單例實例
  factory DuixSdkUtil() {
    return _instance;
  }

  // 統一處理來自原生端的方法調用
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onEvent':
        if (_eventCallback != null) {
          final String event = call.arguments['event'] ?? '';
          final String message = call.arguments['message'] ?? '';
          final dynamic info = call.arguments['info'];
          _eventCallback!(event, message, info);
        }
        break;
      case 'onDownloadProgress':
        if (_downloadProgressCallback != null) {
          final String url = call.arguments['url'] ?? '';
          final int current = call.arguments['current'] ?? 0;
          final int total = call.arguments['total'] ?? 0;
          final bool isUnzip = call.arguments['isUnzip'] ?? false;
          _downloadProgressCallback!(url, current, total, isUnzip);
        }
        break;
    }
  }

  // 初始化 SDK
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod('initialize');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to initialize DUIX SDK: ${e.message}');
      return false;
    }
  }

  // 檢查基礎配置是否已下載
  Future<bool> checkBaseConfig() async {
    try {
      final result = await _channel.invokeMethod('checkBaseConfig');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to check base config: ${e.message}');
      return false;
    }
  }

  // 檢查模型是否已下載
  Future<bool> checkModel(String modelName) async {
    try {
      final result = await _channel.invokeMethod('checkModel', {
        'modelName': modelName,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to check model: ${e.message}');
      return false;
    }
  }

  // 下載並解壓縮 base config
  Future<bool> downloadBaseConfig(String customUrl) async {
    try {
      final result = await _channel.invokeMethod('downloadBaseConfig', {
        'url': customUrl,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to download base config: ${e.message}');
      return false;
    }
  }

  // 下載並解壓縮模型
  Future<bool> downloadModel(String modelUrl) async {
    try {
      final result = await _channel.invokeMethod('downloadModel', {
        'modelUrl': modelUrl,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to download model: ${e.message}');
      return false;
    }
  }

  // 初始化模型
  Future<bool> initModel(String modelName) async {
    try {
      final result = await _channel.invokeMethod('initModel', {
        'modelName': modelName,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to initialize model: ${e.message}');
      return false;
    }
  }

  // 檢查模型是否準備就緒
  Future<bool> isModelReady() async {
    try {
      final result = await _channel.invokeMethod('isModelReady');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to check model ready status: ${e.message}');
      return false;
    }
  }

  // 開始推 PCM 串流
  Future<bool> startPush() async {
    try {
      final result = await _channel.invokeMethod('startPush');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to start push: ${e.message}');
      return false;
    }
  }

  // 推 PCM 數據
  Future<bool> pushPcm(Uint8List pcmData) async {
    try {
      final result = await _channel.invokeMethod('pushPcm', {
        'pcmData': pcmData,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to push PCM data: ${e.message}');
      return false;
    }
  }

  // 停止推 PCM 串流
  Future<bool> stopPush() async {
    try {
      final result = await _channel.invokeMethod('stopPush');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to stop push: ${e.message}');
      return false;
    }
  }

  // 播放 WAV 檔案
  Future<bool> playWavFile(String wavFilePath) async {
    try {
      final result = await _channel.invokeMethod('playWavFile', {
        'wavFilePath': wavFilePath,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to play WAV file: ${e.message}');
      return false;
    }
  }

  // 停止播放音頻
  Future<bool> stopAudio() async {
    try {
      final result = await _channel.invokeMethod('stopAudio');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to stop audio: ${e.message}');
      return false;
    }
  }

  // 設置音量
  Future<bool> setVolume(double volume) async {
    try {
      final result = await _channel.invokeMethod('setVolume', {
        'volume': volume,
      });
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to set volume: ${e.message}');
      return false;
    }
  }

  // 釋放資源
  Future<bool> release() async {
    try {
      final result = await _channel.invokeMethod('release');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to release DUIX SDK: ${e.message}');
      return false;
    }
  }

  // 設置事件回調
  void setEventCallback(Function(String event, String message, dynamic info)? callback) {
    _eventCallback = callback;
  }

  // 設置下載進度回調
  void setDownloadProgressCallback(Function(String url, int current, int total, bool isUnzip)? callback) {
    _downloadProgressCallback = callback;
  }

  // 清除所有回調
  void clearCallbacks() {
    _eventCallback = null;
    _downloadProgressCallback = null;
  }
}