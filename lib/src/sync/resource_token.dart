import 'package:disposable_resource_management/disposable_resource_management.dart';

/// Provides access, which is revoked on disposal, to a resource.
class ResourceToken<T> extends DisposeToken {
  final T _resource;
  final ResourceToken<T> Function() _propagator;

  /// Creates a token granting access to the [resource], allowing propagation
  /// via [propagate], and calling [onDispose] when it is disposed.
  ResourceToken({
    required T resource,
    required void Function(DisposeToken) onDispose,
    required ResourceToken<T> Function() propagator,
  }) : _resource = resource,
       _propagator = propagator,
       super.withToken(onDispose);

  /// The resource this token grants access to.
  T get resource => isDisposed
      ? throw StateError('Cannot access resource from a disposed token.')
      : _resource;

  /// Propagates access to the resource by creating a new token.
  ResourceToken<T> propagate() => isDisposed
      ? throw StateError('Cannot propagate access from a disposed token.')
      : _propagator();

  /// Creates a resource token for a resource loaded with [loadResource] that
  /// will release the resource with [releaseResource] when the token and all
  /// propagated tokens are disposed.
  static ResourceToken<T> create<T>({
    required T Function() loadResource,
    required void Function(T) releaseResource,
  }) => RootResourceToken<T>(
    resource: loadResource(),
    releaseResource: releaseResource,
  );
}
