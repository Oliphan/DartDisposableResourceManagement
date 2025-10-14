Provides base types and utilities for managing the loading and disposal of
resources, for example when working with packages that do so via
[ffi](https://pub.dev/packages/ffi) such as
[flutter_soloud](https://pub.dev/packages/flutter_soloud).

## Set-up

Just add following dependencies to your `pubspec.yaml`:
```yaml
dependencies:
  disposable_resource_management: ^2.0.0
```

## Usage

`AsyncDisposableMixin` (or `DisposableMixin` in scenarios where disposal is
synchronous) can be used to streamline the implementation of disposable types:
```dart
class SomeFFIWrapper with AsyncDisposableMixin {
  final SomeAsyncFFIInteropService _ffi;
  final int _handle;

  SomeFFIWrapper._(int handle, SomeAsyncFFIInteropService ffi)
    : _handle = handle,
      _ffi = ffi;

  Future<void> doSomething() {
    // Since AsyncDisposableMixin implements the isDisposed property for us, we
    // can use it for checks like this to make sure objects are not used after
    // disposal.
    if (isDisposed) {
      throw StateError('Connot use disposed resource.');
    }

    return _ffi.doSomethingWithResource(_handle);
  }

  /// Thanks to [AsyncDisposableMixin] the object will not throw if accidentally
  /// disposed multiple times, as the [onDisposeAsync] logic will only be run
  /// the first time [disposeAsync] is called.
  @protected
  @override
  Future<void> onDisposeAsync() =>
      _ffi.asynchronouslyReleaseUnmanagedResource(_handle);

  static Future<SomeFFIWrapper> create(SomeAsyncFFIInteropService ffi) async {
    final handle = await ffi.asynchronouslyObtainUnmanagedResource();
    return SomeFFIWrapper._(handle, ffi);
  }
}
```

`AsyncResourceManager` (or `ResourceManager` in scenarios where obtaining +
releasing the resource is synchronous) can then be used to manage loading and
disposal of a resource via tokens, similar to how reference counters work in
languages like C++:
```dart
class SomeService with AsyncDisposableMixin {
  AsyncResourceToken<SomeFFIWrapper> token;

  SomeService(this.token);

  // ...

  @protected
  @override
  Future<void> onDisposeAsync() => token.disposeAsync();
}

void main() async {
  final ffi = SomeAsyncFFIInteropService();

  final resourceManager = AsyncResourceManager<SomeFFIWrapper>(
    loadResource: () => SomeFFIWrapper.create(ffi),
    releaseResource: (wrapper) => wrapper.disposeAsync(),
  );

  // The resource gets obtained on the first obtainToken() call.
  final service1 = SomeService(await resourceManager.obtainToken());
  final service2 = SomeService(await resourceManager.obtainToken());

  // The resource will not be released yet since service2 still has an
  // un-disposed token.
  await service1.disposeAsync();

  // The resource is now released when service2's token gets disposed.
  await service2.disposeAsync();

  // This obtains the resource again so service3 can do its thing.
  final service3 = SomeService(await resourceManager.obtainToken());

  // The resource gets released again.
  await service3.disposeAsync();
}
```
