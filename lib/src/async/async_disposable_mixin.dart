import 'package:disposable_resource_management/disposable_resource_management.dart';
import 'package:meta/meta.dart';

/// Implements [AsyncDisposable]'s [isDisposed] property and [disposeAsync]
/// with once-only disposal protection.
/// Requires overriding of an [onDisposeAsync] method with the actual disposal
/// logic.
abstract mixin class AsyncDisposableMixin implements AsyncDisposable {
  bool _disposed = false;

  @override
  bool get isDisposed => _disposed;

  @mustCallSuper
  @override
  Future<void> disposeAsync() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await onDisposeAsync();
  }

  /// Performs one-time disposal logic.
  @mustCallSuper
  @protected
  Future<void> onDisposeAsync();
}
