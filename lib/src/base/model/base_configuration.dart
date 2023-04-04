import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

typedef CertificateValidator = bool Function(X509Certificate certificate);

class BaseConfiguration {
  static const String firstLoadHeroTag = 'firstLoadOAuthWebAuthHeroTag';
  static const String backButtonTooltipKey = 'backButtonTooltipKey';
  static const String forwardButtonTooltipKey = 'forwardButtonTooltipKey';
  static const String reloadButtonTooltipKey = 'reloadButtonTooltipKey';
  static const String clearCacheButtonTooltipKey = 'clearCacheButtonTooltipKey';
  static const String closeButtonTooltipKey = 'closeButtonTooltipKey';
  static const String clearCacheWarningMessageKey =
      'clearCacheWarningMessageKey';

  final String initialUrl;
  final List<String> redirectUrls;

  /// This function will be called when any of the redirectUrls is loaded in web view.
  /// It will pass the url it causes redirect.
  final ValueChanged<String>? onSuccessRedirect;

  /// This function will be called if any error occurs.
  /// It will receive the error data which could be some Exception or Error
  final ValueChanged<dynamic>? onError;

  /// This function will be called when user cancels authentication.
  final VoidCallback? onCancel;

  /// This function will be called when [authorizationEndpointUrl] is first loaded.
  /// If false is returned then a CertificateException() will be thrown
  /// Not available for Web
  final CertificateValidator? onCertificateValidate;

  /// Not available for Web
  final Map<String, String> headers;

  /// Use this stream when you need to asynchronously navigate to a specific url
  /// Not available for Web
  final Stream<String>? urlStream;

  /// Not available for Web
  final ThemeData? themeData;

  /// Not available for Web
  final Map<String, String>? textLocales;

  /// Not available for Web
  final Locale? contentLocale;

  final bool goBackBtnVisible;
  final bool goForwardBtnVisible;
  final bool refreshBtnVisible;
  final bool clearCacheBtnVisible;
  final bool closeBtnVisible;

  const BaseConfiguration({
    required this.initialUrl,
    required this.redirectUrls,
    this.onSuccessRedirect,
    this.onError,
    this.onCancel,
    this.onCertificateValidate,
    Map<String, String>? headers,
    this.urlStream,
    this.themeData,
    this.textLocales,
    this.contentLocale,
    bool? goBackBtnVisible,
    bool? goForwardBtnVisible,
    bool? refreshBtnVisible,
    bool? clearCacheBtnVisible,
    bool? closeBtnVisible,
  })  : headers = headers ?? const {},
        goBackBtnVisible = goBackBtnVisible ?? true,
        goForwardBtnVisible = goForwardBtnVisible ?? true,
        refreshBtnVisible = refreshBtnVisible ?? true,
        clearCacheBtnVisible = clearCacheBtnVisible ?? true,
        closeBtnVisible = closeBtnVisible ?? true;

  String? get backButtonTooltip => textLocales?[backButtonTooltipKey];
  String? get forwardButtonTooltip => textLocales?[forwardButtonTooltipKey];
  String? get reloadButtonTooltip => textLocales?[reloadButtonTooltipKey];
  String? get clearCacheButtonTooltip =>
      textLocales?[clearCacheButtonTooltipKey];
  String? get closeButtonTooltip => textLocales?[closeButtonTooltipKey];
  String? get clearCacheWarningMessage =>
      textLocales?[clearCacheWarningMessageKey];

  BaseConfiguration copyWith({
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
      BaseConfiguration(
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
