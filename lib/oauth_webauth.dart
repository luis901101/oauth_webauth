library oauth_webauth;

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:oauth_webauth/src/utils/widget_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

export 'package:oauth_webauth/src/base/mixin/base_flow_mixin.dart';
export 'package:oauth_webauth/src/base/mixin/base_oauth_flow_mixin.dart';

export 'package:oauth_webauth/src/base/base_flow.dart';
export 'package:oauth_webauth/src/base/base_oauth_flow.dart';

export 'package:oauth_webauth/src/utils/cross_platform_support.dart';

export 'package:oauth_webauth/src/oauth_web_view.dart';
export 'package:oauth_webauth/src/base_web_view.dart';
export 'package:oauth_webauth/src/oauth_web_screen.dart';
export 'package:oauth_webauth/src/base_web_screen.dart';
export 'package:oauth_webauth/src/base/model/base_configuration.dart';
export 'package:oauth_webauth/src/base/model/oauth_configuration.dart';

class OAuthWebAuth {
  ///Singleton instance
  static final instance = OAuthWebAuth();
  SharedPreferences? _sharedPreferences;
  String appBaseUrl = '';

  /// Call this from main() function before runaApp() to enable flutter web support.
  /// It's also required to initialize WidgetsFlutterBinding before calling this init().
  ///
  /// e.g:
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await OAuthWebAuth.instance.init();
  Future<void> init({String? appBaseUrl}) async {
    try {
      this.appBaseUrl = appBaseUrl ?? Uri.base.toString().trim();
      final int ignoreStartIndex = this.appBaseUrl.indexOf('#');
      if (ignoreStartIndex > -1) {
        this.appBaseUrl = this.appBaseUrl.substring(0, ignoreStartIndex);
      }
      while (this.appBaseUrl.endsWith('/')) {
        this.appBaseUrl =
            this.appBaseUrl.substring(0, this.appBaseUrl.length - 1);
      }
      _sharedPreferences = await SharedPreferences.getInstance();
      if (kDebugMode) {
        print('------ OAuthWebAuth appBaseUri: ${this.appBaseUrl} ------');
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future<void> clearCache({InAppWebViewController? controller}) async {
    if (kIsWeb) return;
    Future<void> clearCache(InAppWebViewController controller) async {
      await controller.clearCache();
    }

    if (controller != null) return clearCache(controller);
    final futureCompleter = Completer<void>();
    try {
      InAppWebView(
        onWebViewCreated: (controller) async {
          futureCompleter.complete(clearCache(controller));
        },
      ).buildWidgetOnBackground();
    } catch (e) {
      print(e);
    }
    return futureCompleter.future
        .timeout(const Duration(seconds: 5), onTimeout: () {});
  }

  Future<void> clearCookies() async {
    try {
      await CookieManager.instance().deleteAllCookies();
    } catch (e) {
      print(e);
    }
  }

  Future<void> clearAll({InAppWebViewController? controller}) async {
    await clearCache(controller: controller);
    await clearCookies();
  }

  /// Resets the [appBaseUrl] to the origin url to remove any path segments and query parameters in it.
  void resetAppBaseUrl() {
    appBaseUrl = Uri.parse(appBaseUrl).origin;
  }

  /// Clears the last [codeVerifier] saved state.
  /// Only used in web.
  void clearCodeVerifier() {
    _sharedPreferences?.remove(_codeVerifierKey);
  }

  /// Saves the state of [codeVerifier].
  /// Only used in web.
  void saveCodeVerifier(String codeVerifier) {
    _sharedPreferences?.setString(_codeVerifierKey, codeVerifier);
  }

  /// Restores the state of [codeVerifier].
  /// Only used in web.
  String? restoreCodeVerifier() {
    final code = _sharedPreferences?.getString(_codeVerifierKey);
    if (kDebugMode) print('------ OAuthWebAuth codeVerifier: $code ------');
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
