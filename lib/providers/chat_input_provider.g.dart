// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_input_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatInput)
const chatInputProvider = ChatInputProvider._();

final class ChatInputProvider extends $NotifierProvider<ChatInput, String> {
  const ChatInputProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatInputProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatInputHash();

  @$internal
  @override
  ChatInput create() => ChatInput();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$chatInputHash() => r'a18b0b60c5dd94c5631ca4e5f5f14ef02fc31943';

abstract class _$ChatInput extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(IsNeedLoading)
const isNeedLoadingProvider = IsNeedLoadingProvider._();

final class IsNeedLoadingProvider
    extends $NotifierProvider<IsNeedLoading, bool> {
  const IsNeedLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isNeedLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isNeedLoadingHash();

  @$internal
  @override
  IsNeedLoading create() => IsNeedLoading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isNeedLoadingHash() => r'43e5395ab4fa1c2f850c8b40ac35b161c6366a7b';

abstract class _$IsNeedLoading extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
