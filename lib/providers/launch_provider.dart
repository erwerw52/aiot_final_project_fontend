import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'duix_provider.dart';

part 'launch_provider.g.dart';

// 啟動頁面狀態 provider
@riverpod
class LaunchState extends _$LaunchState {
  @override
  LaunchStateData build() {
    return const LaunchStateData(
      status: LaunchStatus.initial,
      progress: 0.0,
      errorMessage: null,
    );
  }

  void updateStatus(LaunchStatus status, {double? progress, String? errorMessage}) {
    state = state.copyWith(
      status: status,
      progress: progress ?? state.progress,
      errorMessage: errorMessage,
    );
  }

  Future<void> initialize(String modelUrl, String modelName) async {
    final duixService = ref.read(duixServiceProvider);

    try {
      // 階段 1: 初始化 SDK
      updateStatus(LaunchStatus.initializingSdk, progress: 0.1);

      // 階段 2: 檢查並下載基礎配置
      updateStatus(LaunchStatus.downloadingBase, progress: 0.2);
      final hasBaseConfig = await duixService.checkBaseConfig();
      if (!hasBaseConfig) {
        // 下載基礎配置
        final downloadSuccess = await duixService.downloadBaseConfig(
          'https://github.com/duixcom/Duix-Mobile/releases/download/v1.0.0/gj_dh_res.zip'
        );
        if (!downloadSuccess) {
          // 下載失敗，等待事件處理錯誤狀態
          return;
        }
      }
      updateStatus(LaunchStatus.downloadingBase, progress: 0.4);

      // 階段 3: 檢查並下載模型
      updateStatus(LaunchStatus.downloadingModel, progress: 0.5);
      final hasModel = await duixService.checkModel(modelName);
      if (!hasModel) {
        // 下載模型
        final downloadSuccess = await duixService.downloadModel(modelUrl);
        if (!downloadSuccess) {
          // 下載失敗，等待事件處理錯誤狀態
          return;
        }
      }
      updateStatus(LaunchStatus.downloadingModel, progress: 0.8);

      // 階段 4: 初始化模型
      updateStatus(LaunchStatus.initializingModel, progress: 0.9);
      final initSuccess = await duixService.initModel(modelName);
      if (!initSuccess) {
        // 初始化失敗，等待事件處理錯誤狀態
        return;
      }
      // init_ready 事件會在 LaunchPage 中處理

    } catch (e) {
      updateStatus(LaunchStatus.error, errorMessage: e.toString());
    }
  }

  void retry() {
    state = const LaunchStateData(
      status: LaunchStatus.initial,
      progress: 0.0,
      errorMessage: null,
    );
  }
}

// 啟動狀態數據類
class LaunchStateData {
  const LaunchStateData({
    required this.status,
    required this.progress,
    this.errorMessage,
  });

  final LaunchStatus status;
  final double progress;
  final String? errorMessage;

  LaunchStateData copyWith({
    LaunchStatus? status,
    double? progress,
    String? errorMessage,
  }) {
    return LaunchStateData(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 啟動狀態枚舉
enum LaunchStatus {
  initial,
  initializingSdk,
  downloadingBase,
  downloadingModel,
  initializingModel,
  completed,
  error,
}