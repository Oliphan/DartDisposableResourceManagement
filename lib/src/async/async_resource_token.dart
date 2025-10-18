import 'package:disposable_resource_management/disposable_resource_management.dart';

/// Provides access, which is revoked on disposal, to a resource.
class AsyncResourceToken<T> extends AsyncDisposeToken {
  final T _resource;
  final AsyncResourceToken<T> Function() _propagator;

  /// Creates a token granting access to the [resource] and
  /// calling [onDispose] when it is disposed.
  AsyncResourceToken({
    required T resource,
    required Future<void> Function(AsyncDisposeToken) onDispose,
    required AsyncResourceToken<T> Function() propagator,
  }) : _resource = resource,
       _propagator = propagator,
       super.withToken(onDispose);

  /// The resource this token grants access to.
  T get resource => isDisposed
      ? throw StateError('Cannot access resource from a disposed token.')
      : _resource;

  /// Propagates access to the resource by creating a new token.
  AsyncResourceToken<T> propagate() => isDisposed
      ? throw StateError('Cannot propagate access from a disposed token.')
      : _propagator();

  /// Creates a resource token for a resource loaded with [loadResource] that
  /// will release the resource with [releaseResource] when the token and all
  /// propagated tokens are disposed.
  static Future<AsyncResourceToken<T>> create<T>({
    required Future<T> Function() loadResource,
    required Future<void> Function(T) releaseResource,
  }) async => AsyncRootResourceToken<T>(
    resource: await loadResource(),
    releaseResource: releaseResource,
  );
}
