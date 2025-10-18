import 'package:disposable_resource_management/disposable_resource_management.dart';

/// Manages the asynchronous release of a resource once itself and all
/// propagated tokens have been disposed.
class AsyncRootResourceToken<T> implements AsyncResourceToken<T> {
  final Set<AsyncDisposable> _tokens;
  final Future<void> Function(T) _releaseResource;

  final T _resource;

  /// Creates a [AsyncRootResourceToken] that releases the [resource] via
  /// [releaseResource] when itself and all propagated tokens have been
  /// disposed.
  AsyncRootResourceToken({
    required T resource,
    required Future<void> Function(T) releaseResource,
  }) : _tokens = <AsyncDisposable>{},
       _resource = resource,
       _releaseResource = releaseResource {
    _tokens.add(this);
  }

  @override
  bool get isDisposed => _tokens.contains(this);

  /// The resource this token grants access to.
  @override
  T get resource => isDisposed
      ? throw StateError('Cannot access resource from a disposed token.')
      : _resource;

  @override
  Future<void> disposeAsync() async {
    if (isDisposed) {
      return;
    }
    return _releaseToken(this);
  }

  @override
  AsyncResourceToken<T> propagate() {
    if (isDisposed) {
      throw StateError('Cannot propagate access from a disposed token.');
    }

    return _propagateInternal();
  }

  AsyncResourceToken<T> _propagateInternal() => AsyncResourceToken<T>(
    resource: _resource,
    onDispose: _releaseToken,
    propagator: _propagateInternal,
  );

  Future<void> _releaseToken(AsyncDisposable token) async {
    _tokens.remove(token);
    if (_tokens.isNotEmpty) {
      return;
    }
    await _releaseResource(_resource);
  }
}
