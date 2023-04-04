import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:oauth_webauth/oauth_webauth.dart';

mixin BaseOAuthFlowMixin on BaseFlowMixin {
  late oauth2.AuthorizationCodeGrant authorizationCodeGrant;
  String? codeVerifier;

  /// This function will be called when user successfully authenticates.
  /// It will receive the OAuth Credentials
  ValueChanged<oauth2.Credentials>? onSuccessAuth;
  String? baseUrl;

  void initOAuth({
    required OAuthConfiguration configuration,
  }) {
    final redirectUrl =
        originUrl() != null ? originUrl()! : configuration.redirectUrl;
    baseUrl = configuration.baseUrl;
    onSuccessAuth = configuration.onSuccessAuth;
    super.init(
      redirectUrls: baseUrl != null ? [redirectUrl, baseUrl!] : [redirectUrl],
      onError: configuration.onError,
      onCancel: configuration.onCancel,
    );

    if (kIsWeb) {
      codeVerifier = OAuthWebAuth.instance.restoreCodeVerifier() ??
          OAuthWebAuth.instance.generateCodeVerifier();
    }

    authorizationCodeGrant = oauth2.AuthorizationCodeGrant(
      configuration.clientId,
      Uri.parse(configuration.authorizationEndpointUrl),
      Uri.parse(configuration.tokenEndpointUrl),
      secret: configuration.clientSecret,
      codeVerifier: codeVerifier,
      delimiter: configuration.delimiter,
      basicAuth: configuration.basicAuth ?? true,
      httpClient: configuration.httpClient,
    );
    initialUri = authorizationCodeGrant.getAuthorizationUrl(
      Uri.parse(redirectUrl),
      scopes: configuration.scopes,
    );
    initialUri = initialUri.replace(
        queryParameters: Map.from(initialUri.queryParameters)
          ..addAll({
            'state': const Base64Encoder.urlSafe()
                .convert(DateTime.now().toIso8601String().codeUnits),
            'nonce': const Base64Encoder.urlSafe().convert(
                DateTime.now().millisecondsSinceEpoch.toString().codeUnits),
            if (configuration.loginHint != null)
              'login_hint': configuration.loginHint,
            if (configuration.promptValues?.isNotEmpty ?? false)
              'prompt': configuration.promptValues!.join(' '),
          }));
  }

  @override
  void onSuccess(String responseRedirect) async {
    try {
      responseRedirect = responseRedirect.trim();
      final int ignoreStartIndex = responseRedirect.indexOf('#');
      if (ignoreStartIndex > -1) {
        responseRedirect = responseRedirect.substring(0, ignoreStartIndex);
      }
      final parameters = Uri.dataFromString(responseRedirect).queryParameters;

      if (parameters.isEmpty &&
          (baseUrl?.isNotEmpty ?? false) &&
          responseRedirect.startsWith(baseUrl!)) {
        return onCancel();
      }

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
    if (kIsWeb) OAuthWebAuth.instance.saveCodeVerifier(codeVerifier ?? '');
  }
}
