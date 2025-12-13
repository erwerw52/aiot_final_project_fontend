// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ttsRepository)
const ttsRepositoryProvider = TtsRepositoryProvider._();

final class TtsRepositoryProvider
    extends $FunctionalProvider<TtsRepository, TtsRepository, TtsRepository>
    with $Provider<TtsRepository> {
  const TtsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ttsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ttsRepositoryHash();

  @$internal
  @override
  $ProviderElement<TtsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TtsRepository create(Ref ref) {
    return ttsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TtsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TtsRepository>(value),
    );
  }
}

String _$ttsRepositoryHash() => r'83d9835cdf2011152f50c085b6ee5c44f358ccea';
