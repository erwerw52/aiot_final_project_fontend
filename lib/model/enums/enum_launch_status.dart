// 初始化狀態枚舉
enum LaunchStatus {
  initial,
  initializingSdk,
  downloadingBase,
  downloadingModel,
  initializingModel,
  completed,
  error,
}