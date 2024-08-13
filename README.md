
# OAuth WebAuth

This plugin offers a WebView implementation approach for OAuth authorization/authentication with identity providers. In the case of Web it doesn't use WebView, instead it loads the page directly in the browser.

## Compatibility

| Platform | Compatibility |
| ------ | ------ |
| Android | :white_check_mark: |
| iOS | :white_check_mark: |
| Web | :white_check_mark: |

## Preamble
Other plugins like [Flutter AppAuth](https://pub.dev/packages/flutter_appauth) uses native implementation of [AppAuth](https://appauth.io/) which in turn uses `SFAuthenticationSession` and `CustomTabs` for iOS and Android respectively. When using `SFAuthenticationSession` and `CustomTabs` your app will/could present some problems like:
- UI: users will notice a breaking UI difference when system browser opens to handle the identity provider authentication process.
- In iOS an annoying system dialog shows up every time the user tries to authenticate, indicating that the current app and browser could share their information.
- Your system browser cache is shared with your app which is good and **bad**, bad because any cache problem due to your every day navigation use could affect your app authentication and the only way to clean cache it's by cleaning system browser cache at operating system level.
- Authentication page will use the locale from System Browser which in fact uses the Operating System locale, this means if your app uses different language than the Operating System then authentication page will show different internationalization than your app.

## Features
With this plugin you will get:
- Full control over the UI, WebView will run inside your app so Theme and Color Scheme will be yours to choose, in fact you can add AppBar or FloatingActionButton or whatever you thinks it's necessary to your UI.
- No system dialog will be shown when users tries to authenticate.
- Users will not be affected by any system browser problem cache and also will be able to clean app browser cache from the authentication screen itself.
- Authentication page locale can be set from app using the `contentLocale` property to ensure the same locale. By default Operating System locale will be used if no `contentLocale` is specified.
- Custom headers can be set if necessary.
- Custom UserAgent can be set if necessary.

**Notes:**
- `contentLocale` will apply only if the authentication page supports the specified `Locale('...')` and accepts the header: `'Accept-Language': 'es-ES'`.
- Web implementation deson't allow `contentLocale`, custom headers, custom UserAgent, nor full control over UI, because web implementation loads the page directly in the browser.

## Migration from ^1.0.0 to ^2.0.0
- Static constants key for tooltips, message and hero tags were moved from `OAuthWebView` to `BaseWebView`
- `OAuthWebView` renamed `onSuccess` function to `onSuccessAuth`.

## Migration from ^2.0.0 to ^3.0.0
Probably you will not need to do any migration. You only need to do changes:
- If you override some of the plugin widgets in your code, you will have to check for the differences and apply it to your code.
- If you plan to support web you will have to initialize the plugin, this is explained below in the **Initialization** section.

## Migration from ^3.0.0 to ^4.0.0
- Static constants key for tooltips, message and hero tags were moved from `BaseWebView` to `BaseConfiguration`.
- `OAuthWebScreen` and `OAuthWebView` now requires a `OAuthConfiguration` object and `BaseWebScreen` and `BaseWebView` now requires a `BaseConfiguration` object instead of properties directly.
- Make sure your pubspec `environment` fits the following constraints: `sdk: ">=2.19.0 <3.0.0"` and `flutter: ">=2.0.0"`.

## Migration from ^4.0.0 to ^5.0.0
- `OAuthWebAuth.clearAll({BuildContext? context, InAppWebViewController? controller})` to `OAuthWebAuth.clearAll()`, no params required.
- `OAuthWebAuth.clearCache({BuildContext? context, InAppWebViewController? controller})` to `OAuthWebAuth.clearCache()`, no params required.
- As this version uses `flutter_inappwebview: ^6.0.0` which already supports web, it's required *(only if your project supports web)* to include a script in the `index.html` <head> like: `<script type="application/javascript" src="/assets/packages/flutter_inappwebview_web/assets/web/web_support.js" defer></script>`, anyway we recommend you to check the readme of [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) for more details.
- Make sure your pubspec `environment` fits the following constraints: `sdk: ">=3.0.0 <4.0.0"` and `flutter: '>=3.3.0'`.

## Getting started
As stated before this plugin uses WebView implementation specifically the plugin [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview). For any WebView related problem please check the documentation of that plugin at [docs](https://inappwebview.dev/docs/).

### Android setup
Just add the internet permission to your `AndroidManifest`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.example.example">  
    <uses-permission android:name="android.permission.INTERNET"/>  
 <application>  
    ...
 </application>
```

### iOS setup
Just add this to your `Info.plist`

```xml
<plist version="1.0">  
<dict>
    ....
    ....
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    ....
    ....
</dict>  
</plist>
```

### Web setup
To make it work properly on the Web platform, you need to add the `web_support.js` file inside the `<head>` of your `web/index.html` file:

```html
<head>
    <!-- ... -->
    <script type="application/javascript" src="/assets/packages/flutter_inappwebview_web/assets/web/web_support.js" defer></script>
    <!-- ... -->
</head>
```  

## Usage
- This plugin offers a widget `OAuthWebView` which handles all the authorization/authentication and navigation logic; this widget can be used in any widget tree of your current app or as an individual authentication screen. For individual authentication screen it offers the widget `OAuthWebScreen` which can be started as a new route and also handles the Android back button to navigate backward when applies.
- In addition, this plugin offers a simple widget `BaseWebView` which may be useful for cases in which you need to handle a link to your Auth server, let's say for email confirmation, or password reset, etc. This widget will handle the web UI and automatically get back to you when loaded any of the specified `redirectUrls`. The `BaseWebView` widget works very similar to `OAuthWebView`, it can be used in any widget tree of your current app or as an individual screen. For individual screen it offers the widget `BaseWebScreen` which can be started as a new route and also handles the Android back button to navigate backward when applies.

#### **NOTE**: all widgets can be extended to change/improve its features.

### Initialization
In the `main()` function you should initialize this plugin just before runApp(...):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await OAuthWebAuth.instance.init();
  runApp(const MyApp());
}
```
#### IMPORTANT:
- Note that it's required to call `WidgetsFlutterBinding.ensureInitialized();` before `.init()`. In the case of testing `TestWidgetsFlutterBinding.ensureInitialized()` should be called.
- **The plugin initialization is only required for Web, if you plan to use this plugin only for iOS or Android you can ignore initialization.**

## OAuthWebView
#### An authorization/authentication process can get 3 outputs.
1. User successfully authenticates, which returns an OAuth2 Credentials object with the access-token and refresh-token.
2. An error occurred during authorization/authentication, or maybe certificate validation failed.
3. User canceled authentication.

This plugin offers two variants to handle these outputs.

### Variant 1
Awaiting response from navigator route `Future`.
```dart
void loginV1() async {
  final result = await OAuthWebScreen.start(
      context: context,
      configuration: OAuthConfiguration(
        authorizationEndpointUrl: authorizationEndpointUrl,
        tokenEndpointUrl: tokenEndpointUrl,
        clientSecret: clientSecret,
        clientId: clientId,
        redirectUrl: redirectUrl,
        scopes: scopes,
        promptValues: const ['login'],
        loginHint: 'johndoe@mail.com',
        onCertificateValidate: (certificate) {
          ///This is recommended
          /// Do certificate validations here
          /// If false is returned then a CertificateException() will be thrown
          return true;
        },
        textLocales: {
          ///Optionally texts can be localized
          BaseConfiguration.backButtonTooltipKey: 'Ir atrás',
          BaseConfiguration.forwardButtonTooltipKey: 'Ir adelante',
          BaseConfiguration.reloadButtonTooltipKey: 'Recargar',
          BaseConfiguration.clearCacheButtonTooltipKey: 'Limpiar caché',
          BaseConfiguration.closeButtonTooltipKey: 'Cerrar',
          BaseConfiguration.clearCacheWarningMessageKey:
          '¿Está seguro que desea limpiar la caché?',
        },
        contentLocale: Locale('es'),
        refreshBtnVisible: false,
        clearCacheBtnVisible: false,
      ));
  if (result != null) {
    if (result is Credentials) {
      authResponse = getPrettyCredentialsJson(result);
    } else {
      authResponse = result.toString();
    }
  } else {
    authResponse = 'User cancelled authentication';
  }
  setState(() {});
}
```

### Variant2
Using callbacks
 ```dart
void loginV2() {
  OAuthWebScreen.start(
      context: context,
      configuration: OAuthConfiguration(
          authorizationEndpointUrl: authorizationEndpointUrl,
          tokenEndpointUrl: tokenEndpointUrl,
          clientSecret: clientSecret,
          clientId: clientId,
          redirectUrl: redirectUrl,
          scopes: scopes,
          promptValues: const ['login'],
          loginHint: 'johndoe@mail.com',
          onCertificateValidate: (certificate) {
            ///This is recommended
            /// Do certificate validations here
            /// If false is returned then a CertificateException() will be thrown
            return true;
          },
          textLocales: {
            ///Optionally text can be localized
            BaseConfiguration.backButtonTooltipKey: 'Ir atrás',
            BaseConfiguration.forwardButtonTooltipKey: 'Ir adelante',
            BaseConfiguration.reloadButtonTooltipKey: 'Recargar',
            BaseConfiguration.clearCacheButtonTooltipKey: 'Limpiar caché',
            BaseConfiguration.closeButtonTooltipKey: 'Cerrar',
            BaseConfiguration.clearCacheWarningMessageKey:
                '¿Está seguro que desea limpiar la caché?',
          },
          contentLocale: Locale('es'),
          refreshBtnVisible: false,
          clearCacheBtnVisible: false,
          onSuccessAuth: (credentials) {
            isLoading = false;
            setState(() {
              authResponse = getPrettyCredentialsJson(credentials);
            });
          },
          onError: (error) {
            isLoading = false;
            setState(() {
              authResponse = error.toString();
            });
          },
          onCancel: () {
            isLoading = false;
            setState(() {
              authResponse = 'User cancelled authentication';
            });
          }),
    );
}
 ```

## BaseWebView
#### 3 possible outputs.
1. User is successfully redirected, which returns the full redirect url.
2. An error occurred during navigation.
3. User canceled web view.

This plugin offers two variants to handle these outputs.

### Variant 1
Awaiting response from navigator route `Future`.
```dart
void baseRedirectV1() async {
  final result = await BaseWebScreen.start(
      context: context,
      configuration: BaseConfiguration(
        initialUrl: initialUrl,
        redirectUrls: [redirectUrl, baseUrl],
        onCertificateValidate: (certificate) {
          ///This is recommended
          /// Do certificate validations here
          /// If false is returned then a CertificateException() will be thrown
          return true;
        },
        textLocales: {
          ///Optionally texts can be localized
          BaseConfiguration.backButtonTooltipKey: 'Ir atrás',
          BaseConfiguration.forwardButtonTooltipKey: 'Ir adelante',
          BaseConfiguration.reloadButtonTooltipKey: 'Recargar',
          BaseConfiguration.clearCacheButtonTooltipKey: 'Limpiar caché',
          BaseConfiguration.closeButtonTooltipKey: 'Cerrar',
          BaseConfiguration.clearCacheWarningMessageKey:
              '¿Está seguro que desea limpiar la caché?',
        },
        contentLocale: Locale('es'),
        refreshBtnVisible: false,
        clearCacheBtnVisible: false,
      ),
    );
  if (result != null) {
    if (result is String) {
      /// If result is String it means redirected successful
      response = 'User redirected to: $result';
    } else {
      /// If result is not String then some error occurred
      response = result.toString();
    }
  } else {
    /// If no result means user cancelled
    response = 'User cancelled';
  }
  setState(() {});
}
```

### Variant2
Using callbacks
 ```dart
void baseRedirectV2() {
  BaseWebScreen.start(
      context: context,
      configuration: BaseConfiguration(
          initialUrl: initialUrl,
          redirectUrls: [redirectUrl, baseUrl],
          onCertificateValidate: (certificate) {
            ///This is recommended
            /// Do certificate validations here
            /// If false is returned then a CertificateException() will be thrown
            return true;
          },
          textLocales: {
            ///Optionally text can be localized
            BaseConfiguration.backButtonTooltipKey: 'Ir atrás',
            BaseConfiguration.forwardButtonTooltipKey: 'Ir adelante',
            BaseConfiguration.reloadButtonTooltipKey: 'Recargar',
            BaseConfiguration.clearCacheButtonTooltipKey: 'Limpiar caché',
            BaseConfiguration.closeButtonTooltipKey: 'Cerrar',
            BaseConfiguration.clearCacheWarningMessageKey:
                '¿Está seguro que desea limpiar la caché?',
          },
          contentLocale: Locale('es'),
          refreshBtnVisible: false,
          clearCacheBtnVisible: false,
          onSuccessRedirect: (responseRedirect) {
            setState(() {
              response = 'User redirected to: $responseRedirect';
            });
          },
          onError: (error) {
            setState(() {
              response = error.toString();
            });
          },
          onCancel: () {
            setState(() {
              response = 'User cancelled';
            });
          }),
    );
}
 ```

## Important notes
- `goBackBtnVisible`, `goForwardBtnVisible`, `refreshBtnVisible`, `clearCacheBtnVisible`, `closeBtnVisible` allows you to show/hide buttons from toolbar, if you want to completely hide toolbar, set all buttons to false.
- Use `urlStream` when you need to asynchronously navigate to a specific url, like when user registered using `OAuthWebAuth` and the web view waits for user email verification; in this case when the user opens the email verification link you can navigate to this link by emitting the new url to the stream you previously set in the `urlStream` instead of creating a new `OAuthWebAuth` or `BaseWebView`.
- You can clear cache, clear cookies or both directly from `OAuthWebAuth.instance`, like `OAuthWebAuth.instance.clearCache()`, `OAuthWebAuth.instance.clearCookies()` or `OAuthWebAuth.instance.clearAll()`.
- For more details on how to use check the sample project of this plugin.

## Authentication/Authorization services tested
- Keycloak
- Auth0

*Note: It should work with any OAuth2 comatible service that uses **Authorization Code Grant***