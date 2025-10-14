import 'package:disposable_resource_management/disposable_resource_management.dart';

/// A token that performs an asynchronous action on disposal.
class AsyncDisposeToken implements AsyncDisposable {
  Future<void> Function()? _onDispose;

  /// Creates a token that calls [onDispose] on disposal.
  AsyncDisposeToken(Future<void> Function() onDispose) : _onDispose = onDispose;

  /// Creates a token that calls [onDispose] on disposal with this token as a
  /// parameter.
  AsyncDisposeToken.withToken(
    Future<void> Function(AsyncDisposeToken) onDispose,
  ) {
    _onDispose = () => onDispose(this);
  }

  @override
  bool get isDisposed => _onDispose == null;

  @override
  Future<void> disposeAsync() async {
    await _onDispose?.call();
    _onDispose = null;
  }
}
