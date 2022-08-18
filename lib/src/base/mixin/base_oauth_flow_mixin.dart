import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth_webauth/oauth_webauth.dart';

mixin BaseOAuthFlowMixin on BaseFlowMixin {
  late oauth2.AuthorizationCodeGrant authorizationCodeGrant;
  String? codeVerifier;

  /// This function will be called when user successfully authenticates.
  /// It will receive the Oauth Credentials
  ValueChanged<oauth2.Credentials>? onSuccessAuth;
  String? baseUrl;

  void initOauth({
    required final String authorizationEndpointUrl,
    required final String tokenEndpointUrl,
    required String redirectUrl,
    final String? baseUrl,
    required final String clientId,
    final String? clientSecret,
    final String? delimiter,
    final bool? basicAuth,
    final http.Client? httpClient,
    final List<String>? scopes,
    final String? loginHint,
    final List<String>? promptValues,
    required ValueChanged<oauth2.Credentials> onSuccessAuth,
    ValueChanged<dynamic>? onError,
    VoidCallback? onCancel,
  }) {
    redirectUrl =
        originUrl() != null ? redirectUrl = originUrl()! : redirectUrl;
    this.baseUrl = baseUrl;
    this.onSuccessAuth = onSuccessAuth;
    super.init(
      redirectUrls: baseUrl != null ? [redirectUrl, baseUrl] : [redirectUrl],
      onError: onError,
      onCancel: onCancel,
    );

    if (kIsWeb) {
      codeVerifier = OauthWebAuth.instance.restoreCodeVerifier() ??
          OauthWebAuth.instance.generateCodeVerifier();
    }

    authorizationCodeGrant = oauth2.AuthorizationCodeGrant(
        clientId,
        Uri.parse(authorizationEndpointUrl), Uri.parse(tokenEndpointUrl),
        secret: clientSecret, codeVerifier: codeVerifier,
        delimiter: delimiter,
        basicAuth: basicAuth ?? true,
        httpClient: httpClient,
    );
    initialUri = authorizationCodeGrant.getAuthorizationUrl(
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
            if (loginHint != null) 'login_hint': loginHint,
            if (promptValues?.isNotEmpty ?? false)
              'prompt': promptValues!.join(' '),
          }));
  }

  @override
  void onSuccess(String responseRedirect) async {
    if ((baseUrl?.isNotEmpty ?? false) &&
        responseRedirect.startsWith(baseUrl!)) {
      return onCancel();
    }

    responseRedirect = responseRedirect.trim().replaceAll('#', '');
    final parameters = Uri.dataFromString(responseRedirect).queryParameters;

    try {
      final client =
          await authorizationCodeGrant.handleAuthorizationResponse(parameters);
      clearState();
      onSuccessAuth?.call(client.credentials);
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
