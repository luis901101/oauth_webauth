The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

## 4.0.2+1
### Added
- Adds pub topics to package metadata.

### Changed
- Minor changes on `BaseWebView` and `OAuthWebView` to allow more flexibility when extending it.

## 4.0.1+3
### Changed
- Updated http package version to `'>=0.13.0 <2.0.0'` for better compatibility.

## 4.0.1+2
### Changed
- Added support for Dart 3.
- Replaced window singleton with FlutterView.
- Updated `clearCache` and `clearAll` functions with optional `BuildContext` to support `FlutterView`
> Thanks [@frederikstonge](https://github.com/frederikstonge)) for [PR #12](https://github.com/luis901101/oauth_webauth/pull/12) 

## 4.0.0+14
### Added
- Added support to `clearCache` and `clearCookies` directly from `OAuthWebAuth.instance`.

### Changed
- `OauthWebScreen` renamed to `OAuthWebScreen` and `OauthWebView` renamed to `OAuthWebView`.
- Full code refactor to use `BaseConfiguration(...)` and `OAuthConfiguration(...)`. See readme for migration.
- SDK constraints updated to `sdk: ">=2.19.0 <3.0.0"` and `flutter: ">=2.0.0"`.

### Fixed
- Fixed bug in redirect url handling that caused `invalid_grant` due to content after `#` in url.

## 3.1.2+13
### Fixed
- Fixed bug on BaseOAuthFlowMixin onSuccess function that caused wrong flow cancellation on baseUrl redirect.  

## 3.1.1+12
### Fixed
- Fixed bug on BaseWebView setState call after widget no longer appears in the widget tree.

## 3.1.0+11
### Added
- Detailed documentation added to OauthWebView parameters.
- New parameters added: `delimiter`, `basicAuth`, `httpClient`. Each param is described in the OauthWebView class. 

## 3.0.0+10
### Added
- Web support added. Despite this is a breaking change update, it really doesn't brake anything, you can still use it with no change required. Nevertheless if you want Web support to be enabled then you have to do an `init()` call, check README to see details.   
- `shared_preferences` dependency added to support temporary state storage.

## 2.2.0+9
### Added
- `headers` can now be set to web view.

## 2.1.0+8
### Added
- `baseUrl` added to `OauthWebView` and `OauthWebScreen` to allow to get back to application when web view gets redirected to baseUrl. A `baseUrl` redirect will be treated as a `onCancel`.

## 2.0.2+7
### Changed
- T? _ambiguate<T>(T? value) => value; implemented for compatibility reasons to avoid warnings about unnecessary null-safety operator for SchedulerBinding.instance? and WidgetsBinding.instance?.

## 2.0.1+6
### Changed
- WidgetsBinding.instance?.addObserver(this) added null-safety operator for stable channel compatibility.

## 2.0.0+5
### Added
- BaseWebView to handle basic web view with redirects. *(OAuthWebView uses this under the hook)*.
- Boolean flags for controlling toolbar buttons visibility.
- `GlobalKey`s added to BaseWebScreen and OauthWebScreen to allow webview control from outside.
- `urlStream` added to allow to asynchronously indicate web view to navigate to a different url.

### Changed
- OAuthWebView extends from BaseWebView.
- OAuthWebView `onSuccess` function changed to `onSuccessAuth`.

### Fixed
- `useHybridComposition` set to true for Android to avoid bugs with keyboard on recent Android versions > 10.
- AndroidManifest from example project updated to allow project to run in Android 12.
- Minor bugs fixed on UI state update.

## 1.1.0+3 (2022-03-02)
### Added
- `contentLocale` property can be set to indicate the web auth to use that locale for internationalization.

## 1.0.0+2
### Changed
- README updated

## 1.0.0+1
- First release
