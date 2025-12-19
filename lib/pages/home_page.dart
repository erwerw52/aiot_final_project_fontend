import 'package:aiot_final_project_fontend/repository/tts_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/duix_provider.dart';
import '../providers/speech_provider.dart';
import '../api/tts_api/response_data/tts_response.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  Timer? _subtitleTimer;
  List<TimeLineDto> _currentTimeLines = [];
  DateTime? _playStartTime;
  int _lastProcessedTimelineIndex = -1;

  @override
  void initState() {
    super.initState();
    // 訂閱事件
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 初始化語音識別
      final speechAvailable = await ref
          .read(speechRecognitionProvider.notifier)
          .initialize();
      if (!speechAvailable) {
        _showSnackBar('語音識別功能不可用', Colors.orange);
      }
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 背景執行中，都要關掉語音
    if (state == AppLifecycleState.inactive) {
      bool isPlaying = ref.read(isPlayingProvider);
      print('測試測試 ::: $isPlaying');
      if (isPlaying) {
        ref.read(duixServiceProvider).stopAudio();
        _handlePlayStop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 數字人視圖
            const AndroidView(
              viewType: 'duix_platform_view',
              layoutDirection: TextDirection.ltr,
              creationParamsCodec: StandardMessageCodec(),
            ),

            // 字幕顯示區域
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Consumer(
                builder: (context, ref, child) {
                  final subtitle = ref.watch(digitalHumanTalkTextProvider);
                  if (subtitle.isEmpty) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 語音識別控制按鈕
            Positioned(
              bottom: 16,
              right: 150,
              child: FloatingActionButton(
                onPressed: () async {
                  /// 從 assets 拿到 wav 音頻數據
                  var response = await ref
                      .read(ttsRepositoryProvider)
                      .getTtsWav(text: '測試一下喔，我現在要準備產生超過 30 個字以上，請幫我再繼續測試其他功能');

                  _currentTimeLines = response.timeLines;

                  await ref
                      .read(duixServiceProvider)
                      .playAudioBytes(base64Decode(response.audioData));

                  _handlePlayStart();
                },
                backgroundColor: Colors.blue,
                child: Icon(Icons.fiber_manual_record, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePlayStart() {
    ref.read(isPlayingProvider.notifier).startPlaying();
    var isPlaying = ref.read(isPlayingProvider);
    print('測試測試 :: $isPlaying');
    _playStartTime = DateTime.now();
    _lastProcessedTimelineIndex = -1;
    ref.read(digitalHumanTalkTextProvider.notifier).setText('');
    _startSubtitleTimer();
  }

  void _handlePlayStop() {
    ref.read(isPlayingProvider.notifier).stopPlaying();
    _stopSubtitleTimer();
  }

  void _startSubtitleTimer() {
    _subtitleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_playStartTime == null) return;
      final elapsed =
          DateTime.now().difference(_playStartTime!).inMilliseconds / 1000.0;

      // 找到當前時間對應的 timeline
      for (int i = 0; i < _currentTimeLines.length; i++) {
        final timeline = _currentTimeLines[i];
        if (elapsed >= timeline.start && elapsed <= timeline.end) {
          // 如果是新的 timeline（還沒處理過）
          if (i > _lastProcessedTimelineIndex) {
            _lastProcessedTimelineIndex = i;
            final currentSubtitle = ref.read(digitalHumanTalkTextProvider);
            final newText = timeline.text;

            // 計算 append 後的長度
            final combinedText = currentSubtitle + newText;

            if (combinedText.length > 30) {
              // 超過 30 字，清空後使用新文字
              ref.read(digitalHumanTalkTextProvider.notifier).setText(newText);
            } else {
              // 沒超過，直接 append
              ref
                  .read(digitalHumanTalkTextProvider.notifier)
                  .setText(combinedText);
            }
          }
          break;
        }
      }
    });
  }

  void _stopSubtitleTimer() {
    _subtitleTimer?.cancel();
    _subtitleTimer = null;
    _playStartTime = null;
    _lastProcessedTimelineIndex = -1;
    _currentTimeLines = [];
    // 播放結束時清除字幕
    ref.read(digitalHumanTalkTextProvider.notifier).setText('');
  }

  @override
  void dispose() {
    _stopSubtitleTimer();
    ref.read(speechRecognitionProvider.notifier).cancelListening();
    super.dispose();
  }
}
