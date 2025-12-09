import 'package:aiot_final_project_fontend/model/enums/enum_launch_status.dart';
import 'package:aiot_final_project_fontend/model/lanuch_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:aiot_final_project_fontend/util/duix_sdk_util.dart';

part 'launch_provider.g.dart';

// Launch Provider - 使用 @riverpod
@riverpod
class Launch extends _$Launch {
  @override
  LaunchState build() {
    return const LaunchState(
      status: LaunchStatus.initial,
      message: '準備初始化...',
    );
  }

  // 開始初始化流程
  Future<void> startInitialization({
    String? modelUrl,
    String? modelName,
  }) async {
    try {
      // 設置回調
      DuixSdkUtil().setDownloadProgressCallback(_onDownloadProgress);
      DuixSdkUtil().setEventCallback(_onSdkEvent);

      // 1. 初始化 SDK (0% → 10%)
      state = state.copyWith(
        status: LaunchStatus.initializingSdk,
        message: '正在初始化 SDK...',
        progress: 0.0,
        modelUrl: modelUrl,
        modelName: modelName,
      );

      final sdkInitialized = await DuixSdkUtil().initialize();
      if (!sdkInitialized) {
        throw Exception('SDK 初始化失敗');
      }

      // 2. 檢查並下載 Base Config (10% → 50%)
      state = state.copyWith(
        status: LaunchStatus.downloadingBase,
        message: '檢查基礎配置...',
        progress: 0.1,
      );

      final baseConfigExists = await DuixSdkUtil().checkBaseConfig();
      if (baseConfigExists) {
        print('基礎配置已存在，跳過下載');
        state = state.copyWith(
          message: '基礎配置已就緒',
          progress: 0.5,
        );
      } else {
        state = state.copyWith(
          message: '正在下載基礎配置...',
        );
        
        final baseDownloaded = await DuixSdkUtil().downloadBaseConfig(
          "https://github.com/duixcom/Duix-Mobile/releases/download/v1.0.0/gj_dh_res.zip"
        );
        if (!baseDownloaded) {
          throw Exception('基礎配置下載失敗');
        }
      }

      // 3. 檢查並下載模型 (如果提供)
      if (modelUrl != null && modelUrl.isNotEmpty && modelName != null && modelName.isNotEmpty) {
        state = state.copyWith(
          status: LaunchStatus.downloadingModel,
          message: '檢查 AI 模型...',
          progress: 0.5,
        );

        final modelExists = await DuixSdkUtil().checkModel(modelName);
        if (modelExists) {
          print('AI 模型 $modelName 已存在，跳過下載');
          state = state.copyWith(
            message: 'AI 模型已就緒',
            progress: 0.9,
          );
        } else {
          state = state.copyWith(
            message: '正在下載 AI 模型...',
          );
          
          final modelDownloaded = await DuixSdkUtil().downloadModel(modelUrl);
          if (!modelDownloaded) {
            throw Exception('AI 模型下載失敗');
          }
        }
      }

      // 4. 初始化模型 (如果提供) (90% → 100%)
      if (modelName != null && modelName.isNotEmpty) {
        state = state.copyWith(
          status: LaunchStatus.initializingModel,
          message: '正在載入 AI 模型...',
          progress: 0.9,
        );

        final modelInitialized = await DuixSdkUtil().initModel(modelName);
        if (!modelInitialized) {
          throw Exception('AI 模型初始化失敗');
        }

        // 等待模型準備就緒
        await Future.delayed(const Duration(seconds: 1));
        final isReady = await DuixSdkUtil().isModelReady();
        if (!isReady) {
          print('警告: 模型可能未完全準備就緒');
        }
      }

      // 5. 初始化完成
      state = state.copyWith(
        status: LaunchStatus.completed,
        message: '初始化完成！',
        progress: 1.0,
      );

    } catch (e) {
      print('初始化錯誤: $e');
      state = state.copyWith(
        status: LaunchStatus.error,
        message: '初始化失敗',
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // 重試初始化
  Future<void> retryInitialization() async {
    await startInitialization(
      modelUrl: state.modelUrl,
      modelName: state.modelName,
    );
  }

  // 跳過模型初始化
  void skipModelInitialization() {
    state = state.copyWith(
      status: LaunchStatus.completed,
      message: '初始化完成 (跳過模型)',
      progress: 1.0,
    );
  }

  // 下載進度回調
  void _onDownloadProgress(String url, int current, int total, bool isUnzip) {
    if (total <= 0) return;

    final currentProgress = current / total;
    final type = isUnzip ? '解壓' : '下載';
    
    // 根據當前狀態調整進度範圍
    double baseProgress;
    double progressRange;
    
    if (state.status == LaunchStatus.downloadingBase) {
      // 基礎配置：0%-50%
      if (isUnzip) {
        baseProgress = 0.4;
        progressRange = 0.1;
      } else {
        baseProgress = 0.1;
        progressRange = 0.3;
      }
    } else if (state.status == LaunchStatus.downloadingModel) {
      // 模型下載：50%-100%
      if (isUnzip) {
        baseProgress = 0.8;
        progressRange = 0.1;
      } else {
        baseProgress = 0.5;
        progressRange = 0.3;
      }
    } else {
      return;
    }

    final finalProgress = baseProgress + (currentProgress * progressRange);

    state = state.copyWith(
      message: '$type中: ${_formatBytes(current)} / ${_formatBytes(total)}',
      progress: finalProgress,
    );
  }

  // 格式化字節大小
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // SDK 事件回調
  void _onSdkEvent(String event, String message, dynamic info) {
    print('Launch: DUIX Event - $event: $message');

    switch (event) {
      case 'init.ready':
        state = state.copyWith(
          message: '模型初始化完成',
          progress: 0.95,
        );
        break;
      case 'init.error':
        state = state.copyWith(
          status: LaunchStatus.error,
          message: '模型初始化失敗',
          errorMessage: message,
        );
        break;
    }
  }

  // 清理資源
  Future<void> disposeResources() async {
    DuixSdkUtil().clearCallbacks();
    await DuixSdkUtil().release();
  }
}
