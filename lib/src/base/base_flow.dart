import 'package:oauth_webauth/src/utils/cross_platform_support.dart';
import 'package:flutter/foundation.dart';
import 'package:oauth_webauth/oauth_webauth.dart';

class BaseFlow {
  Uri initialUri = Uri();
  List<String> redirectUrls = [];

  // @mustCallSuper
  // void initBase() {
  // }

  void showLoading() {}

  Future<void> hideLoading() async {}

  bool startsWithAnyRedirectUrl(String url) => redirectUrls
      .any((redirectUrl) => url != redirectUrl && url.startsWith(redirectUrl));

  bool onNavigateTo(String url) {
    if (url != 'about:blank') showLoading();
    if (startsWithAnyRedirectUrl(url)) {
      onSuccess(url);
      return false;
    }
    if (kIsWeb) {
      saveState();
      loadPage(initialUri.toString());
    }
    return true;
  }

  void onSuccess(String responseRedirect) async {
    clearState();
  }

  void onError(dynamic error) {
    clearState();
  }

  void onCancel() {
    clearState();
  }

  void saveState() {}
  void clearState() {
    if (kIsWeb) {
      OauthWebAuth.instance.resetAppBaseUrl();
      OauthWebAuth.instance.clearCodeVerifier();
    }
  }
}