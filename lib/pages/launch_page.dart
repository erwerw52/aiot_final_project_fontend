import 'package:aiot_final_project_fontend/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/duix_provider.dart';
import '../providers/launch_provider.dart';

class LaunchPage extends ConsumerStatefulWidget {
  const LaunchPage({
    super.key,
    required this.modelUrl,
    required this.modelName,
    required Function() onCompleted,
  });

  final String modelUrl;
  final String modelName;

  @override
  ConsumerState<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends ConsumerState<LaunchPage> {
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  @override
  void initState() {
    super.initState();

    // 立即訂閱 EventChannel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final duixService = ref.read(duixServiceProvider);
      _eventSubscription = duixService.eventStream.listen((event) {
        final type = event['type'] as String?;

        switch (type) {
          case 'download_progress':
            final category = event['category'] as String?;
            final current = event['current'] as int? ?? 0;
            final total = event['total'] as int? ?? 1;
            final progress = current / total;

            if (category == 'base_config') {
              ref.read(launchStateProvider.notifier).updateStatus(
                LaunchStatus.downloadingBase,
                progress: 0.1 + (progress * 0.2),
              );
            } else if (category == 'model') {
              ref.read(launchStateProvider.notifier).updateStatus(
                LaunchStatus.downloadingModel,
                progress: 0.4 + (progress * 0.3),
              );
            }
            break;

          case 'download_complete':
            final category = event['category'] as String?;
            if (category == 'base_config') {
              ref.read(launchStateProvider.notifier).updateStatus(
                LaunchStatus.initial,
                progress: 0.3,
              );
            } else if (category == 'model') {
              ref.read(launchStateProvider.notifier).updateStatus(
                LaunchStatus.initial,
                progress: 0.7,
              );
            }
            break;

          case 'download_fail':
            final error = event['error'] as String? ?? '下載失敗';
            ref.read(launchStateProvider.notifier).updateStatus(
              LaunchStatus.error,
              errorMessage: error,
            );
            break;

          case 'init_ready':
            print('模型初始化完成');
            ref.read(launchStateProvider.notifier).updateStatus(
              LaunchStatus.completed,
              progress: 1.0,
            );
            _skipToHome();
            break;

          case 'init_error':
            final error = event['error'] as String? ?? '初始化失敗';
            print('模型初始化錯誤: $error');
            ref.read(launchStateProvider.notifier).updateStatus(
              LaunchStatus.error,
              errorMessage: error,
              progress: 0.9,
            );
            break;
        }
      });

      // 開始初始化
      ref.read(launchStateProvider.notifier).initialize(widget.modelUrl, widget.modelName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final launchState = ref.watch(launchStateProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AiTP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  height: 1.0
                ),
              ),

              SizedBox(height: 5,),

              const Text(
                'AI Travel Planner',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  letterSpacing: 1.2,
                    height: 1.0
                ),
              ),

              SizedBox(height: 35,),

              Container(
                child: Assets.images.icon.loadingIcon.image(fit: BoxFit.contain, height: 200),
              ),

              SizedBox(height: 40,),

              // 進度容器
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        value: launchState.progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // 副標題
                    Text(
                      _getStatusMessage(launchState.status),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                          height: 1.0
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    // 進度百分比
                    Text(
                      '${(launchState.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                          height: 1.0
                      ),
                    ),
                  ],
                ),
              ),

              // 錯誤狀態
              if (launchState.status == LaunchStatus.error) ...[
                Container(
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
                        launchState.errorMessage ?? '發生未知錯誤',
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
                            onPressed: () {
                              ref.read(launchStateProvider.notifier).retry();
                              ref.read(launchStateProvider.notifier).initialize(widget.modelUrl, widget.modelName);
                            },
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
            ],
          ),
        ),
      ),
    );
  }

  void _skipToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  String _getStatusMessage(LaunchStatus status) {
    switch (status) {
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
