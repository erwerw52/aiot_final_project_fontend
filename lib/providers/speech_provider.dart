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
        state = state.copyWith(isListening: status == 'listening');
      },
      onError: (error) {
        state = state.copyWith(isListening: false);
      },
    );
    return available;
  }

  void startListening() {
    if (!state.isListening) {
      _speechToText.listen(
        onResult: (result) {
          state = state.copyWith(
            recognizedText: result.recognizedWords,
            confidence: result.confidence,
          );
        },
        localeId: 'zh_TW',
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
        ),
      );
    }
  }

  void stopListening() {
    if (state.isListening) {
      _speechToText.stop();
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
    return '數位助理已就位!! 請開始規劃您的旅遊行程';
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