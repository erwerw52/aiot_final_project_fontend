import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_input_provider.g.dart';

@riverpod
class ChatInput extends _$ChatInput {
  @override
  String build() {
    return '';
  }

  void setText(String text) {
    state = text;
  }

  void clearText() {
    state = '';
  }
}

@riverpod
class IsNeedLoading extends _$IsNeedLoading {
  @override
  bool build() {
    return false;
  }

  void setLoading(bool isLoading) {
    state = isLoading;
  }
}

@riverpod
class UrlText extends _$UrlText {
  @override
  String build() {
    return '';
  }

  void setUrl(String url){
    state = url;
  }
}
