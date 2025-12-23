// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speech_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SpeechRecognition)
const speechRecognitionProvider = SpeechRecognitionProvider._();

final class SpeechRecognitionProvider
    extends $NotifierProvider<SpeechRecognition, SpeechState> {
  const SpeechRecognitionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'speechRecognitionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$speechRecognitionHash();

  @$internal
  @override
  SpeechRecognition create() => SpeechRecognition();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpeechState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpeechState>(value),
    );
  }
}

String _$speechRecognitionHash() => r'b5799beb7e04fcfed4a9ab51259fe231f62a6922';

abstract class _$SpeechRecognition extends $Notifier<SpeechState> {
  SpeechState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SpeechState, SpeechState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SpeechState, SpeechState>,
              SpeechState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 數字人字幕

@ProviderFor(DigitalHumanTalkText)
const digitalHumanTalkTextProvider = DigitalHumanTalkTextProvider._();

/// 數字人字幕
final class DigitalHumanTalkTextProvider
    extends $NotifierProvider<DigitalHumanTalkText, String> {
  /// 數字人字幕
  const DigitalHumanTalkTextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'digitalHumanTalkTextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$digitalHumanTalkTextHash();

  @$internal
  @override
  DigitalHumanTalkText create() => DigitalHumanTalkText();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$digitalHumanTalkTextHash() =>
    r'232b7cb1445407ca4d0e070c4144cd0146d4fe50';

/// 數字人字幕

abstract class _$DigitalHumanTalkText extends $Notifier<String> {
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
