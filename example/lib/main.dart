import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:oauth_webauth/oauth_webauth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Oauth WebAuth example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String authorizationEndpointUrl = String.fromEnvironment(
      'AUTHORIZATION_ENDPOINT_URL',
      defaultValue: 'https://test-auth-endpoint.com');
  static const String tokenEndpointUrl = String.fromEnvironment(
      'TOKEN_ENDPOINT_URL',
      defaultValue: 'https://test-token-endpoint.com');
  static const String clientSecret =
      String.fromEnvironment('CLIENT_SECRET', defaultValue: 'XXXXXXXXX');
  static const String clientId =
      String.fromEnvironment('CLIENT_ID', defaultValue: 'realmClientID');
  static const String redirectUrl = String.fromEnvironment('REDIRECT_URL',
      defaultValue: 'https://test-redirect-to.com');
  final List<String> scopes = const String.fromEnvironment('SCOPES',
          defaultValue: 'https://test-redirect-to.com')
      .split(' ');

  String authResponse = 'Authorization data will be shown here';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                authResponse,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loginV1,
                child: const Text('Login variant 1'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: loginV2,
                child: const Text('Login variant 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  String getPrettyCredentialsJson(Credentials credentials) {
    final jsonMap = {
      'access_token': credentials.accessToken,
      'refresh_token': credentials.refreshToken,
      'id_token': credentials.idToken,
      'token_endpoint': credentials.tokenEndpoint?.toString(),
      'scopes': credentials.scopes,
      'expiration': credentials.expiration?.millisecondsSinceEpoch
    };
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }
}
