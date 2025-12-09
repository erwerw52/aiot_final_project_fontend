import 'package:aiot_final_project_fontend/model/enums/enum_launch_status.dart';

class LaunchState {
  final LaunchStatus status;
  final String message;
  final double progress;
  final String? errorMessage;
  final String? modelUrl;
  final String? modelName;

  const LaunchState({
    required this.status,
    required this.message,
    this.progress = 0.0,
    this.errorMessage,
    this.modelUrl,
    this.modelName,
  });

  LaunchState copyWith({
    LaunchStatus? status,
    String? message,
    double? progress,
    String? errorMessage,
    String? modelUrl,
    String? modelName,
  }) {
    return LaunchState(
      status: status ?? this.status,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      modelUrl: modelUrl ?? this.modelUrl,
      modelName: modelName ?? this.modelName,
    );
  }
}