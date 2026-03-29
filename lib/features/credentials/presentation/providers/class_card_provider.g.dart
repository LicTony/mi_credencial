// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_card_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for SharedPreferences instance.
/// Must be overridden in main.dart with the actual instance.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider for SharedPreferences instance.
/// Must be overridden in main.dart with the actual instance.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Provider for SharedPreferences instance.
  /// Must be overridden in main.dart with the actual instance.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'129ee5e336b3fbd572a363d686c2646e448b859e';

/// Provider for StorageService.

@ProviderFor(storageService)
final storageServiceProvider = StorageServiceProvider._();

/// Provider for StorageService.

final class StorageServiceProvider
    extends $FunctionalProvider<StorageService, StorageService, StorageService>
    with $Provider<StorageService> {
  /// Provider for StorageService.
  StorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageServiceHash();

  @$internal
  @override
  $ProviderElement<StorageService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StorageService create(Ref ref) {
    return storageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageService>(value),
    );
  }
}

String _$storageServiceHash() => r'fa86d58915feb334123f7c19d4e98739a83aa35d';

/// Notifier for managing the class card state.
///
/// Handles all CRUD operations for the card with automatic persistence.

@ProviderFor(ClassCardNotifier)
final classCardProvider = ClassCardNotifierProvider._();

/// Notifier for managing the class card state.
///
/// Handles all CRUD operations for the card with automatic persistence.
final class ClassCardNotifierProvider
    extends $AsyncNotifierProvider<ClassCardNotifier, ClassCardModel> {
  /// Notifier for managing the class card state.
  ///
  /// Handles all CRUD operations for the card with automatic persistence.
  ClassCardNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'classCardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$classCardNotifierHash();

  @$internal
  @override
  ClassCardNotifier create() => ClassCardNotifier();
}

String _$classCardNotifierHash() => r'01d62c4723c7b4ccf81bc910fe925d9927ddaf67';

/// Notifier for managing the class card state.
///
/// Handles all CRUD operations for the card with automatic persistence.

abstract class _$ClassCardNotifier extends $AsyncNotifier<ClassCardModel> {
  FutureOr<ClassCardModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ClassCardModel>, ClassCardModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ClassCardModel>, ClassCardModel>,
              AsyncValue<ClassCardModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
