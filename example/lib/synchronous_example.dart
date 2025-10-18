// Ignored avoiding print for example files
// ignore_for_file: avoid_print

import 'package:disposable_resource_management/disposable_resource_management.dart';
import 'package:meta/meta.dart';

/// Pretend for the sake of the example the methods in this class do some
/// interaction with unmanaged resources.
/// (e.g. via FFI interop like flutter_soloud)
class SomeFFIInteropService {
  /// Does something with the unmanaged resource via its handle.
  void doSomethingWithResource(int handle) {}

  /// Does some synchronous allocation of an unmanaged resource
  ///  and returns a handle to the resource.
  int synchronouslyObtainUnmanagedResource() => 1;

  /// Releases the unmanaged resource via the [handle].
  void synchronouslyReleaseUnmanagedResource(int handle) {}
}

/// We can then wrap the obtaining and management of the handle via a disposable
/// class.
class SomeFFIWrapper with DisposableMixin {
  final SomeFFIInteropService _ffi;
  late final int _handle;

  SomeFFIWrapper(SomeFFIInteropService ffi) : _ffi = ffi {
    _handle = _ffi.synchronouslyObtainUnmanagedResource();
  }

  void doSomething() {
    // Since DisposableMixin implements the isDisposed property for us, we can
    // use it for checks like this to make sure objects are not used after
    // disposal.
    if (isDisposed) {
      throw StateError('Connot use disposed resource.');
    }

    _ffi.doSomethingWithResource(_handle);
  }

  /// Thanks to [DisposableMixin] the object will not throw if accidentally
  /// disposed multiple times, as the [onDispose] logic will only be run the
  /// first time [dispose] is called.
  @protected
  @override
  void onDispose() => _ffi.synchronouslyReleaseUnmanagedResource(_handle);
}

/// We can then create services like this which consume the wrapper via a
/// [ResourceToken] and release the token when they are disposed.
class SomeService with DisposableMixin {
  ResourceToken<SomeFFIWrapper> token;

  SomeService(this.token);

  void doSomeServiceThing() {
    if (isDisposed) {
      throw StateError('Connot use disposed resource.');
    }

    token.resource.doSomething();
  }

  @protected
  @override
  void onDispose() => token.dispose();
}

void main() {
  final ffi = SomeFFIInteropService();

  // Finally, we can use a ResourceManager to manage the obtaining and release
  // of resources for us via tokens, similar to how reference counters work in
  // languages like C++.
  final resourceManager = ResourceManager<SomeFFIWrapper>(
    loadResource: () {
      print('Obtaining resource...');
      return SomeFFIWrapper(ffi);
    },
    releaseResource: (wrapper) {
      print('Releasing resource...');
      wrapper.dispose();
    },
  );

  // The resource gets obtained on the first obtainToken() call.
  final service1 = SomeService(resourceManager.obtainToken());
  final service2 = SomeService(resourceManager.obtainToken());

  service1.doSomeServiceThing();
  service2.doSomeServiceThing();

  // The resource will not be released yet since service2 still has an
  // un-disposed token.
  service1.dispose();

  // The resource is now released when service2's token gets disposed.
  service2.dispose();

  // This obtains the resource again
  final token1 = resourceManager.obtainToken();

  // We can also propagate the token to get another token
  final token2 = token1.propagate();

  // The resource will not be released yet because the propagated token2 still
  // is not disposed.
  token1.dispose();

  // The resource gets released again when all tokens for the resource are
  // disposed.
  token2.dispose();
}
