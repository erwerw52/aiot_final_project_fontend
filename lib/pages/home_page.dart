import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/duix_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    // 訂閱事件
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final duixService = ref.read(duixServiceProvider);
      _eventSubscription = duixService.eventStream.listen((event) {
        final type = event['type'] as String?;

        switch (type) {
          case 'play_start':
            ref.read(homeStateProvider.notifier).startPlaying();
            break;
          case 'play_end':
            ref.read(homeStateProvider.notifier).stopPlaying();
            break;
          case 'play_error':
            ref.read(homeStateProvider.notifier).stopPlaying();
            _showSnackBar('播放錯誤: ${event["error"]}', Colors.red);
            break;
        }
      });

      // 初始化語音識別
      final speechAvailable = await ref.read(speechRecognitionProvider.notifier).initialize();
      if (!speechAvailable) {
        _showSnackBar('語音識別功能不可用', Colors.orange);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeStateProvider);
    final speechState = ref.watch(speechRecognitionProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 數字人視圖
            const AndroidView(
              viewType: 'duix_platform_view',
              layoutDirection: TextDirection.ltr,
              creationParamsCodec: StandardMessageCodec(),
            ),

            // 播放狀態指示器
            if (homeState.isPlaying)
              const Positioned(
                top: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up, size: 16),
                        SizedBox(width: 4),
                        Text('播放中'),
                      ],
                    ),
                  ),
                ),
              ),

            // 字幕顯示區域
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        speechState.recognizedText.isEmpty ? '數字人就緒，請開始規劃您的旅遊行程' : speechState.recognizedText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 語音識別控制按鈕
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  if (speechState.isListening) {
                    ref.read(speechRecognitionProvider.notifier).stopListening();
                  } else {
                    ref.read(speechRecognitionProvider.notifier).startListening();
                  }
                },
                backgroundColor: speechState.isListening ? Colors.red : Colors.blue,
                child: Icon(
                  speechState.isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
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

  @override
  void dispose() {
    _eventSubscription?.cancel();
    ref.read(speechRecognitionProvider.notifier).cancelListening();
    super.dispose();
  }
}