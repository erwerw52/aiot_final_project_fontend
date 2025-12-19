import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/duix_service.dart';

part 'duix_provider.g.dart';

// DuixService provider - 保持活躍避免重複創建
@Riverpod(keepAlive: true)
DuixService duixService(Ref ref) {
  return DuixService();
}

@Riverpod(keepAlive: true)
class IsPlaying extends _$IsPlaying {
  @override
   bool build() {
    return false;
  }

  void startPlaying(){
    state = true;
  }

  void stopPlaying(){
    state = false;
  }
}