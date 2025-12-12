// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LaunchState)
const launchStateProvider = LaunchStateProvider._();

final class LaunchStateProvider
    extends $NotifierProvider<LaunchState, LaunchStateData> {
  const LaunchStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchStateHash();

  @$internal
  @override
  LaunchState create() => LaunchState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchStateData>(value),
    );
  }
}

String _$launchStateHash() => r'20436d9551c157cee5c79a9921d6ecfc2c4be508';

abstract class _$LaunchState extends $Notifier<LaunchStateData> {
  LaunchStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LaunchStateData, LaunchStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LaunchStateData, LaunchStateData>,
              LaunchStateData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
