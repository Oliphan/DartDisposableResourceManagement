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
}
