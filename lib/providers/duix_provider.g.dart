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

@ProviderFor(IsPlaying)
const isPlayingProvider = IsPlayingProvider._();

final class IsPlayingProvider extends $NotifierProvider<IsPlaying, bool> {
  const IsPlayingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isPlayingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isPlayingHash();

  @$internal
  @override
  IsPlaying create() => IsPlaying();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isPlayingHash() => r'9e7cef93d9c561744c34e066d91842711806ccae';

abstract class _$IsPlaying extends $Notifier<bool> {
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
