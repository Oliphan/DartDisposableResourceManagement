import 'package:disposable_resource_management/disposable_resource_management.dart';

/// Provides extensions related to [ResourceToken]
extension ResourceTokenExtensions<T extends Disposable> on T {
  /// Wraps the disposable resource in an [ResourceToken] to manage its access
  /// propagation and disposal.
  ResourceToken<T> toToken() => RootResourceToken(
    resource: this,
    releaseResource: (resource) => resource.dispose(),
  );
}
