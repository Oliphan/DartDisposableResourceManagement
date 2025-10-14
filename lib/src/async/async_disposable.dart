import 'package:disposable_resource_management/disposable_resource_management.dart';
import 'package:meta/meta.dart';

/// An object that can be disposed asynchronously.
abstract interface class AsyncDisposable {
  /// Creates a token that calls [onDispose] on disposal.
  factory AsyncDisposable.token(Future<void> Function() onDispose) =>
      AsyncDisposeToken(onDispose);

  /// Creates a token that calls [onDispose] on disposal with the token as a
  /// parameter.
  factory AsyncDisposable.withToken(
    Future<void> Function(AsyncDisposeToken) onDispose,
  ) => AsyncDisposeToken.withToken(onDispose);

  /// Indicates whether the object has been disposed.
  bool get isDisposed;

  /// Disposes the object.
  @mustCallSuper
  Future<void> disposeAsync();
}
