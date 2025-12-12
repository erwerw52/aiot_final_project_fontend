import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/duix_service.dart';

part 'duix_provider.g.dart';

// DuixService provider - 保持活躍避免重複創建
@Riverpod(keepAlive: true)
DuixService duixService(Ref ref) {
  return DuixService();
}

// 首頁狀態 provider
@riverpod
class HomeState extends _$HomeState {
  @override
  HomeStateData build() {
    return const HomeStateData(isPlaying: false);
  }

  void setPlaying(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }

  void startPlaying() {
    state = state.copyWith(isPlaying: true);
  }

  void stopPlaying() {
    state = state.copyWith(isPlaying: false);
  }
}

// 首頁狀態數據類
class HomeStateData {
  const HomeStateData({required this.isPlaying});

  final bool isPlaying;

  HomeStateData copyWith({bool? isPlaying}) {
    return HomeStateData(isPlaying: isPlaying ?? this.isPlaying);
  }
}

// 語音識別 provider
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