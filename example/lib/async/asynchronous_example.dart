import 'package:disposable_resource_management/disposable_resource_management.dart';
import 'package:meta/meta.dart';


/// Pretend for the sake of the example the methods in this class do some
/// interaction with unmanaged resources.
/// (e.g. via FFI interop like flutter_soloud)
class SomeAsyncFFIInteropService {
  /// Does some asynchronous allocation of an unmanaged resource
  /// and returns a handle to the resource.
  Future<int> asynchronouslyObtainUnmanagedResource() => Future.value(1);

  /// Releases the unmanaged resource via the [handle].
  Future<void> asynchronouslyReleaseUnmanagedResource(int handle) =>
      Future.delayed(Duration.zero);

  /// Does something with the unmanaged resource via its handle.
  Future<void> doSomethingWithResource(int handle) =>
      Future.delayed(Duration.zero);
}

/// We can then wrap the obtaining and management of the handle via an
/// asynchronously disposable class.
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

/// We can then create services like this which consume the wrapper via a
/// [AsyncResourceToken] and release the token when they are disposed.
class SomeService with AsyncDisposableMixin {
  AsyncResourceToken<SomeFFIWrapper> token;

  SomeService(this.token);

  Future<void> doSomeServiceThing() {
    if (isDisposed) {
      throw StateError('Connot use disposed resource.');
    }

    return token.resource.doSomething();
  }

  @protected
  @override
  Future<void> onDisposeAsync() => token.disposeAsync();
}

void main() async {
  final ffi = SomeAsyncFFIInteropService();

  // Finally, we can use an AsyncResourceManager to manage the obtaining and
  // release of resources for us via tokens, similar to how reference counters
  // work in languages like C++.
  final resource = AsyncResourceManager<SomeFFIWrapper>(
    loadResource: () => SomeFFIWrapper.create(ffi),
    releaseResource: (wrapper) => wrapper.disposeAsync(),
  );

  // The resource gets obtained on the first obtainToken() call.
  final service1 = SomeService(await resource.obtainToken());
  final service2 = SomeService(await resource.obtainToken());

  await service1.doSomeServiceThing();
  await service2.doSomeServiceThing();

  // The resource will not be released yet since service2 still has an
  // un-disposed token.
  await service1.disposeAsync();

  // The resource is now de-allocated when service2's token gets disposed.
  await service2.disposeAsync();

  // This obtains the resource again so service3 can do its thing.
  final service3 = SomeService(await resource.obtainToken());

  // The resource gets de-allocated again.
  await service3.disposeAsync();
}
