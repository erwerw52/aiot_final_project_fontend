// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Launch)
const launchProvider = LaunchProvider._();

final class LaunchProvider extends $NotifierProvider<Launch, LaunchState> {
  const LaunchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchHash();

  @$internal
  @override
  Launch create() => Launch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchState>(value),
    );
  }
}

String _$launchHash() => r'60c1d4ee2e9871dcae8e8dde60d59b92611e02b4';

abstract class _$Launch extends $Notifier<LaunchState> {
  LaunchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LaunchState, LaunchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LaunchState, LaunchState>,
              LaunchState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
