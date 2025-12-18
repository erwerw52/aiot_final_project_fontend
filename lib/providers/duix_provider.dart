import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/duix_service.dart';

part 'duix_provider.g.dart';

// DuixService provider - 保持活躍避免重複創建
@Riverpod(keepAlive: true)
DuixService duixService(Ref ref) {
  return DuixService();
}

// 首頁狀態 provider
@riverpod
class HomeState extends _$HomeState {
  @override
  HomeStateData build() {
    return const HomeStateData(isPlaying: false);
  }

  void setPlaying(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }

  void startPlaying() {
    state = state.copyWith(isPlaying: true);
  }

  void stopPlaying() {
    state = state.copyWith(isPlaying: false);
  }
}

// 首頁狀態數據類
class HomeStateData {
  const HomeStateData({required this.isPlaying});

  final bool isPlaying;

  HomeStateData copyWith({bool? isPlaying}) {
    return HomeStateData(isPlaying: isPlaying ?? this.isPlaying);
  }
}