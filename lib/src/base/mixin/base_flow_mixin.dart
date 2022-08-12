import 'package:flutter/foundation.dart';
import 'package:oauth_webauth/oauth_webauth.dart';

mixin BaseFlowMixin {
  /// This function will be called when any of the redirectUrls is loaded in web view.
  /// It will pass the url it causes redirect.
  ValueChanged<String>? _onSuccessRedirect;

  /// This function will be called if any error occurs.
  /// It will receive the error data which could be some Exception or Error
  ValueChanged<dynamic>? _onError;

  /// This function will be called when user cancels authentication.
  VoidCallback? _onCancel;

  Uri initialUri = Uri();
  final Set<String> redirectUrls = {};

  void init({
    Uri? initialUri,
    Iterable<String>? redirectUrls,
    ValueChanged<String>? onSuccessRedirect,
    ValueChanged<dynamic>? onError,
    VoidCallback? onCancel,
  }) {
    if(initialUri != null) this.initialUri = initialUri;
    if(redirectUrls != null) {
      this.redirectUrls.clear();
      this.redirectUrls.addAll(redirectUrls);
    }
    if(originUrl() != null) this.redirectUrls.add(originUrl()!);
    _onSuccessRedirect = onSuccessRedirect;
    _onError = onError;
    _onCancel = onCancel;
  }

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
    _onSuccessRedirect?.call(responseRedirect);
  }

  void onError(dynamic error) {
    clearState();
    _onError?.call(error);
  }

  void onCancel() {
    clearState();
    _onCancel?.call();
  }

  void saveState() {}
  void clearState() {
    if (kIsWeb) {
      OauthWebAuth.instance.resetAppBaseUrl();
      OauthWebAuth.instance.clearCodeVerifier();
    }
  }
}