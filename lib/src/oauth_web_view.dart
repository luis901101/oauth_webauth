import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oauth_webauth/oauth_webauth.dart';

class OAuthWebView extends BaseWebView {
  final OAuthConfiguration _configuration;

  const OAuthWebView({
    super.key,
    required OAuthConfiguration super.configuration,
  }) : _configuration = configuration;

  @override
  State createState() => OAuthWebViewState();
}

class OAuthWebViewState extends BaseWebViewState<OAuthWebView>
    with WidgetsBindingObserver, BaseOAuthFlowMixin {
  @override
  OAuthConfiguration get configuration => widget._configuration;

  @override
  void initBase() {
    super.initBase();
    initOAuth(
      configuration: configuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? const SizedBox() : super.build(context);
  }
}
