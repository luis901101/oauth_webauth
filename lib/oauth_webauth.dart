library oauth_webauth;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:oauth_webauth/src/oauth_web_view.dart';
export 'package:oauth_webauth/src/base_web_view.dart';
export 'package:oauth_webauth/src/oauth_web_screen.dart';
export 'package:oauth_webauth/src/base_web_screen.dart';

class OauthWebAuth {
  static final instance = OauthWebAuth();
  late final SharedPreferences _sharedPreferences;
  String appBaseUrl = '';

  Future<void> init({String? appBaseUrl}) async {
    try {
      this.appBaseUrl =
          appBaseUrl ?? Uri.base.toString().trim().replaceAll('#', '');
      while (this.appBaseUrl.endsWith('/')) {
        this.appBaseUrl =
            this.appBaseUrl.substring(0, this.appBaseUrl.length - 1);
      }
      _sharedPreferences = await SharedPreferences.getInstance();
      if (kDebugMode)
        print('------ OauthWebAuth appBaseUri: ${this.appBaseUrl} ------');
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void resetAppBaseUrl() {
    appBaseUrl = Uri.parse(appBaseUrl).origin;
  }

  void clearCodeVerifier() {
    _sharedPreferences.remove(_codeVerifierKey);
  }

  void saveCodeVerifier(String codeVerifier) {
    _sharedPreferences.setString(_codeVerifierKey, codeVerifier);
  }

  String? restoreCodeVerifier() {
    final code = _sharedPreferences.getString(_codeVerifierKey);
    if (kDebugMode) print('------ codeVerifier: $code ------');
    return code;
  }

  static const String _codeVerifierKey = 'codeVerifier';

  /// Allowed characters for generating a codeVerifier
  static const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  /// Randomly generate a 128 character string to be used as the PKCE code verifier.
  /// The codeVerifier must meet requirements specified in [RFC 7636].
  ///
  /// [RFC 7636]: https://tools.ietf.org/html/rfc7636#section-4.1
  String generateCodeVerifier() {
    return List.generate(
        128, (i) => _charset[Random.secure().nextInt(_charset.length)]).join();
  }
}
