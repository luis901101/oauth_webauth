import 'package:flutter/material.dart';
import 'package:oauth_webauth/oauth_webauth.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

class OAuthConfiguration extends BaseConfiguration {
  /// A URL provided by the authorization server that serves as the base for the
  /// URL that the resource owner will be redirected to to authorize this
  /// client.
  ///
  /// This will usually be listed in the authorization server's OAuth2 API
  /// documentation.
  final String authorizationEndpointUrl;

  /// A URL provided by the authorization server that this library uses to
  /// obtain long-lasting credentials.
  ///
  /// This will usually be listed in the authorization server's OAuth2 API
  /// documentation.
  final String tokenEndpointUrl;

  /// The redirectUrl to which the authorization server will redirect to when
  /// authorization flow completes.
  final String redirectUrl;

  /// It is another redirectUrl to be used by the authorization server when the
  /// user decides to go back to application instead of completing
  /// authorization flow.
  final String? baseUrl;

  /// The client identifier for this client.
  ///
  /// The authorization server will issue each client a separate client
  /// identifier and secret, which allows the server to tell which client is
  /// accessing it. Some servers may also have an anonymous identifier/secret
  /// pair that any client may use.
  ///
  /// This is usually global to the program using this library.
  final String clientId;

  /// The client secret for this client.
  ///
  /// The authorization server will issue each client a separate client
  /// identifier and secret, which allows the server to tell which client is
  /// accessing it. Some servers may also have an anonymous identifier/secret
  /// pair that any client may use.
  ///
  /// This is usually global to the program using this library.
  ///
  /// Note that clients whose source code or binary executable is readily
  /// available may not be able to make sure the client secret is kept a secret.
  /// This is fine; OAuth2 servers generally won't rely on knowing with
  /// certainty that a client is who it claims to be.
  final String? clientSecret;

  /// A [String] used to separate scopes; defaults to `" "`.
  final String? delimiter;

  /// Whether to use HTTP Basic authentication for authorizing the client.
  final bool? basicAuth;

  /// The HTTP client used to make HTTP requests.
  final http.Client? httpClient;

  /// The scopes that the client is requesting access to.
  final List<String>? scopes;

  /// /// Hint to the Authorization Server about the login identifier the End-User might use to log in.
  final String? loginHint;

  /// List of ASCII string values that specifies whether the Authorization Server prompts the End-User for re-authentication and consent.
  /// e.g: promptValues: ['login'].
  /// In this case it prompts the user login even if they have already signed in.
  /// The list of supported values depends on the identity provider.
  final List<String>? promptValues;

  /// This function will be called when user successfully authenticates.
  /// It will receive the OAuth Credentials
  final ValueChanged<oauth2.Credentials>? onSuccessAuth;

  const OAuthConfiguration({
    required this.authorizationEndpointUrl,
    required this.tokenEndpointUrl,
    required this.redirectUrl,
    this.baseUrl,
    required this.clientId,
    this.clientSecret,
    this.delimiter,
    this.basicAuth,
    this.httpClient,
    this.scopes,
    this.loginHint,
    this.promptValues,
    this.onSuccessAuth,
    super.onError,
    super.onCancel,
    super.onCertificateValidate,
    super.headers,
    super.urlStream,
    super.themeData,
    super.textLocales,
    super.contentLocale,
    super.goBackBtnVisible,
    super.goForwardBtnVisible,
    super.refreshBtnVisible,
    super.clearCacheBtnVisible,
    super.closeBtnVisible,
  }) : super(
          initialUrl: '',
          redirectUrls: const [],
        );

  const OAuthConfiguration._({
    required this.authorizationEndpointUrl,
    required this.tokenEndpointUrl,
    required this.redirectUrl,
    this.baseUrl,
    required this.clientId,
    this.clientSecret,
    this.delimiter,
    this.basicAuth,
    this.httpClient,
    this.scopes,
    this.loginHint,
    this.promptValues,
    this.onSuccessAuth,
    super.initialUrl = '',
    super.redirectUrls = const [],
    super.onSuccessRedirect,
    super.onError,
    super.onCancel,
    super.onCertificateValidate,
    super.headers,
    super.urlStream,
    super.themeData,
    super.textLocales,
    super.contentLocale,
    super.goBackBtnVisible,
    super.goForwardBtnVisible,
    super.refreshBtnVisible,
    super.clearCacheBtnVisible,
    super.closeBtnVisible,
  });

  @override
  OAuthConfiguration copyWith({
    String? authorizationEndpointUrl,
    String? tokenEndpointUrl,
    String? redirectUrl,
    String? baseUrl,
    String? clientId,
    String? clientSecret,
    String? delimiter,
    bool? basicAuth,
    http.Client? httpClient,
    List<String>? scopes,
    String? loginHint,
    List<String>? promptValues,
    ValueChanged<oauth2.Credentials>? onSuccessAuth,
    String? initialUrl,
    List<String>? redirectUrls,
    ValueChanged<String>? onSuccessRedirect,
    ValueChanged<dynamic>? onError,
    VoidCallback? onCancel,
    CertificateValidator? onCertificateValidate,
    Map<String, String>? headers,
    Stream<String>? urlStream,
    ThemeData? themeData,
    Map<String, String>? textLocales,
    Locale? contentLocale,
    bool? goBackBtnVisible,
    bool? goForwardBtnVisible,
    bool? refreshBtnVisible,
    bool? clearCacheBtnVisible,
    bool? closeBtnVisible,
  }) =>
      OAuthConfiguration._(
        authorizationEndpointUrl:
            authorizationEndpointUrl ?? this.authorizationEndpointUrl,
        tokenEndpointUrl: tokenEndpointUrl ?? this.tokenEndpointUrl,
        redirectUrl: redirectUrl ?? this.redirectUrl,
        baseUrl: baseUrl ?? this.baseUrl,
        clientId: clientId ?? this.clientId,
        clientSecret: clientSecret ?? this.clientSecret,
        delimiter: delimiter ?? this.delimiter,
        basicAuth: basicAuth ?? this.basicAuth,
        httpClient: httpClient ?? this.httpClient,
        scopes: scopes ?? this.scopes,
        loginHint: loginHint ?? this.loginHint,
        promptValues: promptValues ?? this.promptValues,
        onSuccessAuth: onSuccessAuth ?? this.onSuccessAuth,
        initialUrl: initialUrl ?? this.initialUrl,
        redirectUrls: redirectUrls ?? this.redirectUrls,
        onSuccessRedirect: onSuccessRedirect ?? this.onSuccessRedirect,
        onError: onError ?? this.onError,
        onCancel: onCancel ?? this.onCancel,
        onCertificateValidate:
            onCertificateValidate ?? this.onCertificateValidate,
        headers: headers ?? this.headers,
        urlStream: urlStream ?? this.urlStream,
        themeData: themeData ?? this.themeData,
        textLocales: textLocales ?? this.textLocales,
        contentLocale: contentLocale ?? this.contentLocale,
        goBackBtnVisible: goBackBtnVisible ?? this.goBackBtnVisible,
        goForwardBtnVisible: goForwardBtnVisible ?? this.goForwardBtnVisible,
        refreshBtnVisible: refreshBtnVisible ?? this.refreshBtnVisible,
        clearCacheBtnVisible: clearCacheBtnVisible ?? this.clearCacheBtnVisible,
        closeBtnVisible: closeBtnVisible ?? this.closeBtnVisible,
      );
}
