import 'dart:async';
import 'dart:convert';

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthWebView extends StatefulWidget {

  static const String firstLoadTag = 'firstLoadOAuthWebAuthTag';
  static const String backButtonTooltipKey = 'backButtonTooltipKey';
  static const String forwardButtonTooltipKey = 'forwardButtonTooltipKey';
  static const String reloadButtonTooltipKey = 'reloadButtonTooltipKey';
  static const String clearCacheButtonTooltipKey = 'clearCacheButtonTooltipKey';
  static const String closeButtonTooltipKey = 'closeButtonTooltipKey';
  static const String clearCacheWarningMessageKey = 'clearCacheWarningMessageKey';

  final String authorizationEndpointUrl;
  final String tokenEndpointUrl;
  final String redirectUrl;
  final String clientId;
  final String? clientSecret;
  final List<String>? scopes;
  final String? loginHint;
  final List<String>? promptValues;

  /// This function will be called when user successfully authenticates.
  /// It will receive the Oauth Credentials
  final ValueChanged<oauth2.Credentials> onSuccess;

  /// This function will be called if any error occurs.
  /// It will receive the error data which could be some Exception or Error
  final ValueChanged<dynamic> onError;

  /// This function will be called when user cancels authentication.
  final VoidCallback onCancel;

  final ThemeData? themeData;
  final Map<String, String>? tooltipLocales;

  const OAuthWebView({
    Key? key,
    required this.authorizationEndpointUrl,
    required this.tokenEndpointUrl,
    required this.redirectUrl,
    required this.clientId,
    this.clientSecret,
    this.scopes,
    this.loginHint,
    this.promptValues,
    required this.onSuccess,
    required this.onError,
    required this.onCancel,
    this.themeData,
    this.tooltipLocales,
  }) : super(key: key);

  @override
  OAuthWebViewState createState() => OAuthWebViewState();
}

class OAuthWebViewState extends State<OAuthWebView> with WidgetsBindingObserver {

  bool ready = false;
  bool showToolbar = false;
  bool isLoading = true;
  bool allowGoBack = false;
  bool allowGoForward = false;
  bool tooltipsAlreadyInitialized = false;
  WebViewController? webViewController;
  @override
  late BuildContext context;
  String? initialUrl;
  late String redirectUrlEncoded;
  late oauth2.AuthorizationCodeGrant authorizationCodeGrant;
  late Uri authorizationUri;

  late String backButtonTooltip;
  late String forwardButtonTooltip;
  late String reloadButtonTooltip;
  late String clearCacheButtonTooltip;
  late String closeButtonTooltip;
  late String clearCacheWarningMessage;

  late Timer toolbarTimerShow;

  @override
  void initState() {
    super.initState();
    toolbarTimerShow = Timer(const Duration(seconds: 5), (){
      setState(() {
        showToolbar = true;
      });
    });
    WidgetsBinding.instance?.addObserver(this);
    redirectUrlEncoded = widget.redirectUrl;
    authorizationCodeGrant = oauth2.AuthorizationCodeGrant(
      widget.clientId,
      Uri.parse(widget.authorizationEndpointUrl),
      Uri.parse(widget.tokenEndpointUrl),
      secret: widget.clientSecret,
    );
    authorizationUri = authorizationCodeGrant.getAuthorizationUrl(
      Uri.parse(widget.redirectUrl),
      scopes: widget.scopes,
    );

    authorizationUri = authorizationUri.replace(
      queryParameters: Map.from(authorizationUri.queryParameters)
        ..addAll({
          'state': const Base64Encoder.urlSafe().convert(DateTime.now().toIso8601String().codeUnits),
          'nonce': const Base64Encoder.urlSafe().convert(DateTime.now().millisecondsSinceEpoch.toString().codeUnits),
          if (widget.loginHint != null) 'login_hint': widget.loginHint!,
          if (widget.promptValues?.isNotEmpty ?? false) 'prompt': widget.promptValues!.join(' '),
        }));
  }

  void initTooltips() {
    if(tooltipsAlreadyInitialized) return;
    backButtonTooltip = widget.tooltipLocales?[OAuthWebView.backButtonTooltipKey] ?? 'Go back';
    forwardButtonTooltip = widget.tooltipLocales?[OAuthWebView.forwardButtonTooltipKey]  ?? 'Go forward';
    reloadButtonTooltip = widget.tooltipLocales?[OAuthWebView.reloadButtonTooltipKey]  ?? 'Reload';
    clearCacheButtonTooltip = widget.tooltipLocales?[OAuthWebView.clearCacheButtonTooltipKey]  ?? 'Clear cache';
    closeButtonTooltip = widget.tooltipLocales?[OAuthWebView.closeButtonTooltipKey]  ?? MaterialLocalizations.of(context).closeButtonTooltip;
    clearCacheWarningMessage = widget.tooltipLocales?[OAuthWebView.clearCacheWarningMessageKey]  ?? 'Are you sure you want to clear cache?';
    tooltipsAlreadyInitialized = true;
  }


