import 'package:oauth_webauth/src/utils/cross_platform_support.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth_webauth/oauth_webauth.dart';

class OAuthWebView extends BaseWebView {
  final String authorizationEndpointUrl;
  final String tokenEndpointUrl;
  final String redirectUrl;
  final String? baseUrl;
  final String clientId;
  final String? clientSecret;
  final List<String>? scopes;
  final String? loginHint;
  final List<String>? promptValues;

  /// This function will be called when user successfully authenticates.
  /// It will receive the Oauth Credentials
  final ValueChanged<oauth2.Credentials> onSuccessAuth;

  OAuthWebView({
    Key? key,
    required this.authorizationEndpointUrl,
    required this.tokenEndpointUrl,
    required String redirectUrl,
    this.baseUrl,
    required this.clientId,
    this.clientSecret,
    this.scopes,
    this.loginHint,
    this.promptValues,
    required this.onSuccessAuth,
    required ValueChanged<dynamic> onError,
    required VoidCallback onCancel,
    CertificateValidator? onCertificateValidate,
    ThemeData? themeData,
    Map<String, String>? textLocales,
    Locale? contentLocale,
    Map<String, String>? headers,
    Stream<String>? urlStream,
    bool? goBackBtnVisible,
    bool? goForwardBtnVisible,
    bool? refreshBtnVisible,
    bool? clearCacheBtnVisible,
    bool? closeBtnVisible,
  })  : redirectUrl =
            originUrl() != null ? redirectUrl = originUrl()! : redirectUrl,
        super(
          key: key,

          /// Initial url is obtained from getAuthorizationUrl below.
          initialUrl: '',
          redirectUrls:
              baseUrl != null ? [redirectUrl, baseUrl] : [redirectUrl],
          onError: onError,
          onCancel: onCancel,
          onCertificateValidate: onCertificateValidate,
          themeData: themeData,
          textLocales: textLocales,
          contentLocale: contentLocale,
          headers: headers,
          urlStream: urlStream,
          goBackBtnVisible: goBackBtnVisible,
          goForwardBtnVisible: goForwardBtnVisible,
          refreshBtnVisible: refreshBtnVisible,
          clearCacheBtnVisible: clearCacheBtnVisible,
          closeBtnVisible: closeBtnVisible,
        );

  @override
  OAuthWebViewState createState() => OAuthWebViewState();
}

class OAuthWebViewState extends BaseWebViewState<OAuthWebView>
    with WidgetsBindingObserver {
  late oauth2.AuthorizationCodeGrant authorizationCodeGrant;
  String? codeVerifier;

  @override
  void initBase() {
    super.initBase();
    if (kIsWeb) {
      codeVerifier = OauthWebAuth.instance.restoreCodeVerifier() ??
          OauthWebAuth.instance.generateCodeVerifier();
    }

    authorizationCodeGrant = oauth2.AuthorizationCodeGrant(
        widget.clientId,
        Uri.parse(widget.authorizationEndpointUrl),
        Uri.parse(widget.tokenEndpointUrl),
        secret: widget.clientSecret,
        codeVerifier: codeVerifier);
    initialUri = authorizationCodeGrant.getAuthorizationUrl(
      Uri.parse(widget.redirectUrl),
      scopes: widget.scopes,
    );
    initialUri = initialUri.replace(
        queryParameters: Map.from(initialUri.queryParameters)
          ..addAll({
            'state': const Base64Encoder.urlSafe()
                .convert(DateTime.now().toIso8601String().codeUnits),
            'nonce': const Base64Encoder.urlSafe().convert(
                DateTime.now().millisecondsSinceEpoch.toString().codeUnits),
            if (widget.loginHint != null) 'login_hint': widget.loginHint!,
            if (widget.promptValues?.isNotEmpty ?? false)
              'prompt': widget.promptValues!.join(' '),
          }));
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? const SizedBox() : super.build(context);
  }

  @override
  void onSuccess(String responseRedirect) async {
    if ((widget.baseUrl?.isNotEmpty ?? false) &&
        responseRedirect.startsWith(widget.baseUrl!)) {
      return onCancel();
    }

    responseRedirect = responseRedirect.trim().replaceAll('#', '');
    final parameters = Uri.dataFromString(responseRedirect).queryParameters;

    try {
      final client =
          await authorizationCodeGrant.handleAuthorizationResponse(parameters);
      clearState();
      widget.onSuccessAuth(client.credentials);
    } catch (e) {
      onError(e);
    }
  }

  @override
  void saveState() {
    super.saveState();
    if (kIsWeb) OauthWebAuth.instance.saveCodeVerifier(codeVerifier ?? '');
  }
}
