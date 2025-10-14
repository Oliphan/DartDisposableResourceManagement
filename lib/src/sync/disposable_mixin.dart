import 'package:disposable_resource_management/disposable_resource_management.dart';
import 'package:meta/meta.dart';

/// Implements [Disposable]'s [isDisposed] property and [dispose]
/// with once-only disposal protection.
/// Requires overriding of an [onDispose] method with the actual disposal logic.
abstract mixin class DisposableMixin implements Disposable {
  bool _disposed = false;

  @override
  bool get isDisposed => _disposed;

  @mustCallSuper
  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    onDispose();
    _disposed = true;
  }

  /// Performs one-time disposal logic.
  @mustCallSuper
  @protected
  void onDispose();
}