  Widget get webView {
    return GestureDetector(
      onLongPressDown: (details) {},/// To avoid long press for text selection or open link on new tab
      child: WebView(
        initialUrl: authorizationUri.toString(),
        javascriptMode: JavascriptMode.unrestricted,
        userAgent: 'Mozilla/5.0', /// This custom userAgent is mandatory due to security constraints of Google's OAuth2 policies (https://developers.googleblog.com/2021/06/upcoming-security-changes-to-googles-oauth-2.0-authorization-endpoint.html)
        zoomEnabled: false,
        gestureNavigationEnabled: false,
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        navigationDelegate: (request) async =>
        onNavigateTo(request.url) ?
        NavigationDecision.navigate :
        NavigationDecision.prevent,
        onPageFinished: (url) => hideLoading(),
      ),
    );
  }

  void showLoading() {
    if(!isLoading) {
      setState(() {
        isLoading = true;
      });
    }
  }

  Future<void> hideLoading() async {
    if(isLoading) {
      ready = true;
      showToolbar = true;
      toolbarTimerShow.cancel();
      isLoading = false;
      allowGoBack = await controllerCanGoBack();
      allowGoForward = await controllerCanGoForward();
      setState(() {});
    }
  }

  bool onNavigateTo(String url) {
    // print('uuuuuuuu: $url');
    if(url != 'about:blank') showLoading();
    if (url.startsWith(redirectUrlEncoded)) {
      onSuccess(url);
      return false;
    }
    return true;
  }

  void onSuccess(String responseRedirect) async {
    responseRedirect = responseRedirect.trim().replaceAll('#', '');
    final parameters = Uri.dataFromString(responseRedirect).queryParameters;

    try {
      final client = await authorizationCodeGrant.handleAuthorizationResponse(parameters);
      widget.onSuccess(
          client.credentials
      );
    } catch (e) {
      onError(e);
    }
  }

  void onError(dynamic error) {
    widget.onError(error);
  }

  void onCancell() {
    widget.onCancel();
  }

  Widget iconButton({
    required IconData iconData,
    String? tooltip,
    VoidCallback? onPressed,
    bool respectLoading = true,
  }) => IconButton(
    iconSize: 30,
    tooltip: tooltip,
    icon: Icon(iconData),
    color: Theme.of(context).colorScheme.secondary,
    onPressed: respectLoading && isLoading ? null : onPressed,
  );

  @override
  Widget build(BuildContext context) {
    final content = Builder(
      builder: (context) {
        this.context = context;
        initTooltips();
        return Scaffold(
          body: Stack(
            children: [
              WillPopScope(
                child: webView,
                onWillPop: onBackPressed,
              ),
              Positioned.fill(
                child: Hero(
                  tag: OAuthWebView.firstLoadTag,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: !ready && isLoading ? const CircularProgressIndicator() : const SizedBox(),
                  ),
                ),
              ),
              AnimatedPositioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: ready && isLoading ? 5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const LinearProgressIndicator(),
              ),
            ],
          ),
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: showToolbar ? 50 : 0,
            child: BottomAppBar(
              elevation: 8,
              color: Theme.of(context).bottomAppBarColor,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  iconButton(
                    iconData: Icons.arrow_back_ios_rounded,
                    tooltip: backButtonTooltip,
                    onPressed: !allowGoBack ? null : () => controllerGoBack(),
                  ),
                  iconButton(
                    iconData: Icons.arrow_forward_ios_rounded,
                    tooltip: forwardButtonTooltip,
                    onPressed: !allowGoForward ? null : () => controllerGoForward(),
                  ),
                  iconButton(
                    iconData: Icons.refresh_rounded,
                    tooltip: reloadButtonTooltip,
                    onPressed: () => controllerReload(),
                  ),
                  iconButton(
                    iconData: Icons.cleaning_services_rounded,
                    tooltip: clearCacheButtonTooltip,
                    onPressed: () {
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          title: Text(clearCacheButtonTooltip),
                          content: Text(clearCacheWarningMessage),
                          actions: [
                            TextButton(
                              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text(MaterialLocalizations.of(context).okButtonLabel),
                              onPressed: () {
                                Navigator.pop(context);
                                controllerClearCache();
                              },
                            ),
                          ],
                        );
                      });
                    },
                  ),
                  iconButton(
                    iconData: Icons.close,
                    tooltip: closeButtonTooltip,
                    respectLoading: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return widget.themeData != null ? Theme(
      data: widget.themeData!,
      child: content,
    ) : content;
  }


  Future<void> controllerGoBack() async {
    showLoading();
    webViewController?.goBack();
  }

  Future<void> controllerGoForward() async {
    showLoading();
    webViewController?.goForward();
  }

  Future<void> controllerReload() async {
    showLoading();
    webViewController?.reload();
  }

  Future<void> controllerClearCache() async {
    showLoading();
    await webViewController?.clearCache();
    hideLoading();
  }

  Future<bool> controllerCanGoForward() async => await webViewController?.canGoForward() ?? false;

  Future<bool> controllerCanGoBack() async => await webViewController?.canGoBack() ?? false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        hideLoading();
        break;
      default:
        break;
    }
  }

  Future<bool> onBackPressed() async {
    if(await controllerCanGoBack()) {
      controllerGoBack();
      return false;
    }
    return true;
  }
}
