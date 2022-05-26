The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

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
