import 'package:disposable_resource_management/disposable_resource_management.dart';
import 'package:synchronized/synchronized.dart';

/// Manages the asynchronous loading and disposal of a resource by providing
/// access to it via tokens.
/// When the first token is obtained the resource will be loaded.
/// When the last token is disposed the resource will be released.
class AsyncResourceManager<T> {
  final Set<AsyncDisposable> _tokens;
  final Future<T> Function() _loadResource;
  final Future<void> Function(T) _releaseResource;
  final Lock _loadReleaseLock = Lock();

  T? _resource;

  /// Creates an [AsyncResourceManager] that loads a resource with
  /// [loadResource] and releases it with [releaseResource].
  AsyncResourceManager({
    required Future<T> Function() loadResource,
    required Future<void> Function(T) releaseResource,
  }) : _tokens = <AsyncDisposable>{},
       _loadResource = loadResource,
       _releaseResource = releaseResource;

  /// Obtains an access token for the resource, loading it if necessary.
  Future<AsyncResourceToken<T>> obtainToken() =>
      _loadReleaseLock.synchronized(() async {
        _resource ??= await _loadResource();
        return _createToken();
      });

  AsyncResourceToken<T> _createToken() {
    final token = AsyncResourceToken<T>(
      resource: _resource as T,
      onDispose: _releaseToken,
      propagator: _createToken,
    );

    _tokens.add(token);

    return token;
  }

  Future<void> _releaseToken(AsyncDisposable token) =>
      _loadReleaseLock.synchronized(() async {
        _tokens.remove(token);
        if (_tokens.isNotEmpty) {
          return;
        }
        await _releaseResource(_resource as T);
        _resource = null;
      });
}
