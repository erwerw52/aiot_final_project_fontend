import 'package:flutter/services.dart';
import 'dart:async';

class DuixService {
  static const MethodChannel _channel = MethodChannel('com.example.duix_sdk');
  static const EventChannel _eventChannel = EventChannel('com.example.duix_sdk/events');

  // EventChannel 事件流
  Stream<Map<String, dynamic>> get eventStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }

  // 初始化
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod('initialize');
      return result == true;
    } catch (e) {
      print('Initialize error: $e');
      return false;
    }
  }

  // 檢查基礎配置
  Future<bool> checkBaseConfig() async {
    try {
      final result = await _channel.invokeMethod('checkBaseConfig');
      return result == true;
    } catch (e) {
      print('Check base config error: $e');
      return false;
    }
  }

  // 檢查模型
  Future<bool> checkModel(String modelName) async {
    try {
      final result = await _channel.invokeMethod('checkModel', {
        'modelName': modelName,
      });
      return result == true;
    } catch (e) {
      print('Check model error: $e');
      return false;
    }
  }

  // 下載基礎配置
  Future<bool> downloadBaseConfig(String url) async {
    try {
      final result = await _channel.invokeMethod('downloadBaseConfig', {
        'url': url,
      });
      return result == true;
    } catch (e) {
      print('Download base config error: $e');
      return false;
    }
  }

  // 下載模型
  Future<bool> downloadModel(String modelUrl) async {
    try {
      final result = await _channel.invokeMethod('downloadModel', {
        'modelUrl': modelUrl,
      });
      return result == true;
    } catch (e) {
      print('Download model error: $e');
      return false;
    }
  }

  // 初始化數字人
  Future<bool> initModel(String modelName) async {
    try {
      final result = await _channel.invokeMethod('initModel', {
        'modelName': modelName,
      });
      return result == true;
    } catch (e) {
      print('Init model error: $e');
      return false;
    }
  }

  // 釋放資源
  Future<void> release() async {
    try {
      await _channel.invokeMethod('release');
    } catch (e) {
      print('Release error: $e');
    }
  }

  // 播放 WAV 文件
  Future<void> playWavFile(String wavFilePath) async {
    try {
      await _channel.invokeMethod('playWavFile', {
        'wavFilePath': wavFilePath,
      });
    } catch (e) {
      print('Play WAV file error: $e');
    }
  }

  // 播放音頻字節
  Future<void> playAudioBytes(List<int> audioBytes, {String fileName = 'temp.wav'}) async {
    try {
      await _channel.invokeMethod('playAudioBytes', {
        'audioBytes': Uint8List.fromList(audioBytes),
        'fileName': fileName,
      });
    } catch (e) {
      print('Play audio bytes error: $e');
    }
  }

  // 停止音頻
  Future<void> stopAudio() async {
    try {
      await _channel.invokeMethod('stopAudio');
    } catch (e) {
      print('Stop audio error: $e');
    }
  }

  // 檢查模型是否就緒
  Future<bool> isModelReady() async {
    try {
      final result = await _channel.invokeMethod('isModelReady');
      return result == true;
    } catch (e) {
      print('Is model ready error: $e');
      return false;
    }
  }

  // 設置音量
  Future<void> setVolume(double volume) async {
    try {
      await _channel.invokeMethod('setVolume', {
        'volume': volume,
      });
    } catch (e) {
      print('Set volume error: $e');
    }
  }

  // 開始推送
  Future<void> startPush() async {
    try {
      await _channel.invokeMethod('startPush');
    } catch (e) {
      print('Start push error: $e');
    }
  }

  // 推送 PCM 數據
  Future<void> pushPcm(List<int> pcmData) async {
    try {
      await _channel.invokeMethod('pushPcm', {
        'pcmData': Uint8List.fromList(pcmData),
      });
    } catch (e) {
      print('Push PCM error: $e');
    }
  }

  // 停止推送
  Future<void> stopPush() async {
    try {
      await _channel.invokeMethod('stopPush');
    } catch (e) {
      print('Stop push error: $e');
    }
  }
}
