import 'package:disposable_resource_management/disposable_resource_management.dart';

/// A token that performs an action on disposal.
class DisposeToken implements Disposable {
  void Function()? _onDispose;

  /// Creates a token that calls [onDispose] on disposal.
  DisposeToken(void Function() onDispose) : _onDispose = onDispose;

  /// Creates a token that calls [onDispose] on disposal with this token as a
  /// parameter.
  DisposeToken.withToken(void Function(DisposeToken) onDispose) {
    _onDispose = () => onDispose(this);
  }

  @override
  bool get isDisposed => _onDispose == null;

  @override
  void dispose() {
    _onDispose?.call();
    _onDispose = null;
  }
}
