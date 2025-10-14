import 'package:disposable_resource_management/disposable_resource_management.dart';

/// Provides access, which is revoked on disposal, to a resource.
class AsyncResourceToken<T> extends AsyncDisposeToken {
  final T _resource;

  /// Creates a token granting access to the [resource] and
  /// calling [onDispose] when it is disposed.
  AsyncResourceToken({
    required T resource,
    required Future<void> Function(AsyncDisposeToken) onDispose,
  }) : _resource = resource,
       super.withToken(onDispose);

  /// The resource this token grants access to.
  T get resource => isDisposed
      ? throw StateError('Cannot access resource from a disposed token.')
      : _resource;
}
