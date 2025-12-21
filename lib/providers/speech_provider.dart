import 'package:aiot_final_project_fontend/utils/debug/log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_to_text.dart';

part 'speech_provider.g.dart';

@riverpod
class SpeechRecognition extends _$SpeechRecognition {
  final SpeechToText _speechToText = SpeechToText();

  @override
  SpeechState build() {
    return const SpeechState(
      isListening: false,
      recognizedText: '',
      confidence: 0.0,
    );
  }

  Future<bool> initialize() async {
    final available = await _speechToText.initialize(
      onStatus: (status) {
        Log.get().info('[SpeechRecognition] onStatus $status at ${DateTime.now().toIso8601String()}');
        state = state.copyWith(isListening: status == 'listening');
      },
      onError: (error) {
        Log.get().warning('[SpeechRecognition] onError at ${DateTime.now().toIso8601String()} error: code=${error.errorMsg}, permanent=${error.permanent}');
        state = state.copyWith(isListening: false);
      },
    );

    if (available) {
      final locales = await _speechToText.locales();
      Log.get().info('可用的語言: ${locales.map((l) => l.localeId).take(10).join(", ")}');
    }
    
    return available;
  }

  void startListening() {
    if (!state.isListening) {
      // 清空舊的識別結果
      state = state.copyWith(recognizedText: '', confidence: 0.0);
      
      try {
        Log.get().info('[SpeechRecognition] startListening at ${DateTime.now().toIso8601String()}');
        _speechToText.listen(
          onResult: (result) {
            Log.get().info('onResult 觸發: text="${result.recognizedWords}", isFinal=${result.finalResult}, confidence=${result.confidence}');
            
            // 只要有內容就更新（不管是否為最終結果）
            if (result.recognizedWords.isNotEmpty) {
              state = state.copyWith(
                recognizedText: result.recognizedWords,
                confidence: result.confidence,
              );
            }
          },
          // 先嘗試不指定 locale，使用系統默認
          // localeId: 'zh-TW',
          listenOptions: SpeechListenOptions(
            listenMode: ListenMode.dictation,
            partialResults: true,
            onDevice: false,  // 使用雲端識別
            cancelOnError: true,
            autoPunctuation: true,
            enableHapticFeedback: true,
          ),
        );
      } catch (e) {
        Log.get().warning('startListening 錯誤: $e');
      }
    }
  }

  Future<void> stopListening() async {
    if (state.isListening) {
      Log.get().info('[SpeechRecognition] stopListening at ${DateTime.now().toIso8601String()}');
      await _speechToText.stop();
      // 等待最後的 onResult 回調
      await Future.delayed(const Duration(milliseconds: 300));
      Log.get().info('[SpeechRecognition] stopListening finished');
    }
  }

  void cancelListening() {
    _speechToText.cancel();
    state = state.copyWith(isListening: false);
  }
}

/// 數字人字幕
@riverpod
class DigitalHumanTalkText extends _$DigitalHumanTalkText {
  @override
   String build() {
    return '數位助理已就位!! 請說出您的旅遊地點與需求吧～';
  }

  void setText(String text){
    state = text;
  }
}

// 語音識別狀態數據類
class SpeechState {
  const SpeechState({
    required this.isListening,
    required this.recognizedText,
    required this.confidence,
  });

  final bool isListening;
  final String recognizedText;
  final double confidence;

  SpeechState copyWith({
    bool? isListening,
    String? recognizedText,
    double? confidence,
  }) {
    return SpeechState(
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      confidence: confidence ?? this.confidence,
    );
  }
}