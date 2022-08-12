import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart';
import 'package:oauth_webauth/oauth_webauth.dart';

class AuthSampleScreen extends StatefulWidget {
  const AuthSampleScreen({Key? key}) : super(key: key);

  @override
  State<AuthSampleScreen> createState() => _AuthSampleScreenState();
}

class _AuthSampleScreenState extends State<AuthSampleScreen> {
  bool isLoading = OauthWebAuth.instance.restoreCodeVerifier() != null;
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
  Locale? contentLocale;
  final locales = const [null, Locale('es'), Locale('en')];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          if (OauthWebAuth.instance.restoreCodeVerifier() != null) {
            loginV2();
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oauth login samples'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
              if (isLoading) const CircularProgressIndicator(),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<Locale>(
                  items: locales
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e?.toLanguageTag() ?? 'Default OS')))
                      .toList(),
                  value: contentLocale,
                  onChanged: (locale) {
                    setState(() {
                      contentLocale = locale;
                    });
                  },
                  decoration:
                      const InputDecoration(label: Text('Content language')),
                ),
              ),
              ElevatedButton(
                onPressed: kIsWeb ? null : loginV1,
                child: const Text(
                    'Login variant 1${kIsWeb ? '(NOT SUPPORTED ON WEB)' : ''}'),
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
        BaseWebView.backButtonTooltipKey: 'Ir atrás',
        BaseWebView.forwardButtonTooltipKey: 'Ir adelante',
        BaseWebView.reloadButtonTooltipKey: 'Recargar',
        BaseWebView.clearCacheButtonTooltipKey: 'Limpiar caché',
        BaseWebView.closeButtonTooltipKey: 'Cerrar',
        BaseWebView.clearCacheWarningMessageKey:
            '¿Está seguro que desea limpiar la caché?',
      },
      contentLocale: contentLocale,
    );
    isLoading = false;
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
          BaseWebView.backButtonTooltipKey: 'Ir atrás',
          BaseWebView.forwardButtonTooltipKey: 'Ir adelante',
          BaseWebView.reloadButtonTooltipKey: 'Recargar',
          BaseWebView.clearCacheButtonTooltipKey: 'Limpiar caché',
          BaseWebView.closeButtonTooltipKey: 'Cerrar',
          BaseWebView.clearCacheWarningMessageKey:
              '¿Está seguro que desea limpiar la caché?',
        },
        contentLocale: contentLocale,
        onSuccess: (credentials) {
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
