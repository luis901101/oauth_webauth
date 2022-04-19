import 'package:flutter/material.dart';
import 'package:oauth_webauth/src/base_web_view.dart';

class BaseWebScreen extends StatelessWidget {
  static Future? start({
    Key? key,
    required BuildContext context,
    required String initialUrl,
    required List<String> redirectUrls,
    VoidCallback? onSuccess,
    ValueChanged<dynamic>? onError,
    VoidCallback? onCancel,
    CertificateValidator? onCertificateValidate,
    ThemeData? themeData,
    Map<String, String>? textLocales,
    Locale? contentLocale,
  }) =>
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BaseWebScreen(
          initialUrl: initialUrl,
          redirectUrls: redirectUrls,
          onSuccess: onSuccess,
          onError: onError,
          onCancel: onCancel,
          onCertificateValidate: onCertificateValidate,
          themeData: themeData,
          textLocales: textLocales,
          contentLocale: contentLocale,
        )));

  final String initialUrl;
  final List<String> redirectUrls;

  /// This function will be called when redirectUrl is loaded in web view.
  final VoidCallback? onSuccess;

  /// This function will be called if any error occurs.
  /// It will receive the error data which could be some Exception or Error
  final ValueChanged<dynamic>? onError;

  /// This function will be called when user cancels web view.
  final VoidCallback? onCancel;

  final CertificateValidator? onCertificateValidate;

  final ThemeData? themeData;
  final Map<String, String>? textLocales;
  final Locale? contentLocale;

  late final BuildContext context;
  final globalKey = GlobalKey<BaseWebViewState>();

  BaseWebScreen({
    Key? key,
    required this.initialUrl,
    required this.redirectUrls,
    this.onSuccess,
    this.onError,
    this.onCancel,
    this.onCertificateValidate,
    this.themeData,
    this.textLocales,
    this.contentLocale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        this.context = context;
        return Scaffold(
          body: SafeArea(
            bottom: false, left: false, right: false,
            child: WillPopScope(
              onWillPop: onBackPressed,
              child: BaseWebView(
                key: globalKey,
                initialUrl: initialUrl,
                redirectUrls: redirectUrls,
                onSuccessRedirect: _onSuccess,
                onError: _onError,
                onCancel: _onCancel,
                onCertificateValidate: onCertificateValidate,
                themeData: themeData,
                textLocales: textLocales,
                contentLocale: contentLocale,
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSuccess() {
    Navigator.pop(context, true);
    onSuccess?.call();
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
