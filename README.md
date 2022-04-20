
# OAuth WebAuth

This plugin offers a WebView implementation approach for OAuth authorization/authentication with identity providers.

## Compatibility

| Platform | Compatibility |
| ------ | ------ |
| Android | :white_check_mark: |
| iOS | :white_check_mark: |
| Web | *Work in progress* |

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

**Note:**
- `contentLocale` will apply only if the authentication page supports the specified `Locale('...')` and accepts the header: `'Accept-Language': 'es-ES'`

## Migration from ^1.0.0 to ^2.0.0
- Static constants key for tooltips, message and hero tags were moved from `OAuthWebView` to `BaseWebView` 
- `OAuthWebView` renamed `onSuccess` function to `onSuccessAuth`.

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

## Usage
- This plugin offers a widget `OAuthWebView` which handles all the authorization/authentication and navigation logic; this widget can be used in any widget tree of your current app or as an individual authentication screen. For individual authentication screen it offers the widget `OAuthWebScreen` which can be started as a new route and also handles the Android back button to navigate backward when applies.
- In addition, this plugin offers a simple widget `BaseWebView` which may be useful for cases in which you need to handle a link to your Auth server, let's say for email confirmation, or password reset, etc. This widget will handle the web UI and automatically get back to you when loaded any of the specified `redirectUrls`. The `BaseWebView` widget works very similar to `OAuthWebView`, it can be used in any widget tree of your current app or as an individual screen. For individual screen it offers the widget `BaseWebScreen` which can be started as a new route and also handles the Android back button to navigate backward when applies.

#### **NOTE**: all widgets can be extended to change/improve its features.

## OAuthWebView
#### An authorization/authentication process can get 3 outputs.
1. User successfully authenticates, which returns an Oauth2 Credentials object with the access-token and refresh-token.
2. An error occurred during authorization/authentication, or maybe certificate validation failed.
3. User canceled authentication.

This plugin offers two variants to handle these outputs.

### Variant 1
Awaiting response from navigator route `Future`.
```dart
void loginV1() async {
  final result = await OAuthWebScreen.start(
      context: context,
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
      contentLocale: Locale('es'),
      refreshBtnVisible: false,
      clearCacheBtnVisible: false,
      textLocales: {
        ///Optionally texts can be localized
        OAuthWebView.backButtonTooltipKey: 'Ir atrás',
        OAuthWebView.forwardButtonTooltipKey: 'Ir adelante',
        OAuthWebView.reloadButtonTooltipKey: 'Recargar',
        OAuthWebView.clearCacheButtonTooltipKey: 'Limpiar caché',
        OAuthWebView.closeButtonTooltipKey: 'Cerrar',
        OAuthWebView.clearCacheWarningMessageKey:
        '¿Está seguro que desea limpiar la caché?',
      });
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
      contentLocale: Locale('es'),
      refreshBtnVisible: false,
      clearCacheBtnVisible: false,
      textLocales: {
        ///Optionally text can be localized
        OAuthWebView.backButtonTooltipKey: 'Ir atrás',
        OAuthWebView.forwardButtonTooltipKey: 'Ir adelante',
        OAuthWebView.reloadButtonTooltipKey: 'Recargar',
        OAuthWebView.clearCacheButtonTooltipKey: 'Limpiar caché',
        OAuthWebView.closeButtonTooltipKey: 'Cerrar',
        OAuthWebView.clearCacheWarningMessageKey:
        '¿Está seguro que desea limpiar la caché?',
      },
      onSuccess: (credentials) {
        setState(() {
          authResponse = getPrettyCredentialsJson(credentials);
        });
      },
      onError: (error) {
        setState(() {
          authResponse = error.toString();
        });
      },
      onCancel: () {
        setState(() {
          authResponse = 'User cancelled authentication';
        });
      });
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
      BaseWebView.backButtonTooltipKey: 'Ir atrás',
      BaseWebView.forwardButtonTooltipKey: 'Ir adelante',
      BaseWebView.reloadButtonTooltipKey: 'Recargar',
      BaseWebView.clearCacheButtonTooltipKey: 'Limpiar caché',
      BaseWebView.closeButtonTooltipKey: 'Cerrar',
      BaseWebView.clearCacheWarningMessageKey:
      '¿Está seguro que desea limpiar la caché?',
    },
    contentLocale: contentLocale,
    refreshBtnVisible: false,
    clearCacheBtnVisible: false,
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
        BaseWebView.backButtonTooltipKey: 'Ir atrás',
        BaseWebView.forwardButtonTooltipKey: 'Ir adelante',
        BaseWebView.reloadButtonTooltipKey: 'Recargar',
        BaseWebView.clearCacheButtonTooltipKey: 'Limpiar caché',
        BaseWebView.closeButtonTooltipKey: 'Cerrar',
        BaseWebView.clearCacheWarningMessageKey:
        '¿Está seguro que desea limpiar la caché?',
      },
      contentLocale: contentLocale,
      refreshBtnVisible: false,
      clearCacheBtnVisible: false,
      onSuccess: () {
        setState(() {
          response = 'User redirected';
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
      });
}
 ```

## Important notes
- `goBackBtnVisible`, `goForwardBtnVisible`, `refreshBtnVisible`, `clearCacheBtnVisible`, `closeBtnVisible` allows you to show/hide buttons from toolbar, if you want to completely hide toolbar, set all buttons to false.
- Use `urlStream` when you need to asynchronously navigate to a specific url, like when user registered using `OauthWebAuth` and the web view waits for user email verification; in this case when the user opens the email verification link you can navigate to this link by emitting the new url to the stream you previously set in the `urlStream` instead of creating a new `OautHWebAuth` or `BaseWebView`.
- For more details on how to use check the sample project of this plugin.
