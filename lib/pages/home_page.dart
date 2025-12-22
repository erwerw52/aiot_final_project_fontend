import 'dart:convert';
import 'package:aiot_final_project_fontend/api/tts_api/response_data/tts_response.dart';
import 'package:aiot_final_project_fontend/gen/assets.gen.dart';
import 'package:aiot_final_project_fontend/providers/chat_input_provider.dart';
import 'package:aiot_final_project_fontend/providers/duix_provider.dart';
import 'package:aiot_final_project_fontend/providers/speech_provider.dart';
import 'package:aiot_final_project_fontend/repository/tts_repository.dart';
import 'package:aiot_final_project_fontend/utils/debug/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  Timer? _subtitleTimer;
  List<TimeLineDto> _currentTimeLines = [];
  DateTime? _playStartTime;
  int _lastProcessedTimelineIndex = -1;
  String _originalText = ''; // 儲存完整的原始文字(包含標點)
  int _originalTextPos = 0; // 當前處理到 originalText 的位置

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
    // 背景執行中，關掉語音
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
    // 監聽語音辨識結果，並同步到輸入框
    ref.listen(speechRecognitionProvider, (previous, next) {
      if (next.recognizedText.isNotEmpty &&
          next.recognizedText != previous?.recognizedText) {
        ref.read(chatInputProvider.notifier).setText(next.recognizedText);
        _textController.text = next.recognizedText;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Container(color: Color(0xFF7461a3)),
            // 數字人視圖
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 70, 0, 90),
              child: const AndroidView(
                viewType: 'duix_platform_view',
                layoutDirection: TextDirection.ltr,
                creationParamsCodec: StandardMessageCodec(),
              ),
            ),

            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Plan your next trip with AiTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.0,
                  ),
                ),
              ),
            ),

            // 字幕顯示區域
            Positioned(
              bottom: 110,
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
            Consumer(
              builder: (context, ref, widget) {
                final chatInputText = ref.watch(chatInputProvider);
                final speechState = ref.watch(speechRecognitionProvider);
                final isLoading = ref.watch(isNeedLoadingProvider);

                return Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Assets.images.icon.loadingIcon.image(
                              height: 65,
                              width: 65
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Just a few moments...',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // 文字輸入框
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  onChanged: (value) => ref
                                      .read(chatInputProvider.notifier)
                                      .setText(value),
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    hintText: speechState.isListening
                                        ? 'Listening...'
                                        : 'Ask me anything...',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 分隔線
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                              const SizedBox(width: 8),
                              // 功能按鈕
                              GestureDetector(
                                onTap: () async {
                                  // 如果有文字，直接走發送流程
                                  if (chatInputText.isNotEmpty) {
                                    final textToSend = chatInputText;

                                    // 清空輸入框
                                    ref
                                        .read(chatInputProvider.notifier)
                                        .clearText();
                                    _textController.clear();

                                    // 隱藏鍵盤
                                    FocusScope.of(context).unfocus();

                                    final ByteData byteData = await rootBundle
                                        .load(Assets.wav.hearRequest);
                                    final Uint8List bytes = byteData.buffer
                                        .asUint8List();
                                    await ref
                                        .read(duixServiceProvider)
                                        .playAudioBytes(bytes);

                                    ref.read(isNeedLoadingProvider.notifier).setLoading(true);

                                    try {
                                      var response = await ref
                                          .read(ttsRepositoryProvider)
                                          .getTtsWav(text: textToSend);

                                      ref.read(isNeedLoadingProvider.notifier).setLoading(false);

                                      _currentTimeLines = response.timeLines;

                                      await ref
                                          .read(duixServiceProvider)
                                          .playAudioBytes(
                                            base64Decode(response.audioData),
                                          );

                                      _handlePlayStart(response);
                                    } catch (e) {
                                      print(e.toString());
                                    }

                                    return;
                                  }

                                  // 如果沒文字，處理語音辨識啟動/停止
                                  if (speechState.isListening) {
                                    // 停止並等待最後結果
                                    await ref
                                        .read(
                                          speechRecognitionProvider.notifier,
                                        )
                                        .stopListening();

                                    final recognized = ref
                                        .read(speechRecognitionProvider)
                                        .recognizedText;

                                    if (recognized.isEmpty) {
                                      _showSnackBar('未識別到任何內容', Colors.orange);
                                      return;
                                    }
                                  } else {
                                    ref
                                        .read(
                                          speechRecognitionProvider.notifier,
                                        )
                                        .startListening();
                                    // 隱藏鍵盤
                                    FocusScope.of(context).unfocus();
                                    return;
                                  }
                                },
                                child: Icon(
                                  chatInputText.isNotEmpty
                                      ? Icons.send_rounded
                                      : (speechState.isListening
                                            ? Icons.stop_rounded
                                            : Icons.mic_rounded),
                                  color: chatInputText.isNotEmpty
                                      ? Color(0xFF7461a3)
                                      : (speechState.isListening)
                                      ? Colors.red
                                      : Color(0xFF7461a3),
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
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

  void _handlePlayStart(TtsResponse response) {
    ref.read(isPlayingProvider.notifier).startPlaying();
    _playStartTime = DateTime.now();
    _lastProcessedTimelineIndex = -1;
    ref.read(digitalHumanTalkTextProvider.notifier).setText('');

    // 保存原始文字用於標點處理
    _originalText = response.originalText;
    _originalTextPos = 0; // 從頭開始順序遍歷

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

      // 檢查是否已超過所有時間軸 + 3 秒
      if (_currentTimeLines.isNotEmpty) {
        final lastTimeline = _currentTimeLines.last;
        if (elapsed > lastTimeline.end + 3.0) {
          _handlePlayStop(); // 自動停止
          return;
        }
      }

      // 找到當前時間對應的 timeline
      for (int i = 0; i < _currentTimeLines.length; i++) {
        final timeline = _currentTimeLines[i];
        if (elapsed >= timeline.start && elapsed <= timeline.end) {
          // 如果是新的 timeline（還沒處理過）
          if (i > _lastProcessedTimelineIndex) {
            _lastProcessedTimelineIndex = i;
            final currentSubtitle = ref.read(digitalHumanTalkTextProvider);
            final timelineText = timeline.text;

            String textToAppend = timelineText;
            // 包含中文和英文所有標點符號
            const punctuations =
                '。，、；：！？""'
                '《》「」【】（）…—,.;:!?\'"()[]{}~`';

            // 從當前位置順序匹配
            int matchStart = _originalTextPos;
            int matchedChars = 0;

            // 跳過開頭的標點符號
            while (matchStart < _originalText.length &&
                punctuations.contains(_originalText[matchStart])) {
              matchStart++;
            }

            // 逐字匹配 timeline.text
            int currentPos = matchStart;
            for (int j = 0; j < timelineText.length; j++) {
              // 跳過中間的標點
              while (currentPos < _originalText.length &&
                  punctuations.contains(_originalText[currentPos])) {
                currentPos++;
              }

              // 匹配當前字符
              if (currentPos < _originalText.length &&
                  _originalText[currentPos] == timelineText[j]) {
                matchedChars++;
                currentPos++;
              } else {
                // 不匹配就中斷
                break;
              }
            }

            // 檢查是否完全匹配
            if (matchedChars == timelineText.length) {
              // 追加所有連續的標點符號
              while (currentPos < _originalText.length &&
                  punctuations.contains(_originalText[currentPos])) {
                textToAppend += _originalText[currentPos];
                currentPos++;
              }

              // 更新全局位置指針
              _originalTextPos = currentPos;
            } else {
              // 匹配失敗,記錄詳細信息
              final previewStart = _originalTextPos.clamp(
                0,
                _originalText.length,
              );
              final previewEnd = (_originalTextPos + 20).clamp(
                0,
                _originalText.length,
              );
              final preview = _originalText.substring(previewStart, previewEnd);
              Log.get().warning(
                '⚠️ 字幕匹配失敗 at pos $_originalTextPos: timeline="$timelineText", matched=$matchedChars/${timelineText.length}',
              );
              Log.get().warning('   原文預覽(pos $_originalTextPos 起): "$preview"');
              if (currentPos < _originalText.length) {
                Log.get().warning(
                  '   當前字符: "${_originalText[currentPos]}" vs 期望: "${timelineText[matchedChars]}"',
                );
              }
            }

            // 檢查長度並更新字幕
            final combinedText = currentSubtitle + textToAppend;
            if (combinedText.length > 30) {
              ref
                  .read(digitalHumanTalkTextProvider.notifier)
                  .setText(textToAppend);
            } else {
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

    // 清理標點處理相關變數
    _originalText = '';
    _originalTextPos = 0;

    // 播放結束時清除字幕
    ref.read(digitalHumanTalkTextProvider.notifier).setText('');
  }

  @override
  void dispose() {
    _textController.dispose();
    _stopSubtitleTimer();
    ref.read(speechRecognitionProvider.notifier).cancelListening();
    super.dispose();
  }
}
