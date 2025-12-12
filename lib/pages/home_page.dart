import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/duix_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DuixService _service = DuixService();
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    
    // 訂閱事件
    _eventSubscription = _service.eventStream.listen((event) {
      final type = event['type'] as String?;
      
      switch (type) {
        case 'play_start':
          setState(() => _isPlaying = true);
          break;
        case 'play_end':
          setState(() => _isPlaying = false);
          break;
        case 'play_error':
          setState(() => _isPlaying = false);
          _showSnackBar('播放錯誤: ${event["error"]}', Colors.red);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            if (_isPlaying)
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
    super.dispose();
  }
}