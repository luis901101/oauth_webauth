import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth_webauth/oauth_webauth.dart';

class BaseRedirectSampleScreen extends StatefulWidget {
  const BaseRedirectSampleScreen({Key? key}) : super(key: key);

  @override
  State<BaseRedirectSampleScreen> createState() =>
      _BaseRedirectSampleScreenState();
}

class _BaseRedirectSampleScreenState extends State<BaseRedirectSampleScreen> {
  static String initialUrl =
      const String.fromEnvironment('INITIAL_URL', defaultValue: '');
  static String baseUrl = const String.fromEnvironment('BASE_URL',
      defaultValue: 'https://some.base.url.com');
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
  static String redirectUrl = originUrl() != null
      ? originUrl()!
      : const String.fromEnvironment('REDIRECT_URL',
          defaultValue: 'https://test-redirect-to.com');
  final List<String> scopes = const String.fromEnvironment('SCOPES',
          defaultValue: 'https://test-redirect-to.com')
      .split(' ');

  String response = 'Response feedback will be shown here';
  Locale? contentLocale;
  final locales = const [null, Locale('es'), Locale('en')];

  @override
  void initState() {
    super.initState();

    /// Here a validation to generate a valid initialUrl from OAuth data
    if (initialUrl.isEmpty) {
      final authorizationCodeGrant = oauth2.AuthorizationCodeGrant(
        clientId,
        Uri.parse(authorizationEndpointUrl),
        Uri.parse(tokenEndpointUrl),
        secret: clientSecret,
      );
      Uri initialUri = authorizationCodeGrant.getAuthorizationUrl(
        Uri.parse(redirectUrl),
        scopes: scopes,
      );

      initialUri = initialUri.replace(
          queryParameters: Map.from(initialUri.queryParameters)
            ..addAll({
              'state': const Base64Encoder.urlSafe()
                  .convert(DateTime.now().toIso8601String().codeUnits),
              'nonce': const Base64Encoder.urlSafe().convert(
                  DateTime.now().millisecondsSinceEpoch.toString().codeUnits),
            }));
      initialUrl = initialUri.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base redirect samples'),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                response,
              ),
              const SizedBox(height: 16),
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
                onPressed: kIsWeb ? null : baseRedirectV1,
                child: const Text(
                    'Base redirect variant 1${kIsWeb ? '(NOT SUPPORTED ON WEB)' : ''}'),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
              ),
              const SizedBox(height: 4),
              ElevatedButton(
                onPressed: baseRedirectV2,
                child: const Text('Base redirect 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        onSuccess: (responseRedirect) {
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
        });
  }
}
