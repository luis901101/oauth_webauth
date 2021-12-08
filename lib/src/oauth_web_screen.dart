import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:oauth_webauth/src/oauth_web_view.dart';

class OAuthWebScreen extends StatelessWidget {
  static Future? start(
          {Key? key,
          required BuildContext context,
          required String authorizationEndpointUrl,
          required String tokenEndpointUrl,
          required String redirectUrl,
          required String clientId,
          String? clientSecret,
          List<String>? scopes,
          String? loginHint,
          List<String>? promptValues,
          ValueChanged<Credentials>? onSuccess,
          ValueChanged<dynamic>? onError,
          VoidCallback? onCancel,
          CertificateValidator? onCertificateValidate,
          ThemeData? themeData,
          Map<String, String>? textLocales}) =>
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OAuthWebScreen(
                    authorizationEndpointUrl: authorizationEndpointUrl,
                    tokenEndpointUrl: tokenEndpointUrl,
                    redirectUrl: redirectUrl,
                    clientId: clientId,
                    clientSecret: clientSecret,
                    scopes: scopes,
                    loginHint: loginHint,
                    promptValues: promptValues,
                    onSuccess: onSuccess,
                    onError: onError,
                    onCancel: onCancel,
                    onCertificateValidate: onCertificateValidate,
                    themeData: themeData,
                    textLocales: textLocales,
                  )));

  final String authorizationEndpointUrl;
  final String tokenEndpointUrl;
  final String redirectUrl;
  final String clientId;
  final String? clientSecret;
  final List<String>? scopes;
  final String? loginHint;
  final List<String>? promptValues;

  /// This function will be called when user successfully authenticates.
  /// It will receive the Oauth Credentials
  final ValueChanged<Credentials>? onSuccess;

  /// This function will be called if any error occurs.
  /// It will receive the error data which could be some Exception or Error
  final ValueChanged<dynamic>? onError;

  /// This function will be called when user cancels authentication.
  final VoidCallback? onCancel;

  /// This function will be called when [authorizationEndpointUrl] is first loaded.
  final CertificateValidator? onCertificateValidate;

  final ThemeData? themeData;
  final Map<String, String>? textLocales;

  late final BuildContext context;
  final paymentViewStateKey = GlobalKey<OAuthWebViewState>();

  OAuthWebScreen({
    Key? key,
    required this.authorizationEndpointUrl,
    required this.tokenEndpointUrl,
    required this.redirectUrl,
    required this.clientId,
    this.clientSecret,
    this.scopes,
    this.loginHint,
    this.promptValues,
    this.onSuccess,
    this.onError,
    this.onCancel,
    this.onCertificateValidate,
    this.themeData,
    this.textLocales,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        this.context = context;
        return Scaffold(
          body: WillPopScope(
            onWillPop: onBackPressed,
            child: OAuthWebView(
              key: paymentViewStateKey,
              authorizationEndpointUrl: authorizationEndpointUrl,
              tokenEndpointUrl: tokenEndpointUrl,
              clientId: clientId,
              clientSecret: clientSecret,
              redirectUrl: redirectUrl,
              scopes: scopes,
              loginHint: loginHint,
              promptValues: promptValues,
              onSuccess: _onSuccess,
              onError: _onError,
              onCancel: _onCancel,
              onCertificateValidate: onCertificateValidate,
              themeData: themeData,
              textLocales: textLocales,
            ),
          ),
        );
      },
    );
  }

  void _onSuccess(Credentials credentials) {
    Navigator.pop(context, credentials);
    onSuccess?.call(credentials);
  }

  void _onError(dynamic error) {
    Navigator.pop(context, error);
    onError?.call(error);
  }

  void _onCancel() {
    Navigator.pop(context);
    onCancel?.call();
  }

  Future<bool> onBackPressed() async {
    if (!((await paymentViewStateKey.currentState?.onBackPressed()) ?? false)) {
      return false;
    }
    onCancel?.call();
    return true;
  }
}
