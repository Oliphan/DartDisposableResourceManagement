## 4.1.0

- Updated README setup instructions to install ^4.0.0
- Added token propagation example to README
- Added `AsyncRootResourceToken` and `RootResourceToken` to manage token-tracked
  disposal of already-obtained and non-reobtainable resources.
- Added `ResourceToken.create` method
- Optimized `AsyncResourceToken.create` to use `AsyncRootResourceToken`
- Added `toToken` extension method for `Disposable` and `toAsyncToken` for
  `AsyncDisposable` to allow easily creating tokens to manage their disposal.

## 4.0.0

- \[BREAKING\] Updated `AsyncResourceToken` propagation to be synchronous as it
  does not load or dispose.
- Updated exampless to include propagation

## 3.0.0

- \[Breaking\] Added ability to propagate access via tokens. `ResourceToken` and
  `AsyncResourceToken` now require a `propagator` constructor paramater to
  facilitate this.

## 2.0.2

- Reduced meta package dependency version to 1.16.0 to fix compatibility with
  flutter sdk

## 2.0.1

- Updated examples.

## 2.0.0

- \[Breaking\] Fixed access level of `AsyncResourceManager` to be private.
- Removed exprimental variance.

## 1.0.0

- Initial version.
