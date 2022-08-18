import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:http/http.dart' as http;
import 'package:oauth_webauth/oauth_webauth.dart';

class OAuthWebScreen extends StatelessWidget {
  static Future? start({
    Key? key,
    GlobalKey<OAuthWebViewState>? globalKey,
    required BuildContext context,
    required String authorizationEndpointUrl,
    required String tokenEndpointUrl,
    required String redirectUrl,
    final String? baseUrl,
    required String clientId,
    String? clientSecret,
    String? delimiter,
    bool? basicAuth,
    http.Client? httpClient,
    List<String>? scopes,
    String? loginHint,
    List<String>? promptValues,
    ValueChanged<Credentials>? onSuccess,
    ValueChanged<dynamic>? onError,
    VoidCallback? onCancel,
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
  }) {
    assert(
        !kIsWeb ||
            (kIsWeb &&
                onSuccess != null &&
                onError != null &&
                onCancel != null),
        'You must set onSuccess, onError and onCancel function when running on Web otherwise you will not get any result.');
    if (kIsWeb) {
      final oauthFlow = BaseOAuthFlow()
        ..initOauth(
          authorizationEndpointUrl: authorizationEndpointUrl,
          tokenEndpointUrl: tokenEndpointUrl,
          redirectUrl: redirectUrl,
          baseUrl: baseUrl,
          clientId: clientId,
          clientSecret: clientSecret,
          delimiter: delimiter,
          basicAuth: basicAuth,
          httpClient: httpClient,
          scopes: scopes,
          loginHint: loginHint,
          promptValues: promptValues,
          onSuccessAuth: onSuccess!,
          onError: onError,
          onCancel: onCancel,
        );
      oauthFlow.onNavigateTo(OauthWebAuth.instance.appBaseUrl);
      return null;
    }
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OAuthWebScreen(
                  authorizationEndpointUrl: authorizationEndpointUrl,
                  tokenEndpointUrl: tokenEndpointUrl,
                  redirectUrl: redirectUrl,
                  baseUrl: baseUrl,
                  clientId: clientId,
                  clientSecret: clientSecret,
                  delimiter: delimiter,
                  basicAuth: basicAuth,
                  httpClient: httpClient,
                  scopes: scopes,
                  loginHint: loginHint,
                  promptValues: promptValues,
                  onSuccess: onSuccess,
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
                )));
  }

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
  /// It will receive the Oauth Credentials
  final ValueChanged<Credentials>? onSuccess;

  /// This function will be called if any error occurs.
  /// It will receive the error data which could be some Exception or Error
  final ValueChanged<dynamic>? onError;

  /// This function will be called when user cancels authentication.
  final VoidCallback? onCancel;

  /// This function will be called when [authorizationEndpointUrl] is first loaded.
  /// Not available for Web
  final CertificateValidator? onCertificateValidate;

  /// Not available for Web
  final ThemeData? themeData;

  /// Not available for Web
  final Map<String, String>? textLocales;

  /// Not available for Web
  final Locale? contentLocale;

  /// Not available for Web
  final Map<String, String>? headers;

  /// Use this stream when you need to asynchronously navigate to a specific url
  /// Not available for Web
  final Stream<String>? urlStream;

  final bool? goBackBtnVisible;
  final bool? goForwardBtnVisible;
  final bool? refreshBtnVisible;
  final bool? clearCacheBtnVisible;
  final bool? closeBtnVisible;

  late final BuildContext context;
  final GlobalKey<OAuthWebViewState> globalKey;

  OAuthWebScreen({
    Key? key,
    GlobalKey<OAuthWebViewState>? globalKey,
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
    this.onSuccess,
    this.onError,
    this.onCancel,
    this.onCertificateValidate,
    this.themeData,
    this.textLocales,
    this.contentLocale,
    this.headers,
    this.urlStream,
    this.goBackBtnVisible,
    this.goForwardBtnVisible,
    this.refreshBtnVisible,
    this.clearCacheBtnVisible,
    this.closeBtnVisible,
  })  : globalKey = globalKey ?? GlobalKey<OAuthWebViewState>(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        this.context = context;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: WillPopScope(
              onWillPop: onBackPressed,
              child: OAuthWebView(
                key: globalKey,
                authorizationEndpointUrl: authorizationEndpointUrl,
                tokenEndpointUrl: tokenEndpointUrl,
                clientId: clientId,
                clientSecret: clientSecret,
                delimiter: delimiter,
                basicAuth: basicAuth,
                httpClient: httpClient,
                redirectUrl: redirectUrl,
                baseUrl: baseUrl,
                scopes: scopes,
                loginHint: loginHint,
                promptValues: promptValues,
                onSuccessAuth: _onSuccess,
                onError: _onError,
                onCancel: _onCancel,
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
              ),
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
    if (!((await globalKey.currentState?.onBackPressed()) ?? false)) {
      return false;
    }
    onCancel?.call();
    return true;
  }
}
