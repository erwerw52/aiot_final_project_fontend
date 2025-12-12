// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'duix_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(duixService)
const duixServiceProvider = DuixServiceProvider._();

final class DuixServiceProvider
    extends $FunctionalProvider<DuixService, DuixService, DuixService>
    with $Provider<DuixService> {
  const DuixServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'duixServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$duixServiceHash();

  @$internal
  @override
  $ProviderElement<DuixService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DuixService create(Ref ref) {
    return duixService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DuixService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DuixService>(value),
    );
  }
}

String _$duixServiceHash() => r'8cb970365937cae291c95927729a25d60cc13852';

@ProviderFor(HomeState)
const homeStateProvider = HomeStateProvider._();

final class HomeStateProvider
    extends $NotifierProvider<HomeState, HomeStateData> {
  const HomeStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeStateHash();

  @$internal
  @override
  HomeState create() => HomeState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeStateData>(value),
    );
  }
}

String _$homeStateHash() => r'20f012a0295d23108385f535b6e6a29b3e1a3485';

abstract class _$HomeState extends $Notifier<HomeStateData> {
  HomeStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HomeStateData, HomeStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeStateData, HomeStateData>,
              HomeStateData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

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

String _$speechRecognitionHash() => r'75fd36f0c04506e9fdf0896216c0a2e956141f8c';

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
