import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oauth_webauth/oauth_webauth.dart';

class OAuthWebView extends BaseWebView {
  final OauthConfiguration _configuration;

  const OAuthWebView({
    Key? key,
    required OauthConfiguration configuration,
  })  : _configuration = configuration,
        super(key: key, configuration: configuration);

  @override
  OAuthWebViewState createState() => OAuthWebViewState();
}

class OAuthWebViewState extends BaseWebViewState<OAuthWebView>
    with WidgetsBindingObserver, BaseOAuthFlowMixin {
  @override
  OauthConfiguration get configuration => widget._configuration;

  @override
  void initBase() {
    super.initBase();
    initOauth(
      configuration: configuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb ? const SizedBox() : super.build(context);
  }
}
