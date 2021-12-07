
# OAuth WebAuth

This plugin offers a WebView implementation approach for OAuth authorization/authentication with identity providers.

## Preamble
Other plugins like [Flutter AppAuth](https://pub.dev/packages/flutter_appauth) uses native implementation of [AppAuth](https://appauth.io/) which in turn uses `SFAuthenticationSession` and `CustomTabs` for iOS and Android respectively. When using `SFAuthenticationSession` and `CustomTabs` your app will/could present some problems like:
- UI: users will notice a breaking UI difference when system browser opens to handle the identity provider authentication process.
- In iOS an annoying system dialog shows up every time the user tries to authenticate, indicating that the current app and browser could share their information.
- Your system browser cache is shared with your app which is good and **bad**, bad because any cache problem due to your every day navigation use could affect your app authentication and the only way to clean cache it's by cleaning system browser cache at operating system level.

## Features

With this plugin you will get:
- Full control over the UI, WebView will run inside your app so Theme and Color Scheme will be yours to choose, in fact you can add AppBar or FloatingActionButton or whatever you thinks it's necessary to your UI.
- No system dialog will be shown when users tries to authenticate.
- Users will not be affected by any system browser problem cache and also will be able to clean app browser cache from the authentication screen itself.

## Getting started

As stated before this plugin uses WebView implementation specifically the official plugin [webview_flutter](https://pub.dev/packages/webview_flutter). For any WebView related problem please check the documentation of that plugin.

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
This plugin offers a widget `OAuthWebView` which handles all the authorization/authentication and navigation logic; this widget can be used in any widget tree of your current app or as an individual authentication screen. For individual authentication screen it offers the widget `OAuthWebScreen` which can be started as a new route and also handles the Android back button to navigate backward when applies.
**NOTE**: both widgets can be extended to change/improve its features.

#### An authorization/authentication process can get 3 outputs.
1. User successfully authenticates
2. An error occurred during authorization/authentication
3. User canceled authentication

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
	textLocales: { ///Optionally texts can be localized  
	  OAuthWebView.backButtonTooltipKey: 'Ir atrás',  
	  OAuthWebView.forwardButtonTooltipKey: 'Ir adelante',  
	  OAuthWebView.reloadButtonTooltipKey: 'Recargar',  
	  OAuthWebView.clearCacheButtonTooltipKey: 'Limpiar caché',  
	  OAuthWebView.closeButtonTooltipKey: 'Cerrar',  
	  OAuthWebView.clearCacheWarningMessageKey: '¿Está seguro que desea limpiar la caché?',  
	}  
  );  
  if(result != null) {  
    if(result is Credentials) {  
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
	textLocales: { ///Optionally text can be localized  
	OAuthWebView.backButtonTooltipKey: 'Ir atrás',  
	OAuthWebView.forwardButtonTooltipKey: 'Ir adelante',  
	OAuthWebView.reloadButtonTooltipKey: 'Recargar',  
	OAuthWebView.clearCacheButtonTooltipKey: 'Limpiar caché',  
	OAuthWebView.closeButtonTooltipKey: 'Cerrar',  
	OAuthWebView.clearCacheWarningMessageKey: '¿Está seguro que desea limpiar la caché?',  
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
  }  
  );  
}
 ```