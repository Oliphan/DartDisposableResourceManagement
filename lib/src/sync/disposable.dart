import 'package:disposable_resource_management/disposable_resource_management.dart';
import 'package:meta/meta.dart';

/// An object that can be disposed synchronously.
abstract interface class Disposable {
  /// Creates a token that calls [onDispose] on disposal.
  factory Disposable.token(void Function() onDispose) =>
      DisposeToken(onDispose);

  /// Creates a token that calls [onDispose] on disposal with the token as a
  /// parameter.
  factory Disposable.withToken(void Function(DisposeToken) onDispose) =>
      DisposeToken.withToken(onDispose);

  /// Indicates whether the object has been disposed.
  bool get isDisposed;

  /// Disposes the object.
  @mustCallSuper
  void dispose();
}
