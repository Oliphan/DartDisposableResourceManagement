import 'package:disposable_resource_management/disposable_resource_management.dart';

/// Manages the asynchronous release of a resource once itself and all
/// propagated tokens have been disposed.
class RootResourceToken<T> implements ResourceToken<T> {
  final Set<Disposable> _tokens;
  final void Function(T) _releaseResource;

  final T _resource;

  /// Creates a [RootResourceToken] that releases the [resource] via
  /// [releaseResource] when itself and all propagated tokens have been
  /// disposed.
  RootResourceToken({
    required T resource,
    required void Function(T) releaseResource,
  }) : _tokens = <Disposable>{},
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
  void dispose() {
    if (isDisposed) {
      return;
    }
    _releaseToken(this);
  }

  @override
  ResourceToken<T> propagate() {
    if (isDisposed) {
      throw StateError('Cannot propagate access from a disposed token.');
    }

    return _propagateInternal();
  }

  ResourceToken<T> _propagateInternal() => ResourceToken<T>(
    resource: _resource,
    onDispose: _releaseToken,
    propagator: _propagateInternal,
  );

  void _releaseToken(Disposable token) {
    _tokens.remove(token);
    if (_tokens.isNotEmpty) {
      return;
    }
    _releaseResource(_resource);
  }
}
