import 'package:aiot_final_project_fontend/model/enums/enum_launch_status.dart';
import 'package:aiot_final_project_fontend/model/lanuch_state.dart';
import 'package:aiot_final_project_fontend/util/duix_sdk_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aiot_final_project_fontend/providers/launch_provider.dart';

class LaunchPage extends ConsumerStatefulWidget {
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
  ConsumerState<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends ConsumerState<LaunchPage> {
  @override
  void initState() {
    super.initState();

    // 開始初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(launchProvider.notifier).startInitialization(
        modelUrl: widget.modelUrl,
        modelName: widget.modelName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final launchState = ref.watch(launchProvider);

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
                // Logo 或圖標
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // 標題
                const Text(
                  'AIOT 智慧助手',
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
                  _getStatusMessage(launchState),
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
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // 詳細訊息
                      Text(
                        launchState.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 12),

                      // 進度百分比
                      Text(
                        '${(launchState.progress * 100).toStringAsFixed(0)}%',
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
                if (launchState.status == LaunchStatus.error) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.4),
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
                                ref.read(launchProvider.notifier).retryInitialization();
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
                              onPressed: () {
                                ref.read(launchProvider.notifier).skipModelInitialization();
                              },
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
                if (launchState.status == LaunchStatus.completed) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: widget.onCompleted ?? () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
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

  String _getStatusMessage(LaunchState state) {
    switch (state.status) {
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
    // 不在這裡清理 DUIX SDK 資源，因為可能還需要使用
    // 只清理回調
    DuixSdkUtil().clearCallbacks();
    super.dispose();
  }
}
