import 'package:disposable_resource_management/disposable_resource_management.dart';

/// Provides extensions related to [AsyncResourceToken]
extension AsyncResourceTokenExtensions<T extends AsyncDisposable> on T {
  /// Wraps the disposable resource in an [AsyncResourceToken] to manage its
  /// access propagation and disposal.
  AsyncResourceToken<T> toAsyncToken() => AsyncRootResourceToken(
    resource: this,
    releaseResource: (resource) => resource.disposeAsync(),
  );
}
