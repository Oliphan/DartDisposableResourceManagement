import 'package:disposable_resource_management/disposable_resource_management.dart';

/// Manages the synchronous loading and disposal of a resource by providing
/// access to it via tokens.
/// When the first token is obtained the resource will be loaded.
/// When the last token is disposed the resource will be released.
class ResourceManager<inout T> {
  final Set<Disposable> _tokens;
  final T Function() _loadResource;
  final void Function(T) _releaseResource;

  T? _resource;

  /// Creates an [ResourceManager] that loads a resource with
  /// [loadResource] and releases it with [releaseResource].
  ResourceManager({
    required T Function() loadResource,
    required void Function(T) releaseResource,
  }) : _tokens = <Disposable>{},
       _loadResource = loadResource,
       _releaseResource = releaseResource;

  /// Obtains an access token for the resource, loading it if necessary.
  ResourceToken<T> obtainToken() {
    _resource ??= _loadResource();

    final token = ResourceToken<T>(
      resource: _resource as T,
      onDispose: _releaseToken,
    );

    _tokens.add(token);

    return token;
  }

  void _releaseToken(Disposable token) {
        _tokens.remove(token);
        if (_tokens.isNotEmpty) {
          return;
        }
        _releaseResource(_resource as T);
        _resource = null;
      }
}
