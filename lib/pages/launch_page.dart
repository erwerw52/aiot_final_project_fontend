import 'package:flutter/material.dart';
import 'dart:async';
import '../services/duix_service.dart';

enum LaunchStatus {
  initial,
  initializingSdk,
  downloadingBase,
  downloadingModel,
  initializingModel,
  completed,
  error,
}

class LaunchPage extends StatefulWidget {
  const LaunchPage({
    super.key,
    required this.modelUrl,
    required this.modelName,
    this.onCompleted,
  });

  final String modelUrl;
  final String modelName;
  final VoidCallback? onCompleted;

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  final DuixService _service = DuixService();
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;
  
  LaunchStatus _status = LaunchStatus.initial;
  double _progress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    // 立即訂閱 EventChannel
    _eventSubscription = _service.eventStream.listen((event) {
      final type = event['type'] as String?;
      print('收到事件: $type, 完整事件: $event');
      
      switch (type) {
        case 'download_progress':
          final category = event['category'] as String?;
          final current = event['current'] as int? ?? 0;
          final total = event['total'] as int? ?? 1;
          final progress = current / total;
          
          if (category == 'base_config') {
            setState(() {
              _status = LaunchStatus.downloadingBase;
              _progress = 0.1 + (progress * 0.2);
            });
          } else if (category == 'model') {
            setState(() {
              _status = LaunchStatus.downloadingModel;
              _progress = 0.4 + (progress * 0.3);
            });
          }
          break;
          
        case 'download_complete':
          final category = event['category'] as String?;
          if (category == 'base_config') {
            setState(() => _progress = 0.3);
          } else if (category == 'model') {
            setState(() => _progress = 0.7);
          }
          break;
          
        case 'download_fail':
          final error = event['error'] as String? ?? '下載失敗';
          setState(() {
            _status = LaunchStatus.error;
            _errorMessage = error;
          });
          break;
          
        case 'init_ready':
          print('模型初始化完成');
          setState(() {
            _status = LaunchStatus.completed;
            _progress = 1.0;
          });
          break;
          
        case 'init_error':
          final error = event['error'] as String? ?? '初始化失敗';
          print('模型初始化錯誤: $error');
          setState(() {
            _status = LaunchStatus.error;
            _errorMessage = error;
            _progress = 0.9;
          });
          break;
      }
    });
    
    // 開始初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInitialization();
    });
  }

  Future<void> _startInitialization() async {
    try {
      setState(() {
        _status = LaunchStatus.initializingSdk;
        _progress = 0.1;
      });

      // 1. 檢查基礎配置
      final hasBaseConfig = await _service.checkBaseConfig();
      if (!hasBaseConfig) {
        // 下載基礎配置
        setState(() => _status = LaunchStatus.downloadingBase);
        await _service.downloadBaseConfig(
          'https://public-model.obs.cn-north-4.myhuaweicloud.com/config.zip'
        );
      } else {
        setState(() => _progress = 0.3);
      }

      // 2. 檢查模型
      final hasModel = await _service.checkModel(widget.modelName);
      if (!hasModel) {
        // 下載模型
        setState(() => _status = LaunchStatus.downloadingModel);
        await _service.downloadModel(widget.modelUrl);
      } else {
        setState(() => _progress = 0.7);
      }

      // 3. 初始化模型
      setState(() {
        _status = LaunchStatus.initializingModel;
        _progress = 0.9;
      });
      
      print('開始初始化模型: ${widget.modelName}');
      await _service.initModel(widget.modelName);
      // init_ready 事件會在 EventChannel listener 中處理
      
    } catch (e) {
      print('初始化失敗: $e');
      setState(() {
        _status = LaunchStatus.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _retryInitialization() {
    setState(() {
      _status = LaunchStatus.initial;
      _progress = 0.0;
      _errorMessage = null;
    });
    _startInitialization();
  }

  void _skipToHome() {
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // 標題
                const Text(
                  'AIOT Travel Planner',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // 副標題
                Text(
                  _getStatusMessage(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // 進度容器
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // 進度條
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 進度百分比
                      Text(
                        '${(_progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 錯誤狀態
                if (_status == LaunchStatus.error) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withAlpha(1),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '初始化失敗',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage ?? '發生未知錯誤',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _retryInitialization,
                              icon: const Icon(Icons.refresh),
                              label: const Text('重試'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF667EEA),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _skipToHome,
                              icon: const Icon(Icons.skip_next),
                              label: const Text('跳過'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white, width: 2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // 完成狀態
                if (_status == LaunchStatus.completed) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _skipToHome,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('開始使用'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667EEA),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusMessage() {
    switch (_status) {
      case LaunchStatus.initial:
        return '準備初始化...';
      case LaunchStatus.initializingSdk:
        return '正在初始化系統...';
      case LaunchStatus.downloadingBase:
        return '正在下載基礎配置...';
      case LaunchStatus.downloadingModel:
        return '正在下載 AI 模型...';
      case LaunchStatus.initializingModel:
        return '正在載入 AI 模型...';
      case LaunchStatus.completed:
        return '初始化完成！';
      case LaunchStatus.error:
        return '初始化遇到問題';
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
